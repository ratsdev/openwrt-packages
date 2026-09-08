# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 ratsdev
#
# Build requirements:
#   - The `packages` feed must be installed (provides lang/rust host toolchain).
#   - Host `clang` on PATH: the eBPF datapath (bpf/kern/vianes.c) is compiled
#     by build.rs on every cargo invocation.

include $(TOPDIR)/rules.mk

PKG_NAME:=vianes
PKG_VERSION:=0.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ratsdev/vianes/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b5f1b2dbf4ced2289939796989941334690f22aa7bd60e68499ff4ac3af63b74

PKG_MAINTAINER:=ratsdev <admin@rats.dev>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/vianes
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Vianes eBPF policy-based traffic steering daemon
  URL:=https://github.com/ratsdev/vianes
  # Upstream compiles its BPF datapath as bpfel only.
  DEPENDS:=$(RUST_ARCH_DEPENDS) +kmod-sched-core +kmod-sched-bpf +kmod-nft-tproxy +kmod-veth @!BIG_ENDIAN
endef

define Package/vianes/description
  Vianes classifies packets ingressing one bind_interface and steers them
  to named network upstreams (tproxy or iface) using eBPF (TC clsact
  ingress), policy routing and a small nft table. The daemon reads the
  YAML file /etc/vianes/config.yaml.
endef

define Package/vianes/conffiles
/etc/config/vianes
/etc/vianes/config.yaml
endef

define Package/vianes/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/vianes $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/vianes.init $(1)/etc/init.d/vianes
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/vianes.config $(1)/etc/config/vianes
	$(INSTALL_DIR) $(1)/etc/vianes
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/examples/config.yaml $(1)/etc/vianes/config.yaml
endef

$(eval $(call RustBinPackage,vianes))
$(eval $(call BuildPackage,vianes))
