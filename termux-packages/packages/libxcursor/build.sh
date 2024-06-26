# X11 package
TERMUX_PKG_HOMEPAGE=https://xorg.freedesktop.org/
TERMUX_PKG_DESCRIPTION="X cursor management library"
# License: HPND
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.2.2"
TERMUX_PKG_SRCURL=https://xorg.freedesktop.org/releases/individual/lib/libXcursor-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=53d071bd2cc56e517a30998d5e685c8a74556ddada43c6985d14da9a023a88ee
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libx11, libxfixes, libxrender"
TERMUX_PKG_BUILD_DEPENDS="xorg-util-macros"
