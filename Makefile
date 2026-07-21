TARGET := iphone:clang:latest:16.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_PACKAGE_SCHEME = roothide
ARCHS = arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CryptoTicker
CryptoTicker_FILES = Tweak.x
CryptoTicker_CFLAGS = -fobjc-arc

include $(THEOS_PACKAGE_NAME)/tweak.mk
