#!/usr/bin/env bash

wget https://sourceforge.net/projects/subread/files/subread-2.0.3/subread-2.0.3-Linux-x86_64.tar.gz
sudo mkdir -p /opt/apps/bioinfo/subread
sudo mv subread-2.0.3-Linux-x86_64.tar.gz /opt/apps/bioinfo/subread/
cd /opt/apps/bioinfo/subread/
sudo tar xvf subread-2.0.3-Linux-x86_64.tar.gz
sudo rm subread-2.0.3-Linux-x86_64.tar.gz

base_path='/opt/apps/bioinfo/subread/subread-2.0.3-Linux-x86_64'

for exec_name in $(/usr/bin/ls -A1 ${base_path}/bin/ | grep -v utilities); do
  sudo /usr/bin/ln -sf ${base_path}/bin/${exec_name} /usr/local/bin/${exec_name};
done

$(which featureCounts) -v;


