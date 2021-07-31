include $(TOPDIR)/rules.mk

PKG_NAME:=dpinger
PKG_VERSION:=3.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/dennypage/dpinger.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=cee7ac9da0febde90adc538930139edfd33719c8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=b5b34bd75818eb2b35c5cb854c1fa6b64be769a1fad5cfe5a7a64e3e3d4e3530

PKG_LICENSE:=BSD 2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  CATEGORY:=Custom
  TITLE:=Link Monitoring
  DEPENDS:=+libpthread
endef

define Package/$(PKG_NAME)/description
  dpinger is a daemon for continuous monitoring of latency and loss on a network connection.
  It is intended for use by firewalls to monitor link health, as well as for providing
  information to various monitoring systems such as Cacti, Nagios, Zabbix, etc.
endef

define Build/Compile
	$(TARGET_CC) -g -O2 -lpthread $(PKG_BUILD_DIR)/dpinger.c -o $(PKG_BUILD_DIR)/dpinger
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dpinger $(1)/usr/bin
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
