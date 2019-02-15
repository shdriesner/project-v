#
#   Copyright (c) 2019 John Unland
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# libmkmod library helps facilitate create of modules (Collection of packages). Mainly used with mkmod command.
#

set -e

## Common colors
RESTORE=$(echo -en '\033[0m') # This will terminate the color variables.
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')
WHITE=$(echo -en '\033[01;37m')

## Common functions

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
print_warn() {
    if [ "$1" == "" ] ; then
        echo "No warning message has been passed... Please fix this."
        exit 99
    fi
    
    echo "${YELLOW}=====> $1 ${RESTORE}"
}

# print_warn prints yellow text
print_ok() {
    if [ "$1" == "" ] ; then
        echo "No OK message has been passed... Please fix this."
        exit 99
    fi
    
    echo "${GREEN}=====> $1 ${RESTORE}"
}

# download_agent helps with downloading a source using diffrent agents like curl or wget.
# Prereq: Need to source a BUILDPKG file before running
# Ex. download_agent <URL> <Output Dir.> <Output filename> <Agent type>
download_agent() {
    local LEN LCHAR DEST_DIR
    if [ "$1" == "" ] ; then
        print_err "No download url has been specified in download_agent. Exiting."
        exit 1
    fi
    
    if [ "$2" == "" ] ; then
        print_err "No destination directory has been specified in setup_source. Exiting."
        exit 1
    fi
    
    if [ ! -d "$2" ]; then
        print_err "The $2 destination directory does not exist or is not a directory. Exiting."
        exit 1
    fi
    
    if [ "$3" == "" ] ; then
        print_err "No output filename has been specified in download_agent. Exiting."
        exit 1
    fi
    
    if [ "$4" == "" ] ; then
        print_err "No download agent has been specified in download_agent. Exiting."
        exit 1
    fi
    
    DEST_DIR=${2%/}
    
    case "$4" in
        curl)
            print_info "Getting $1 -- $DEST_DIR/$3" && sleep 1
            curl -C - --fail --ftp-pasv --retry 4 --retry-delay 5 -L "$1" --output "$DEST_DIR/$3"
            print_ok "Placed file into $DEST_DIR/$3"
        ;;
        wget)
            print_err "wget agent hasn't been implmented yet."
            exit 99
        ;;
        *)
            print_err "$4 is not a valid download agent."
            exit 1
        ;;
    esac
    
}

# extract_dl_file extracts a file and places it within a directory.
extract_dl_file() {
    local FILE FILE_TYPE
    
    if [ "$1" == "" ] ; then
        print_err "No file has been specified in extract_file. Exiting."
        exit 1
    fi
    
    if [ ! -f "$1" ] ; then
        print_err "Specified file $1 is not a file in extract_file. Exiting."
        exit 1
    fi
    
    if [ "$2" == "" ] ; then
        print_err "No destination directory has been specified in extract_file. Exiting."
        exit 1
    fi
    
    FILE=$1
    FILE_TYPE=$(file -bizL -- "$FILE")
    
    print_info "Attempting to unarchive downloaded file"
    
    case "$FILE_TYPE" in
        *application/x-tar*|*application/zip*|*application/x-zip*|*application/x-cpio*)
            tar -xaf "$FILE" --strip-components 1 --directory $2 2>/dev/null
            print_ok "Done unarchiving $FILE into $2"
        ;;
        *application/x-gzip*)
            bzip2 -dk "$FILE" > $2
            print_ok "Done unarchiving $FILE into $2"
        ;;
        *application/x-bzip*)
            bzip2 -dk "$FILE" > $2
            print_ok "Done unarchiving $FILE into $2"
        ;;
        *application/x-xz*)
            unxz  "$FILE"
            print_ok "Done unarchiving $FILE into $2"
        ;;
        *)
            print_err "Looks like $FILE is not a archive -- $FILE_TYPE"
            exit 2
        ;;
    esac
}

# setup_source Downloads, moves, and unpacks files into the sources directory.
# Prereq: Need to source a BUILDPKG file before running
# Ex. setup_source <Destination dir> <BUILDPKG dir> <DL Agent>
setup_source() {
    local FILE FILENAME LEN LCHAR DEST_DIR BUILDPKG_DIR PKG
    
    CHECK='(https|http|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]://'
    if [ "$1" == "" ] ; then
        print_err "No destination directory has been specified in setup_source. Exiting."
        exit 1
    fi
    
    if [ ! -d "$1" ]; then
        print_err "The $1 destination directory does not exist or is not a directory. Exiting."
        exit 1
    fi
    
    if [ "$2" == "" ] ; then
        print_err "No BUILDPKG directory has been specified in setup_source. Exiting."
        exit 1
    fi
    
    DEST_DIR=${1%/}
    BUILDPKG_DIR=${2%/} ## Full path to the package in a module.
    DL_AGENT=$3
    
    source $BUILDPKG_DIR/BUILDPKG
    
    for FILE in "${source[@]}"; do
        print_info "Checking $FILE source"
        
        if [[ $FILE =~ $CHECK ]] ; then
            FILENAME=$(echo "$FILE" | awk -F '::' '{print $1}')
        else
            FILENAME=$(basename "$FILE")
        fi
        
        print_info "Creating package directory -- $DEST_DIR/$pkgname"
        mkdir -p "$DEST_DIR/$pkgname"
        print_info "Copying BUILDPKG to package directory -- $pkgname"
        cp $BUILDPKG_DIR/BUILDPKG $DEST_DIR/$pkgname/BUILDPKG
        
        if [ "$FILENAME" != "$FILE" ] ; then
            download_agent "$FILE" "$DEST_DIR/$pkgname" "$FILENAME" "$DL_AGENT"
            print_ok "Download complete for $FILE"
            extract_dl_file "$DEST_DIR/$pkgname/$FILENAME" "$DEST_DIR/$pkgname"
        else
            print_info "Placing $BUILDPKG_DIR/$FILE into $DEST_DIR/$pkgname/"
            cp "$BUILDPKG_DIR/$FILE" "$DEST_DIR/$pkgname/"
        fi
    done
}

# load_buildpkg is a helper fucntion to load a buildpkg file within a module.
load_buildpkg() {

    if [ "$1" == "" ] ; then
        print_err "No BUILDPKG directory has been specified in load_buildpkg. Exiting."
        exit 1
    fi

    ## Remove trailing slash
    BUILDPKG_DIR=${1%/}

    if [ ! -f "$BUILDPKG_DIR/BUILDPKG" ] ; then
        print_err "BUILDPKG does not exist in $BUILDPKG_DIR"
        exit 1
    fi
    print_info "    "
    print_info "Loading $BUILDPKG_DIR/BUILDPKG"
    print_info "    "

    source "$BUILDPKG_DIR/BUILDPKG"

    print_ok "Done loading $BUILDPKG_DIR/BUILDPKG"
}

check_chroot_with_tools() {
  local CHROOT_DIR PKG_DIR
  
  CHROOT_DIR=$1
  PKG_DIR=$2
  
  if [ -z "$CHROOT_DIR" ] ; then
      print_err "No chroot parameter has been passed."
      exit 1
  fi
  
  if [ ! -d "$CHROOT_DIR" ] ; then
      print_err "Chroot parameter points to a non-directory."
      exit 1
  fi
  
  if [ -z "$PKG_DIR" ] ; then
      print_err "No package directory has been passed."
      exit 1
  fi
  
  if [ -d "$CHROOT_DIR/$PKG_DIR" ] ; then
      print_err "Package directory does not exist inside chroot directory. -- $CHROOT_DIR/$PKG_DIR"
      exit 1
  fi
}

# do_build_chroot_with_tools is used when you the root filesystem has a toolchain present. This is configured with the standard LFS
# bash lookup path.
# do_build_chroot_with_tools <dir of chroot> <name of pkg> 
do_build_chroot_with_tools() {
  local CHROOT_DIR PKG_DIR

  CHROOT_DIR=$1
  PKG_DIR=$2
  
  check_chroot_with_tools $CHROOT_DIR $PKG_DIR
  
  print_info "Going to build inside /sources/$PKG_DIR"
  
  chroot "$CHROOT_DIR" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(project-v chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
	/tools/bin/bash -c "cd /sources/$PKG_DIR && . ./BUILDPKG && build"
}
