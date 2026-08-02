import hashlib
import re
import sys
from pathlib import Path

# Target branch name
BRANCH_NAME = "master"

# Match everything after /<BRANCH_NAME>/ as relative path
URL_PATTERN = re.compile(
    rf"^http.*/{re.escape(BRANCH_NAME)}/(?P<rel_path>.+)$")


def calculate_md5(filepath: Path) -> str:
    return hashlib.md5(filepath.read_bytes()).hexdigest()


def process_list(list_file_path: Path):
    if not list_file_path.exists():
        print(f"Error: {list_file_path} not found.")
        return

    updated_lines = []
    repo_root = Path.cwd()

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
                file_hash = calculate_md5(local_file)
                updated_lines.append(f"{file_hash} {url}\n")
                continue
            else:
                print(f"Warning: File missing at {local_file} for URL: {url}")

        # Preserve line if pattern matching fails or target file is missing
        updated_lines.append(line if line.endswith("\n") else line + "\n")

    with open(list_file_path, "w", encoding="utf-8", newline="\n") as f:
        f.writelines(updated_lines)

    print(f"Updated {list_file_path} using MD5 hashes.")


if __name__ == "__main__":
    target_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("list.txt")
    process_list(target_path)
