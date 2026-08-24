import re
import sys
import argparse

from pathlib import Path

# Regular expression to find :local startupScripts { ... } block
STARTUP_SCRIPTS_PATTERN = re.compile(
    r"(:local\s+startupScripts\s*\{)(.*?)(\})", re.DOTALL)


def update_startup_scripts(target_file_path: Path) -> bool:
    # Check if target file exists
    if not target_file_path.exists() or not target_file_path.is_file():
        print(f"Error: file not found at {target_file_path}")
        return False

    parent_dir = target_file_path.parent
    target_name = target_file_path.name

    # Find all .rsc files in the directory excluding the target file
    rsc_files = [
        f.stem for f in parent_dir.glob("*.rsc")
        if f.is_file() and f.name != target_name
    ]

    # Sort files alphabetically for consistent output
    rsc_files.sort()

    # Format the new list content
    formatted_scripts = ";\n".join([f'    "{script}"' for script in rsc_files])
    new_block_content = f"\n{formatted_scripts}\n"

    # Read target file content
    with open(target_file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Search for the variable using regex
    match = STARTUP_SCRIPTS_PATTERN.search(content)
    if not match:
        print(
            f"Error: ':local startupScripts' variable not found in {target_file_path}"
        )
        return False

    # Replace the old content inside the block with the new list
    updated_content = STARTUP_SCRIPTS_PATTERN.sub(
        rf"\1{new_block_content}\3",
        content,
    )

    # Write back to the target file
    with open(target_file_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(updated_content)

    print(f"Successfully updated startupScripts in {target_file_path}")
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Update list of startup scripts.",
        formatter_class=lambda prog: argparse.HelpFormatter(
            prog, max_help_position=50, width=100))

    parser.add_argument(
        "file_path",
        type=Path,
        help="Path to the target script file to update",
    )

    args = parser.parse_args()

    # Execute and exit with code 1 if it fails
    if not update_startup_scripts(args.file_path):
        sys.exit(1)
