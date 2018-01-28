ARCHS ?= $(NEUTRAL_ARCH)

ifeq ($(SYSROOT),)
ifneq ($(wildcard $(THEOS_SDKS_PATH)/$(_THEOS_TARGET_PLATFORM_SDK_NAME)$(_THEOS_TARGET_SDK_VERSION).sdk),)
SYSROOT ?= $(THEOS_SDKS_PATH)/$(_THEOS_TARGET_PLATFORM_SDK_NAME)$(_THEOS_TARGET_SDK_VERSION).sdk
ISYSROOT ?= $(THEOS_SDKS_PATH)/$(_THEOS_TARGET_PLATFORM_SDK_NAME)$(_THEOS_TARGET_INCLUDE_SDK_VERSION).sdk
else
SYSROOT ?= $(THEOS_PLATFORM_SDK_ROOT)/Platforms/$(_THEOS_TARGET_PLATFORM_SDK_NAME).platform/Developer/SDKs/$(_THEOS_TARGET_PLATFORM_SDK_NAME)$(_THEOS_TARGET_SDK_VERSION).sdk
ISYSROOT ?= $(THEOS_PLATFORM_SDK_ROOT)/Platforms/$(_THEOS_TARGET_PLATFORM_SDK_NAME).platform/Developer/SDKs/$(_THEOS_TARGET_PLATFORM_SDK_NAME)$(_THEOS_TARGET_INCLUDE_SDK_VERSION).sdk
endif
else
ISYSROOT ?= $(SYSROOT)
endif

TARGET_PRIVATE_FRAMEWORK_PATH ?= $(SYSROOT)/System/Library/PrivateFrameworks
TARGET_PRIVATE_FRAMEWORK_INCLUDE_PATH ?= $(ISYSROOT)/System/Library/PrivateFrameworks

ifeq ($(_THEOS_DARWIN_CAN_USE_MODULES),1)
MODULESFLAGS := -fmodules -fcxx-modules -fmodule-name=$(THEOS_CURRENT_INSTANCE) -fbuild-session-file=$(_THEOS_BUILD_SESSION_FILE) -fmodules-prune-after=345600 -fmodules-prune-interval=86400 -fmodules-validate-once-per-build-session
endif

# “iOS 9 changed the 32-bit pagesize on 64-bit CPUs from 4096 bytes to 16384:
# all 32-bit binaries must now be compiled with -Wl,-segalign,4000.”
# https://twitter.com/saurik/status/654198997024796672

ifneq ($(THEOS_CURRENT_ARCH),arm64)
LEGACYFLAGS := -Xlinker -segalign -Xlinker 4000
endif

# TODO: this seems unnecessary now?
# SDKFLAGS := -D__IPHONE_OS_VERSION_MIN_REQUIRED=__IPHONE_$(subst .,_,$(_THEOS_TARGET_IPHONEOS_DEPLOYMENT_VERSION))
VERSIONFLAGS := -m$(_THEOS_TARGET_PLATFORM_FLAG_NAME)-version-min=$(_THEOS_TARGET_OS_DEPLOYMENT_VERSION)

_THEOS_TARGET_CFLAGS := -isysroot "$(ISYSROOT)" $(SDKFLAGS) $(VERSIONFLAGS) $(_THEOS_TARGET_CC_CFLAGS) $(MODULESFLAGS)
_THEOS_TARGET_LDFLAGS := -isysroot "$(SYSROOT)" $(SDKFLAGS) $(VERSIONFLAGS) $(LEGACYFLAGS) -multiply_defined suppress

_THEOS_TARGET_SWIFTFLAGS := -sdk "$(SYSROOT)" $(_THEOS_TARGET_CC_SWIFTFLAGS)
_THEOS_TARGET_SWIFT_TARGET := $(_THEOS_TARGET_PLATFORM_SWIFT_NAME)$(_THEOS_TARGET_DARWIN_DEPLOYMENT_VERSION)

ifeq ($(call __executable,$(TARGET_SWIFT)),$(_THEOS_TRUE))
_THEOS_TARGET_SWIFT_VERSION := $(shell $(TARGET_SWIFT) --version | head -1 | cut -d' ' -f4)
_THEOS_TARGET_SWIFT_LDPATH := $(THEOS_VENDOR_LIBRARY_PATH)/libswift/$(_THEOS_TARGET_SWIFT_VERSION)
endif

ifeq ($(_THEOS_TARGET_DARWIN_BUNDLE_TYPE),hierarchial)
_THEOS_TARGET_BUNDLE_INFO_PLIST_SUBDIRECTORY := /Contents
_THEOS_TARGET_BUNDLE_RESOURCE_SUBDIRECTORY := /Contents/Resources
_THEOS_TARGET_BUNDLE_BINARY_SUBDIRECTORY := /Contents/MacOS
_THEOS_TARGET_BUNDLE_HEADERS_SUBDIRECTORY := /Contents/Headers
else
_THEOS_TARGET_BUNDLE_INFO_PLIST_SUBDIRECTORY :=
_THEOS_TARGET_BUNDLE_RESOURCE_SUBDIRECTORY :=
_THEOS_TARGET_BUNDLE_BINARY_SUBDIRECTORY :=
_THEOS_TARGET_BUNDLE_HEADERS_SUBDIRECTORY := /Headers
endif
