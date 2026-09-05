# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 ratsdev
#
# Enable switch, YAML editor, and log viewer for Vianes.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-vianes
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for Vianes
LUCI_DESCRIPTION:=LuCI configuration UI for the Vianes traffic steering daemon
LUCI_DEPENDS:=+vianes
LUCI_PKGARCH:=all

PKG_MAINTAINER:=ratsdev <admin@rats.dev>
PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
