# Shell-lib

<p align="center">
  Made with 💝 for <img src=".github/tux.png" align="top" width="18" />
</p>

<!--
| |
| :---: |
| Made with 💝 for <img src=".github/tux.png" align="top" width="18" /> |
-->

This repository includes a library of shell functions that are intended to
be used as part of other Shell Scripting software development projects
or used interactively as Shell functions sourced from an interactive Shell.

> **Some functions require Bash Shell v4.4 or newer to be installed in the system.**

The file `lib/force-xdg-basedirs.sh` actually don't follow the standards
of this library.
This file is intended to be sourced from an interactive session to force some
applications to abide by the XDG Base Directory Specification.

---

## Usage

### Using as executable tools

Independent executables can be found in the `bin` directory.
Copy files to a directory in your `PATH` to find them automatically when
you type the name of the tool in your Shell.

Recommended directory: `/usr/local/bin` for system-wide installation or
`${HOME}/.local/bin` for user-only installation.

### Using as a library

Function files can be found in the `lib` directory.
Copy individual files to your project and source them from your scripts.

---

> Source with caution and have fun!
