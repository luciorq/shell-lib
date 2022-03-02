

wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.2.tar.gz
gunzip -c openmpi-4.1.2.tar.gz | tar xf -


cd openmpi-4.1.2

./configure --prefix=/usr/local


sudo make all install
