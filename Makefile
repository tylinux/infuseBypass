TARGET := appletv:clang:latest:17.0
THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
INSTALL_TARGET_PROCESSES = infuse


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = infuseBypass

infuseBypass_FILES = InfuseBypass/InfuseBypass.mm
infuseBypass_USE_MODULES = 0
infuseBypass_CFLAGS = -fobjc-arc -Wno-unused-function

include $(THEOS_MAKE_PATH)/tweak.mk
