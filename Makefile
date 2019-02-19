PWD := $(shell pwd)
GIT_COMMIT:=$(shell git rev-parse --verify HEAD --short=7)
ROOTFS?="${PWD}/rootfs"
ROOTFS_TGT?=$(shell uname -m)-project_v-linux-gnu
MODULE_DIR?="${PWD}/modules"
CPU_JOBS=$(shell grep -c ^processor /proc/cpuinfo)
## @hostnamectl | grep "Chassis: vm" || echo "Not in a VM..." && exit 1

## Main Targets ##

.PHONY: clean
clean:
	@echo "Cleaning..."
	rm -rf ./modules/**/pkg
	rm -rf ./modules/**/src
	rm -rf ./modules/*/*.tar.xz
	rm -rf ./modules/*/*.tar.gz
	rm -rf ./docker
	rm -rf ./artifacts
	rm -rf ./rootfs
	rm -f ./builder.env
	@echo "Cleaning symbolic links..."
	rm -f /tools

.PHONY: prep-local
prep-local:
	@echo "Prepping the local rootfs build enviroment..."
	@echo "Creating enviroment file..."
	echo "set +h" > builder.env
	echo "umask 022" >> builder.env
	echo "MODULE_DIR=${MODULE_DIR}" >> builder.env
	echo "ROOTFS=${ROOTFS}" >> builder.env
	echo "LC_ALL=POSIX" >> builder.env
	echo 'ROOTFS_TGT=$(uname -m)-project_v-linux-gnu' >> builder.env
	echo "PATH=/tools/bin:/bin:/usr/bin:/sbin:/usr/local/bin" >> builder.env
	echo "export ROOTFS LC_ALL ROOTFS_TGT PATH" >> builder.env

.PHONY: install
install:
	@echo "Creating project-v dirs..."
	mkdir -p /usr/share/project-v/
	@echo "Installing shell libraries..."
	cp lib/libmkmod.sh /usr/share/project-v/libmkmod.sh
	cp lib/libcommon.sh /usr/share/project-v/libcommon.sh
	@echo "Installing shell commands..."
	chmod +x scripts/mkmod
	chmod +x scripts/addtmpl
	cp scripts/mkmod /usr/local/bin/mkmod
	cp scripts/addtmpl /usr/local/bin/addtmpl

.PHONY: docker
docker:
	@echo "Creating docker images..."
	docker build --build-arg BRANCH=master -f ./conf/docker/Dockerfile.build-toolchain -t build-toolchain:master
	docker build --build-arg BRANCH=dev -f ./conf/docker/Dockerfile.build-toolchain -t build-toolchain:dev
	docker build --build-arg BRANCH=master -f ./conf/docker/Dockerfile.build-base-os -t build-base-os:master
	docker build --build-arg BRANCH=dev -f ./conf/docker/Dockerfile.build-base-os -t build-base-os:dev

.PHONY: docker-pipeline
docker-pipeline:
	@echo "Creating docker images for pipelines..."
	docker build --build-arg BRANCH=master -f ./conf/docker/Dockerfile.build-toolchain -t build-toolchain:master
	docker build --build-arg BRANCH=dev -f ./conf/docker/Dockerfile.build-toolchain -t build-toolchain:dev
	docker build --build-arg BRANCH=master -f ./conf/docker/Dockerfile.build-base-os -t build-base-os:master
	docker build --build-arg BRANCH=dev -f ./conf/docker/Dockerfile.build-base-os -t build-base-os:dev

.PHONY: check
check:
	@echo "Checking host build system..."
	chmod +x ./scripts/checkhostsystem
	./scripts/checkhostsystem
