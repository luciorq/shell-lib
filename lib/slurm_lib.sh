#!/usr/bin/env bash

# Retrieve Running or complete job details
function slurm_check_job () {
  local sacct_bin;
  local format_string;
  sacct_bin="$(require 'sacct')";
  format_string="JobID%20,JobName%20,User,Partition,NodeList,Elapsed,State,ExitCode,MaxRSS,AllocTRES%32";
  if [[ ${#} -eq 0 ]]; then
    SACCT_FORMAT="${format_string}" \
      "${sacct_bin}" -u "${USER}";
  else
    SACCT_FORMAT="${format_string}" \
      "${sacct_bin}" -j "${@}";
  fi
  return 0;
}

# Check partitions details
function slurm_check_partitions () {
  local sinfo_bin;
  sinfo_bin="$(require 'sinfo')";
  "${sinfo_bin}" -o "%25N %5c %10m %15l %25R";
  return 0;
}

function slurm_check_nodes () {
  local sinfo_bin;
  sinfo_bin="$(require 'sinfo')";
  "${sinfo_bin}" -N -o "%25N %5c %10m %15l %25R";
  return 0;
}

# Request interactive section on slurm
# + Defaults: 4 CPU, 32 GB RAM, 120 Minutes, 0 GPU
function slurm_interactive_session () {
  local _usage="Usage: ${0} [PARTITION] [N_CPU] [MEM_GB] [TIME_MIN] [GPU_NUM] [GROUP_NAME]";
  unset _usage;
  local bash_bin;
  local srun_bin;
  local sg_bin;
  local partition_name;
  local num_cpu;
  local mem_gb;
  local time_min;
  local time_hour;
  local gpu_num;
  bash_bin="$(require 'bash')";
  srun_bin="$(require 'srun')";
  sg_bin="$(require 'sg')";
  partition_name="${1:-scu-cpu}";
  num_cpu="${2:-4}";
  mem_gb="${3:-8}";
  time_min="${4:-120}";
  gpu_num="${5-0}";
  group_name="${6:-marchionnilab}";
  ((time_hour = time_min / 60));
  ((time_min = time_min % 60));
  time_hour="$(builtin printf '%02d' "${time_hour}")";
  time_min="$(builtin printf '%02d' "${time_min}")";
  # "${gpu_block[@]}" \
  # --gres=gpu:1;
  "${sg_bin}" "${group_name}" "\
    ${srun_bin} --partition ${partition_name} \
    --job-name InteractiveJob \
    --cpus-per-task ${num_cpu} \
    --mem-per-cpu ${mem_gb}G \
    --gres=gpu:${gpu_num} \
    --time ${time_hour}:${time_min}:00 \
    --pty ${bash_bin} \
    ";
  return 0;
}

# Request interactive session with GPU support
# + Defaults: 1 GPU, 4 CPU, 32 GB RAM, 120 Minutes
function slurm_interactive_gpu_session () {
  local _usage="Usage: ${0} [GPU_NUM] [PARTITION] [N_CPU] [MEM_GB] [TIME_MIN]";
  unset _usage;
  local gpu_num;
  local partition_name;
  local num_cpu;
  local mem_gb;
  local time_min;
  gpu_num="${1-1}";
  partition_name="${2:-scu-gpu}";
  num_cpu="${3:-4}";
  mem_gb="${4:-8}";
  time_min="${5:-120}";
  slurm_interactive_session \
    "${partition_name}" \
    "${num_cpu}" \
    "${mem_gb}" \
    "${time_min}" \
    "${gpu_num}";
  return 0;
}
function slurm_check_queue () {
  local squeue_bin;
  squeue_bin="$(require 'squeue')";
  "${squeue_bin}" -o \
    "%.18i %.9P %.8j %.8u %.2t %.10M %.6D      %C      %m      %R";
  return 0;
}

function slurm_check_limits () {
  local sacc_bin;
  sacc_bin="$(require 'sacctmgr')";
  "${sacc_bin}" list associations;
  return 0;
}

# Check GPUs available in each node
function slurm_check_gpus () {
  local scontrol_bin;
  local grep_bin;
  local gpu_output;
  local gpu_node_names;
  local gpus_installed;
  local gpus_used;
  local partition_names;
  local gpus_model;
  local sed_bin;
  local paste_bin;
  local column_bin;
  scontrol_bin="$(require 'scontrol')";
  grep_bin="$(require 'grep')";
  sed_bin="$(require 'sed')";
  paste_bin="$(require 'paste')";
  column_bin="$(require 'column')";
  gpu_output="$("${scontrol_bin}" show nodes \
    | "${grep_bin}" -i \
    -e CfgTRES= -e AllocTRES= -e NodeName= -e Gres= -e Partitions=
  )";
  gpu_node_names="$(
    builtin echo -ne "${gpu_output}" \
      | grep 'NodeName=' \
      | sed -e 's|\s.*||g' \
      | sed -e 's|NodeName=||g'
  )";
  gpus_installed="$(
    builtin echo -ne "${gpu_output}" \
      | grep 'Gres=' \
      | sed -e 's|Gres\=||g' \
      | sed -e 's|gpu\:||g'
  )";
  gpus_used="$(
    builtin echo -ne "${gpu_output}" \
      | grep 'AllocTRES=' \
      | sed -e 's|.*gres/gpu:||g' \
      | sed -e 's|AllocTRES\=|0|g'
  )";
  partition_names="$(
    builtin echo -ne "${gpu_output}" \
      | grep -v 'Gres=' \
      | grep -v 'AllocTRES=' \
      | grep -v 'CfgTRES=' \
      | sed -e 's|NodeName\=.*|NA|g' \
      | sed -e ':a;N;$!ba;s/\n//g' \
      | sed -e 's|Partitions\=||g' \
      | sed -e 's/,/|/g' \
      | sed -e 's|NA|\n|g'
  )";
  CLICOLOR_FORCE=1 "${paste_bin}" \
    <(builtin echo -ne "NODENAME\n${gpu_node_names}") \
    <(builtin echo -ne "TOTAL_GPUS\n${gpus_installed}") \
    <(builtin echo -ne "USED_GPUS\n${gpus_used}") \
    <(builtin echo -ne "PARTITION\n${partition_names}") \
    | grep -v '(null)' \
    | "${column_bin}" -t;
    # | bat_fun -l tsv -pp;
    return 0;
}
