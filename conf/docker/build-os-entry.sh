#!/bin/bash

# colors
RESTORE=$(echo -en '\033[0m') # This will terminate the color variables.
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
WHITE=$(echo -en '\033[01;37m')

# print_info prints normal text
print_info() {
        if [ "$1"	== "" ] ; then
           echo "No informational message has been passed... Please fix this."
           exit 99
        fi
        
        echo "=====> $1"
}

# print_err prints red text
print_err() {
        if [ "$1" == "" ] ; then
           echo "No error message has been passed... Please fix this."
           exit 99
        fi
        
        echo "${RED}=====> $1 ${RESTORE}"
}

# print_warn prints yellow text
print_ok() {
        if [ "$1" == "" ] ; then
           echo "No OK message has been passed... Please fix this."
           exit 99
        fi
        
        echo "${GREEN}=====> $1 ${RESTORE}"
}

prep_env () {
    print_info "Getting master github repo..."

    git clone https://github.com/junland/project-v.git

    print_ok "Complete"

    sleep 5

    cd project-v

    if [ $1 == "dev" ] ; then
      print_info "Checking out dev branch"
      git checkout dev
    fi

    make install

    make clean

    make check

    make prep-pipeline

    print_ok "Done."
}

prep_env $1

## make toolchain-pipeline

CPU_JOBS=$(grep -c ^processor /proc/cpuinfo)
echo $CPU_JOBS
export MAKEFLAGS="-j$CPU_JOBS"

print_info "Setting MAKEFLAGS for $MAKEFLAGS"

ROOTFS=/work/project-v/rootfs ROOTFS_TGT=x86_64-project_v-linux-gnu MODULE_DIR=/work/project-v/modules mkmod tools

## ROOTFS=/work/project-v/rootfs ROOTFS_TGT=x86_64-project_v-linux-gnu MODULE_DIR=/work/project-v/modules mkmod base-os
