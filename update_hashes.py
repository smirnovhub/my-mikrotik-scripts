import re
import sys
import zlib

from pathlib import Path

# Match everything after /refs/heads/<any_branch>/ as relative path
URL_PATTERN = re.compile(r"^http.*/refs/heads/[^/]+/(?P<rel_path>.+)$")


def calculate_hash(filepath: Path) -> str:
    # Read bytes and calculate CRC32 checksum
    crc_val = zlib.crc32(filepath.read_bytes())
    # Format as 8-character lowercase hex string
    return f"{crc_val:08x}"


def process_list(list_file_path: Path):
    if not list_file_path.exists():
        print(f"Error: {list_file_path} not found.")
        return

    updated_lines = []
    repo_root = Path.cwd()

    print(f"Updating {list_file_path} hashes...")

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
                file_hash = calculate_hash(local_file)
                updated_lines.append(f"{file_hash} {url}\n")
                print(f"{file_hash} {url}")
                continue
            else:
                print(f"Warning: File missing at {local_file} for URL: {url}")

        # Preserve line if pattern matching fails or target file is missing
        updated_lines.append(line if line.endswith("\n") else line + "\n")

    with open(list_file_path, "w", encoding="utf-8", newline="\n") as f:
        f.writelines(updated_lines)

    print(f"Hashes {list_file_path} Updated.")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: python {Path(sys.argv[0]).name} <path/to/list.txt>")
        sys.exit(1)

    target_path = Path(sys.argv[1])
    process_list(target_path)
