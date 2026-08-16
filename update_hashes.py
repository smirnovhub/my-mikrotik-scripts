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

    updated_lines = []
    repo_root = Path.cwd()

    print(f"Updating {list_file_path} using [{alg.upper()}] hashes...")

    with open(list_file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    for line in lines:
        stripped = line.strip()

        # Retain comments and empty lines without modification
        if not stripped or stripped.startswith("#"):
            updated_lines.append(line)
            continue

        # Extract target URL from line
        parts = stripped.split()
        url = parts[-1]

        match = URL_PATTERN.match(url)
        if match:
            rel_path_str = match.group("rel_path")

            # Resolve file path relative to repository root
            local_file = repo_root / rel_path_str

            if local_file.exists() and local_file.is_file():
                file_hash = hash_func(local_file)
                updated_lines.append(f"{file_hash} {url}\n")
                print(f"{file_hash} {url}")
                continue
            else:
                print(f"Error: file missing at {local_file} for URL: {url}")
                return False

        # Preserve line if pattern matching fails or target file is missing
        updated_lines.append(line if line.endswith("\n") else line + "\n")

    with open(list_file_path, "w", encoding="utf-8", newline="\n") as f:
        f.writelines(updated_lines)

    print(f"Hashes in {list_file_path} updated successfully.")
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Update file checksums in a reference list.")
    parser.add_argument("list_path", type=Path, help="Path to the list file")
    parser.add_argument(
        "-a",
        type=str,
        required=True,
        choices=list(HASH_FUNCTIONS.keys()),
        help="Hash algorithm to use",
    )

    args = parser.parse_args()
    if not process_list(args.list_path, args.a):
        sys.exit(1)
