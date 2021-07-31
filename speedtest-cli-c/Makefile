include $(TOPDIR)/rules.mk

PKG_NAME:=speedtest-cli-c
PKG_VERSION:=01-01-2019
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/haibbo/speedtest-cli.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=bf70b1c93053fe1e4253143e435127fe71d78b45
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=b5b34bd75818eb2b35c5cb854c1fa6b64be769a1fad5cfe5a7a64e3e3d4e3530

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  CATEGORY:=Custom
  TITLE:=speedtest-cli C base bandwidth testing
  DEPENDS:=+libpthread +libcurl +libexpat
endef

define Package/$(PKG_NAME)/description
  Command line interface for testing internet bandwidth using speedtest.net
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)"

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) speedtest_cli
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/speedtest_cli $(1)/usr/bin
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
