#
# Copyright (C) 2023 THDN Print Server Project
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cups
PKG_VERSION:=2.4.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source.tar.gz
PKG_SOURCE_URL:=https://github.com/OpenPrinting/cups/releases/download/v$(PKG_VERSION)/
PKG_HASH:=skip

PKG_BUILD_DEPENDS:=libpng zlib
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/cups
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System
  URL:=https://www.cups.org/
  DEPENDS:=+libpthread +libpng +zlib +libusb-1.0
endef

define Package/cups/description
 CUPS is the standards-based, open source printing system developed
 by Apple Inc. for macOS and other UNIX-like operating systems.
endef

define Package/cups-bsd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=CUPS BSD commands
  DEPENDS:=+cups
endef

define Package/cups-client
  SECTION:=net
  CATEGORY:=Network
  TITLE:=CUPS client
  DEPENDS:=+cups
endef

define Package/cups-filters
  SECTION:=net
  CATEGORY:=Network
  TITLE:=CUPS filters
  DEPENDS:=+cups +ghostscript
endef

define Package/cups-ppdc
  SECTION:=net
  CATEGORY:=Network
  TITLE:=CUPS PPDC compiler
  DEPENDS:=+cups
endef

CONFIGURE_ARGS += \
	--libdir=/usr/lib \
	--disable-gssapi \
	--disable-dnssd \
	--disable-avahi \
	--disable-libpaper \
	--disable-systemd \
	--without-rcdir \
	--without-init-dir \
	--without-systemd \
	--without-php \
	--without-perl \
	--without-python \
	--without-dbus \
	--enable-browsing \
	--enable-webif \
	--with-cups-user=cups \
	--with-cups-group=cups \
	--with-system-groups="cups" \
	--with-printcap=/etc/printcap \
	--with-log-file-perm=0644 \
	--with-log-dir=/var/log/cups \
	--with-request-root=/var/spool/cups \
	--with-cupsd-file-perm=0755 \
	--with-cupsd-user=root \
	--with-cupsd-group=root

define Build/Configure
	$(call Build/Configure/Default)
	$(SED) 's|/usr/bin/install|install|g' $(PKG_BUILD_DIR)/Makefile
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fPIC" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/cups/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/cups
	$(INSTALL_DIR) $(1)/var/log/cups
	$(INSTALL_DIR) $(1)/var/spool/cups
	$(INSTALL_DIR) $(1)/etc/init.d
	
	# Install binaries
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cupsd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cupsctl $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cupsaccept $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cupsreject $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cupsenable $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cupsdisable $(1)/usr/sbin/
	
	# Install client tools
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lp $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpr $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpstat $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpoptions $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpadmin $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lppasswd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cancel $(1)/usr/bin/
	
	# Install libraries
	$(CP) $(PKG_BUILD_DIR)/cups/*.so* $(1)/usr/lib/
	
	# Install configuration files
	$(INSTALL_CONF) ./files/cupsd.conf $(1)/etc/cups/
	$(INSTALL_DATA) ./files/mime.types $(1)/etc/cups/
	$(INSTALL_DATA) ./files/mime.convs $(1)/etc/cups/
	
	# Install init script
	$(INSTALL_BIN) ./files/cups.init $(1)/etc/init.d/cups
	
	# Create directories
	$(INSTALL_DIR) $(1)/var/spool/cups/tmp
	$(INSTALL_DIR) $(1)/var/spool/cups/cache
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(INSTALL_DIR) $(1)/usr/share/cups/doc
endef

define Package/cups-bsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpq $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lprm $(1)/usr/bin/
endef

define Package/cups-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lp $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpr $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpstat $(1)/usr/bin/
endef

$(eval $(call BuildPackage,cups))
$(eval $(call BuildPackage,cups-bsd))
$(eval $(call BuildPackage,cups-client))
$(eval $(call BuildPackage,cups-filters))
$(eval $(call BuildPackage,cups-ppdc))
