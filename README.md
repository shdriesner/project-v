<p align="center">
  <img alt="Project V Logo" src="https://raw.githubusercontent.com/junland/miniature-journey/master/images/logo_transparent_github.png" />
</p>

# Project V 
[![Build Status](https://dev.azure.com/junlandfoss/Github/_apis/build/status/junland.project-v?branchName=master)](https://dev.azure.com/junlandfoss/Github/_build/latest?definitionId=5&branchName=master)

`Project V` is a project in creating a distributed systems server operating system from [scratch](http://www.linuxfromscratch.org/). This project will be looking into deriving / building upon existing technologies and techniques from other distributions such as CoreOS, Intel Clear Linux, openSUSE Kubic and Fedora / CentOS Atomic. Using these ideas, I hope to create a platform that can bridge the gap between traditional packaged and atomic update based distros while also looking towards the future of lightweight distributed-system oriented operating systems.

_This repo will be the main staging ground for the whole project, down the road I would like to seperate this out into seperate repos under a organization. (Lot eaiser to maintain with one repo at the moment.)_

## In-Progress / In-Testing Features

* Monolithic dependancy resolution: One script to handle all packages within a module.

## Proposed Ideas / Features

* A/B backup and restore roots using `chroot`. Similar to [ostree](https://ostree.readthedocs.io/en/latest/).

* Swupd like [upgrades](https://clearlinux.org/documentation/clear-linux/concepts/swupd-about#updating).

* Swupd like modularity. (i.e. [bundles](https://clearlinux.org/documentation/clear-linux/concepts/bundles-about))

* Continous builds via Arch Linux's `PKGBUILD` format.

* Docker / Container's as the main mode of deploying and running applications.

* Rolling distribution.

* Look into Unikernels as the next generation of application deployment.

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
docker run build-toolchain ## Master Branch
```
or
```
docker run build-toolchain dev ## Dev Branch
```
4. Build the base-os. 
```
docker run --privileged build-base-os ## Master Branch
```
or
```
docker run --privileged build-base-os -b dev ## Dev Branch
```

_`build-base-os` will take a prebuilt toolchain from Github to build the base-os module._

From invokeing `docker run` the image should clone the repo and start building the tools and base operating system. After it's built you will have to find the container ID and use `docker cp` to copy the `/work` directory to pull the project and rootfs onto your host machine.

## Contributing

Your contributions are always welcome! Below is a list of things that I may need help with:

```
- Pull Requests (Weather that be code, documentation, spelling corrections, etc.)
- Spread the word!
- Post a bug (Issue Tracker).
- Post a suggestion (Issue Tracker).
- Suggest a new name for the OS (I wanna have a proper name for the OS.)
- Pictures, branding, logos, flyers, wallpapers.
```

## License

This project is licensed under the GPLv2 License - see the [LICENSE.md](LICENSE.md) file for details.

## FAQ
**Q: What makes this unique from all the other server distributions?**

**A:** See [Proposed Ideas / Features](https://github.com/junland/project-v#proposed-ideas--features)

**Q: Why not just use [some mainstream distro] as base?**

**A:** I tried to use Debian, CentOS, Alpine, etc. but some of the tools had out of date documentation and just finding information on these tools was a bit of pain. It felt I was going down the path that most people go when they want there own distribution. Eventually I ended up just going with Linux From Scratch as a base since the base system was pretty simple and it could help me prototype specific OS features faster.

**Q: What goals have you set for your project?**

**A:** For now I have landed on these 3 goals:
```
0. Get a light base operating system going.
1. Gather a SDK of all the build tools needed so that anyone can build the OS with little to no effort.
2. Work on optimizing each indivdual package and optimize for space.
```

**Q: What distro has inspired this project?**

**A:** Mostly the Clear Linux Project by Intel and CoreOS distributions, I'd like to adapt some of there features into this project.
