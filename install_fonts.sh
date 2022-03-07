#!/usr/bin/env bash

# Install fonts from remote URL 
function install_fonts () {
  # Usage: install_fonts <BASE_URL> <FAMILY_DIR> <TYPE_ARRAY> <VERSION> 
  local base_url base_dest_dir font_version font_url
  local dest_dir family_dir font_dir font_path
  local name_type path_type temp_dir
  local is_su su_bin
  local fontype_array
  local i j 
   
  base_url="$1"

  is_su=$(sudo_check)
  su_bin=""
  if [[ ${is_su} == true ]]; then
    su_bin=$(which sudo || echo "")
    # TODO luciorq Currently /usr/share files are taking
    # + precedence over /usr/local/share, we need to discover
    # + how to change that for the user
    base_dest_dir=/usr/share
    # base_dest_dir=/usr/local/share
  elif [[ -v "${XDG_DATA_HOME}" ]]; then
    base_dest_dir="${XDG_DATA_HOME}"
  else
    base_dest_dir=$(realpath ~/.local/share)
  fi

  dest_dir='/fonts/truetype'
  family_dir="/$2"
  font_dir="${base_dest_dir}${dest_dir}${family_dir}"

  font_version="$4"

  # fonttype_array=("Regular" "Bold" "Italic" "Bold Italic")
  
  # TODO luciorq use sed to replace "\'" with "" on $fonttype_str
  fonttype_array=()
  fonttype_str=$3
  eval echo $3
  eval_str="fonttype_array=(${fonttype_str})"
  eval_str=$( echo ${eval_str} | sed "s|\\\'||g" )
  eval ${eval_str}
  echo ${!fonttype_array[@]}
  echo ${fonttype_array[@]}

  
  temp_dir=$(create_temp)

  for i in ${!fonttype_array[@]}; do
    j="${fonttype_array[${i}]}";
    path_type=$(echo "${j}" | sed "s|\s||g")
    name_type=$(echo "${j}" | sed "s|\s|%20|g")
    font_url="$(echo "${base_url}" | sed "s|{{path_type}}|${path_type}|g" )";
    font_url="$(echo "${font_url}" | sed "s|{{name_type}}|${name_type}|g" )";
    font_url="$(echo "${font_url}" | sed "s|{{version}}|${font_version}|g" )";
    echo "Downloading ${font_url}";
    download "${font_url}" "${temp_dir}"
  done
  ${su_bin} /usr/bin/mkdir -p "${font_dir}"
  ${su_bin} /usr/bin/cp -r "${temp_dir}"/* "${font_dir}"/
  echo "Succesfully installed fonts at ${font_dir}";
}



# install JetBrains Mono NF
function install_jetbrains-mono-nf () {
  # Usage: install_fonts <BASE_URL> <FAMILY_DIR> <TYPE_ARRAY> <VERSION> 
  local base_url font_version 
  base_url='https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/Ligatures/{{path_type}}/complete/JetBrains%20Mono%20{{name_type}}%20Nerd%20Font%20Complete.ttf'
  font_version='2.225'
  font_dir='jetbrains-mono'
  type_array='"Regular" "Bold" "Italic" "Bold Italic" "ExtraBold" "ExtraBold Italic"'
  install_fonts ${base_url} ${font_dir} "${type_array}" ${font_version} 
}

# TODO luciorq Install FiraCode NF


# Regenerate font cache
function regenerate_font_cache () {
  fc-cache --force --really-force -r -v
}

# List available fonts and path
function list_fonts () {
  echo ""
  echo "System fonts:"
  fc-list : file

  echo ""
  echo ""
  echo ""
  echo "Kitty fonts:"
  kitty + list-fonts --psnames
}
