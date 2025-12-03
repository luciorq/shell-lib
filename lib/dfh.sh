#!/usr/bin/env bash

function dfh () {
  \builtin local ls_bin;
  \builtin local df_bin;
  \builtin local grep_bin;
  \builtin local sed_bin;
  \builtin local column_bin;
  # \builtin local glow_bin;
  \builtin local header_str;
  \builtin local align_str;
  \builtin local body_str;
  header_str="FS,Type,Size,Used,Available,Usage(%),MountPath\n";
  align_str="---,---,---,---,---,---,---\n";
  ls_bin="$(which_bin 'ls')";
  df_bin="$(which_bin 'df')";
  grep_bin="$(which_bin 'grep')";
  sed_bin="$(which_bin 'sed')";
  column_bin="$(which_bin 'column')";
  # glow_bin="$(which_bin 'glow')";
  # NOTE: @luciorq On my remote servers I always mount
  # + data directories at `/data/{ hostname }` also `/home`
  # + is usually a NFS endpoint.
  # Force NFS to mount prior to df execution
  LC_ALL=C "${ls_bin}" -- /data/* /home 2> /dev/null 1> /dev/null \
    || \builtin echo -ne '';
  body_str="$(
    "${df_bin}" -h -T -x squashfs -x devtmpfs \
      | "${grep_bin}" -v '/var/lib/docker/zfs' \
      | "${grep_bin}" -v '^tmpfs.*[^scratch]$' \
      | "${grep_bin}" -v '^Filesystem.*on$' \
      | "${sed_bin}" -r 's/\s+/,/g'
  )";

  # if [[ -n ${glow_bin} ]]; then
    # NOTE: @luciorq glow is used to render markdown
    # + in the terminal, but it is not installed by
    # + default on all systems.
    # + `pixi global install glow-md`
    # CLICOLOR_FORCE=1 \
    #   builtin echo -ne \
    #     "${header_str}${align_str}${body_str}\n" \
    #   | bat_fun -l csv -pp --color=never \
    #   | "${sed_bin}" 's/,/ | /g' \
    #   | "${sed_bin}" 's/^/| /g' \
    #   | "${sed_bin}" 's/$/ |/g' \
    #   | "${column_bin}" -t \
    #   | "${glow_bin}" -w 120;
    # else
  CLICOLOR_FORCE=1 \
    builtin echo -ne \
    "${header_str}${align_str}${body_str}\n" \
    | bat_fun -l csv -pp --color=always \
    | "${sed_bin}" 's/,/ | /g' \
    | "${sed_bin}" 's/^/| /g' \
    | "${sed_bin}" 's/$/ |/g' \
    | "${column_bin}" -t;
  #fi
  \builtin return 0;
}
