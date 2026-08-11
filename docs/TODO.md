# TODO: Code review follow-ups for `lib/`

Actionable items from the 2026-08-11 full review of `lib/` (see
[`style_guide.md`](./style_guide.md) for the conventions each item should
converge to). Grouped by priority; check items off as they land.

## P0: Security and data-loss risks

- [ ] **Re-enable TLS verification in all download paths.**
  Remove `--insecure` from `curl` and `--no-check-certificate` from `wget` in
  `lib/download.sh`, `lib/install_apps.sh` (`__get_gh_latest_release`,
  `__get_gh_latest_tag`), and `lib/bootstrap_remote_user.sh`
  (`__build_bash`, `__build_glibc`). Standardize on
  `curl --proto '=https' --tlsv1.2 -fsSL`.
- [x] `lib/is_installed.sh`: `command -p "${1:-}"` **executes** the queried
  command instead of checking it exists; must be `command -pv`.
- [ ] `lib/bootstrap_remote_user.sh` (`__clean_home`):
  `rm -rf "${HOME}"/.Trash/.*` matches `..`; replace the dot-glob with a safe
  pattern or `find`.
- [ ] `lib/rm_safe.sh`: protection fails **open** when `realpath` is
  missing (all resolved paths become empty and the `rm` proceeds). Fail
  closed; add `cd`+`pwd -P` fallback. Remove the literal single-quoted
  entries (`'${HOME}'` etc.) from the safe list.
- [ ] `lib/git_lib.sh` (`git_remove_file`): `exit_fun` on empty filename is
  not followed by `return 1`, so `git filter-branch` still runs; the
  filename is also interpolated unquoted into the filter shell string.

## P1: Functional bugs

- [x] `lib/bat_fun.sh`: fallback branch runs `"${cat_bin}"` **without**
  `"${@}"`; hangs reading stdin when `bat` is absent.
- [x] `lib/timeout_exec.sh`: `"${cmd_bin}" "${@}"` duplicates the command
  (`cmd cmd args...`); should pass `"${@}"` once. Also needs a `gtimeout`
  fallback for macOS.
- [x] `lib/get_device_config.sh` (`get_hostname`): second branch tests
  `hostname_bin` where it should test `uname_bin` (the `uname -n` fallback is
  unreachable); first branch calls bare `hostname` instead of
  `"${hostname_bin}"`.
- [ ] `lib/bootstrap_remote_user.sh` (`__build_glibc`):
  ~~`inst_path` uses `${app_name}` before it is assigned~~ (fixed);
  `force_version="${2:-latest}"` is never empty so the `__check_glibc`
  short-circuit is dead code;
  `[[ ${latest_version} =~ ${glibc_version} ]]` treats a version as a regex.
- [ ] `lib/bootstrap_remote_user.sh` (`__clean_home`): the
  `.kitty-ssh-kitten*` array entry never matches: globs do not expand inside
  `[[ -f ... ]]`.
- [ ] `lib/radian_fun.sh`: passes `--r-binary="${r_bin}"` but the `r_bin`
  assignment is commented out (always empty).
- [ ] `lib/gen_passwd.sh`: `"${mkpw_bin}" ...` is a literal `...`
  placeholder; the mkpasswd-only path is broken.
- [ ] `lib/encrypt.sh` (`encrypt_file_password`): `gpg -R` is
  `--hidden-recipient` and consumes `--encrypt` as its argument; symmetric
  encryption needs no recipient. `encrypt_str`/`unencrypt_str` are empty
  stubs: implement or remove.
- [ ] `lib/ssh_utils.sh` (`ssh_generate_key`): `rsa` branch sets
  `key_args=(-t)` with no key type/size.
- [ ] `lib/follow_logs.sh`: `mapfile -t file_path < <( "${@}" )` executes
  the arguments as a command; should be `printf '%s\n' "${@}"`. `bat_bin`
  is unchecked.
- [ ] `lib/head_pure.sh`: `"${line_arr[@]:-${n_arg}}"` prints the line
  *count* when the file is empty; argument order/`-n` parsing TODO remains.
- [ ] `lib/cat_pure.sh`: `echo "$(<file)"` strips trailing newlines and
  mangles leading-dash content; use `printf`.
- [ ] `lib/cd_dirs.sh`: `dir_arg=("$@:-")` appends a literal `:-`;
  `eval echo` on input; unquoted array from `realpath`. Per the file's own
  TODO: probably delete the file in favor of `cd_fun`.
- [ ] `lib/install_apps.sh`: `__get_app_num_from_app_name` uses
  `"${grep_bin}"` without assigning it; `exec_path`/`extra_cmd` templates
  substitute `${install_path}`/`${lib_path}` before assignment;
  `skip_download_step='true;'` stray semicolon; `exec_path_arr`
  scalar/array churn.
- [ ] `lib/unpack.sh`: plain `*.bz2` routed to `tar -xjf`;
  `${output_file_path/.gz/}` should anchor the suffix (`%.gz`).
- [ ] `lib/which_bin.sh`: `[[ ${file_name} =~ ${cmd_arg}$ ]]` treats the
  command name as a regex (`which_bin 'g++'` never matches); the check is
  redundant: drop it.
- [ ] `lib/create_temp.sh`: `mktemp --suffix` is GNU-only (contradicts the
  macOS comment); drop the string-building + `eval`, put the suffix in the
  `-t` template.
- [ ] `lib/require.sh`: stderr capture makes the "can it run" check
  ineffective (own TODO at the top of the block); decide semantics and fix.
- [ ] `lib/ssh_fun.sh` / `lib/run_kitty_integration.sh`: unconditional
  `set -x` left enabled; gate behind the `DEBUG` convention.
  `__sync_user_config` concatenates `-i${key_path}` without a space and
  duplicates the 15-line rsync call (use an args array).
- [ ] `lib/command_tools.sh`: leftover `Debug 1`/`Debug 2` output; file is
  self-declared leftover: delete or finish.
- [ ] `lib/user_manage.sh` (`__user_add_group`): `mapfile < <(echo "${@}")`
  mangles arguments; `groups_to_add` is a string indexed as an array.
- [ ] `lib/exec_remote.sh`: capturing output then echoing loses the remote
  exit code and breaks interactive use with `-t`.
- [ ] `lib/text_box.sh`: `w` used unset in arithmetic; `tput sgr 0` should
  be `sgr0`.
- [ ] `lib/force-xdg-basedirs.sh`: `mkdir -p .../latexmk/latexmkrc`
  creates a *directory* named like the rc file. (File otherwise exempt from
  conventions.)

## P2: Portability gaps (vs. the project claim)

- [ ] **`sed -i` dialect split**: `lib/fix_quotes.sh` uses the GNU form,
  `lib/replace_in_file.sh` uses the BSD form; each breaks on the other
  platform. Add a shared `sed_inplace` helper (or temp-file + move).
- [ ] **GNU-only regex escapes** (`\s`, `sed -r`) in `lib/dfh.sh`,
  `lib/port_utils.sh`, `lib/user_manage.sh` → `[[:space:]]` and `sed -E`.
- [ ] `lib/list_permission.sh`: `stat -c` is GNU-only; branch to
  `stat -f '%Lp %N'` on darwin.
- [ ] `lib/dfh.sh`: `df -h -T -x` is Linux-only; guard with `get_os_type`
  or add a darwin variant.
- [ ] `lib/check_used_ports.sh`: `ss` is Linux-only; add `lsof`/`netstat`
  fallback for darwin, or guard explicitly.
- [ ] `lib/get_lib_path.sh`: `[ ]` instead of `[[ ]]`; bare
  `${XDG_LIB_HOME}` errors under `nounset` (needs `:-` default).
- [ ] Bare external commands bypassing `which_bin`/`require` discipline:
  `lib/bootstrap_remote_user.sh` (`__check_glibc`: `head`, `sed`, `sort`),
  `lib/get_default_shell.sh` (`awk`, `sed`, `grep`, `cut`),
  `lib/port_utils.sh` (`sudo`, `grep`, `sed`, `cut`, `seq`),
  `lib/neovim_utils.sh` (`git clone`, `rm -rf`), `lib/pixi_tools.sh` and
  `lib/rstats_lib.sh` (`curl | bash`, `brew`), `lib/slurm_lib.sh`
  (`grep -v '(null)'`).
- [ ] `lib/create_log.sh`: hardcoded `TZ='US/Eastern'`; move to config.
- [ ] Replace `ls`-parsing (`mapfile < <(ls -A1 ...)`) with globs in
  `lib/bootstrap_remote_user.sh`, `lib/install_apps.sh`, `lib/unpack.sh`.

## P3: Consistency and cleanup

- [x] `"${@:-}"` → `"${@}"` everywhere (empty-argument injection; safe on
  Bash >= 4.4). Affected: `exa_fun.sh`, `highlight_fun.sh`, `pure.sh`,
  `text_box.sh`, `get_conda_bin.sh`, `install_apps.sh`, `ssh_alias.sh`,
  `cat_color`/`color_cmds.sh`, `bootstrap_remote_user.sh`.
- [x] Pair every `exit_fun` with `\builtin return 1;` (audit all call
  sites; several fall through or `return 0`).
- [x] Add missing `local` declarations: `check_used_ports.sh` (`grep_bin`),
  `get_nthreads.sh` (`awk_bin`, `sysctl_bin`), `get_conda_bin.sh`
  (`use_uv_flag`), `bootstrap_remote_user.sh` (`rustup_bin`, `base_name`),
  `is_compressed.sh` (`res_txt`), `install_apps.sh`/`__install_yq`
  (`inst_path`, `base_url`), `sudo_fun.sh` (`type_str`), `slurm_lib.sh`
  (`group_name`), `unpack.sh` (`content_dirs`), `install_apps.sh`
  (`latest_tag_arr`, `_i`).
- [ ] `_usage` strings: use `${FUNCNAME[0]}` instead of `${0}`; wire to a
  `-h`/`--help` check or drop the dead `_usage=...; unset _usage` pairs.
  Update the `bash_header` template accordingly (also remove
  `set -o errexit` from the sourced-function template).
- [ ] Replace `echo -ne "${data}"` with `printf '%s' "${data}"` for data
  output (keep `echo -ne` for literal format strings only).
- [ ] Unify naming: pick one suffix convention (`_lib`) for topical files;
  rename dash-bearing function names (`rstats_install_r-env_pixi`,
  `__source_remote_shell-lib`); `ssh_send_key` missing `()`.
- [ ] Unify semicolon/indentation style: `download.sh`, `gen_passwd.sh`,
  `user_manage.sh`, `conda_fun.sh`, `rstats_lib.sh` (semicolons);
  `dirname_pure.sh`, `head_pure.sh`, `command_tools.sh` (4-space indent);
  `install_apps.sh` (over-indented function blocks).
- [ ] Add `# shellcheck shell=bash` header to all lib files (currently 3/84).
- [ ] Standardize redirections on `> /dev/null 2>&1`.
- [ ] Standardize error-message quoting on `'value'` (drop backtick and
  `{brace}` variants).
- [ ] Delete commented-out dead code (`neovim_utils.sh`,
  `run_kitty_integration.sh`: the latter is self-declared deprecated,
  consider removing the file).
- [ ] `lib/parse_yaml.sh`: Ruby backend uses `Kernel#open` (pipe-exec on
  crafted paths) → `File.read`; Python backend interpolates path/keys into
  code; `python2` preferred over `python3` in `__parse_yaml_python` while
  `parse_yaml` may have chosen the method based on `python3` only.
- [ ] Extract site-specific defaults to config: SLURM partition/group names
  in `slurm_lib.sh`, `/data/{hostname}` layout in `dfh.sh` and
  `user_manage.sh`.

## Additional Personal Notes

- [ ] Add shellcheck directives to all files, and run `just lint` to check for
  errors.
- [ ] Check for every place where order and sort matter, and add `LC_ALL=C` to
  the environment.
  E.g.: `LC_ALL=C "${sort_bin}"` and `LC_ALL=C "${uniq_bin}"` are the only
  portable ways to get the expected behavior.
- [ ] Harden the Python version detection in all places where it interfaces
  with the system python, check for Python version and if required packages
  are available.
- [ ] Harden the `--version` checks in all places where it is used,
  and make sure that the version is parsed correctly.
- [ ] Check for every place where `grep` is used, and add `LC_ALL=C` to the
  environment.
- [ ] In the Style Guide, everytime macOS (darwin) is mentioned in reality it
  is just a check for BSD vs GNU coreutils, update the text to reflect that
  because this is one of the most important caveats that people overlook in
  safe cross-platform shell scripting.
- [ ] Add robust method for determining if a coreutils program is GNU or BSD,
  instead of relying on `uname` or other brittle methods.
  Even on macOS, if GNU coreutils are installed from Homebrew or Conda-Forge,
  they should be supported.
  I am not sure if checking version number or version string is enough,
  but it is worth investigating.
  If this is implemented successfully, update `docs/style_guide.md` to reflect
  that this is the preferred method for checking for tool compatibility instead
  of just checking the OS strings.
- [ ] Review the right way of redirecting stderr to stdout in a portable way,
  and update all scripts to use that method.
  Probably, `"${cmd}" 2>&1;` and `${cmd} > /dev/null 2>&1;` but check for any
  edge cases.
