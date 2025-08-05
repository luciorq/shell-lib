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


# Tests for `which_bin`


def test_which_bin_fail() -> None:
    """Test `which_bin` error message."""

    res = run_app("which_bin", ["lsxyzwaz"])

    assert res.returncode == 0

    assert res.stdout.decode() == ""

    assert res.stderr.decode() == ""


def test_which_bin_success() -> None:
    """Test `which_bin` sucessfull return path."""

    res = run_app("which_bin", ["python"])

    assert res.returncode == 0

    assert sys.executable == res.stdout.decode()

    assert re.search(r"python", res.stdout.decode()) is not None

    assert res.stderr.decode() == ""


def test_which_bin_custom_path() -> None:
    """Test `which_bin` with custom PATH env var."""

    old_path_env = os.environ["PATH"]
    bash_dir = shutil.which("bash")
    if bash_dir is None:
        bash_dir = ""
    bash_dir = os.path.dirname(bash_dir)
    os.environ["PATH"] = f"{os.path.join(".", "bin")}:{bash_dir}"
    res = run_app("which_bin", ["which_bin"])
    os.environ["PATH"] = old_path_env

    assert res.returncode == 0

    assert res.stdout.decode() == os.path.join(".", "bin", "which_bin")
