[![Travis Build Status](https://travis-ci.org/Juppit/esp-new-sdk.svg?branch=master)](https://travis-ci.org/Juppit/esp-new-sdk)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/Juppit/esp-new-sdk?svg=true)](https://ci.appveyor.com/project/Juppit/esp-new-sdk)
# esp-new-sdk

Makefile to build the toolchain and a complete standalone SDK for Espressif ESP8266.

It was developed for use under Windows on Cygwin. It should be easy to maintain and configure, without additional files and scripts.

Under Travis-CI it builds successfully on Linux and as well on MacOS64.

Thus it builds successfully on
- Cygwin
- MinGW64
- Linux
- MacOS64

Install the project in a directory of your choice, for example 'esp-new-sdk'
```bash
  git clone https://github.com/Juppit/esp-new-sdk esp-new-sdk
```

If you like to prepare the build before 'make' you can download most sources into the tarballs directory:
```bash
  make get-tars
```

If you edit the 'Makefile' you can use the following versions
```bash
  xtensa-lx106-elf-sdk:   version 2.1.x  down to 1.5.0
```
The listed versions will build without errors.

You may configure the 'Makefile' to build with or without gdb and lwip
or enable additional libraries such as:
```bash
  ncurses, ISL, CLoog, expat
```

To build the complete project use the following command:
```bash
  make                  # build all with last versions
```
If an error occurs during the 'make' process, it can be continued with 'make' (after correcting the error, of course).

To build parts of the project use the following commands:
```bash
  make build-gmp        # version 6.1.2  down to 6.0.0a
  make build-mpfr       # version 3.1.6  down to 3.1.1
  make build-mpc        # version 1.0.3  down to 1.0.1
  make build-binutils   # version 2.30   down to 2.26
  make build-gcc-1      # version 7.2.0  down to 4.8.2
  make build-newlib     # version xtensa
  make build-gcc-2
  make build-gcc-libhal # version lx106-hal
  ```

If configured you can build additional libraries with:
```bash
  make build-ncurses    # version 6.0
  make build-isl        # version 0.18   down to 0.14
  make build-cloog      # version 0.18.1 down to 0.18.4
  make build-expat      # version 2.1.0
  make build-gdb        # version 8.0.1  down to 7.5.1
  ```

To rebuild one of the above parts it should be enough to:
- delete the corresponding file <src/.xxx.loaded> from 'src' directory, for example <src/.mpc.loaded>.

Note: build directories are named after the operating system, for example 'build-Cygwin64'

To clean the build system use the following commands:
```bash
  make clean            # removes all build directories and <.xxx.installed> marker
  make purge            # removes additionally the source directories
```
