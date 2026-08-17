import json
import re
import sys
import zlib
import argparse
import hashlib

from pathlib import Path

# Match everything after /refs/heads/<any_branch>/ as relative path
URL_PATTERN = re.compile(r"^http.*/refs/heads/[^/]+/(?P<rel_path>.+)$")


def calculate_crc32(filepath: Path) -> str:
    # Read bytes and calculate CRC32 checksum
    crc_val = zlib.crc32(filepath.read_bytes())
    # Format as 8-character lowercase hex string
    return f"{crc_val:08x}"


def calculate_md5(filepath: Path) -> str:
    # Read bytes and calculate MD5 checksum
    return hashlib.md5(filepath.read_bytes()).hexdigest()


def calculate_sha1(filepath: Path) -> str:
    # Read bytes and calculate SHA1 checksum
    return hashlib.sha1(filepath.read_bytes()).hexdigest()


def calculate_sha256(filepath: Path) -> str:
    # Read bytes and calculate SHA256 checksum
    return hashlib.sha256(filepath.read_bytes()).hexdigest()


# Registry mapping algorithm names to their handler functions
HASH_FUNCTIONS = {
    "crc32": calculate_crc32,
    "md5": calculate_md5,
    "sha1": calculate_sha1,
    "sha256": calculate_sha256,
}


def process_list(list_file_path: Path, alg: str) -> bool:
    if not list_file_path.exists():
        print(f"Error: {list_file_path} not found.")
        return False

    hash_func = HASH_FUNCTIONS.get(alg.lower())
    if not hash_func:
        print(
            f"Error: unsupported hash algorithm '{alg}'. Supported: {', '.join(HASH_FUNCTIONS.keys())}"
        )
        return False

    has_updates = False
    updated_lines = []
    repo_root = Path.cwd()

    print(f"Updating {alg.upper()} hashes for {list_file_path}...")

    with open(list_file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    for line in lines:
        stripped = line.strip()

        # Retain comments and empty lines without modification
        if not stripped or stripped.startswith("#"):
            updated_lines.append(line)
            continue

        # Extract target URL and existing hash from line
        parts = stripped.split()
        url = parts[-1]
        existing_hash = parts[0] if len(parts) >= 2 else ""

        match = URL_PATTERN.match(url)
        if match:
            rel_path_str = match.group("rel_path")

            # Resolve file path relative to repository root
            local_file = repo_root / rel_path_str

            if local_file.exists() and local_file.is_file():
                file_hash = hash_func(local_file)

                # Compare new hash with existing one
                if file_hash != existing_hash:
                    has_updates = True
                    print(f"{file_hash} {url}")
                updated_lines.append(f"{file_hash} {url}\n")
                continue
            else:
                print(f"Error: file missing at {local_file} for URL: {url}")
                return False

        # Preserve line if pattern matching fails or target file is missing
        updated_lines.append(stripped + "\n")

    with open(list_file_path, "w", encoding="utf-8", newline="\n") as f:
        f.writelines(updated_lines)

    if has_updates:
        print(f"Hashes in {list_file_path} updated successfully.")
    else:
        print(f"Hashes in {list_file_path} are already up to date.")

    return True


def process_config(config_path: Path) -> bool:
    # Load and process multiple target configurations from a JSON file
    if not config_path.exists():
        print(f"Error: configuration file {config_path} not found.")
        return False

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            tasks = json.load(f)
    except Exception as e:
        print(f"Error parsing JSON configuration file {config_path}: {e}")
        return False

    if not isinstance(tasks, list):
        print("Error: JSON configuration must contain a list of objects.")
        return False

    for entry in tasks:
        if not isinstance(entry, dict):
            print(f"Error: invalid entry in configuration: {entry}")
            return False

        # Support flexible field names for algorithm and target file
        alg = entry.get("alg")
        file_path = entry.get("file")

        if not alg or not file_path:
            print(
                f"Error: entry missing required 'algo' or 'file' key: {entry}")
            return False

        if not process_list(Path(file_path), alg):
            return False

    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Update file checksums in a reference list.",
        formatter_class=lambda prog: argparse.HelpFormatter(
            prog, max_help_position=50, width=100))

    parser.add_argument(
        "list_path",
        nargs="?",
        type=Path,
        help="Path to the list file (required if --config is not used)",
    )

    parser.add_argument(
        "-a",
        type=str,
        choices=list(HASH_FUNCTIONS.keys()),
        help="Hash algorithm to use (required if --config is not used)",
    )

    parser.add_argument(
        "-c",
        "--config",
        type=Path,
        help="Path to JSON configuration file containing update targets",
    )

    args = parser.parse_args()

    if args.config:
        if not process_config(args.config):
            sys.exit(1)
    elif args.list_path and args.a:
        if not process_list(args.list_path, args.a):
            sys.exit(1)
    else:
        parser.error(
            "Must provide either positional list_path with -a, or specify --config / -c."
        )
