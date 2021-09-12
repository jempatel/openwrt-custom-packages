include $(TOPDIR)/rules.mk

PKG_NAME:=base-utils
PKG_VERSION:=1.0
PKG_RELEASE:=2

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  TITLE:=Base Utilities
  CATEGORY:=Custom
  DEPENDS:= +base-files +curl +rpcd +uci +uuidgen +jsonfilter +libubox +jq
endef

define Package/$(PKG_NAME)/description
  Base Utilities
endef

define Build/$(PKG_NAME)/Prepare
  mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
  $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
