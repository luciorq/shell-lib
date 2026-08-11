# Shell-lib

<p align="center">
  Made with 💝 for <img src="docs/figures/tux.png" align="top" width="18" />
</p>

<!--
| |
| :---: |
| Made with 💝 for <img src=".github/tux.png" align="top" width="18" /> |
-->

This repository includes a library of shell functions that are intended to
be used as part of other Shell Scripting software development projects
or used interactively as Shell functions sourced from an interactive Shell.

> [!IMPORTANT]
> **Some functions require Bash Shell v4.4 or newer to be installed in the system.**

The file `lib/force-xdg-basedirs.sh` actually don't follow the standards
of this library.
This file is intended to be sourced from an interactive session to force some
applications to abide by the XDG Base Directory Specification.

## Content

📂 [lib](./lib) has Shell scripts containing functions to be sourced\
📂 [bin](./bin) has independent executable scripts that can be added to PATH directly\
📂 [src](./src) contain additional executables used during development\
  ⊢ 📂 [appbuilder](./src/appbuilder) Experimental Python library for building apps\
📂 [tests](./tests) contain tests for both functions and executables\
  ⊢ 📄 `test-app-*.py` tests for individual executables\
  ⊢ 📄 `test-*.bats` tests for functions loaded in a Bash Shell

Check the dependency graph in [docs/dependency_graph.md](./docs/dependency_graph.md).

## Usage

### Using as executable tools

Independent executables can be found in the `bin` directory.
Copy files to a directory in your `PATH` to find them automatically when
you type the name of the tool in your Shell.

Recommended installation directory:

- `${HOME}/.local/bin` for user-only installation.
- `/usr/local/bin` for system-wide installation.
- `/opt/shell-lib/bin` or `/opt/apps/bin` are also good candidates for
  system-wide installation.

### Using as a library

Function files can be found in the `lib` directory.
Copy individual files to your project and source them from your scripts.

### Calling individual scripts

All scripts in the `bin` directory are formatted in a way to be executed directly
from the internet if needed.

E.g. for calling `dfh` script.

```bash
\curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/luciorq/shell-lib/main/bin/dfh | bash
```

---

## Further Reading: Bash Safety and Best Practices

> [!NOTE]
> The links in this section are provided for reference and learning,
> though I do not necessarily endorse or adopt all the practices they describe.
> For the specific style and design patterns used in this project, please refer
> to [docs/style_guide.md](./docs/style_guide.md).

- [Common Bash pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [Parsing `ls` ouput can be really dangerous](https://mywiki.wooledge.org/ParsingLs)
- [Why you don't read lines with `for`](https://mywiki.wooledge.org/DontReadLinesWithFor)
- [Palomero Lab Bash Scripting Reference](https://palomerolab.org/how-to/linux-cli/bash/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

---

> [!WARNING]
> Source with caution and have fun!
