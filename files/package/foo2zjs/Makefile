#
# Copyright (C) 2023 THDN Print Server Project
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=foo2zjs
PKG_VERSION:=20201202
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.jonof.id.au/files/foo2zjs/
PKG_HASH:=skip

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/foo2zjs
  SECTION:=net
  CATEGORY:=Network
  TITLE:=HP LaserJet 1020/1020plus/1007/1008/1108 driver
  URL:=https://www.jonof.id.au/foo2zjs/
  DEPENDS:=+libcups +libusb-1.0
endef

define Package/foo2zjs/description
  foo2zjs is an open source printer driver for printers that use the
  Zenographics ZjStream wire protocol for their print data, such as the
  HP LaserJet 1020, HP LaserJet Pro P1102, HP LaserJet Pro M12a/M12w,
  and other compatible printers.
endef

define Package/foo2xqx
  SECTION:=net
  CATEGORY:=Network
  TITLE:=HP LaserJet 1000/1005/1018/1020/1022 driver
  DEPENDS:=+foo2zjs
endef

define Package/foo2hp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=HP LaserJet 1000/1150/1200/1220/1300 driver
  DEPENDS:=+foo2zjs
endef

define Package/foo2zjs-common
  SECTION:=net
  CATEGORY:=Network
  TITLE:=foo2zjs common files
  DEPENDS:=+foo2zjs
endef

CONFIGURE_ARGS += \
	--prefix=/usr \
	--enable-cups \
	--enable-usb \
	--disable-static

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/foo2zjs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(INSTALL_DIR) $(1)/usr/share/cups/model
	
	# Install foo2zjs binary
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2zjs $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2zjs-wrapper $(1)/usr/bin/
	
	# Install CUPS filter
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2zjs-wrapper $(1)/usr/lib/cups/filter/foo2zjs
	
	# Install PPD files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/PPD/*.ppd $(1)/usr/share/cups/model/
	
	# Install ICC profiles
	$(INSTALL_DIR) $(1)/usr/share/foo2zjs
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/icm/*.icm $(1)/usr/share/foo2zjs/
endef

define Package/foo2xqx/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(INSTALL_DIR) $(1)/usr/share/cups/model
	
	# Install foo2xqx binary
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2xqx $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2xqx-wrapper $(1)/usr/bin/
	
	# Install CUPS filter
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2xqx-wrapper $(1)/usr/lib/cups/filter/foo2xqx
	
	# Install PPD files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/PPD/HP-LaserJet_1020.ppd $(1)/usr/share/cups/model/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/PPD/HP-LaserJet_1020plus.ppd $(1)/usr/share/cups/model/
endef

define Package/foo2hp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(INSTALL_DIR) $(1)/usr/share/cups/model
	
	# Install foo2hp binary
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2hp $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2hp-wrapper $(1)/usr/bin/
	
	# Install CUPS filter
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/foo2hp-wrapper $(1)/usr/lib/cups/filter/foo2hp
	
	# Install PPD files for HP 1007/1008/1108
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/PPD/HP-LaserJet_1007.ppd $(1)/usr/share/cups/model/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/PPD/HP-LaserJet_1008.ppd $(1)/usr/share/cups/model/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/PPD/HP-LaserJet_1108.ppd $(1)/usr/share/cups/model/
endef

define Package/foo2zjs-common/install
	$(INSTALL_DIR) $(1)/usr/share/foo2zjs
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/firmware/sihp1005.dl $(1)/usr/share/foo2zjs/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/firmware/sihp1020.dl $(1)/usr/share/foo2zjs/
endef

$(eval $(call BuildPackage,foo2zjs))
$(eval $(call BuildPackage,foo2xqx))
$(eval $(call BuildPackage,foo2hp))
$(eval $(call BuildPackage,foo2zjs-common))
