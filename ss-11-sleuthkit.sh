#!/bin/bash

echo "Installing Sleuthkit."

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi


# Dependencies
yum -y install afflib afflib-devel afftools libewf-devel ewftools libtool gcc-c++ libstd-c++

# Clone and compile Sleuthkit
cd /tmp
git clone https://github.com/sleuthkit/sleuthkit.git
cd sleuthkit && ./bootstrap && ./configure && make && make install && ldconfig
