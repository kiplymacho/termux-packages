TERMUX_PKG_HOMEPAGE=https://xorg.freedesktop.org/
TERMUX_PKG_DESCRIPTION="X clock"
# Licenses: MIT, HPND
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=1.1.1
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://xorg.freedesktop.org/releases/individual/app/xclock-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=df7ceabf8f07044a2fde4924d794554996811640a45de40cb12c2cf1f90f742c
TERMUX_PKG_DEPENDS="libiconv, libx11, libxaw, libxft, libxkbfile, libxmu, libxrender, libxt"
TERMUX_PKG_BUILD_DEPENDS="xorg-util-macros"
TERMUX_PKG_CONFLICTS="xclock"
TERMUX_PKG_REPLACES="xclock"
