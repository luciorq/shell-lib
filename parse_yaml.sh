#!/usr/bin/env bash

# Extract variables from YAML a file
function parse_yaml () {
  local ruby_bin ruby_script;
  local yaml_path;
  local args_arr;
  local yaml_levels levels;
  local i args_range;
  declare -a yaml_levels;
  yaml_path="$1";

  args_arr=($@);
  args_seq=( $(seq ${#args_arr[@]}) );
 
  for i in ${args_seq[@]}; do
    if [[ -n "${args_arr[${i}]}" ]]; then
      yaml_levels[ $(( ${i} - 1 )) ]=${args_arr[${i}]};
    fi
  done
  # TODO luciorq Add check for MacOS or at least having
  # + ruby installed, or try python or jq if ruby is not
  # + available.
  ruby_bin="$(which_bin 'ruby')";
  ruby_script="puts YAML::load(open(ARGV.first).read)";
  for levels in ${yaml_levels[@]}; do
    ruby_script="${ruby_script}['${levels}']";
  done
  # echo $ruby_script;
  "${ruby_bin}" -ryaml -e "${ruby_script}" "${yaml_path}";
}

