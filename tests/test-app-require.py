#!/usr/bin/env python3

import os
import re
import shutil
import subprocess
import sys

# from src.appbuilder import run_app

# import pytest


# Run Bash Script from the bin directory inside the the root of the project
def run_app(script_name: str, args: list[str]) -> subprocess.CompletedProcess:
    """Run script to be tested with arguments."""
    script_path = os.path.join(".", "bin", script_name)
    res = subprocess.run(
        [script_path, *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    return res


# Tests for require


def test_require_fail() -> None:
    """Test require error message."""

    res = run_app("require", ["lsx"])

    assert res.returncode == 1

    assert res.stdout.decode() == ""

    assert (
        re.search(
            r"Error: 'lsx' executable not found in '\$\{PATH\}'", res.stderr.decode()
        )
        is not None
    )


def test_require_success() -> None:
    """Test `require` sucessfull return."""

    res = run_app("require", ["python"])

    assert res.returncode == 0

    assert sys.executable == res.stdout.decode()

    assert re.search(r"python", res.stdout.decode()) is not None

    assert res.stderr.decode() == ""


# TODO: @luciorq This actually should fails
# + need to investigate a bit more.
# + Probably I changed the require logic to accept when arguments fail.
def test_require_command_without_version_flag() -> None:
    """Test `require ssh` fail with `--version`"""

    res = run_app("require", ["ssh", "--version"])

    assert res.returncode == 0

    assert shutil.which("ssh") == res.stdout.decode()

    assert res.stderr.decode() == ""
