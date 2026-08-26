import re
import json
import sys
import zlib
import argparse
import hashlib

from typing import List
from pathlib import Path

KEY_CONFIG = "config"
KEY_BASE_URL = "base_url"
KEY_METHOD = "method"
KEY_HASH_ALGORITHM = "hash_algorithm"
KEY_HASH_LIST_FILE = "hash_list_file"
KEY_HASH_LIST_FILES_PATH = "hash_list_files_path"
KEY_HASH_LIST_FILES_PATTERN = "hash_list_files_pattern"
KEY_HASH_LIST_EXCLUDE = "hash_list_exclude"
KEY_HASH_LIST_FILES = "hash_list_files"
KEY_HASH_LIST_RECURSIVE = "hash_list_recursive"
KEY_SETUP_FILE = "setup_file"

# Regular expression to find startup scripts array
STARTUP_SCRIPTS_PATTERN = re.compile(
    r"(:local\s+startupScripts\s*\{)(.*?)(\})", re.DOTALL)

HASH_FUNCTIONS = {
    "crc32": lambda filepath: f"{zlib.crc32(filepath.read_bytes()):08x}",
    "md5": lambda filepath: hashlib.md5(filepath.read_bytes()).hexdigest(),
    "sha1": lambda filepath: hashlib.sha1(filepath.read_bytes()).hexdigest(),
    "sha256":
    lambda filepath: hashlib.sha256(filepath.read_bytes()).hexdigest(),
    "sha512":
    lambda filepath: hashlib.sha512(filepath.read_bytes()).hexdigest(),
}


def process_task(task: dict) -> bool:
    if not all(
            k in task
            for k in (KEY_HASH_ALGORITHM, KEY_HASH_LIST_FILE, KEY_BASE_URL)):
        print(f"Error: missing required keys in task: {task}")
        return False

    # Ensure at least 'path' or 'files' is provided in the configuration
    if KEY_HASH_LIST_FILES_PATH not in task and KEY_HASH_LIST_FILES not in task:
        print(
            f"Error: task must contain either '{KEY_HASH_LIST_FILES_PATH}' or '{KEY_HASH_LIST_FILES}': {task}"
        )
        return False

    if task.get(KEY_HASH_ALGORITHM).lower() not in HASH_FUNCTIONS:
        print(
            f"Error: unsupported hash algorithm '{task.get(KEY_HASH_ALGORITHM)}'"
        )
        return False

    repo_root = Path.cwd()
    target_files: List[Path] = []

    # Collect explicitly defined files or scan the directory based on configuration
    if KEY_HASH_LIST_FILES in task:
        files = task[KEY_HASH_LIST_FILES]

        if not isinstance(files, list):
            print(f"Error: '{KEY_HASH_LIST_FILES}' must be a list: {task}")
            return False

        if not files:
            print(f"Error: '{KEY_HASH_LIST_FILES}' is empty: {task}")
            return False

        for f_name in files:
            if not (repo_root /
                    f_name).exists() or not (repo_root / f_name).is_file() or (
                        repo_root / f_name).stat().st_size == 0:
                print(f"Error: file missing or empty: {f_name}")
                return False
            target_files.append(repo_root / f_name)

        if not target_files:
            print(
                f"Error: no valid files found in the explicit list for task: {task}"
            )
            return False
    else:
        if not (repo_root / task.get(KEY_HASH_LIST_FILES_PATH, "")).exists(
        ) or not (repo_root / task.get(KEY_HASH_LIST_FILES_PATH, "")).is_dir():
            print(
                f"Error: search path missing or not a directory: {task.get(KEY_HASH_LIST_FILES_PATH)}"
            )
            return False

        target_path = repo_root / task.get(KEY_HASH_LIST_FILES_PATH, "")
        pattern = task.get(KEY_HASH_LIST_FILES_PATTERN, "")
        if not pattern:
            print(f"Error: file pattern should be specified: {task}")
            return False

        is_recursive = task.get(KEY_HASH_LIST_RECURSIVE, False)

        if not isinstance(is_recursive, bool):
            print(f"Error: '{KEY_HASH_LIST_RECURSIVE}' must be a bool, "
                  f"got {type(is_recursive).__name__}")
            return False

        files = target_path.rglob(
            pattern) if is_recursive else target_path.glob(pattern)

        target_files.extend(files)

        if not target_files:
            print(
                f"Error: no files found for pattern '{pattern}' in path '{task.get(KEY_HASH_LIST_FILES_PATH)}'."
            )
            return False

    seen_names = {}
    duplicate_paths = set()

    # Track files by their base name to catch duplicates across different directories
    for f_path in target_files:
        file_name = f_path.name
        if file_name in seen_names:
            duplicate_paths.add(f_path)
            # Add the original file that claimed this name to clarify the conflict
            duplicate_paths.add(seen_names[file_name])
        else:
            seen_names[file_name] = f_path

    # Trigger error and halt if duplicate names exist
    if duplicate_paths:
        formatted_dupes = "\n".join(p.as_posix() for p in duplicate_paths)
        print(
            f"Error: duplicate file names detected across paths:\n{formatted_dupes}"
        )
        return False

    lines_to_keep = []

    # Extract existing comments from the list file before truncation
    if not (repo_root / task.get(KEY_HASH_LIST_FILE)).exists():
        print(f"Error: list file {task.get(KEY_HASH_LIST_FILE)} not found.")
        return False

    with open(repo_root / task.get(KEY_HASH_LIST_FILE), "r",
              encoding="utf-8") as f:
        all_lines = f.readlines()

    example_line_index = -1
    last_comment_index = -1

    for i, line in enumerate(all_lines):
        if line.lstrip().startswith("#"):
            last_comment_index = i
            if line.strip().endswith("Example:"):
                example_line_index = i

    method = task.get(KEY_METHOD)
    if method and example_line_index != -1:
        lines_to_keep = all_lines[:example_line_index + 1]
        if lines_to_keep and not lines_to_keep[-1].endswith("\n"):
            lines_to_keep[-1] += "\n"
        list_rel_path = Path(task.get(KEY_HASH_LIST_FILE)).as_posix()
        full_list_url = f"{task.get(KEY_BASE_URL)}{list_rel_path}"
        lines_to_keep.append(f"# :global {method}\n")
        lines_to_keep.append(f"# ${method} {full_list_url}\n")
    elif last_comment_index != -1:
        lines_to_keep = all_lines[:last_comment_index + 1]
        if lines_to_keep and not lines_to_keep[-1].endswith("\n"):
            lines_to_keep[-1] += "\n"

    # Ensure clean separation between comments and the newly generated payload
    lines_to_keep.append("\n")

    setup_file = task.get(KEY_SETUP_FILE, "").strip()
    if setup_file:
        script_file_path = repo_root / setup_file
        if not update_startup_script(
                repo_root=repo_root,
                script_file_path=script_file_path,
                rsc_files=target_files,
        ):
            print(f"Error: failed to update startup script {setup_file}")
            return False

    # Filter out excluded files by checking substring presence
    if KEY_HASH_LIST_EXCLUDE in task:
        exclude_list = task[KEY_HASH_LIST_EXCLUDE]

        if not isinstance(exclude_list, list):
            print(f"Error: '{KEY_HASH_LIST_EXCLUDE}' must be a list: {task}")
            return False

        if not exclude_list:
            print(f"Error: '{KEY_HASH_LIST_EXCLUDE}' is empty: {task}")
            return False

        target_files = [
            f_path for f_path in target_files
            if not any(ex_str in f_path.as_posix() for ex_str in exclude_list)
        ]

    # Append fresh hash data for every localized file directly to the output buffer
    for f_path in sorted(target_files):
        lines_to_keep.append(
            f"{HASH_FUNCTIONS[task.get(KEY_HASH_ALGORITHM).lower()](f_path)} "
            f"{task.get(KEY_BASE_URL)}{f_path.relative_to(repo_root).as_posix()}\n"
        )

    with open(
            repo_root / task.get(KEY_HASH_LIST_FILE),
            "w",
            encoding="utf-8",
            newline="\n",
    ) as f:
        f.writelines(lines_to_keep)

    print(
        f"Successfully updated {task.get(KEY_HASH_LIST_FILE)} with {len(target_files)} files."
    )
    return True


def update_startup_script(
    repo_root: Path,
    script_file_path: Path,
    rsc_files: List[Path],
) -> bool:
    script_file_relative_path = script_file_path.relative_to(
        repo_root).as_posix()

    # Check if target file exists
    if not script_file_path.exists() or not script_file_path.is_file():
        print(f"Error: file not found at {script_file_relative_path}")
        return False

    # Exclude the startup script itself
    filtered_rsc_files = [
        script for script in sorted(rsc_files) if script != script_file_path
    ]

    # Format the new list content
    formatted_scripts = ";\n".join(f'    "{script.stem}"'
                                   for script in filtered_rsc_files)

    new_block_content = f"\n{formatted_scripts}\n"

    # Read target file content
    with open(script_file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Search for the variable using regex
    match = STARTUP_SCRIPTS_PATTERN.search(content)
    if not match:
        print(
            f"Error: ':local startupScripts' variable not found in {script_file_relative_path}"
        )
        return False

    # Replace the old content inside the block with the new list
    updated_content = STARTUP_SCRIPTS_PATTERN.sub(
        lambda match: f"{match.group(1)}{new_block_content}{match.group(3)}",
        content,
    )

    # Write back to the target file
    with open(script_file_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(updated_content)

    print(
        f"Successfully updated startupScripts in {script_file_relative_path} with {len(filtered_rsc_files)} files."
    )
    return True


def process_config(config_path: Path) -> bool:
    if not config_path.exists():
        print(f"Error: configuration file {config_path} not found.")
        return False

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error parsing JSON configuration file {config_path}: {e}")
        return False

    if not isinstance(
            data, dict) or KEY_CONFIG not in data or KEY_BASE_URL not in data:
        print(
            f"Error: JSON configuration must be an object containing '{KEY_BASE_URL}' and a '{KEY_CONFIG}' list."
        )
        return False

    base_url = data.get(KEY_BASE_URL)
    method = data.get(KEY_METHOD)
    tasks = data.get(KEY_CONFIG)

    if not isinstance(tasks, list):
        print(f"Error: '{KEY_CONFIG}' must be a list of objects.")
        return False

    for entry in tasks:
        if not isinstance(entry, dict):
            print(f"Error: invalid entry in configuration: {entry}")
            return False

        # Inject base_url and method into the task dictionary
        entry[KEY_BASE_URL] = base_url
        entry[KEY_METHOD] = method

        if not process_task(entry):
            return False

    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Update file checksums based on JSON config.",
        formatter_class=lambda prog: argparse.HelpFormatter(
            prog,
            max_help_position=50,
            width=100,
        ),
    )

    parser.add_argument(
        "-c",
        "--config",
        required=True,
        type=Path,
        help="Path to JSON configuration file containing update targets",
    )

    args = parser.parse_args()

    if not process_config(args.config):
        sys.exit(1)
