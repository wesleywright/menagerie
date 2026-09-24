"""
Helper script to build a list of files to backup with restic.

This script takes a list of directories and recursively prints the absolute
paths to all files within those directories, with the following exceptions:

1. Files ignored by `git` are omitted. This is achieved by detecting `git`
   repositories and invoking `git ls-files` rather than iterating the
   repositories directly.
2. Directories named `.snapshots` as omitted. These are typically Snapper
   snapshot directories, and backing them up would result in massive backup
   file lists with very large numbers of duplicates.

The output of this script will also be sorted lexicographically. This makes it
easier to compare the output of two invocations of the script, and also makes
it easy to predict the order in which files will be backed up.
"""
from __future__ import annotations

from argparse import ArgumentParser
from collections.abc import Generator
from contextlib import contextmanager
import os
from pathlib import Path
import subprocess


def parser() -> ArgumentParser:
    parser = ArgumentParser()
    parser.add_argument("directory", nargs="+", type=Path)
    return parser


def visit(path: Path) -> Generator[Path]:
    # Skip Snapper snapshot subvolumes.
    if path.name == ".snapshots":
        return

    # Non-directory paths should be output directly.
    if not path.is_dir():
        yield path
    # Any directory containing a subdirectory named `.git` is treated as git
    # repository.
    elif (path / ".git").is_dir():
        yield from git_ls(path)
    # Any other directory is visited recursively.
    else:
        for child in path.iterdir():
            yield from visit(child)


@contextmanager
def pushd(path: Path) -> Generator[None]:
    previous = Path.cwd()
    try:
        os.chdir(path)
        yield
    finally:
        os.chdir(previous)


def git_ls(path: Path) -> Generator[Path]:
    with pushd(path):
        child = subprocess.Popen(
            [
                "git",
                # `-c safe.directory*` overrides a git sanity check that will
                # cause the command to fail if the repository is not owned by
                # the expected user. Since we're only reading from the
                # repository (and since we expect the backup command to be run
                # by a different user than `naptime`), it's safe to bypass this
                # check.
                "-c",
                "safe.directory=*",
                "ls-files",
                # Include files that are tracked by git.
                "--cached",
                # Include files that are not tracked by git, except...
                "--other",
                # Exclude any files from standard git exclusions (.gitignore,
                # cache directories, &c.)
                "--exclude-standard",
            ],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            text=True,
        )
        for line in child.stdout:
            yield path.joinpath(line.strip())
        assert child.wait() == 0, "git ls-files failed"


def main() -> None:
    arguments = parser().parse_args()

    paths = []
    for directory in arguments.directory:
        assert directory.exists(), f"directory {directory} does not exist"
        paths.extend(visit(directory))

    # We convert the path into a string and lowercase it to ensure
    # lexicographical sort order.
    paths.sort(key=lambda path: str(path).lower())
    for path in paths:
        # annoying edge case: by default, Restic wants to interpret square
        # brackets as part of glob patterns, so filenames with square brackets
        # will not be backed up. Replacing them with ? to match any character
        # works instead.
        #
        # In theory this may result in backing up more files than intended,
        # but it seems very unlikely that a file that I want to back up and a
        # file that I don't want to back up would vary by a single square
        # bracket.
        print(str(path).replace('[', '?').replace(']', '?'))


if __name__ == "__main__":
    main()
