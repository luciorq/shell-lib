#!/usr/bin/env bash

# Retrieve Running or complete job details
function slurm_check_job () {
  local job_id;
  declare -a job_id=($@);
  SACCT_FORMAT="JobID%20,JobName,User,Partition,NodeList,Elapsed,State,ExitCode,MaxRSS,AllocTRES%32" \
    sacct -j ${job_id[@]};
}

# Check partitions details
function slurm_check_partitions () {
  sinfo -N -o "%25N %5c %10m %15l %25R"
}

