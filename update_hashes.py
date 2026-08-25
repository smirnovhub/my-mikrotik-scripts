import json
import sys
import zlib
import argparse
import hashlib
from pathlib import Path


def calculate_crc32(filepath: Path) -> str:
    return f"{zlib.crc32(filepath.read_bytes()):08x}"


def calculate_md5(filepath: Path) -> str:
    return hashlib.md5(filepath.read_bytes()).hexdigest()


def calculate_sha1(filepath: Path) -> str:
    return hashlib.sha1(filepath.read_bytes()).hexdigest()


def calculate_sha256(filepath: Path) -> str:
    return hashlib.sha256(filepath.read_bytes()).hexdigest()


def calculate_sha512(filepath: Path) -> str:
    return hashlib.sha512(filepath.read_bytes()).hexdigest()


HASH_FUNCTIONS = {
    "crc32": calculate_crc32,
    "md5": calculate_md5,
    "sha1": calculate_sha1,
    "sha256": calculate_sha256,
    "sha512": calculate_sha512,
}


def process_task(task: dict) -> bool:
    if not all(k in task for k in ("alg", "list", "base_url")):
        print(f"Error: missing required keys in task: {task}")
        return False

    # Ensure at least 'path' or 'files' is provided in the configuration
    if "path" not in task and "files" not in task:
        print(f"Error: task must contain either 'path' or 'files': {task}")
        return False

    if task.get("alg").lower() not in HASH_FUNCTIONS:
        print(f"Error: unsupported hash algorithm '{task.get('alg')}'")
        return False

    repo_root = Path.cwd()
    target_files = []

    # Collect explicitly defined files or scan the directory based on configuration
    if task.get("files"):
        for f_name in task.get("files"):
            if not (repo_root /
                    f_name).exists() or not (repo_root / f_name).is_file() or (
                        repo_root / f_name).stat().st_size == 0:
                print(f"Error: file missing or empty: {f_name}")
                return False
            target_files.append(repo_root / f_name)
    else:
        if not (repo_root / task.get("path", "")).exists() or not (
                repo_root / task.get("path", "")).is_dir():
            print(
                f"Error: search path missing or not a directory: {task.get('path')}"
            )
            return False

        target_files.extend(
            (repo_root / task.get("path", "")
             ).glob("**/*.rsc" if task.get("recursive") else "*.rsc"))

    lines_to_keep = []

    # Extract existing comments from the list file before truncation
    if not (repo_root / task.get("list")).exists():
        print(f"Error: list file {task.get('list')} not found.")
        return False

    with open(repo_root / task.get("list"), "r", encoding="utf-8") as f:
        all_lines = f.readlines()

    last_comment_index = -1
    for i, line in enumerate(all_lines):
        if line.lstrip().startswith("#"):
            last_comment_index = i

    if last_comment_index != -1:
        lines_to_keep = all_lines[:last_comment_index + 1]

    # Ensure clean separation between comments and the newly generated payload
    if lines_to_keep and not lines_to_keep[-1].endswith("\n"):
        lines_to_keep[-1] += "\n"

    lines_to_keep.append("\n")

    # Append fresh hash data for every localized file directly to the output buffer
    for f_path in sorted(target_files):
        lines_to_keep.append(
            f"{HASH_FUNCTIONS[task.get('alg').lower()](f_path)} "
            f"{task.get('base_url')}{f_path.relative_to(repo_root).as_posix()}\n"
        )

    (repo_root / task.get("list")).parent.mkdir(parents=True, exist_ok=True)

    with open(
            repo_root / task.get("list"),
            "w",
            encoding="utf-8",
            newline="\n",
    ) as f:
        f.writelines(lines_to_keep)

    print(
        f"Successfully updated {task.get('list')} with {len(target_files)} files."
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

    if not isinstance(data,
                      dict) or "config" not in data or "base_url" not in data:
        print(
            "Error: JSON configuration must be an object containing 'base_url' and a 'config' list."
        )
        return False

    base_url = data.get("base_url")
    tasks = data.get("config")

    if not isinstance(tasks, list):
        print("Error: 'config' must be a list of objects.")
        return False

    for entry in tasks:
        if not isinstance(entry, dict):
            print(f"Error: invalid entry in configuration: {entry}")
            return False

        # Inject base_url into the task dictionary to keep process_task completely unchanged
        entry["base_url"] = base_url

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
