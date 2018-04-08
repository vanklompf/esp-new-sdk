# Author: Peter Dobler (@Juppit)
#
# based on esp-alt-sdk from Dmitry Kireev (@kireevco)
#
# Credits to Max Fillipov (@jcmvbkbc) for major xtensa-toolchain (gcc-xtensa, newlib-xtensa)
# Credits to Paul Sokolovsky (@pfalcon) for esp-open-sdk
# Credits to Ivan Grokhotkov (@igrr) for compiler options (NLX_OPT) and library modifications
#
# Last edit: 20.03.2018

#*******************************************
#************** configuration **************
#*******************************************

# the standalone version is used only
STANDALONE = y
# debug = y	gives a lot of output
DEBUG = n
# strip:	reduces used disc space by approx. 40-50 percent
USE_STRIP = y
# compress:	reduces used disc space by approx. 40-50 percent
USE_COMPRESS = n
# The Curses library "cursor optimization"
USE_CURSES = n
# build lwip-lib
USE_LWIP = n
# build isl
USE_ISL = n
# XML-Parser
USE_EXPAT = n
# The Chunky Loop Generator
USE_CLOOG = n
# build debugger
USE_GDB = n

BUILDPATH = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

PLATFORM := $(shell uname -s)
ifneq (,$(findstring 64, $(shell uname -m)))
    ARCH = 64
else
    ARCH = 32
endif

BUILD := $(PLATFORM)
ifeq ($(OS),Windows_NT)
    ifneq (,$(findstring MINGW32,$(PLATFORM)))
        BUILD := MinGW$(ARCH)
        BUILDPATH := /mingw$(ARCH)/bin:$(BUILDPATH)
    endif
    ifneq (,$(findstring MINGW64,$(PLATFORM)))
        BUILD := MinGW$(ARCH)
        BUILDPATH := /mingw$(ARCH)/bin:$(BUILDPATH)
    endif
    ifneq (,$(findstring MSYS,$(PLATFORM)))
        BUILD := MSYS$(ARCH)
        BUILDPATH := /msys$(ARCH)/bin:$(BUILDPATH)
    endif
    ifneq (,$(findstring CYGWIN,$(PLATFORM)))
        BUILD := Cygwin$(ARCH)
    endif
else
    ifeq ($(PLATFORM),Darwin)
        BUILD := MacOS$(ARCH)
    endif
    ifeq ($(PLATFORM),Linux)
        ifneq (,$(findstring ARM,$(PLATFORM)))
            BUILD := LinuxARM$(ARCH)
        else
            BUILD := Linux$(ARCH)
        endif
        ifneq (,$(findstring ARCH64,$(PLATFORM)))
            BUILD := LinuxARM$(ARCH)
        endif
    endif
endif

# various hosts are not supported like 'darwin'
#HOST   = x86_64-apple-darwin14.0.0
TARGET = xtensa-lx106-elf

# create tar-file for distribution
DISTRIB  = ""
DISTRIB  = $(BUILD)-$(TARGET)
USE_DISTRIB = y

# xtensa-lx106-elf-gcc means the executable e.g. xtensa-lx106-elf-gcc.exe
XCC  = $(TARGET)-cc
XGCC = $(TARGET)-gcc
XAR  = $(TARGET)-ar
XOCP = $(TARGET)-objcopy

# listed versions are somewhat tested
# the last versions will be used
SDK_VERSION = 1.3.0-rtos
SDK_VERSION = 1.4.0-rtos
SDK_VERSION = 1.5.0
ESP_SDK_VERSION = 010500
SDK_VERSION = 1.5.1
ESP_SDK_VERSION = 010501
SDK_VERSION = 1.5.2
ESP_SDK_VERSION = 010502
SDK_VERSION = 1.5.3
ESP_SDK_VERSION = 010503
SDK_VERSION = 1.5.4
ESP_SDK_VERSION = 010504
SDK_VERSION = 2.0.0
ESP_SDK_VERSION = 020000
SDK_VERSION = 2.1.0
SDK_VERSION = 2.1.x
ESP_SDK_VERSION = 020100
SDK_VERSION = 2.2.0
SDK_VERSION = 2.2.x
ESP_SDK_VERSION = 020200

GMP_VERSION = 6.0.0a
GMP_VERSION = 6.1.0
GMP_VERSION = 6.1.1
GMP_VERSION = 6.1.2

MPFR_VERSION = 3.1.1
MPFR_VERSION = 3.1.2
MPFR_VERSION = 3.1.3
MPFR_VERSION = 3.1.4
MPFR_VERSION = 3.1.5
MPFR_VERSION = 3.1.6
#MPFR_VERSION = 4.0.0

MPC_VERSION  = 1.0.1
MPC_VERSION  = 1.0.2
MPC_VERSION  = 1.0.3

GCC_VERSION  = 4.8.2
GCC_VERSION  = 4.9.2
GCC_VERSION  = 5.1.0
GCC_VERSION  = 5.2.0
GCC_VERSION  = 5.3.0
GCC_VERSION  = 5.5.0
GCC_VERSION  = 6.4.0
#GCC_VERSION = 7.1.0
GCC_VERSION  = 7.2.0

GDB_VERSION  = 7.5.1
GDB_VERSION  = 7.10
GDB_VERSION  = 7.11
GDB_VERSION  = 7.12
GDB_VERSION  = 7.12.1
GDB_VERSION  = 8.0.1

BIN_VERSION  = 2.26
BIN_VERSION  = 2.27
BIN_VERSION  = 2.28
BIN_VERSION  = 2.29
BIN_VERSION  = 2.29.1
BIN_VERSION  = 2.30

HAL_VERSION  = lx106-hal

CURSES_VERSION  = 6.0
EXPAT_VERSION = 2.1.0
EXPAT_VERSION = 2.2.5

ISL_VERSION  = 0.14
ISL_VERSION  = 0.18

CLOOG_VERSION  = 0.18.1
CLOOG_VERSION  = 0.18.4

LWIP_VERSION = esp-open-lwip
LWIP_VERSION = lwip2

#*******************************************
#************* define variables ************
#*******************************************

TOP = $(PWD)

SDK = sdk
SDK_SRC_DIR = $(SDK)
TOP_SDK = $(TOP)/$(SDK_SRC_DIR)
SDK_VER = $(SDK_SRC_DIR)_v$(SDK_VERSION)
SDK_DIR = $(TOP_SDK)/$(SDK_VER)

TOOLCHAIN = $(TOP)/$(TARGET)
TARGET_DIR = $(TOOLCHAIN)/$(TARGET)

SAFEPATH = "$(TOOLCHAIN)/bin:"$(BUILDPATH)

COMP_LIB = $(TOP)/comp_libs
SOURCE_DIR = $(TOP)/src
TAR_DIR = $(TOP)/tarballs
PATCHES_DIR = $(SOURCE_DIR)/patches
BUILD_DIR = build-$(BUILD)
DIST_DIR = $(TOP)/distrib

OUTPUT_DATE = date +"%Y-%m-%d %X" 

# Log file
BUILD_LOG = $(DIST_DIR)/$(BUILD)-build.log
ERROR_LOG = $(DIST_DIR)/$(BUILD)-error.log

GNU_URL = https://ftp.gnu.org/gnu

GMP = gmp
GMP_DIR = $(SOURCE_DIR)/$(GMP)-$(GMP_VERSION)
# make it easy for gmp-6.0.0a
ifneq (,$(findstring 6.0.0a,$(NLX_VERSION)))
    GMP_DIR = $(SOURCE_DIR)/$(GMP)-6.0.0
endif
BUILD_GMP_DIR = $(GMP_DIR)/$(BUILD_DIR)
GMP_URL = $(GNU_URL)/$(GMP)/$(GMP)-$(GMP_VERSION).tar.bz2
GMP_TAR = $(TAR_DIR)/$(GMP)-$(GMP_VERSION).tar.bz2
GMP_TAR_DIR = $(GMP)-$(GMP_VERSION)

MPFR = mpfr
MPFR_DIR = $(SOURCE_DIR)/$(MPFR)-$(MPFR_VERSION)
BUILD_MPFR_DIR = $(MPFR_DIR)/$(BUILD_DIR)
MPFR_URL = $(GNU_URL)/$(MPFR)/$(MPFR)-$(MPFR_VERSION).tar.bz2
MPFR_TAR = $(TAR_DIR)/$(MPFR)-$(MPFR_VERSION).tar.bz2
MPFR_TAR_DIR = $(MPFR)-$(MPFR_VERSION)

MPC = mpc
MPC_DIR = $(SOURCE_DIR)/$(MPC)-$(MPC_VERSION)
BUILD_MPC_DIR = $(MPC_DIR)/$(BUILD_DIR)
MPC_URL = $(GNU_URL)/$(MPC)/$(MPC)-$(MPC_VERSION).tar.gz
MPC_TAR = $(TAR_DIR)/$(MPC)-$(MPC_VERSION).tar.gz
MPC_TAR_DIR = $(MPC)-$(MPC_VERSION)

BIN = binutils
BIN_DIR = $(SOURCE_DIR)/$(BIN)-$(BIN_VERSION)
BUILD_BIN_DIR = $(BIN_DIR)/$(BUILD_DIR)
BIN_URL = $(GNU_URL)/$(BIN)/$(BIN)-$(BIN_VERSION).tar.gz
BIN_TAR = $(TAR_DIR)/$(BIN)-$(BIN_VERSION).tar.gz
BIN_TAR_DIR = $(BIN)-$(BIN_VERSION)

NLX = newlib
#NLX_VERSION  = 2.5.0
#NLX_VERSION  = esp32
NLX_VERSION  = xtensa
NLX_DIR = $(SOURCE_DIR)/$(NLX)-$(NLX_VERSION)
BUILD_NLX_DIR = $(NLX_DIR)/$(BUILD_DIR)

# get from NLX_URL
# find as NLX_TAR (zip/tar.gz) in tarballs
# untar to NLX_TAR_DIR directory
# move from NLX_TAR_DIR to NLX_DIR
NLX_URL  = ftp://sourceware.org/pub/newlib/$(NLX)-$(NLX_VERSION).tar.gz
NLX_TAR  = $(TAR_DIR)/$(NLX)-$(NLX_VERSION).tar.gz
NLX_TAR_DIR = $(NLX)-$(NLX_VERSION)

ifneq (,$(findstring xtensa,$(NLX_VERSION)))
    NLX_URL  = https://github.com/jcmvbkbc/newlib-xtensa/archive/xtensa.zip
    NLX_TAR  = $(TAR_DIR)/newlib-xtensa-master.zip
    NLX_TAR_DIR = $(NLX)-xtensa-xtensa
endif

ifneq (,$(findstring esp32,$(NLX_VERSION)))
    NLX_URL  = https://github.com/espressif/newlib-esp32/archive/$(NLX_TAR)
    NLX_TAR  = $(TAR_DIR)/newlib-esp32.zip
    NLX_TAR_DIR = $(NLX)-esp32-master
endif

GCC = gcc
GCC_DIR = $(SOURCE_DIR)/$(GCC)-$(GCC_VERSION)
BUILD_GCC_DIR = $(GCC_DIR)/$(BUILD_DIR)
GCC_URL = $(GNU_URL)/$(GCC)/$(GCC)-$(GCC_VERSION)/$(GCC)-$(GCC_VERSION).tar.gz
GCC_TAR = $(TAR_DIR)/$(GCC)-$(GCC_VERSION).tar.gz
GCC_TAR_DIR = $(GCC)-$(GCC_VERSION)

CURSES = ncurses
CURSES_DIR = $(SOURCE_DIR)/$(CURSES)-$(CURSES_VERSION)
BUILD_CURSES_DIR = $(CURSES_DIR)/$(BUILD_DIR)
CURSES_URL = $(GNU_URL)/$(CURSES)/$(CURSES)-$(CURSES_VERSION).tar.gz
CURSES_TAR = $(TAR_DIR)/$(CURSES)-$(CURSES_VERSION).tar.bz2
CURSES_TAR_DIR = $(CURSES)-$(CURSES_VERSION)

EXPAT = expat
EXPAT_DIR = $(SOURCE_DIR)/$(EXPAT)-$(EXPAT_VERSION)
BUILD_EXPAT_DIR = $(EXPAT_DIR)/$(BUILD_DIR)
EXPAT_URL = https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VERSION)/expat-$(EXPAT_VERSION).tar.bz2/download
ifneq (,$(findstring 2.1.0,$(EXPAT_VERSION)))
    EXPAT_URL = https://github.com/libexpat/libexpat/releases/download/R_2_1_0/expat-2.1.0.tar.gz
endif
EXPAT_TAR = $(TAR_DIR)/$(EXPAT)-$(EXPAT_VERSION).tar.gz
EXPAT_TAR_DIR = $(EXPAT)-$(EXPAT_VERSION)

ISL = isl
ISL_DIR = $(SOURCE_DIR)/$(ISL)-$(ISL_VERSION)
BUILD_ISL_DIR = $(ISL_DIR)/$(BUILD_DIR)
ISL_URL = ftp://gcc.gnu.org/pub/gcc/infrastructure/$(ISL)-$(ISL_VERSION).tar.bz2
ISL_TAR = $(TAR_DIR)/$(ISL)-$(ISL_VERSION).tar.bz2
ISL_TAR_DIR = $(ISL)-$(ISL_VERSION)

CLOOG = cloog
CLOOG_DIR = $(SOURCE_DIR)/$(CLOOG)-$(CLOOG_VERSION)
BUILD_CLOOG_DIR = $(CLOOG_DIR)/$(BUILD_DIR)
CLOOG_URL = http://www.bastoul.net/cloog/pages/download/$(CLOOG)-$(CLOOG_VERSION).tar.gz
CLOOG_TAR = $(TAR_DIR)/$(CLOOG)-$(CLOOG_VERSION).tar.gz
CLOOG_TAR_DIR = $(CLOOG)-$(CLOOG_VERSION)

HAL = libhal
HAL_DIR = $(SOURCE_DIR)/$(HAL)-$(HAL_VERSION)
BUILD_HAL_DIR = $(HAL_DIR)/$(BUILD_DIR)
HAL_URL  = https://github.com/tommie/lx106-hal/archive/master.zip
HAL_TAR  = $(TAR_DIR)/$(HAL)-$(HAL_VERSION)-master.zip
HAL_TAR_DIR = $(HAL_VERSION)-master

GDB = gdb
GDB_DIR = $(SOURCE_DIR)/$(GDB)-$(GDB_VERSION)
BUILD_GDB_DIR = $(GDB_DIR)/$(BUILD_DIR)
GDB_URL = $(GNU_URL)/$(GDB)/$(GDB)-$(GDB_VERSION).tar.gz
GDB_TAR = $(TAR_DIR)/$(GDB)-$(GDB_VERSION).tar.gz
GDB_TAR_DIR = $(GDB)-$(GDB_VERSION)

LWIP = lwip
LWIP_DIR = $(SOURCE_DIR)/$(LWIP)-$(LWIP_VERSION)
BUILD_LWIP_DIR = $(LWIP_DIR)/$(BUILD_DIR)
LWIP_URL = https://github.com/pfalcon/esp-open-lwip/archive/sdk-1.5.0-experimental.zip
LWIP_TAR = $(TAR_DIR)/$(LWIP)-sdk-1.5.0-experimental.zip
LWIP_TAR_DIR = esp-open-lwip-sdk-1.5.0-experimental
ifeq ($(LWIP_VERSION),lwip2)
    BUILD_LWIP_DIR = $(LWIP_DIR)/build-536
    LWIP_URL = https://github.com/d-a-v/esp82xx-nonos-linklayer/archive/master.zip
    LWIP_TAR = $(TAR_DIR)/$(LWIP)-esp82xx-nonos-linklayer-master.zip
    LWIP_TAR_DIR = esp82xx-nonos-linklayer-master
endif

ifeq ($(DEBUG),y)
	WGET     := wget -c --progress=dot:binary
	PATCH    := patch -b -N
	QUIET    :=
	MKDIR    := mkdir -p
	RM       := rm -f
	RMDIR    := rm -R -f
	MOVE     := mv -f
	UNTAR    := bsdtar -vxf
	CONF_OPT := configure
	INST_OPT := install
	AR_DEL   := dv
	AR_XTRACT:= xv
	AR_INSERT:= rv
	OCP_REDEF:= --redefine-sym
else
	WGET     := wget -cq
	PATCH    := patch -s -b -N 
	QUIET    := 2> /dev/null
	QUIET    := >>$(BUILD_LOG) 2>&1
	QUIET    := >>$(BUILD_LOG) 2>>$(ERROR_LOG)
	MKDIR    := mkdir -p
	RM       := rm -f
	RMDIR    := rm -R -f
	MOVE     := mv -f
	UNTAR    := bsdtar -xf
	CONF_OPT := configure -q
	INST_OPT := install -s
	AR_DEL   := d
	AR_XTRACT:= x
	AR_INSERT:= r
	OCP_REDEF:= --redefine-sym
endif

WITH_GMP  = --with-$(GMP)=$(COMP_LIB)/$(GMP)-$(GMP_VERSION)
WITH_MPFR = --with-$(MPFR)=$(COMP_LIB)/$(MPFR)-$(MPFR_VERSION)
WITH_MPC  = --with-$(MPC)=$(COMP_LIB)/$(MPC)-$(MPC_VERSION)
WITH_NLX  = --with-$(NLX)
WITH_ISL  = --with-$(ISL)=$(COMP_LIB)/$(ISL)-$(ISL_VERSION)
WITH_CLOOG= --with-$(CLOOG)=$(COMP_LIB)/$(CLOOG)-$(CLOOG_VERSION)

GMP_OPT   = --disable-shared --enable-static
MPFR_OPT  = --disable-shared --enable-static
MPC_OPT   = --disable-shared --enable-static
BUILD_OPT = --enable-werror=no --disable-multilib --disable-nls --disable-shared --disable-threads \
            --with-gnu-as --with-gnu-ld
BIN_OPT   = $(BUILD_OPT) --with-$(GCC)
ISL_OPT   = --disable-shared --enable-static $(WITH_GMP)
CLOOG_OPT = --disable-shared --enable-static $(WITH_GMP)
#see: xtensa-lx106-elf-gcc-4.8.2.exe -v
GCC_OPT   = $(BUILD_OPT) $(WITH_GMP) $(WITH_MPFR) $(WITH_MPC) $(WITH_NLX) $(WITH_CLOOG) \
            --disable-libssp --disable-__cxa_atexit --disable-libstdcxx-pch \
			--enable-target-optspace --without-long-double-128 --disable-libgomp --disable-libmudflap \
			--disable-libquadmath --disable-libquadmath-support
GC1_OPT   = --enable-languages=c $(GCC_OPT) --without-headers
GC2_OPT   = --enable-languages=c,c++ $(GCC_OPT) --enable-cxx-flags='-fno-exceptions -fno-rtti'
NLX_OPT   = --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls
NLX_OPT   = --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls \
            --with-$(NLX) --enable-target-optspace --disable-option-checking \
            --enable-$(NLX)-nano-formatted-io --enable-$(NLX)-reent-small \
            --disable-$(NLX)-io-c99-formats --disable-$(NLX)-supplied-syscalls \
            --with-target-subdir=$(TARGET)

#			 --program-transform-name="s&^&$(TARGET)-&"
NLX_OPT1  = CROSS_CFLAGS="-DSIGNAL_PROVIDED -DABORT_PROVIDED -DMALLOC_PROVIDED"

CURSES_OPT = --enable-symlinks --without-manpages --without-tests \
              --without-cxx --without-cxx-binding --without-ada

EXPAT_OPT =
HAL_OPT   =
GDB_OPT   = $(BUILD_OPT)

# from SDK_URL get archive with SDK_ZIP inside and extract to SDK_VER
SDK_URL_1.4.0-rtos = "https://github.com/espressif/ESP8266_RTOS_SDK/archive/dba89f9aba75f9858157618e8bb4927d2da76296.zip"
SDK_ZIP_1.4.0-rtos = ESP8266_RTOS_SDK-dba89f9aba75f9858157618e8bb4927d2da76296
SDK_VER_1.4.0-rtos = esp-rtos-sdk-v1.4.0
SDK_URL_1.3.0-rtos = "https://github.com/espressif/ESP8266_RTOS_SDK/archive/3ca6af5da68678d809b34c7cd98bee71e0235039.zip"
SDK_ZIP_1.3.0-rtos = ESP8266_RTOS_SDK-3ca6af5da68678d809b34c7cd98bee71e0235039
SDK_VER_1.3.0-rtos = esp-rtos-sdk-v1.3.0
#ESP8266_NONOS_SDK-2.2.0-3-gf8f27ce
SDK_URL_2.2.x = "https://github.com/espressif/ESP8266_NONOS_SDK/archive/release/v2.2.x.zip"
SDK_ZIP_2.2.x = ESP8266_NONOS_SDK-release-v2.2.x
SDK_VER_2.2.x = esp_iot_sdk_v2.2.x
SDK_URL_2.2.0 = "https://github.com/espressif/ESP8266_NONOS_SDK/archive/v2.2.0.zip"
SDK_ZIP_2.2.0 = ESP8266_NONOS_SDK-2.2.0
SDK_VER_2.2.0 = esp_iot_sdk_v2.2.0
#ESP8266_NONOS_SDK-2.1.0-18-g61248df
SDK_URL_2.1.x = "https://github.com/espressif/ESP8266_NONOS_SDK/archive/release/v2.1.x.zip"
SDK_ZIP_2.1.x = ESP8266_NONOS_SDK-release-v2.1.x
SDK_VER_2.1.x = esp_iot_sdk_v2.1.x
SDK_URL_2.1.0 = "https://github.com/espressif/ESP8266_NONOS_SDK/archive/v2.1.0.zip"
SDK_ZIP_2.1.0 = ESP8266_NONOS_SDK-2.1.0
SDK_VER_2.1.0 = esp_iot_sdk_v2.1.0
SDK_URL_2.0.0 = "http://bbs.espressif.com/download/file.php?id=1690"
SDK_ZIP_2.0.0 = ESP8266_NONOS_SDK
SDK_VER_2.0.0 = esp_iot_sdk_v2.0.0
SDK_URL_1.5.4 = "http://bbs.espressif.com/download/file.php?id=1469"
SDK_ZIP_1.5.4 = ESP8266_NONOS_SDK
SDK_VER_1.5.4 = esp_iot_sdk_v1.5.4
SDK_URL_1.5.3 = "http://bbs.espressif.com/download/file.php?id=1361"
SDK_ZIP_1.5.3 = ESP8266_NONOS_SDK_V1.5.3_16_04_18
SDK_VER_1.5.3 = esp_iot_sdk_v1.5.3
SDK_ZIP_1.5.2 = esp_iot_sdk_v1.5.2
SDK_URL_1.5.2 = "http://bbs.espressif.com/download/file.php?id=1079"
SDK_VER_1.5.2 = esp_iot_sdk_v1.5.2
SDK_URL_1.5.1 = "http://bbs.espressif.com/download/file.php?id=1046"
SDK_ZIP_1.5.1 = esp_iot_sdk_v1.5.1
SDK_VER_1.5.1 = esp_iot_sdk_v1.5.1
SDK_URL_1.5.0 = "http://bbs.espressif.com/download/file.php?id=989"
SDK_ZIP_1.5.0 = esp_iot_sdk_v1.5.0_15_11_27
SDK_VER_1.5.0 = esp_iot_sdk_v1.5.0

SDK_ZIP = $(SDK_ZIP_$(SDK_VERSION))
SDK_URL = $(SDK_URL_$(SDK_VERSION))
SDK_VER = $(SDK_VER_$(SDK_VERSION))
SDK_TAR = $(TAR_DIR)/$(SDK_VER).zip
SDK_TAR_DIR = $(SDK_VER)/$(SDK_ZIP)


#*******************************************
#************** rules section **************
#*******************************************

.PHONY: build build-bins build-libraries get-tars
.PHONY: info-start info-build info inst-info info-distrib
.PHONY: distrib install strip compress clean clean-build clean-sdk
#.PHONY: get-$(CURSES) get-$(ISL) get-$(CLOOG) get-$(EXPAT) get-$(GDB) get-$(LWIP)

#*******************************************
#************* Build Toolchain *************
#*******************************************

# splitted builds to prevent Travis from from assuming a stalled build
all:
	@$(MAKE) info-start
	@$(MAKE) info-build
	@$(MAKE) build-bins 2>>$(ERROR_LOG)
	@$(MAKE) build 2>>$(ERROR_LOG)
	@$(MAKE) compress 2>>$(ERROR_LOG)
	@$(MAKE) build-sdk-libs 2>>$(ERROR_LOG)
	@$(MAKE) info
	@cat build-start.txt; rm build-start.txt
	@$(MAKE) distrib
	@$(OUTPUT_DATE)
	@echo -e "\07"

install:
	rm $(SOURCE_DIR)/.*.installed
	$(MAKE) info-install
	$(MAKE) all

#*******************************************
#************* single builds ***************
#*******************************************

build:
	$(MAKE) build-$(GCC)-1 
	$(MAKE) build-$(NLX) 
	$(MAKE) build-$(GCC)-2 
	$(MAKE) build-$(HAL) 
	$(MAKE) build-sdk-libs

build-bins: build-$(GMP) build-$(MPFR) build-$(ISL) build-$(CLOOG) build-$(MPC) build-$(BIN)
build-tools:
	$(MAKE) build-$(GDB) 
	$(MAKE) build-$(LWIP)
	$(MAKE) build-$(EXPAT) 
	$(MAKE) build-$(CURSES)
	
# prefetch for travis Osx-build-2
get-gcc-src-dir:
	$(MAKE) $(SOURCE_DIR)/.$(GCC).extracted

get-tars: $(TAR_DIR) get-$(CURSES) $(GMP_TAR) $(MPFR_TAR) get-$(ISL) get-$(CLOOG) $(MPC_TAR) get-$(EXPAT) $(BIN_TAR) $(GCC_TAR) $(NLX_TAR) $(HAL_TAR) if_isl_tar if_cloog_tar if_lwip_tar if_gdb_tar

get-$(CURSES):
ifeq ($(USE_CURSES),y)
	$(MAKE) $(CURSES_TAR)
endif

get-$(ISL):
ifeq ($(USE_ISL),y)
	$(MAKE) $(ISL_TAR)
endif

get-$(CLOOG):
ifeq ($(USE_CLOOG),y)
	$(MAKE) $(CLOOG_TAR)
endif

get-$(EXPAT):
ifeq ($(USE_EXPAT),y)
	$(MAKE) $(EXPAT_TAR)
endif

get-$(GDB):
ifeq ($(USE_GDB),y)
	$(MAKE) $(GDB_TAR)
endif

get-$(LWIP):
ifeq ($(USE_LWIP),y)
	$(MAKE) $(LWIP_TAR)
endif

$(SOURCE_DIR):
	@$(MKDIR) $(SOURCE_DIR)

$(TAR_DIR):
	@$(MKDIR) $(TAR_DIR)

$(COMP_LIB):
	@$(MKDIR) $(COMP_LIB)
	@$(MKDIR) $(COMP_LIB)/$(GMP)-$(GMP_VERSION)
	@$(MKDIR) $(COMP_LIB)/$(MPFR)-$(MPFR_VERSION)
	@$(MKDIR) $(COMP_LIB)/$(MPC)-$(MPC_VERSION)
	@$(MKDIR) $(COMP_LIB)/$(ISL)-$(ISL_VERSION)
	@$(MKDIR) $(COMP_LIB)/$(CLOOG)-$(CLOOG_VERSION)

$(DIST_DIR):
	@$(MKDIR) $(DIST_DIR)

$(TOOLCHAIN): | $(DIST_DIR) $(SOURCE_DIR) $(TAR_DIR) $(COMP_LIB)
	@git config --global core.autocrlf false
	@$(MKDIR) $(TOOLCHAIN)

#*******************************************
#************* single targets **************
#*******************************************
#
build-$(GMP):    $(SOURCE_DIR)/.$(GMP).installed | $(TOOLCHAIN) 
build-$(MPFR):   $(SOURCE_DIR)/.$(MPFR).installed | $(TOOLCHAIN) 
build-$(MPC):    $(SOURCE_DIR)/.$(MPC).installed | $(TOOLCHAIN) 
build-$(BIN):    $(SOURCE_DIR)/.$(BIN).installed | $(TOOLCHAIN) 
build-$(GCC)-1:  $(SOURCE_DIR)/.$(GCC)-pass-1.installed | $(TOOLCHAIN) 
build-$(NLX):    $(SOURCE_DIR)/.$(NLX).installed | $(TOOLCHAIN) 
build-$(GCC)-2:  $(SOURCE_DIR)/.$(GCC)-pass-2.installed | $(TOOLCHAIN) 
build-$(HAL):    $(SOURCE_DIR)/.$(HAL).installed | $(TOOLCHAIN) 
build-sdk-libs:  $(SOURCE_DIR)/.$(SDK).installed $(SOURCE_DIR)/.sdk-libs.installed | $(TOOLCHAIN)

build-$(CURSES): | $(TOOLCHAIN)
ifeq ($(USE_CURSES),y)
	$(MAKE) $(SOURCE_DIR)/.$(CURSES).installed
endif

build-$(ISL): | $(TOOLCHAIN)
ifeq ($(USE_ISL),y)
	$(MAKE) $(SOURCE_DIR)/.$(ISL).installed
endif

build-$(CLOOG): | $(TOOLCHAIN)
ifeq ($(USE_CLOOG),y)
	$(MAKE) $(SOURCE_DIR)/.$(CLOOG).installed
endif

build-$(EXPAT): | $(TOOLCHAIN)
ifeq ($(USE_EXPAT),y)
	$(MAKE) $(SOURCE_DIR)/.$(EXPAT).installed
endif

build-$(GDB): | $(TOOLCHAIN)
ifeq ($(USE_GDB),y)
	$(MAKE) $(SOURCE_DIR)/.$(GDB).installed
endif

build-$(LWIP): | $(TOOLCHAIN)
ifeq ($(USE_LWIP),y)
	$(MAKE) $(SOURCE_DIR)/.$(LWIP).installed
endif

strip:
ifeq ($(USE_STRIP),y)
	$(MAKE) $(SOURCE_DIR)/.$(SDK).stripped
endif

compress:
ifeq ($(USE_COMPRESS),y)
	$(MAKE) $(SOURCE_DIR)/.$(SDK).compressed
endif

distrib:
ifeq ($(USE_DISTRIB),y)
	$(MAKE) $(SOURCE_DIR)/.$(SDK).distributed
endif

#*******************************************
#****************** Infos ******************
#*******************************************

info-start:
	@date +"%Y-%m-%d %X" > build-start.txt
	@$(MKDIR) $(DIST_DIR)
	@cat build-start.txt > $(BUILD_LOG)
	@echo "" >> $(BUILD_LOG)
	@cat build-start.txt > $(ERROR_LOG)
	@echo "" >> $(ERROR_LOG)
	@$(OUTPUT_DATE)
	$(info Detected: $(BUILD) on $(OS))
	$(info Path: $(SAFEPATH))
	$(info Processors: $(NUMBER_OF_PROCESSORS))

info-build:
	$(info ##########################)
	$(info #### Build Toolchain...)
	$(info ##########################)

info-install:
	$(info ##########################)
	$(info #### Install Toolchain...)
	$(info ##########################)

info:
	$(info +------------------------------------------------+)
	$(info | $(TARGET) Toolchain is build with:)
	$(info |)
ifeq ($(USE_CURSES),y)
	$(info |   CURSES   $(CURSES_VERSION))
endif
	$(info |   GMP      $(GMP_VERSION))
	$(info |   MPFR     $(MPFR_VERSION))
	$(info |   MPC      $(MPC_VERSION))
ifeq ($(USE_EXPAT),y)
	$(info |   EXPAT    $(EXPAT_VERSION))
endif
	$(info |   BINUTILS $(BIN_VERSION))
ifeq ($(USE_ISL),y)
	$(info |   ISL      $(ISL_VERSION))
endif
ifeq ($(USE_CLOOG),y)
	$(info |   CLOOG    $(CLOOG_VERSION))
endif
	$(info |   GCC      $(GCC_VERSION))
	$(info |   NEWLIB   $(NLX_VERSION))
	$(info |   LIBHAL   $(HAL_VERSION))
ifeq ($(USE_GDB),y)
	$(info |   GDB      $(GDB_VERSION))
endif
ifeq ($(USE_LWIP),y)
	$(info |   LWIP     $(LWIP_VERSION))
endif
	$(info |)
	$(info |   SDK      $(SDK_VERSION))
ifeq ($(USE_DISTRIB),y)
	$(info |)
	$(info |   Distribution:)
	$(info |     $(DISTRIB).tar.gz)
endif
	$(info +------------------------------------------------+)

info-inst:
	$(info +------------------------------------------------+)
	$(info | $(TARGET) Toolchain is built. To use it:)
	$(info |   export PATH=$(TOOLCHAIN)/bin:\$$PATH)
	$(info |)
ifneq ($(STANDALONE),y)
	$(info | Espressif ESP8266 SDK is installed.)
	$(info | Toolchain contains only Open Source components)
	$(info | To link external proprietary libraries add:)
	$(info |)
	$(info |   $(XGCC) \\)
	$(info |       -I $(SDK_DIR)/include \\)
	$(info |       -L $(SDK_DIR)/lib)
	$(info +------------------------------------------------+)
else
	$(info | Espressif ESP8266 SDK is installed,)
	$(info |   libraries and headers are merged)
	$(info +------------------------------------------------+)
endif

distrib-info:
	$(info +------------------------------------------------+)
	$(info | The Toolchain will be packed)
	$(info | for distribution,)
	$(info |   creating: $(DISTRIB).tar.gz)
	$(info +------------------------------------------------+)

#*******************************************
#*************** SDK  section **************
#*******************************************

$(SOURCE_DIR)/.$(SDK).distributed: $(SOURCE_DIR)/.$(SDK).stripped
ifeq ($(USE_DISTRIB),y)
	@$(MAKE) distrib-info
	@$(MKDIR) $(DIST_DIR)
	-@bsdtar -cz -f $(DIST_DIR)/$(DISTRIB).tar.gz $(TARGET)
	@ls $(DIST_DIR)/$(DISTRIB)*
	@touch $@
endif
$(SOURCE_DIR)/.$(SDK).loaded:
	$(call Load_Modul,$(SDK),$(SDK_URL),$(SDK_TAR))
$(SOURCE_DIR)/.$(SDK).extracted: $(SOURCE_DIR)/.$(SDK).loaded
	$(call Extract_Modul,$(SDK),$(TOP_SDK)/$(SDK_VER),$(SDK_TAR),$(TOP_SDK)/$(SDK_TAR_DIR))
    ifneq "$(wildcard $(TOP_SDK)/release_note.txt )" ""
		-@$(MOVE) $(TOP_SDK)/release_note.txt $(TOP_SDK)/$(SDK_VER)/
    endif
    ifneq "$(wildcard $(TOP_SDK)/License )" ""
		-@$(MOVE) $(TOP_SDK)/License $(TOP_SDK)/$(SDK_VER)/
    endif
$(SOURCE_DIR)/.$(SDK).patched: $(SOURCE_DIR)/.$(SDK).extracted
	@$(MAKE) sdk_patch
	@touch $@
$(SOURCE_DIR)/.$(SDK).installed: $(SOURCE_DIR)/.$(SDK).patched
	$(RM) $(SOURCE_DIR)/.$(SDK).distributed
ifeq ($(STANDALONE),y)
	$(call Info_Modul,Install,$(SDK))
	@cp -p -R -f $(SDK_DIR)/include/* $(TARGET_DIR)/include/
	@cp -p -R -f $(SDK_DIR)/lib/* $(TARGET_DIR)/lib/
	@sed -e 's/\r//' $(SDK_DIR)/ld/eagle.app.v6.ld | sed -e s@../ld/@@ >$(TARGET_DIR)/lib/eagle.app.v6.ld
	@sed -e 's/\r//' $(SDK_DIR)/ld/eagle.rom.addr.v6.ld >$(TARGET_DIR)/lib/eagle.rom.addr.v6.ld
endif
	@touch $@

#*******************************************
#*************** LIBs section **************
#*******************************************

$(SOURCE_DIR)/.sdk-libs.installed: $(TARGET_DIR)/lib/libc.a $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	$(call Info_Modul,Modify,Libs)
	@$(MAKE) libc
	$(TOOLCHAIN)/bin/$(XOCP) --rename-section .text=.irom0.text \
		--rename-section .literal=.irom0.literal $(<) $(TARGET_DIR)/lib/libcirom.a;
	#@touch $@
	$(info #### libcirom.a...    ####)
	@$(MAKE) libmain
	@$(MAKE) libgcc
	@$(MAKE) libstdc++
	@touch $@

libc_objs = lib_a-bzero.o lib_a-memcmp.o lib_a-memcpy.o lib_a-memmove.o lib_a-memset.o lib_a-rand.o \
		lib_a-strcmp.o lib_a-strcpy.o lib_a-strlen.o lib_a-strncmp.o lib_a-strncpy.o lib_a-strstr.o
libc: $(TARGET_DIR)/lib/libc.a | $(TOOLCHAIN) $(NLX_DIR)
	$(TOOLCHAIN)/bin/$(XAR) $(AR_DEL) $(TARGET_DIR)/lib/$@.a $(libc_objs)
	$(info #### libc.a ...       ####)

libmain_objs = mem_manager.o time.o
libmain: $(TARGET_DIR)/lib/libmain.a
	@$(TOOLCHAIN)/bin/$(XAR) $(AR_DEL) $(TARGET_DIR)/lib/$@.a $(libmain_objs)
	@$(TOOLCHAIN)/bin/$(XAR) $(AR_XTRACT) $(TARGET_DIR)/lib/$@.a eagle_lwip_if.o user_interface.o
	@$(TOOLCHAIN)/bin/$(XOCP) $(OCP_REDEF) hostname=wifi_station_hostname eagle_lwip_if.o 
	@$(TOOLCHAIN)/bin/$(XOCP) $(OCP_REDEF) hostname=wifi_station_hostname user_interface.o 
	@$(TOOLCHAIN)/bin/$(XOCP) $(OCP_REDEF) default_hostname=wifi_station_default_hostname eagle_lwip_if.o 
	@$(TOOLCHAIN)/bin/$(XOCP) $(OCP_REDEF) default_hostname=wifi_station_default_hostname user_interface.o 
	@$(TOOLCHAIN)/bin/$(XAR) $(AR_INSERT) $(TARGET_DIR)/lib/$@.a eagle_lwip_if.o user_interface.o
	-@rm -f eagle_lwip_if.o user_interface.o
	$(info #### libmain ...      ####)

libgcc_objs = _addsubdf3.o _addsubsf3.o _divdf3.o _divdi3.o _divsi3.o _extendsfdf2.o _fixdfsi.o _fixunsdfsi.o \
		_fixunssfsi.o _floatsidf.o _floatsisf.o _floatunsidf.o _floatunsisf.o _muldf3.o _muldi3.o _mulsf3.o \
		_truncdfsf2.o _udivdi3.o _udivsi3.o _umoddi3.o _umulsidi3.o
libgcc: $(TARGET_DIR)/lib/libgcc.a
	@$(TOOLCHAIN)/bin/$(XAR) $(AR_DEL) $(TARGET_DIR)/lib/$@.a $(libgcc_objs)
	$(info #### libgcc  ...      ####)

libstdc++_objs = pure.o vterminate.o guard.o functexcept.o del_op.o del_opv.o new_op.o new_opv.o
libstdc++: $(TARGET_DIR)/lib/libstdc++.a
	@$(TOOLCHAIN)/bin/$(XAR) $(AR_DEL) $(TARGET_DIR)/lib/$@.a $(libstdc++_objs)
	$(info #### libstdc ...      ####)
	$(info ##########################)

#*******************************************
#************ submodul section *************
#*******************************************

define Load_Modul
	@$(MKDIR) $(TAR_DIR)
	@if ! test -s $3; then echo "##########################"; fi
	@if ! test -s $3; then echo "#### Load $1..."; fi
	if ! test -s $3; then $(WGET) $2 --output-document $3 && $(RM) $(SOURCE_DIR)/.$1.*ed; fi
	@touch $(SOURCE_DIR)/.$1.loaded
endef

define Extract_Modul
	@if ! test -f $(SOURCE_DIR)/.$1.extracted; then echo "##########################"; fi
	@if ! test -f $(SOURCE_DIR)/.$1.extracted; then echo "#### Extract $1..."; fi
	#### Extract: if not exist $(SOURCE_DIR)/.$1.extracted then $(RMDIR) $2 && $(MKDIR) $2 && untar $3 to $2
	@if ! test -f $(SOURCE_DIR)/.$1.extracted; then $(RMDIR) $2 && $(MKDIR) $2 && $(UNTAR) $3 -C $2; fi
	#### Extract: if $4 exists then mv -f $4/* to $2 && $(RMDIR) $4
	@if test -d $4 && $(MKDIR) $2; then $(MOVE) $4/* $2 && $(RMDIR) $4; fi
	@touch $(SOURCE_DIR)/.$1.extracted
endef

define Config_Modul
	@echo "##########################"
	@echo "#### Config $1..."
	@if ! test -f $(SOURCE_DIR)/.$1.patched; then $(MAKE) $1_patch && touch $(SOURCE_DIR)/.$1.patched; fi
	@$(MKDIR) $2
	#### Config: Path=$(SAFEPATH); cd $2 ../$(CONF_OPT) $3 $4
	PATH=$(SAFEPATH); cd $2; ../$(CONF_OPT) $3 $4 $(QUIET)
	@touch $(SOURCE_DIR)/.$1.configured
endef

define Build_Modul
	@echo "##########################"
	@echo "#### Build $1..."
	#### Build: Path=$(SAFEPATH); $3 $(MAKE) $4 -C $2
	PATH=$(SAFEPATH); $3 $(MAKE) $4 -C $2 $(QUIET) 
	@touch $(SOURCE_DIR)/.$1.builded
endef

define Install_Modul
	echo "##########################"
	echo "#### Install $1..."
	echo "##########################"
	#### "Install: Path=$(SAFEPATH); $(MAKE) $3=$(INST_OPT) -C $2"
	PATH=$(SAFEPATH); $(MAKE) $3 -C $2 $(QUIET)
	touch $(SOURCE_DIR)/.$1.installed
	$(OUTPUT_DATE)
endef

#************** CURSES
$(SOURCE_DIR)/.$(CURSES).loaded:
	$(call Load_Modul,$(CURSES),$(CURSES_URL),$(CURSES_TAR))
$(SOURCE_DIR)/.$(CURSES).extracted: $(SOURCE_DIR)/.$(CURSES).loaded
	$(call Extract_Modul,$(CURSES),$(CURSES_DIR),$(CURSES_TAR),$(CURSES_DIR)/$(CURSES_TAR_DIR))
$(SOURCE_DIR)/.$(CURSES).configured: $(SOURCE_DIR)/.$(CURSES).extracted
	$(call Config_Modul,$(CURSES),$(BUILD_CURSES_DIR),--prefix=$(COMP_LIB)/$(CURSES)-$(CURSES_VERSION),$(CURSES_OPT))
$(SOURCE_DIR)/.$(CURSES).builded: $(SOURCE_DIR)/.$(CURSES).configured
	$(call Build_Modul,$(CURSES),$(BUILD_CURSES_DIR))
$(SOURCE_DIR)/.$(CURSES).installed: $(SOURCE_DIR)/.$(CURSES).builded
	$(call Install_Modul,$(CURSES),$(BUILD_CURSES_DIR),$(INST_OPT))

#************** GMP (GNU Multiple Precision Arithmetic Library)
$(SOURCE_DIR)/.$(GMP).loaded:
	$(call Load_Modul,$(GMP),$(GMP_URL),$(GMP_TAR))
$(SOURCE_DIR)/.$(GMP).extracted: $(SOURCE_DIR)/.$(GMP).loaded
	$(call Extract_Modul,$(GMP),$(GMP_DIR),$(GMP_TAR),$(GMP_DIR)/$(GMP_TAR_DIR))
$(SOURCE_DIR)/.$(GMP).configured: $(SOURCE_DIR)/.$(GMP).extracted
	$(call Config_Modul,$(GMP),$(BUILD_GMP_DIR),--prefix=$(COMP_LIB)/$(GMP)-$(GMP_VERSION),$(GMP_OPT))
$(SOURCE_DIR)/.$(GMP).builded: $(SOURCE_DIR)/.$(GMP).configured
	$(call Build_Modul,$(GMP),$(BUILD_GMP_DIR))
$(SOURCE_DIR)/.$(GMP).installed: $(SOURCE_DIR)/.$(GMP).builded
	$(call Install_Modul,$(GMP),$(BUILD_GMP_DIR),$(INST_OPT))

#************** MPFR (Multiple Precision Floating-Point Reliable Library)
$(SOURCE_DIR)/.$(MPFR).loaded:
	$(call Load_Modul,$(MPFR),$(MPFR_URL),$(MPFR_TAR))
$(SOURCE_DIR)/.$(MPFR).extracted: $(SOURCE_DIR)/.$(MPFR).loaded
	$(call Extract_Modul,$(MPFR),$(MPFR_DIR),$(MPFR_TAR),$(MPFR_DIR)/$(MPFR_TAR_DIR))
$(SOURCE_DIR)/.$(MPFR).configured: $(SOURCE_DIR)/.$(MPFR).extracted $(SOURCE_DIR)/.$(GMP).installed
	$(call Config_Modul,$(MPFR),$(BUILD_MPFR_DIR),--prefix=$(COMP_LIB)/$(MPFR)-$(MPFR_VERSION) -with-$(GMP)=$(COMP_LIB)/$(GMP)-$(GMP_VERSION),$(MPFR_OPT))
$(SOURCE_DIR)/.$(MPFR).builded: $(SOURCE_DIR)/.$(MPFR).configured
	$(call Build_Modul,$(MPFR),$(BUILD_MPFR_DIR))
$(SOURCE_DIR)/.$(MPFR).installed: $(SOURCE_DIR)/.$(MPFR).builded
	$(call Install_Modul,$(MPFR),$(BUILD_MPFR_DIR),$(INST_OPT))

#************** MPC (Multiple precision complex arithmetic Library)
$(SOURCE_DIR)/.$(MPC).loaded:
	$(call Load_Modul,$(MPC),$(MPC_URL),$(MPC_TAR))
$(SOURCE_DIR)/.$(MPC).extracted: $(SOURCE_DIR)/.$(MPC).loaded
	$(call Extract_Modul,$(MPC),$(MPC_DIR),$(MPC_TAR),$(MPC_DIR)/$(MPC_TAR_DIR))
$(SOURCE_DIR)/.$(MPC).configured: $(SOURCE_DIR)/.$(MPC).extracted $(SOURCE_DIR)/.$(GMP).installed $(SOURCE_DIR)/.$(MPFR).installed
	$(call Config_Modul,$(MPC),$(BUILD_MPC_DIR),--prefix=$(COMP_LIB)/$(MPC)-$(MPC_VERSION) -with-$(MPFR)=$(COMP_LIB)/$(MPFR)-$(MPFR_VERSION) -with-$(GMP)=$(COMP_LIB)/$(GMP)-$(GMP_VERSION),$(MPC_OPT))
$(SOURCE_DIR)/.$(MPC).builded: $(SOURCE_DIR)/.$(MPC).configured
	$(call Build_Modul,$(MPC),$(BUILD_MPC_DIR))
$(SOURCE_DIR)/.$(MPC).installed: $(SOURCE_DIR)/.$(MPC).builded
	$(call Install_Modul,$(MPC),$(BUILD_MPC_DIR),$(INST_OPT))

#************** EXPAT
$(SOURCE_DIR)/.$(EXPAT).loaded:
	$(call Load_Modul,$(EXPAT),$(EXPAT_URL),$(EXPAT_TAR))
$(SOURCE_DIR)/.$(EXPAT).extracted: $(SOURCE_DIR)/.$(EXPAT).loaded
	$(call Extract_Modul,$(EXPAT),$(EXPAT_DIR),$(EXPAT_TAR),$(EXPAT_DIR)/$(EXPAT_TAR_DIR))
$(SOURCE_DIR)/.$(EXPAT).configured: $(SOURCE_DIR)/.$(EXPAT).extracted
	$(call Config_Modul,$(EXPAT),$(BUILD_EXPAT_DIR),--prefix=$(COMP_LIB)/$(EXPAT)-$(EXPAT_VERSION),$(EXPAT_OPT))
$(SOURCE_DIR)/.$(EXPAT).builded: $(SOURCE_DIR)/.$(EXPAT).configured
	$(call Build_Modul,$(EXPAT),$(BUILD_EXPAT_DIR))
$(SOURCE_DIR)/.$(EXPAT).installed: $(SOURCE_DIR)/.$(EXPAT).builded
	$(call Install_Modul,$(EXPAT),$(BUILD_EXPAT_DIR),$(INST_OPT))

#************** Binutils (The GNU binary utilities)
$(SOURCE_DIR)/.$(BIN).loaded:
	$(call Load_Modul,$(BIN),$(BIN_URL),$(BIN_TAR))
$(SOURCE_DIR)/.$(BIN).extracted: $(SOURCE_DIR)/.$(BIN).loaded
	$(call Extract_Modul,$(BIN),$(BIN_DIR),$(BIN_TAR),$(BIN_DIR)/$(BIN_TAR_DIR))
$(SOURCE_DIR)/.$(BIN).configured: $(SOURCE_DIR)/.$(BIN).extracted
	$(call Config_Modul,$(BIN),$(BUILD_BIN_DIR),--prefix=$(TOOLCHAIN) -target=$(TARGET),$(BIN_OPT))
$(SOURCE_DIR)/.$(BIN).builded: $(SOURCE_DIR)/.$(BIN).configured
	$(call Build_Modul,$(BIN),$(BUILD_BIN_DIR))
$(SOURCE_DIR)/.$(BIN).installed: $(SOURCE_DIR)/.$(BIN).builded
	$(call Install_Modul,$(BIN),$(BUILD_BIN_DIR),$(INST_OPT))

#************** ISL
$(SOURCE_DIR)/.$(ISL).loaded:
	$(call Load_Modul,$(ISL),$(ISL_URL),$(ISL_TAR))
$(SOURCE_DIR)/.$(ISL).extracted: $(SOURCE_DIR)/.$(ISL).loaded
	$(call Extract_Modul,$(ISL),$(ISL_DIR),$(ISL_TAR),$(ISL_DIR)/$(ISL_TAR_DIR))
$(SOURCE_DIR)/.$(ISL).configured: $(SOURCE_DIR)/.$(ISL).extracted $(SOURCE_DIR)/.$(GMP).installed
	$(call Config_Modul,$(ISL),$(BUILD_ISL_DIR),--prefix=$(COMP_LIB)/$(ISL)-$(ISL_VERSION),$(ISL_OPT))
$(SOURCE_DIR)/.$(ISL).builded: $(SOURCE_DIR)/.$(ISL).configured
	$(call Build_Modul,$(ISL),$(BUILD_ISL_DIR))
$(SOURCE_DIR)/.$(ISL).installed: $(SOURCE_DIR)/.$(ISL).builded
	$(call Install_Modul,$(ISL),$(BUILD_ISL_DIR),$(INST_OPT))

#************** CLooG
$(SOURCE_DIR)/.$(CLOOG).loaded:
	$(call Load_Modul,$(CLOOG),$(CLOOG_URL),$(CLOOG_TAR))
$(SOURCE_DIR)/.$(CLOOG).extracted: $(SOURCE_DIR)/.$(CLOOG).loaded
	$(call Extract_Modul,$(CLOOG),$(CLOOG_DIR),$(CLOOG_TAR),$(CLOOG_DIR)/$(CLOOG_TAR_DIR))
$(SOURCE_DIR)/.$(CLOOG).configured: $(SOURCE_DIR)/.$(CLOOG).extracted $(SOURCE_DIR)/.$(GMP).installed $(SOURCE_DIR)/.$(ISL).installed
	$(call Config_Modul,$(CLOOG),$(BUILD_CLOOG_DIR),--prefix=$(COMP_LIB)/$(CLOOG)-$(CLOOG_VERSION),$(CLOOG_OPT))
$(SOURCE_DIR)/.$(CLOOG).builded: $(SOURCE_DIR)/.$(CLOOG).configured
	$(call Build_Modul,$(CLOOG),$(BUILD_CLOOG_DIR))
$(SOURCE_DIR)/.$(CLOOG).installed: $(SOURCE_DIR)/.$(CLOOG).builded
	$(call Install_Modul,$(CLOOG),$(BUILD_CLOOG_DIR),$(INST_OPT))

#************** GCC (The GNU C preprocessor)
$(SOURCE_DIR)/.$(GCC).loaded:
	$(call Load_Modul,$(GCC),$(GCC_URL),$(GCC_TAR))
$(SOURCE_DIR)/.$(GCC).extracted: $(SOURCE_DIR)/.$(GCC).loaded
	$(call Extract_Modul,$(GCC),$(GCC_DIR),$(GCC_TAR),$(GCC_DIR)/$(GCC_TAR_DIR))
#************** GCC Pass 1
$(SOURCE_DIR)/.$(GCC)-pass-1.configured: $(SOURCE_DIR)/.$(GCC).extracted
	$(call Config_Modul,$(GCC)-pass-1,$(BUILD_GCC_DIR)-pass-1,--prefix=$(TOOLCHAIN) -target=$(TARGET),$(GC1_OPT))
$(SOURCE_DIR)/.$(GCC)-pass-1.builded: $(SOURCE_DIR)/.$(GCC)-pass-1.configured
	$(call Build_Modul,$(GCC)-pass-1,$(BUILD_GCC_DIR)-pass-1,,all-gcc)
$(SOURCE_DIR)/.$(GCC)-pass-1.installed: $(SOURCE_DIR)/.$(GCC)-pass-1.builded
	$(call Install_Modul,$(GCC)-pass-1,$(BUILD_GCC_DIR)-pass-1,install-gcc)
	@cp -p -f $(TOOLCHAIN)/bin/$(XGCC) $(TOOLCHAIN)/bin/$(XCC)

$(TOOLCHAIN)/bin/$(XGCC): $(SOURCE_DIR)/.$(BIN).installed
	@cp -p -f $(TOOLCHAIN)/bin/$(XGCC) $(TOOLCHAIN)/bin/$(XCC)

#************** GCC Pass 2
$(SOURCE_DIR)/.$(GCC)-pass-2.configured: $(SOURCE_DIR)/.$(GCC)-pass-1.installed $(SOURCE_DIR)/.$(NLX).installed
	$(call Config_Modul,$(GCC)-pass-2,$(BUILD_GCC_DIR)-pass-2,--prefix=$(TOOLCHAIN) -target=$(TARGET),$(GC2_OPT))
$(SOURCE_DIR)/.$(GCC)-pass-2.builded: $(SOURCE_DIR)/.$(GCC)-pass-2.configured
	$(call Build_Modul,$(GCC)-pass-2,$(BUILD_GCC_DIR)-pass-2)
$(SOURCE_DIR)/.$(GCC)-pass-2.installed: $(SOURCE_DIR)/.$(GCC)-pass-2.builded
	$(call Install_Modul,$(GCC)-pass-2,$(BUILD_GCC_DIR)-pass-2,$(INST_OPT))

#************** Newlib (ANSI C library, math library, and collection of board support packages)
$(SOURCE_DIR)/.$(NLX).loaded:
	$(call Load_Modul,$(NLX),$(NLX_URL),$(NLX_TAR))
$(SOURCE_DIR)/.$(NLX).extracted: $(SOURCE_DIR)/.$(NLX).loaded
	$(call Extract_Modul,$(NLX),$(NLX_DIR),$(NLX_TAR),$(NLX_DIR)/$(NLX_TAR_DIR))
$(SOURCE_DIR)/.$(NLX).configured: $(SOURCE_DIR)/.$(NLX).extracted
	$(call Config_Modul,$(NLX),$(BUILD_NLX_DIR),$(NLX_OPT1),--prefix=$(TOOLCHAIN) -target=$(TARGET),$(NLX_OPT))
$(SOURCE_DIR)/.$(NLX).builded: $(SOURCE_DIR)/.$(NLX).configured
	$(call Build_Modul,$(NLX),$(BUILD_NLX_DIR),$(NLX_OPT1),all)
	@$(MAKE) -C $(BUILD_NLX_DIR) $(QUIET)
$(SOURCE_DIR)/.$(NLX).installed: $(SOURCE_DIR)/.$(NLX).builded
	$(call Install_Modul,$(NLX),$(BUILD_NLX_DIR),$(INST_OPT))

#************** Libhal (Hardware Abstraction Library for Xtensa LX106)
$(SOURCE_DIR)/.$(HAL).loaded:
	$(call Load_Modul,$(HAL),$(HAL_URL),$(HAL_TAR))
$(SOURCE_DIR)/.$(HAL).extracted: $(SOURCE_DIR)/.$(HAL).loaded
	$(call Extract_Modul,$(HAL),$(HAL_DIR),$(HAL_TAR),$(HAL_DIR)/$(HAL_TAR_DIR))
	@cd $(HAL_DIR); autoreconf -i $(QUIET)
$(SOURCE_DIR)/.$(HAL).configured: $(SOURCE_DIR)/.$(HAL).extracted
	$(call Config_Modul,$(HAL),$(BUILD_HAL_DIR),--host=$(TARGET) -prefix=$(TOOLCHAIN)/$(TARGET),$(HAL_OPT))
$(SOURCE_DIR)/.$(HAL).builded: $(SOURCE_DIR)/.$(HAL).configured
	$(call Build_Modul,$(HAL),$(BUILD_HAL_DIR))
$(SOURCE_DIR)/.$(HAL).installed: $(SOURCE_DIR)/.$(HAL).builded
	$(call Install_Modul,$(HAL),$(BUILD_HAL_DIR),$(INST_OPT))

#************** GDB (The GNU debugger)
$(SOURCE_DIR)/.$(GDB).loaded:
	$(call Load_Modul,$(GDB),$(GDB_URL),$(GDB_TAR))
$(SOURCE_DIR)/.$(GDB).extracted: $(SOURCE_DIR)/.$(GDB).loaded
	$(call Extract_Modul,$(GDB),$(GDB_DIR),$(GDB_TAR),$(GDB_DIR)/$(GDB_TAR_DIR))
$(SOURCE_DIR)/.$(GDB).configured: $(SOURCE_DIR)/.$(GDB).extracted
	$(call Config_Modul,$(GDB),$(BUILD_GDB_DIR),--prefix=$(COMP_LIB)/$(GDB)-$(GDB_VERSION),$(GDB_OPT))
$(SOURCE_DIR)/.$(GDB).builded: $(SOURCE_DIR)/.$(GDB).configured
	$(call Build_Modul,$(GDB),$(BUILD_GDB_DIR))
$(SOURCE_DIR)/.$(GDB).installed: $(SOURCE_DIR)/.$(GDB).builded
	$(call Install_Modul,$(GDB),$(BUILD_GDB_DIR),$(INST_OPT))

#************** LWIP
$(SOURCE_DIR)/.$(LWIP).loaded:
	$(call Load_Modul,$(LWIP),$(LWIP_URL),$(LWIP_TAR))
$(SOURCE_DIR)/.$(LWIP).extracted: $(SOURCE_DIR)/.$(LWIP).loaded
	$(call Extract_Modul,$(LWIP),$(LWIP_DIR),$(LWIP_TAR),$(LWIP_DIR)/$(LWIP_TAR_DIR))
$(SOURCE_DIR)/.$(LWIP).configured: $(SOURCE_DIR)/.$(LWIP).extracted
	$(call Config_Modul,$(LWIP),$(BUILD_LWIP_DIR))
$(SOURCE_DIR)/.$(LWIP).builded: $(SOURCE_DIR)/.$(LWIP).configured
	$(call Build_Modul,$(LWIP),$(BUILD_LWIP_DIR) -f Makefile.open install CC=$(TOOLCHAIN)/bin/$(XGCC) AR=$(TOOLCHAIN)/bin/$(XAR) PREFIX=$(TOOLCHAIN))
$(SOURCE_DIR)/.$(LWIP).installed: $(SOURCE_DIR)/.$(LWIP).builded
	$(call Install_Modul,$(LWIP),$(BUILD_LWIP_DIR),$(INST_OPT))
	@cp -p -a $(LWIP_DIR)/include/arch $(LWIP_DIR)/include/lwip $(LWIP_DIR)/include/netif $(LWIP_DIR)/include/lwipopts.h $(TARGET_DIR)/include/

#*******************************************
#*******************************************
#*******************************************

#************** Strip Debug
$(SOURCE_DIR)/.$(SDK).stripped:
	@$(OUTPUT_DATE)
	$(info ##########################)
	$(info #### stripping...)
	$(info ##########################)
	@du -sh $(TOOLCHAIN)/bin
	-@find $(TOOLCHAIN) -maxdepth 2 -type f -perm /0111 -exec strip -s "{}" +
	@du -sh $(TOOLCHAIN)/bin
	$(RM) $(SOURCE_DIR)/.$(SDK).distributed
	@touch $@

#************** Compress via UPX
$(SOURCE_DIR)/.$(SDK).compressed:
	@$(OUTPUT_DATE)
	$(info ##########################)
	$(info #### compressing...)
	$(info ##########################)
	@du -sh $(TOOLCHAIN)/bin
	-@find $(TOOLCHAIN) -maxdepth 2 -type f -perm /0111 -exec upx -q -1 "{}" +
	@$(OUTPUT_DATE)
	@du -sh $(TOOLCHAIN)/bin
	$(RM) $(SOURCE_DIR)/.$(SDK).distributed
	@touch $@

#*******************************************
#************** patch section **************
#*******************************************

sdk_patch_1.4.0-rtos:
sdk_patch_1.3.0-rtos:

sdk_patch_2.1.0 sdk_patch_2.1.x sdk_patch_2.2.0 sdk_patch_2.2.x: $(SDK_DIR)/user_rf_cal_sector_set.o
	@echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION $(ESP_SDK_VERSION)" >>$(SDK_DIR)/include/esp_sdk_ver.h
	-@$(PATCH) -d $(SDK_DIR) -p1 -i $(PATCHES_DIR)/c_types-c99_sdk_2.patch $(QUIET)
	@cd $(SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/$(XAR) x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/$(XAR) rs libwpa.a tmp/*.o; rm -R tmp
	@$(TOOLCHAIN)/bin/$(XAR) r $(SDK_DIR)/lib/libmain.a $(SDK_DIR)/user_rf_cal_sector_set.o
sdk_patch_2.0.0: ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip $(SDK_DIR)/user_rf_cal_sector_set.o
	@echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION $(ESP_SDK_VERSION)" >>$(SDK_DIR)/include/esp_sdk_ver.h
	@$(UNTAR) $(PATCHES_DIR)/ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip
	-@$(MOVE) libmain.a libnet80211.a libpp.a $(SDK_DIR_2.0.0)/lib/
	-@$(PATCH) -d $(SDK_DIR) -p1 -i $(PATCHES_DIR)/c_types-c99_sdk_2.patch $(QUIET)
	@cd $(SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/$(XAR) x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/$(XAR) rs libwpa.a tmp/*.o; rm -R tmp
	@$(TOOLCHAIN)/bin/$(XAR) r $(SDK_DIR)/lib/libmain.a $(SDK_DIR)/user_rf_cal_sector_set.o
sdk_patch_1.5.0 sdk_patch_1.5.1 sdk_patch_1.5.4:
	@echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION $(ESP_SDK_VERSION)" >>$(SDK_DIR)/include/esp_sdk_ver.h
	-@$(PATCH) -d $(SDK_DIR) -p1 -i $(PATCHES_DIR)/c_types-c99.patch $(QUIET)
	@cd $(SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/$(XAR) x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/$(XAR) rs libwpa.a tmp/*.o; rm -R tmp
sdk_patch_1.5.3:
	@echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION $(ESP_SDK_VERSION)" >>$(SDK_DIR)/include/esp_sdk_ver.h
	-@$(PATCH) -d $(SDK_DIR) -p1 -i $(PATCHES_DIR)/c_types-c99.patch $(QUIET)
	@$CP FRM_ERR_PATCH/*.a $(SDK_DIR)/lib/
sdk_patch_1.5.2: Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip
	@echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION $(ESP_SDK_VERSION)" >>$(SDK_DIR)/include/esp_sdk_ver.h
	@$(UNTAR) $(PATCHES_DIR)/Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip 
	-@$(MOVE) libssl.a libnet80211.a libmain.a $(SDK_DIR_1.5.2)/lib/
	-@$(PATCH) -d $(SDK_DIR) -p1 -i $(PATCHES_DIR)/c_types-c99.patch $(QUIET)
	@cd $(SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/$(XAR) x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/$(XAR) rs libwpa.a tmp/*.o; rm -R tmp

sdk_patch:
	@$(MAKE) sdk_patch_$(SDK_VERSION)

$(GMP)_patch:
$(MPFR)_patch:
$(MPC)_patch:

$(GCC)-pass-1_patch:

$(GCC)-pass-2_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(GCC)/$(GCC_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(GCC)/$(GCC_VERSION)/*.patch; do $(PATCH) -d $(GCC_DIR) -p1 < $$i $(QUIET); done
endif

$(CURSES)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(CURSES)/$(CURSES_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(CURSES)/$(CURSES_VERSION)/*.patch; do $(PATCH) -d $(CURSES_DIR) -p1 < $$i $(QUIET); done
endif

$(BIN)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(BIN)/$(BIN_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(BIN)/$(BIN_VERSION)/*.patch; do $(PATCH) -d $(BIN_DIR) -p1 < $$i $(QUIET); done
endif

$(ISL)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(ISL)/$(ISL_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(ISL)/$(ISL_VERSION)/*.patch; do $(PATCH) -d $(ISL_DIR) -p1 < $$i $(QUIET); done
endif

$(CLOOG)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(CLOOG)/$(CLOOG_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(CLOOG)/$(CLOOG_VERSION)/*.patch; do $(PATCH) -d $(CLOOG_DIR) -p1 < $$i $(QUIET); done
endif

$(EXPAT)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(EXPAT)/$(EXPAT_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(EXPAT)/$(EXPAT_VERSION)/*.patch; do $(PATCH) -d $(EXPAT_DIR) -p1 < $$i $(QUIET); done
endif

$(HAL)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(HAL)/$(HAL_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(HAL)/$(HAL_VERSION)/*.patch; do $(PATCH) -d $(HAL_DIR) -p1 < $$i $(QUIET); done
endif

$(NLX)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(NLX)/$(NLX_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(NLX)/$(NLX_VERSION)/*.patch; do $(PATCH) -d $(NLX_DIR) -p1 < $$i $(QUIET); done
	-@touch $(NLX_DIR)/$(NLX)/libc/sys/xtensa/include/xtensa/dummy.h
endif

$(GDB)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(GDB)/$(GDB_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(GDB)/$(GDB_VERSION)/*.patch; do $(PATCH) -d $(GDB_DIR) -p1 < $$i $(QUIET); done
endif

$(LWIP)_patch:
ifneq "$(wildcard $(PATCHES_DIR)/$(LWIP)/$(LWIP_VERSION) )" ""
	-for i in $(PATCHES_DIR)/$(LWIP)/$(LWIP_VERSION)/*.patch; do $(PATCH) -d $(LWIP_DIR) -p1 < $$i $(QUIET); done
endif

Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip:
	@$(WGET) --content-disposition "http://bbs.espressif.com/download/file.php?id=1168" --output-document $(PATCHES_DIR)/$@
ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip:
	@$(WGET) --content-disposition "http://bbs.espressif.com/download/file.php?id=1654" --output-document $(PATCHES_DIR)/$@

$(SDK_DIR)/user_rf_cal_sector_set.o: $(SOURCE_DIR)/.$(SDK).extracted $(TOOLCHAIN)/bin/$(XGCC)
	@cp -p $(PATCHES_DIR)/user_rf_cal_sector_set.c $(SDK_DIR)
	@cd $(SDK_DIR); $(TOOLCHAIN)/bin/$(XGCC) -O2 -I$(SDK_DIR)/include -c $(SDK_DIR)/user_rf_cal_sector_set.c

#*******************************************
#************** clean section **************
#*******************************************
clean: clean-sdk clean-build

clean-build:
	$(info ##########################)
	$(info #### cleaning...)
	$(info ##########################)
	-@$(RMDIR) $(TOOLCHAIN) $(COMP_LIB)/ $(BUILD_GMP_DIR) $(BUILD_MPFR_DIR) $(BUILD_MPC_DIR) $(BUILD_CURSES_DIR) $(BUILD_BIN_DIR) $(BUILD_ISL_DIR) $(BUILD_CLOOG_DIR)
	-@$(RMDIR) $(BUILD_GCC_DIR)-pass-1 $(BUILD_NLX_DIR) $(BUILD_GCC_DIR)-pass-2 $(BUILD_HAL_DIR) $(BUILD_GDB_DIR)
	-rm -f $(SOURCE_DIR)/.*ed
clean-sdk:
	$(info ##########################)
	$(info #### clean-sdk...)
	$(info ##########################)
	-rm -rf $(TOP_SDK)
	-$(MAKE) -C $(LWIP_DIR) -f Makefile.open clean

purge: clean
	$(info ##########################)
	$(info #### purge...)
	$(info ##########################)
	-rm -rf $(GMP_DIR) $(MPFR_DIR) $(MPC_DIR) $(CURSES_DIR) $(BIN_DIR) $(ISL_DIR) $(CLOOG_DIR)
	-rm -rf $(GCC_DIR) $(NLX_DIR) $(HAL_DIR) $(GDB_DIR)
#rm -rf $(TAR_DIR)/*.{zip,bz2,xz,gz}