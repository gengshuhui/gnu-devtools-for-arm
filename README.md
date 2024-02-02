# README

The below is the README we intend to release onto GitHub as the repo's README file. It is, therefore, entirely written in Markdown. Please do not remove this from its Markdown block.


## Table of Contents
// TODO: Fill this in before releasing.

- [Overview](#overview)
- [Package contents](#package-contents)
- [Supported configurations](#supported-configurations)
- [How to build the toolchains](#how-to-build-the-toolchains)
  - [Create the build environment](#create-the-build-environment)
    - [1) Ensure that you are in a correct shell environment and have all prerequisite packages installed](#1-ensure-that-you-are-in-a-correct-shell-environment-and-have-all-prerequisite-packages-installed)
    - [2) Create folder for build](#2-create-folder-for-build)
    - [3) Obtain the source code of all the relevant GNU projects](#3-obtain-the-source-code-of-all-the-relevant-GNU-projects)
<etc.>


## Overview

**gnu-devtools-for-arm is an open-source project for building, testing and debugging the Arm GNU Toolchain**

The Arm GNU toolchain gets periodically released at [https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)

- gnu-devtools-for-arm is intended as a full package to reproduce our releases from source code and fully build-test-debug using Arm's [Fast Models](https://developer.arm.com/Tools%20and%20Software/Fast%20Models) or, in some cases, [QEMU](https://www.qemu.org/).
- The intended users of this package are:
  - GNU Toolchain developers, who want to build and test the toolchain on models.
  - Users of the Arm GNU Toolchain that wish to compile our releases from Source Code.
- This package is a work-in-progress, it does not currently support all build-host-host-target variants or complete testing of those variants. It is the intention of the GNU team within Arm to further incrementally improve this package until all variants of the Arm GNU Toolchain are reproducible and testable.

## Package contents

**The components of gnu-devtools-for-arm can be categorised as:**

- Build Scripts
- Testing configuration files (DejaGNU site and board files)
- The Fast Model runner script: models-run
- The Fast Models GDB Plugin

The directory layout is as follows:

```
gnu-devtools-for-arm
│   README  --> This file.
│   models-run
│   source-fetch.py
└───build-scripts
│       │   build-gnu-toolchain.sh
│       │   build-baremetal-toolchain.sh
│       │   build-cross-linux-toolchain.sh
└───dejagnu
│       │   <a set of dejagnu test configuration board files>
└───fm-gdb-plugin
        │   <a plugin to Fast Models that enabled target debugging with the toolchain GDB>

```

## Supported configurations

**What configurations are officially supported**

```
| Toolchain [*]                                                                      | Compiling the toolchain   | Testing with Fast Models  | Testing with QEMU         |  fm-gdb-plugin debugging  |
| ---------------------------------------------------------------------------------- | ------------------------- | ------------------------- | ------------------------- | ------------------------- |
| Build                   | Host                    | Target                         |                           |                           |                           |                           |
| ---------------------------------------------------------------------------------- | ------------------------- | ------------------------- | ------------------------- | ------------------------- |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | aarch64-none-elf               |             X             |                           |             X             |                           |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | MORELLO aarch64-none-elf       |             X             |                           |                           |                           |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | MORELLO aarch64-none-linux-gnu |             X             |                           |                           |                           |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-eabi                  |             X             |                           |             X             |                           |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-linux-gnueabihf       |             X             |                           |             X             |                           |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-elf               |             X             |             X             |             X             |             X             |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | MORELLO aarch64-none-elf       |             X             |             X             |                           |             X             |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | MORELLO aarch64-none-linux-gnu |             X             |                           |                           |                           |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-linux-gnu         |             X             |                           |             X             |                           |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64_be-none-linux-gnu      |             X             |                           |             X             |                           |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-eabi                  |             X             |             X             |             X             |             X             |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-linux-gnueabihf       |             X             |                           |             X             |                           |
| macOS (x86_64)          | macOS (x86_64)          | aarch64-none-elf               |             X             |                           |                           |                           |
| macOS (x86_64)          | macOS (x86_64)          | arm-none-eabi                  |             X             |                           |                           |                           |
| macOS (Apple silicon)   | macOS (Apple silicon)   | aarch64-none-elf               |             X             |                           |                           |                           |
| macOS (Apple silicon)   | macOS (Apple silicon)   | arm-none-eabi                  |             X             |                           |                           |                           |
| x86_64-none-linux-gnu   | Windows (mingw, x86)    | aarch64-none-elf               |                                  Not currently supported through these scripts                                |
| x86_64-none-linux-gnu   | Windows (mingw, x86)    | arm-none-eabi                  |                                  Not currently supported through these scripts                                |
| x86_64-none-linux-gnu   | Windows (mingw, x86)    | arm-none-linux-gnueabihf       |                                  Not currently supported through these scripts                                |
| x86_64-none-linux-gnu   | Windows (mingw, x86)    | aarch64-none-linux-gnu         |                                  Not currently supported through these scripts                                |
| ---------------------------------------------------------------------------------- | ------------------------- | ------------------------- | ------------------------- | ------------------------- |
```

[*] This list of toolchains is the full list of currently released Arm GNU Toolchain variants. Other build-host-target combinations are not _officially_ supported by these scripts (they may work out of coincidence, but we do not run them regularly, so they may not work out of the box. Contributions welcome!).


## How to build the toolchains

To build the toolchain, please follow the following process:

### Create the build environment

#### 1) Ensure that you are in a correct shell environment and have all prerequisite packages installed

/////// TODO: blurb about Build machines: Toolchains built on Ubuntu 20.04 won't run on 18.04, etc.: Internally we use CentOS 7 for these builds


A number of packages are needed to build the toolchain. Here is an over-exhaustive list:
For Ubuntu  Linux distros:

```
sudo apt-get update
sudo apt install -y autoconf autogen automake binutils-mingw-w64-i686 binutils-mingw-w64-x86-64 binutils bison build-essential cgdb cmake coreutils curl dblatex dejagnu dh-autoreconf docbook-xsl-doc-html docbook-xsl-doc-pdf docbook-xsl-ns doxygen emacs expect flex flip g++-mingw-w64-i686 g++ gawk gcc-mingw-w64-base gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 gcc-mingw-w64 gcc-multilib gcc gdb gettext gfortran ghostscript git-core golang google-mock keychain less libbz2-dev libc-dev libc6-dev libelf-dev libglib2.0-dev libgmp-dev libgmp3-dev libisl-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libpugixml-dev libreadline-dev libtool libx11-dev libxml2-utils linux-libc-dev make mingw-w64-common mingw-w64-i686-dev mingw-w64-x86-64-dev ninja-build nsis perl php-cli pkg-config libpixman-1-0 qemu-system-arm qemu-user ruby-nokogiri ruby rsync scons shtool swig tcl texinfo texlive-extra-utils texlive-full texlive time transfig valgrind vim wget xsltproc zlib1g-dev 
```

//TODO For MacOS:

(this list is derived from a list of packages we install on internal builders, in the future we hope to minimise this list and/or provide a containerised environment for toolchain building)

If you plan on using source-fetch.py to clone upstream repositories or plan on building a Python-enabled GDB, you will also need a python3 environment:

For Ubuntu Linux distros:

```
sudo apt install python3 python3-pip
```

#### 2) Create folder for build

In a clean folder, create a ./src subfolder and clone this gnu-devtools-for-arm repo into it

```
mkdir src
git clone <GITHUB LINK> ./src/gnu-devtools-for-arm
```

#### 3) Obtain the source code of all the relevant GNU projects

To do this you can:

##### a) Download the Source Code tar from one of our releases

Find the source code of the release you want to rebuild at: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

Place the contents into the ./src folder, such that the ./src folder looks like this:

```
./src
  │
  └───gnu-devtools-for-arm/
  └───binutils-gdb/
  └───binutils-gdb--gdb/
  └───gcc/
  └───glibc/
  └───<etc.>
```

Note 1: This Source Code package does not contain the source code for QEMU, since QEMU does not form part of the Arm GNU Toolchain release. If you wish to test the toolchain using QEMU, you can separately fetch the QEMU source code and place it in `./src/qemu` (e.g. `git clone https://gitlab.com/qemu-project/qemu.git ./src/qemu`)

Note 2: The build scripts contain legacy code for supporting minor components cloog and libffi. This is not currently used by our standard build processes, hence why they have not been documented in these instructions.


##### b) Use source-fetch.py to fetch from upstream repositories

Find the source snapshot manifest SPEC file of the release you want to rebuild at: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

```
cd ./src/gnu-devtools-for-arm
<download the source snapshot manifest SPEC file and place it into the ./src/gnu-devtools-for-arm folder>
python3 source-fetch.py checkout --src-dir=..   <name of manifest file>
cd ../..
```

Sadly, we haven't been consistent in including the following minor tools in the source manifest file:


```
gmp
mpc
mpfr
isl
libexpat
libiconv [OPTIONAL: This is only needed if you plan on building mingw-Windows-hosted toolchains -- this is currently unsupported]
```

These will need to be fetched separately:

```
cd ./src/gcc
./contrib/download_prerequisites  --force --directory=..
cd ..
git clone https://github.com/libexpat/libexpat.git -b R_2_4_8
# Fetch libiconv only if planning on building a mingw-Windows-hosted toolchain -- this is currently unsupported
# wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
# tar -xf libiconv-1.17.tar.gz
```

Note 1: This may result in you using slightly different revisions of these minor toolchain components than those used in Arm's official release. This is _generally_ considered harmless. If you want to use the exact revisions used by Arm, please get them from the Source Tarball of the release.

Note 2: The advantage of this method is that you are fetching git whole repositories of the relevant projects, so can more easily make changes or apply patches (the downside is that this method is much slower to fetch whole repositories, of course!).

Note 3: The source snapshot manifest SPEC file does not code the source code for QEMU, since QEMU does not form part of the Arm GNU Toolchain release. If you wish to test the toolchain using QEMU, you can separately fetch the QEMU source code and place it in `./src/qemu` (e.g. `git clone https://gitlab.com/qemu-project/qemu.git ./src/qemu` )

Note 4: The build scripts contain legacy code for supporting minor components cloog and libffi. This is not currently used by our standard build processes, hence why they have not been documented in these instructions.

After completion of one of the above steps, the full ./src folder should now contain at least the below components (all these manes also support a `-<version_number>` suffix:

```
./src
  │
  └───gnu-devtools-for-arm/
  └───binutils-gdb/
  └───binutils-gdb--gdb/
  └───gcc/                 (may also be named arm-gnu-toolchain-src-snapshot.* if fetched from our source tarball)
  └───glibc/
  └───gmp/
  └───isl/
  └───libexpat/
  └───libiconv/            [OPTIONAL: This is only needed if you plan on building mingw-Windows-hosted toolchains -- this is currently unsupported]
  └───linux/
  └───mpc/
  └───mpfr/
  └───newlib-cygwin/
  └───qemu/                [OPTIONAL: Only needed if you plan on testing with QEMU. Will only be present if manually fetched.]
```

#### 4) Invoking the build scripts

The build scripts can be invoked either directly through the generic wrapper script `build-gnu-toolchain.sh` or with a call to the lower-level scripts `build-baremetal-toolchain.sh` (for baremetal toolchains) and `build-cross-linux-toolchain.sh` (for linux-targetting toolchains).

First, add the `gnu-devtools-for-arm` folder to your PATH environment variable:
```
export PATH="$PWD/src/gnu-devtools-for-arm:$PATH"
```

##### Building a toolchain in debug mode for development
In order to build a toolchain, the build-gnu-toolchain.sh wrapper script is usually used. It has a simple interface for the usual development usecases.

Generally, the calls look like this. Use build-gnu-toolchain --help to discover more command line options.

The build scripts log their various "stages" into a `.stage` file. If they failed in stage `C`, they would normally resume building from stage `C`.

However, the `start` at the end of the command instructs the scripts to always start from the beginning of the build process and recompile any changed components (e.g. restart `A` -> `B` -> `C` -> etc.). This is recommended for development, as it will pick up and recompile any changes in any stages. Other commands that can be used are `clean`, to delete any partially built or fully built toolchains, or, in fact, any named stage within the scripts, like `gcc2`, will instruct the scripts to resume from that stage. `gcc2` is a useful one if making changes to GCC and wanting to iterate quickly (although one full build from `start` should have completed successfully at least once to enable this sort of a "resume frrom gcc2" to succeed).

```
| Toolchain                                                                     |
| ----------------------------------------------------------------------------- |
| Build                   | Host                    | Target                    |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | aarch64-none-elf          | build-gnu-toolchain.sh --target=aarch64-none-elf --debug --debug-target start
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | aarch64_be-none-elf       | build-gnu-toolchain.sh --target=aarch64_be-none-elf --debug --debug-target start
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-eabi             | build-gnu-toolchain.sh --target=arm-none-eabi --aprofile  --rmprofile --debug --debug-target start
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | armeb-none-eabi           | build-gnu-toolchain.sh --target=armeb-none-eabi --aprofile  --rmprofile --debug --debug-target start
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-linux-gnueabihf  | build-gnu-toolchain.sh --target=arm-none-linux-gnueabihf --debug --debug-target start
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | armeb-none-linux-gnueabihf| build-gnu-toolchain.sh --target=armeb-none-linux-gnueabihf --debug --debug-target start
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-elf          | build-gnu-toolchain.sh --target=aarch64-none-elf --debug --debug-target start
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64_be-none-elf       | build-gnu-toolchain.sh --target=aarch64_be-none-elf --debug --debug-target start
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-linux-gnu    | build-gnu-toolchain.sh --target=aarch64-none-linux-gnu --debug --debug-target start
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64_be-none-linux-gnu | build-gnu-toolchain.sh --target=aarch64_be-none-linux-gnu --debug --debug-target start
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-eabi             | build-gnu-toolchain.sh --target=arm-none-eabi --aprofile  --rmprofile --debug --debug-target start
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | armeb-none-eabi           | build-gnu-toolchain.sh --target=armeb-none-eabi --aprofile  --rmprofile --debug --debug-target start
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-linux-gnueabihf  | build-gnu-toolchain.sh --target=arm-none-linux-gnueabihf --debug --debug-target start
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | armeb-none-linux-gnueabihf| build-gnu-toolchain.sh --target=armeb-none-linux-gnueabihf --debug --debug-target start
| macOS (x86_64)          | macOS (x86_64)          | aarch64-none-elf          | build-gnu-toolchain.sh --target=aarch64-none-elf --debug --debug-target start
| macOS (x86_64)          | macOS (x86_64)          | aarch64_be-none-elf       | build-gnu-toolchain.sh --target=aarch64_be-none-elf --debug --debug-target start
| macOS (x86_64)          | macOS (x86_64)          | arm-none-eabi             | build-gnu-toolchain.sh --target=arm-none-eabi --debug --debug-target start
| macOS (x86_64)          | macOS (x86_64)          | armeb-none-eabi           | build-gnu-toolchain.sh --target=armeb-none-eabi --debug --debug-target start
| macOS (Apple silicon)   | macOS (Apple silicon)   | aarch64-none-elf          | build-gnu-toolchain.sh --target=aarch64-none-elf --debug --debug-target start
| macOS (Apple silicon)   | macOS (Apple silicon)   | aarch64_be-none-elf       | build-gnu-toolchain.sh --target=aarch64_be-none-elf --debug --debug-target start
| macOS (Apple silicon)   | macOS (Apple silicon)   | arm-none-eabi             | build-gnu-toolchain.sh --target=arm-none-eabi --debug --debug-target start
| macOS (Apple silicon)   | macOS (Apple silicon)   | armeb-none-eabi           | build-gnu-toolchain.sh --target=armeb-none-eabi --debug --debug-target start
| ----------------------------------------------------------------------------- |
```
Note: Since all those invocations actually use practically the same paramters to all the different targets (or there are parameters whose default is ON, like `--aprofile --rmprofile`), then a lot of these toolchains could also be built in sequence as:
```build-gnu-toolchain.sh --target=arm-none-eabi --target=aarch64-none-elf --target=aarch64_be-none-linux-gnu --debug --debug-target start```

For more complex toolchains, the simple interface of the `build-gnu-toolchain.sh` script isn't enough, so we also need to leverage the command line interfaces of the lower-level scripts `build-baremetal-toolchain.sh` and `build-cross-linux-toolchain.sh`. This can be done by adding `--` to separate the `build-gnu-toolchain.sh` command line options from the `build-baremetal-toolchain.sh` or `build-cross-linux-toolchain.sh` command line options.
One useful skill, especially for `arm-none-eabi` toolchains, which normally take hours to build due to the number of "mutlilibs" needed, is to know how to build a toolchain only with one multilib: this minimises the build time for quick iteration during development.
```
# Run this at least once to completion:
./build-me.sh --target=arm-eabi --with-arch=armv8.1-m.main+mve.fp+fp.dp --disable-multilib -- --config-flags-gcc=--with-float=hard start
# Run this to recompile changes in `gcc2` for quick n easy iteration:
./build-me.sh --target=arm-eabi --with-arch=armv8.1-m.main+mve.fp+fp.dp --disable-multilib -- --config-flags-gcc=--with-float=hard gcc2
```

##### Building a toolchain in release mode

Running the scripts in release mode also requires that some parameters from the lower-level scripts `build-baremetal-toolchain.sh` and `build-cross-linux-toolchain.sh` to be used.
The following are sample invokations as used to build our binary releases:
```
| Toolchain                                                                     |
| ----------------------------------------------------------------------------- |
| Build                   | Host                    | Target                    |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | aarch64-none-elf          | build-gnu-toolchain.sh --target=aarch64-none-elf -- --release --package --enable-gdb-with-python=yes
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-eabi             | build-gnu-toolchain.sh --target=arm-none-eabi --aprofile  --rmprofile -- --release --package --enable-newlib-nano --enable-gdb-with-python=yes
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-linux-gnueabihf  | build-gnu-toolchain.sh --target=arm-none-linux-gnueabihf -- --release --package --enable-gdb-with-python=yes
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-elf          | build-gnu-toolchain.sh --target=aarch64-none-elf -- --release --package --enable-gdb-with-python=yes
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-linux-gnu    | build-gnu-toolchain.sh --target=aarch64-none-linux-gnu -- --release --package --enable-gdb-with-python=yes
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64_be-none-linux-gnu | build-gnu-toolchain.sh --target=aarch64_be-none-linux-gnu -- --release --package --enable-gdb-with-python=yes
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-eabi             | build-gnu-toolchain.sh --target=arm-none-eabi --aprofile  --rmprofile -- --release --package --enable-newlib-nano --enable-gdb-with-python=yes
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-linux-gnueabihf  | build-gnu-toolchain.sh --target=arm-none-linux-gnueabihf -- --release --package --enable-gdb-with-python=yes
| macOS (x86_64)          | macOS (x86_64)          | aarch64-none-elf          | build-gnu-toolchain.sh --target=aarch64-none-elf -- --release --package
| macOS (x86_64)          | macOS (x86_64)          | arm-none-eabi             | build-gnu-toolchain.sh --target=arm-none-eabi --aprofile  --rmprofile -- --release --package --enable-newlib-nano
| macOS (Apple silicon)   | macOS (Apple silicon)   | aarch64-none-elf          | build-gnu-toolchain.sh --target=aarch64-none-elf -- --release --package
| macOS (Apple silicon)   | macOS (Apple silicon)   | arm-none-eabi             | build-gnu-toolchain.sh --target=arm-none-eabi --aprofile  --rmprofile -- --release --package --enable-newlib-nano
| ----------------------------------------------------------------------------- |
```
#### Notes:
* The aarch64-none-elf baremetal toolchains are built with both lp64 and ilp32 multilibs.
* The arm-none-eabi baremetal toolchain with both A-profile and RM-profile multilibs. After building, use `./build-arm-none-eabi/install/bin/arm-none-eabi-gcc --print-multi-lib` to view the whole list.
* You may notice the inconsistency around the --enable-gdb-with-python=yes command line option. GDB with Python support is a known and unresolved inconsistency of the current toolchain-building process. Python scripting support in GDB makes it less out-of-the-box portable between OS versions, but it is a functionality that many people are increasingly relying on. Currently, we enable gdb-with-python for Linux-hosted toolchains, but keep it disabled for MacOS and Windows-hosted toolchains.
* As Arm, we use the `--tag` and `--bugurl` options to the lower-level scripts to tag our releases. **Do not use the same tags as Arm when building your own toolchain. If you wish to add such tags, please use your own branding.**

## How to test the toolchains

In this section we describe how to test all the above --target options (aarch64-none-elf, aarch64-none-linux-gnu, arm-none-eabi, etc.) across different configurations.
All these toolchains are currently cross-compiler toolchains, so they require a model or simulator the target CPU and environment. Supported models are:
* Arm's various Fast Models products: Supported only on x86_64 Linux hosts and some models may require a licence from Arm.
* QEMU: We compile QEMU from source in these scripts, so it should work on x86_64 and Arm 32-bit and 64-bit Linux hosts.

In order to control the testing we provide `site*.exp` files the define a set of testsuite configurations. These then pull in the applicable DejaGNU `board file.exp` for each architecture target.

Testing the baremetal toolchains
The baremetal toolchains can be tested with QEMU (on any Linux host) or with Arm's Fastmodels (on x86_64 Linux hosts).

These toolchains contain different multilibs for different target architectures.
<details open>
<summary>For 32-bit `arm` there are currently 39 multilibs (the number generally increases over time)</summary>
<br>
```
arm/v5te/softfp;@marm@march=armv5te+fp@mfloat-abi=softfp
arm/v5te/hard;@marm@march=armv5te+fp@mfloat-abi=hard
thumb/nofp;@mthumb@mfloat-abi=soft
thumb/v7/nofp;@mthumb@march=armv7@mfloat-abi=soft
thumb/v7+fp/softfp;@mthumb@march=armv7+fp@mfloat-abi=softfp
thumb/v7+fp/hard;@mthumb@march=armv7+fp@mfloat-abi=hard
thumb/v7-r+fp.sp/softfp;@mthumb@march=armv7-r+fp.sp@mfloat-abi=softfp
thumb/v7-r+fp.sp/hard;@mthumb@march=armv7-r+fp.sp@mfloat-abi=hard
thumb/v7-a/nofp;@mthumb@march=armv7-a@mfloat-abi=soft
thumb/v7-a+fp/softfp;@mthumb@march=armv7-a+fp@mfloat-abi=softfp
thumb/v7-a+fp/hard;@mthumb@march=armv7-a+fp@mfloat-abi=hard
thumb/v7-a+simd/softfp;@mthumb@march=armv7-a+simd@mfloat-abi=softfp
thumb/v7-a+simd/hard;@mthumb@march=armv7-a+simd@mfloat-abi=hard
thumb/v7ve+simd/softfp;@mthumb@march=armv7ve+simd@mfloat-abi=softfp
thumb/v7ve+simd/hard;@mthumb@march=armv7ve+simd@mfloat-abi=hard
thumb/v8-a/nofp;@mthumb@march=armv8-a@mfloat-abi=soft
thumb/v8-a+simd/softfp;@mthumb@march=armv8-a+simd@mfloat-abi=softfp
thumb/v8-a+simd/hard;@mthumb@march=armv8-a+simd@mfloat-abi=hard
thumb/v6-m/nofp;@mthumb@march=armv6s-m@mfloat-abi=soft
thumb/v7-m/nofp;@mthumb@march=armv7-m@mfloat-abi=soft
thumb/v7e-m/nofp;@mthumb@march=armv7e-m@mfloat-abi=soft
thumb/v7e-m+fp/softfp;@mthumb@march=armv7e-m+fp@mfloat-abi=softfp
thumb/v7e-m+fp/hard;@mthumb@march=armv7e-m+fp@mfloat-abi=hard
thumb/v7e-m+dp/softfp;@mthumb@march=armv7e-m+fp.dp@mfloat-abi=softfp
thumb/v7e-m+dp/hard;@mthumb@march=armv7e-m+fp.dp@mfloat-abi=hard
thumb/v8-m.base/nofp;@mthumb@march=armv8-m.base@mfloat-abi=soft
thumb/v8-m.main/nofp;@mthumb@march=armv8-m.main@mfloat-abi=soft
thumb/v8-m.main+fp/softfp;@mthumb@march=armv8-m.main+fp@mfloat-abi=softfp
thumb/v8-m.main+fp/hard;@mthumb@march=armv8-m.main+fp@mfloat-abi=hard
thumb/v8-m.main+dp/softfp;@mthumb@march=armv8-m.main+fp.dp@mfloat-abi=softfp
thumb/v8-m.main+dp/hard;@mthumb@march=armv8-m.main+fp.dp@mfloat-abi=hard
thumb/v8.1-m.main+mve/hard;@mthumb@march=armv8.1-m.main+mve@mfloat-abi=hard
thumb/v8.1-m.main+pacbti/bp/nofp;@mthumb@march=armv8.1-m.main+pacbti@mbranch-protection=standard@mfloat-abi=soft
thumb/v8.1-m.main+pacbti+fp/bp/softfp;@mthumb@march=armv8.1-m.main+pacbti+fp@mbranch-protection=standard@mfloat-abi=softfp
thumb/v8.1-m.main+pacbti+fp/bp/hard;@mthumb@march=armv8.1-m.main+pacbti+fp@mbranch-protection=standard@mfloat-abi=hard
thumb/v8.1-m.main+pacbti+dp/bp/softfp;@mthumb@march=armv8.1-m.main+pacbti+fp.dp@mbranch-protection=standard@mfloat-abi=softfp
thumb/v8.1-m.main+pacbti+dp/bp/hard;@mthumb@march=armv8.1-m.main+pacbti+fp.dp@mbranch-protection=standard@mfloat-abi=hard
thumb/v8.1-m.main+pacbti+mve/bp/hard;@mthumb@march=armv8.1-m.main+pacbti+mve@mbranch-protection=standard@mfloat-abi=hard
```
</details>
For `aarch64` there are currently only 2 (LP64 and ILP32).

Techincally, we'd need to test all of the above architecture combinations in Big Endian and Little Endian mode (and even more architecture combinations that aren't reflected in the mulilibs) to ensure correctness of the toolchain, but, especially for 32-bit `arm`, that would be really exhaustive. As such, we usually care about testing:

For 32-bit `arm`
```
-marm/-march=armv7-a/-mfloat-abi=soft
-mthumb/-march=armv8-a+simd/-mfloat-abi=hard
-mthumb/-march=armv6s-m/-mtune=cortex-m0/-mfloat-abi=soft
-mthumb/-march=armv7-m/-mtune=cortex-m3/-mfloat-abi=softfp
-mthumb/-march=armv7e-m+fp.dp/-mtune=cortex-m7/-mfloat-abi=hard
-mthumb/-march=armv8-m.base/-mtune=cortex-m23/-mfloat-abi=soft
-mthumb/-march=armv8-m.main+dsp+fp/-mtune=cortex-m33/-mfloat-abi=hard
-mthumb/-march=armv8.1-m.main+mve.fp+fp.dp/-mtune=cortex-m55/-mfloat-abi=hard
```

For 64-bit `aarch64`:
```
-march=armv8-a
-march=armv8.6-a+sve
```

Note 1: We generally don't test or track Big Endian configurations.
Note 2: The `aarch64` ILP32 configuration, although it exists as a multilib, is also not regularly tested or tracked.
Note 3: Internally this testing is done with Fastmodels, but doing it with QEMU is equally valid.

##### Testing with QEMU: ensure you have a QEMU binary

Ensure that the toolchain you built above did additionally build a binary of QEMU: This should have happened if you had a `qemu` folder in your `./src` folder and the QEMU binary should be found under `./build-<target>/install-qemu/bin/qemu<arm/aarch64>`.
If you don't have a version of QEMU under that path, ensure that you have the QEMU source in the aforementioned location and re-run the build script, with the same parameters as before, but with the `start` command at the end of the invokation.

##### Testing with Fastmodels: ensure you have the correct models, that the scripts know where to find them, and that you have the correct licence rights to the models

Before attempting this, you will need to set up these `board files` to point to a locally installed version of Fastmodels. **Take a look inside each board file and make the appropriate changes needed to point to a valid Fastmodels for the configuration under test**
//TODO: more details on what model is needed in each case....

##### Testing many configurations with site*.exp

We've provided a `site-exhaustive-*.exp` file that can be used to test all the above configurations (and more) in one go. This will take many hours, but do feel free to create derivatives of `site-exhaustive-*.exp` with fewer test sets.
To run this sort of testing, simply add `--dejagnu-site=<site.exp filename>.exp` to the `build-gnu-toolchain.sh` invocation and add `check` (to test all components) or `check-gcc` (to only test the main compiler) as the command, e.g.:
```
build-gnu-toolchain.sh --target=arm-none-eabi --debug --debug-target --dejagnu-site=site-exhaustive-<model>.exp check
```
Note 1: the cross-linux toolchains `*-linux-gnu*` cannot be tested with Fastmodels, so **even if the Fastmodels site.exp file is given, the scripts will still attempt to run on QEMU**.
Note 2: If testing with Fastmodels, **any board file you use needs to have been modified to point to a valid local installation of Fastmodels**


#####  Testing a single configuration with a single target board file

This is similar to using a site*.exp file, except that the `--target-board` parameter must be given and **appropriate RUNTESTFLAGS must be set.**
```
RUNESTFLAGS="-mthumb/-march=armv8.1-m.main+mve.fp+fp.dp/-mtune=cortex-m55/-mfloat-abi=hard" build-gnu-toolchain.sh --target=arm-none-eabi --debug --debug-target --target-board=arm-eabi-mps2-armv8.1-m.main.exp check

```

##### Testing native toolchains
Building native toolchains through these scripts isn't currently supported.

##### GDB testing:
GDB testing is generally disabled. We haven't monitored the GDB testsuite through these scripts for many years. This needs proper debugging before re-enabling (also note that GDB testing only works with QEMU as the simulator, not with Fastmodels)

## How to debug target binaries running on Fast Models with the Fast Models GDB Plugin
// TODO: write a bit more here:
```models-run --fm-gdb-plugin=<PATH TO BUILT PLUGIN> <rest of models-run invocation>```
Take a look inside the applicable DejaGNU board file to figure out what command line options you may need to pass to models-run (usually `--model` and `--arch`).


## How to debug target binaries running on QEMU
See (https://qemu-project.gitlab.io/qemu/system/gdb.html)[https://qemu-project.gitlab.io/qemu/system/gdb.html] .
Take a look inside the applicable DejaGNU board file to figure out which QEMU binary (qemu-aarch64, qemu-aarch64_be, qemu-arm, etc.) and what command line options you may need (usually just a `-cpu` option).

# Licence
// TODO
Licence will be maybe BSD or MIT... TBD
Note that for GitHUB this needs be an explicit LICENCE file.
