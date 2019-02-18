#!/bin/bash

# Set default variables.
OPTIND=1
BRANCH="master"
TOOLCHAIN_URL="https://github.com/junland/project-v/releases/download/0.0.1-alpha/x86_64-project_v-linux-gnu.tar.gz"

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

usage() {
        echo "build-base-os usage: build-base-os [-t TOOLCHAIN URL] [-b BRANCH NAME]" >&2
        exit 1
}

while getopts 'ht:b:' OPTION; do
  case "$OPTION" in
    b)
      BRANCH="$OPTARG"
      ;;
    t)
      TOOLCHAIN_URL="$OPTARG"
      CHECK='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
      if [[ $TOOLCHAIN_URL =~ $CHECK ]]
      then 
          print_ok "External toolchain looks valid -- $TOOLCHAIN_URL"
      else
          print_err "$OPTARG doesn't look like a URL"
          exit 1
      fi
      ;;
    h)
      usage
      ;;
    ?)
      usage
      ;;
  esac
done
shift "$(($OPTIND -1))"

print_info "$BRANCH branch selected"

prep_env () {
    cd /work
    
    mkdir project-v
    
    cd project-v

    print_info "Downloading $TOOLCHAIN_URL"
    
    wget -c $TOOLCHAIN_URL -O toolchain.compressed
    
    print_info "Getting Project-V Repo"

    cd /work/project-v

    git init .

    git remote add origin https://github.com/junland/project-v

    git pull

    git pull origin master

    git pull

    if [ $BRANCH == "dev" ] ; then
      print_info "Checking out dev branch"
      git checkout dev
    fi
    
    make install

    make clean

    make check

    make prep-pipeline

    print_info "Linking tools to host system... (This can be deleted later)"
    mkdir -p "/work/project-v/rootfs/tools"
    ln -sv "/work/project-v/rootfs/tools" /

    print_info "Unpacking toolchain"

    tar -xavf ./toolchain.compressed -C ./rootfs/tools

    print_ok "Done."
}

run() {
    # Set any variables here.
    CPU_JOBS=$(grep -c ^processor /proc/cpuinfo)
    echo $CPU_JOBS
    export MAKEFLAGS="-j$CPU_JOBS"

    print_info "Setting MAKEFLAGS for $MAKEFLAGS"

    # Source the newly created env from make-pipeline.

    . ./builder.env

    # Start the build process.

    FORCE_UNSAFE_CONFIGURE=1 ROOTFS=/work/project-v/rootfs ROOTFS_TGT=x86_64-project_v-linux-gnu MODULE_DIR=/work/project-v/modules mkmod base-os
}

prep_env

run
