#!/usr/bin/env bash

# Retrieve Running or complete job details
function slurm_check_job () {
  SACCT_FORMAT="JobID%20,JobName,User,Partition,NodeList,Elapsed,State,ExitCode,MaxRSS,AllocTRES%32" \
    sacct -j "${@}";
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

function slurm_interactive_session () {
  local _usage="Usage: ${0} [PARTITION] [N_CPU] [MEM_GB] [TIME_MIN]";
  unset _usage;
  local bash_bin;
  local srun_bin;
  local partition_name;
  local num_cpu;
  local mem_gb;
  local time_min;
  local time_hour;
  bash_bin="$(require 'bash')";
  srun_bin="$(require 'srun')";

  partition_name="${1:-scu-cpu}";
  num_cpu="${2:-4}";
  mem_gb="${3:-8}";
  time_min="${4:-120}";
  ((time_hour = time_min / 60));
  ((time_min = time_min % 60));
  time_hour="$(builtin printf '%02d' "${time_hour}")";
  time_min="$(builtin printf '%02d' "${time_min}")";
  "${srun_bin}" --partition "${partition_name}" \
    --job-name "InteractiveJob" \
    --cpus-per-task "${num_cpu}" \
    --mem-per-cpu "${mem_gb}"G \
    --time "${time_hour}":"${time_min}":00 \
    --pty "${bash_bin}";
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