# README

# Table of Contents
	* [Overview](#Overview)
	* [Package contents](#Package-contents)
	* [Supported configurations](#Supported-configurations)
	* [How to build the toolchains](#How-to-build-the-toolchains)
		* [Create the build environment](#Create-the-build-environment)
			* [Install prerequisite packages](#Install-prerequisite-packages)
			* [Create folder for build](#Create-folder-for-build)
			* [Obtain the source code of all the relevant GNU projects](#Obtain-the-source-code-of-all-the-relevant-GNU-projects)
			* [Invoking the build scripts](#Invoking-the-build-scripts)
		* [Known build issues](#Known-build-issues)
	* [How to test the toolchains (Not supported yet)](#How-to-test-the-toolchains-(Not-supported-yet))
    * [Licence](#Licence)

## Overview

**gnu-devtools-for-arm is an open-source project for building, testing and debugging the Arm GNU Toolchain**

> At this time, the scripts don't implement the testing process yet, it will be introduced soon in a future release.

The Arm GNU toolchain gets periodically released at [https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)

- gnu-devtools-for-arm provides users access to build scripts that produce toolchains with similar configuration and build of the Arm GNU Toolchain releases. The scripts do not currently support certain features such as regression testing and binary signing.
- The intended users of this package are:
  - GNU Toolchain developers, who want to build and test the toolchain on models (testing not supported yet).
  - Users of the Arm GNU Toolchain that wish to build toolchains similar to Arm GNU Toolchain releases, from Source Code.
- This package is a work-in-progress, it does not currently support all build-host-target variants or complete testing of those variants.

## Package contents

**The components of gnu-devtools-for-arm can be categorised as:**

- Build Scripts
- Testing configuration files (DejaGNU site and board files)
- The Fast Model runner script: models-run
- The Fast Models GDB Plugin

The directory layout is as follows:

```
gnu-devtools-for-arm
├── README.md  --> This file.
├── build-baremetal-toolchain.sh
├── build-cross-linux-toolchain.sh
├── build-gnu-toolchain.sh
├── extras
│   └── source-fetch.py
└── utilities.sh
```

## Supported configurations

**What configurations are officially supported**

The following table shows the list of combinations that work for building the toolchain:


```
| Toolchain [*]                                                                      |    Building   |
| ---------------------------------------------------------------------------------- | ------------- |
| Build                   | Host                    | Target                         |               |
| ---------------------------------------------------------------------------------- | --------------|
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | aarch64-none-elf               |       x       |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | MORELLO aarch64-none-elf       |       x       |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | MORELLO aarch64-none-linux-gnu |       x       |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-eabi                  |       x       |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-linux-gnueabihf       |       x       |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-elf               |       x       |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | MORELLO aarch64-none-elf       |       x       |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | MORELLO aarch64-none-linux-gnu |       x       |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-linux-gnu         |       x       |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64_be-none-linux-gnu      |       x       |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-eabi                  |       x       |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-linux-gnueabihf       |       x       |
| macOS (x86_64)          | macOS (x86_64)          | aarch64-none-elf               |       x       |
| macOS (x86_64)          | macOS (x86_64)          | arm-none-eabi                  |       x       |
| macOS (Apple silicon)   | macOS (Apple silicon)   | aarch64-none-elf               |       x       |
| macOS (Apple silicon)   | macOS (Apple silicon)   | arm-none-eabi                  |       x       |
| x86_64-none-linux-gnu   | Windows (mingw, x86)    | aarch64-none-elf               | Not supported |
| x86_64-none-linux-gnu   | Windows (mingw, x86)    | arm-none-eabi                  | Not supported |
| x86_64-none-linux-gnu   | Windows (mingw, x86)    | arm-none-linux-gnueabihf       | Not supported |
| x86_64-none-linux-gnu   | Windows (mingw, x86)    | aarch64-none-linux-gnu         | Not supported |
| ---------------------------------------------------------------------------------- |---------------|
```

[*] This list of toolchains is the full list of currently released Arm GNU Toolchain variants. Other build-host-target combinations are not supported by these scripts (Contributions welcome!).


## How to build the toolchains

To build the toolchain, please follow the following process:

### Create the build environment

#### Install prerequisite packages

The GNU Toolchain binaries that are released by Arm are built in relatively old OS environments, like CentOS7 or Ubuntu 18.04. This is particularly important as to ensure the highest backward compatibility with old glibc versions.
The toolchain binaries produced by these scripts will only work on the same (or newer) OS version on which the scripts are run.

A number of packages are needed to build the toolchain. If source-fetch.py is being used to clone upstream repositories or Python-enabled GDB is needed, a python3 environment will be required.


##### For Ubuntu Linux distros

Here is a list of packages that might be required:

```
sudo apt-get update
sudo apt install -y \
  autoconf autogen automake \
  binutils-mingw-w64-i686 binutils-mingw-w64-x86-64 binutils bison build-essential \
  cgdb cmake coreutils curl \
  dblatex dejagnu dh-autoreconf docbook-xsl-doc-html docbook-xsl-doc-pdf docbook-xsl-ns doxygen \
  emacs expect \
  flex flip \
  g++-mingw-w64-i686 g++ gawk gcc-mingw-w64-base gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 gcc-mingw-w64 gcc-multilib gcc gdb gettext gfortran ghostscript git-core golang google-mock \
  keychain \
  less libbz2-dev libc-dev libc6-dev libelf-dev libglib2.0-dev libgmp-dev libgmp3-dev libisl-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libpugixml-dev libreadline-dev libtool libx11-dev libxml2-utils linux-libc-dev \
  make mingw-w64-common mingw-w64-i686-dev mingw-w64-x86-64-dev \
  ninja-build nsis \
  perl php-cli pkg-config python3 python3-venv \
  libpixman-1-0 \
  qemu-system-arm qemu-user \
  ruby-nokogiri ruby rsync \
  scons shtool swig \
  tcl texinfo texlive-extra-utils texlive-full texlive time transfig \
  valgrind vim \
  wget \
  xsltproc \
  zlib1g-dev
```

##### For macOS 11(Big Sur) or higher

Provided that xcode is installed, run, if needed:

```
sudo xcode-select --install
```

With brew pre-configured, install the additional packages:

```
brew install \
    autoconf automake \
    bash bison \
    ca-certificates cmake coreutils \
    deja-gnu docker dockutil \
    fontconfig freetype \
    gdbm gettext ghostscript git gmp gnu-getopt gnu-sed gnu-tar \
    htop \
    iperf3 \
    jbig2dec jpeg \
    libevent libidn libidn2 libpng libtiff libtool libunistring little-cms2 \
    m4 mactex-no-gui make mpdecimal \
    ncurses \
    openjpeg openssl@1.1 openssl@3 \
    pcre2 pstree python@3.10 \
    readline \
    six smartmontools sqlite ssh-copy-id \
    tmux \
    utf8proc \
    virtualenv \
    watch wget \
    xz
```

Note: a dependency in the current binutils version requires texinfo@6.x installed, not older, not newer. There are two possible cases, depending on the macOS version in use.
For macOS Big Sur this version is known to work correctly:

> brew install texinfo@6.5

In recent OS versions (eg: macOS Sonoma 14.3.1) brew only provides texinfo@7.x and a custom build of the package is required:

```
export PKG=texinfo
export PKGVER=6.8
brew uninstall $PKG

brew tap-new $USER/local-$PKG

brew tap --force homebrew/core

brew extract --version=$PKGVER $PKG $USER/local-$PKG
brew install $PKG@$PKGVER
```



#### Create folder for build

In a clean folder, create a ./src subfolder and clone this gnu-devtools-for-arm repo into it

```
mkdir src
git clone https://git.gitlab.arm.com/tooling/gnu-devtools-for-arm.git ./src/gnu-devtools-for-arm
```

#### Obtain the source code of all the relevant GNU projects

The source code can be obtained in different ways, please check below for the one that fits best for specific use cases:

##### Download the Source Code tar from one of our releases

The source code of the release to rebuild can be found at this address, in the "Source code" section: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

The content needs to be placed into the ./src folder, such that the ./src folder looks like this:

```
./src
  │
  ├───gnu-devtools-for-arm/
  ├───binutils-gdb/
  ├───binutils-gdb--gdb/
  ├───gcc/
  ├───glibc/
  └───<etc>
```

Note 1: This Source Code package does not contain the source code for QEMU, because QEMU does not form part of the Arm GNU Toolchain release. If tests using QEMU are required, the QEMU source code needs to be fetched and placed in `./src/qemu` (e.g. `git clone https://gitlab.com/qemu-project/qemu.git ./src/qemu`)

Note 2: The build scripts contain legacy code for supporting minor components cloog and libffi. This is not currently used by our standard build processes, hence why they have not been documented in these instructions.


##### Use source-fetch.py to fetch from upstream repositories

With python3 installed in the build environment (see package list above), it is possible to use the source snapshot manifest file of the release to rebuild: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

```
cd ./src/gnu-devtools-for-arm
<download the source snapshot manifest SPEC file and place it into the ./src/gnu-devtools-for-arm folder>

python3 extras/source-fetch.py checkout [--shallow] --src-dir=..   <name of manifest file>
cd ../..
```

Sample manifest files are provided in the spc directory; for example, spc/trunk.spc can be used to build a development version of the toolchain using the latest upstream sources.

If the full history of the respective git repositories is not needed, it is possible to use --shallow for faster and more compact downloads.


Some libraries are not listed in the spec file and are required:


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

Note 1: This may result in a slightly different revision than those used in Arm's official release. This is _generally_ considered harmless. If the exact revisions used by Arm is needed, it is advised to download the Source Tarball of the release.

Note 2: The advantage of this method is that whole git repositories of the relevant projects are fetched. This allows to make custom changes or apply patches to the code to rebuild, but it is much slower.

Note 3: The source snapshot manifest SPEC file does not contain the source code for QEMU, because QEMU does not form part of the Arm GNU Toolchain release. If the toolchain needs to be tested using QEMU, the QEMU source code needs to be fetched separately and placed in `./src/qemu` (e.g. `git clone https://gitlab.com/qemu-project/qemu.git ./src/qemu` )

Note 4: The build scripts contain legacy code for supporting minor components cloog and libffi. This is not currently used by our standard build processes, hence why they have not been documented in these instructions.

After completion of one of the above steps, the full ./src folder should now contain at least the below components (all these names also support a `-<version_number>` suffix:

```
./src
  │
  ├───gnu-devtools-for-arm/
  ├───binutils-gdb/
  ├───binutils-gdb--gdb/
  ├───gcc/                 (may also be named arm-gnu-toolchain-src-snapshot.* if fetched from our source tarball)
  ├───glibc/
  ├───gmp/
  ├───isl/
  ├───libexpat/
  ├───libiconv/            [OPTIONAL: This is only needed if you plan on building mingw-Windows-hosted toolchains -- this is currently unsupported]
  ├───linux/
  ├───mpc/
  ├───mpfr/
  ├───newlib-cygwin/
  └───qemu/                [OPTIONAL: Only needed if you plan on testing with QEMU. Will only be present if manually fetched.]
```

#### Invoking the build scripts

The build scripts can be invoked either directly through the generic wrapper script `build-gnu-toolchain.sh` or with a call to the lower-level scripts `build-baremetal-toolchain.sh` (for baremetal toolchains) and `build-cross-linux-toolchain.sh` (for linux targeting toolchains).

In order to configure the scripts to run, it is possible to either add them to PATH or create a link in the working directory:

Option1: PATH environment variable:

```
export PATH="$PWD/src/gnu-devtools-for-arm:$PATH"
build-gnu-toolchain.sh --target=<target> start
```

Option2: symlink in working dir:

```
ln -s src/gnu-devtools-for-arm/build-gnu-toolchain.sh
./build-gnu-toolchain.sh --target=<target> start
```


##### Building a toolchain in debug mode for development
In order to build a toolchain, the build-gnu-toolchain.sh wrapper script is usually used. It has a simple interface for the usual development use cases.

Generally, the calls look like this. Use `build-gnu-toolchain.sh --help` to discover more command line options.

>For debugging add --debug --debug-target to build-gnu-toolchain.sh

```
build-gnu-toolchain.sh --target=<TARGET> start
```

Where `TARGET` can be any of:
- `aarch64-none-elf`
- `aarch64_be-none-elf`
- `arm-none-eabi`
- `arm-none-linux-gnueabihf`
- `aarch64-none-linux-gnu`
- `aarch64_be-none-linux-gnu`

Please refer to the table below, which provides information of the valid target to use for each `build/host` platform.


```
| Toolchain                                                                     |
| ----------------------------------------------------------------------------- |
| Build                   | Host                    | Target                    |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | aarch64-none-elf          |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | aarch64_be-none-elf       |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-eabi             |
| aarch64-none-linux-gnu  | aarch64-none-linux-gnu  | arm-none-linux-gnueabihf  |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-elf          |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64_be-none-elf       |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64-none-linux-gnu    |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | aarch64_be-none-linux-gnu |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-eabi             |
| x86_64-none-linux-gnu   | x86_64-none-linux-gnu   | arm-none-linux-gnueabihf  |
| macOS (x86_64)          | macOS (x86_64)          | aarch64-none-elf          |
| macOS (x86_64)          | macOS (x86_64)          | arm-none-eabi             |
| macOS (Apple silicon)   | macOS (Apple silicon)   | aarch64-none-elf          |
| macOS (Apple silicon)   | macOS (Apple silicon)   | arm-none-eabi             |
| ----------------------------------------------------------------------------- |
```

The build scripts log their various "stages" into a `.stage` file. If they failed in stage `C`, they would normally resume building from stage `C`.

However, the `start` at the end of the command instructs the scripts to always start from the beginning of the build process and recompile any changed components (e.g. restart `A` -> `B` -> `C` -> etc.). This is recommended for development, as it will pick up and recompile any changes in any stages. Other commands that can be used are `clean`, to delete any partially built or fully built toolchains, or, in fact, any named stage within the scripts, like `gcc2`, will instruct the scripts to resume from that stage. `gcc2` is a useful one if making changes to GCC and wanting to iterate quickly (although one full build from `start` should have completed successfully at least once to enable this sort of a "resume from gcc2" to succeed).

**Note:**
Since all those invocations use practically the same parameters for all the different targets (or there are parameters whose default is ON, like `--aprofile --rmprofile`), then a lot of these toolchains could also be built in sequence as:

```
build-gnu-toolchain.sh --target=arm-none-eabi --target=aarch64-none-elf --target=aarch64_be-none-linux-gnu --debug --debug-target start
```

For more complex toolchains, the simple interface of the `build-gnu-toolchain.sh` script isn't enough, so we also need to leverage the command line interfaces of the lower-level scripts:
- `build-baremetal-toolchain.sh`
- `build-cross-linux-toolchain.sh`

This can be done by adding "`--`" to separate the `build-gnu-toolchain.sh` command line options from the `build-baremetal-toolchain.sh` or `build-cross-linux-toolchain.sh` command line options.
It is possible to build a toolchain only with one multilib in order to minimise the build time for quick iterations during development. This is especially useful for `arm-none-eabi` toolchains, which normally take hours to build due to the number of "mutlilibs" needed.
```
# Run this at least once to completion:
build-gnu-toolchain.sh --target=arm-none-eabi --with-arch=armv8.1-m.main+mve.fp+fp.dp --disable-multilib -- --config-flags-gcc=--with-float=hard start
# Run this to recompile changes in `gcc2` for quick and easy iteration:
build-gnu-toolchain.sh --target=arm-none-eabi --with-arch=armv8.1-m.main+mve.fp+fp.dp --disable-multilib -- --config-flags-gcc=--with-float=hard gcc2
```

##### Building a toolchain in release mode

Running the scripts in release mode also requires that some parameters from the lower-level scripts `build-baremetal-toolchain.sh` and `build-cross-linux-toolchain.sh` to be used.
The following are sample invocations as used to build our binary releases:
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

**Notes:**
* The aarch64-none-elf baremetal toolchains are built with both lp64 and ilp32 multilibs.
* The arm-none-eabi baremetal toolchain with both A-profile and RM-profile multilibs. After building, use `./build-arm-none-eabi/install/bin/arm-none-eabi-gcc --print-multi-lib` to view the whole list.
* Inconsistency may be noticed around the `--enable-gdb-with-python=yes` command line option. GDB with Python support is a known inconsistency of the current toolchain-building process. Python scripting support in GDB makes it less portable between OS versions. Currently, we enable `gdb-with-python` for Linux-hosted toolchains, but keep it disabled for macOS and Windows-hosted toolchains.
* At Arm, we use the `--tag` and `--bugurl` options to the lower-level scripts to tag our releases.

**It is important that the same tags used by Arm are not used when building the toolchain. Usage of a different branding needs to be specified in case `--tag` is needed.**

### Known build issues

* When building gcc-13 or earlier gcc versions, together with glibc v2.38, the build process fails:

```
src/gcc/libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cpp:180:10: fatal error: crypt.h: No such file or directory
  180 | #include <crypt.h>
      |          ^~~~~~~~~
compilation terminated.
```

This can be solved by passing the following argument to the build scripts:

```
--config-flags-libc="--enable-crypt"  # directly to the lower level build scripts
or
--extra="--config-flags-libc=--enable-crypt" # to build-gnu-toolchain.sh
```

* Building certain parts of the toolchain source code might require support for a newer C or C++ language standard. It is recommended to build the toolchain using GCC 9 or later, to avoid such build errors.


## How to test the toolchains

These scripts do not currently support running the regression testsuite.

# Licence
This project is licensed under the terms of the MIT license.
