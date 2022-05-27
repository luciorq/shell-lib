#!/usr/bin/env bash

function dfh () {
  local ls_bin;
  local df_bin;
  local grep_bin;
  local header_str;
  local align_str;
  local body_str;
  header_str="FS,Type,Size,Used,Available,Usega(%),MountPath\n";
  align_str="---,---,---,---,---,---,---\n";
  ls_bin="$(which_bin 'ls')";
  df_bin="$(which_bin 'df')";
  grep_bin="$(which_bin 'grep')";
  column_bin="$(which_bin 'column')";
  "${ls_bin}" /data/* /home 2> /dev/null 1> /dev/null \
    || builtin echo -ne '';
  body_str="$(
    "${df_bin}" -h -T -x squashfs -x devtmpfs \
      | "${grep_bin}" -v '/var/lib/docker/zfs' \
      | "${grep_bin}" -v '^tmpfs.*[^scratch]$' \
      | "${grep_bin}" -v '^Filesystem.*on$' \
      | sed -r 's/\s+/,/g'
  )";
  CLICOLOR_FORCE=1 \
    builtin echo -ne "${header_str}${align_str}${body_str}\n" \
    | bat_fun -l csv -pp --color=always \
    | sed 's/,/ | /g' \
    | sed 's/^/| /g' \
    | sed 's/$/ |/g'
  return 0;
}
