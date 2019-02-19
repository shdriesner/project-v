<p align="center">
  <img alt="Project V Logo" src="https://raw.githubusercontent.com/junland/miniature-journey/master/images/logo_transparent_github.png" />
</p>

# Project V 
[![Build Status](https://dev.azure.com/junlandfoss/Github/_apis/build/status/junland.project-v?branchName=master)](https://dev.azure.com/junlandfoss/Github/_build/latest?definitionId=5&branchName=master)

`Project V` is very basic build system to build Linux From Scratch.

## Stuff to keep in mind

* While the OS does not rely on singular packages to add software, there is a package format that is used to build the OS and keep track of each piece that makes up a OS. However that format shouldn't be viewable from the system. Following Clear Linux example, all packages will be group into `modules` where all dependinces are resolved within each individual `module`

* This project is based off of Linux From Scratch.

## Getting started

For the host system you just need the bog standard Ubuntu, Fedora, CentOS, Arch, or Gentoo with a couple of packages installed.

For DEB based systems:
```
autoconf-archive curl bison g++ xz-utils libtool automake pkg-config perl libtool m4 autoconf gawk build-essential texinfo tree git sudo p7zip lzma-dev lzma
```

For RPM based systems:
```
'Development Tools' package group
```

It's highly recommended that you use a Vagrant VM (I have included a Vagrant file with all dependencies installed.) or a Docker image. (This has also been included in this project)

### Vagrant
1. Go into project folder.
```
cd project-v/
```
2. Provision Vagrant VM.
```
vagrant up
```
3. Login into Vagrant VM.
```
vagrant ssh
```
4. Change into project dir.
```
cd project-v
```
5. Prep the enviroment.
```
make prep-local
```
6. Install libraries, scripts, and commands.
```
make install
```
7. Source new enviroment file.
```
. ./builder.env
```

8. Build the toolchain first.
```
ROOTFS=/home/vagrant/project-v/rootfs ROOTFS_TGT=x86_64-project_v-linux-gnu MODULE_DIR=/home/vagrant/project-v/modules mkmod tools
```

_Note that file paths for `ROOTFS` and `MODULE_DIR` need to be the full paths._


### Docker
1. Go into project folder.
```
cd project-v/
```
2. Make the docker images.
```
make docker
```
3. Build the toolchain.
```
docker run build-toolchain:<BRANCH>
```
4. Build the base-os. 
```
docker run --privileged build-base-os:<BRANCH>
```

_`build-base-os` will take a prebuilt toolchain from Github to build the base-os module._

From invokeing `docker run` the image should clone the repo and start building the tools and base operating system. After it's built you will have to find the container ID and use `docker cp` to copy the `/work` directory to pull the project and rootfs onto your host machine.

## License

This project is licensed under the GPLv2 License - see the [LICENSE.md](LICENSE.md) file for details.
