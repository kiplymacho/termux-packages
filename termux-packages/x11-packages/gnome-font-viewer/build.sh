TERMUX_PKG_HOMEPAGE=https://gitlab.gnome.org/GNOME/gnome-font-viewer
TERMUX_PKG_DESCRIPTION="A font viewer utility for GNOME"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="46.0"
TERMUX_PKG_SRCURL=https://download.gnome.org/sources/gnome-font-viewer/${TERMUX_PKG_VERSION%.*}/gnome-font-viewer-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=592f401e485d02cc044d487bb5c8e04c961da6856216768a59f1ff98bd2d537c
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="fontconfig, freetype, fribidi, glib, graphene, gtk4, gnome-desktop4, harfbuzz, libadwaita, libcairo, pango"
TERMUX_PKG_BUILD_DEPENDS="glib-cross"

termux_step_pre_configure() {
	local _WRAPPER_BIN="${TERMUX_PKG_BUILDDIR}/_wrapper/bin"
	mkdir -p "${_WRAPPER_BIN}"
	if [[ "${TERMUX_ON_DEVICE_BUILD}" == "false" ]]; then
		sed "s|^export PKG_CONFIG_LIBDIR=|export PKG_CONFIG_LIBDIR=${TERMUX_PREFIX}/opt/glib/cross/lib/x86_64-linux-gnu/pkgconfig:|" \
			"${TERMUX_STANDALONE_TOOLCHAIN}/bin/pkg-config" \
			> "${_WRAPPER_BIN}/pkg-config"
		chmod +x "${_WRAPPER_BIN}/pkg-config"
		export PKG_CONFIG="${_WRAPPER_BIN}/pkg-config"
	fi
	export PATH="${_WRAPPER_BIN}:${PATH}"
}
