include $(TOPDIR)/rules.mk

PKG_NAME:=nuttcp
PKG_VERSION:=8.1.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://nuttcp.net/nuttcp/
PKG_HASH:=737f702ec931ec12fcf54e66c4c1d5af72bd3631439ffa724ed2ac40ab2de78d
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  CATEGORY:=Custom
  TITLE:=Performance Measurement
  DEPENDS:=+libpthread
endef

define Package/$(PKG_NAME)/description
  nuttcp is a network performance measurement tool intended for use by network and system managers.
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)"

define Build/Compile
	$(TARGET_CC) -g -O2 -lpthread $(PKG_BUILD_DIR)/nuttcp.c -o $(PKG_BUILD_DIR)/nuttcp
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nuttcp $(1)/usr/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
