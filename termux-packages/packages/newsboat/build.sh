TERMUX_PKG_HOMEPAGE=https://newsboat.org/
TERMUX_PKG_DESCRIPTION="RSS/Atom feed reader for the text console"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="2.35"
TERMUX_PKG_SRCURL=https://newsboat.org/releases/${TERMUX_PKG_VERSION}/newsboat-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=f4f003f6ca38e44c0fef01fb6bc8c5ba6b53589c7c87db7b0cc2284e018db6c4
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="json-c, libandroid-glob, libandroid-support, libc++, libcurl, libiconv, libsqlite, libxml2, ncurses, stfl"
TERMUX_PKG_BUILD_DEPENDS="openssl"
TERMUX_PKG_BUILD_IN_SRC=true
# TERMUX_PKG_RM_AFTER_INSTALL="share/locale"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="ac_cv_lib_bsd_main=no"
TERMUX_PKG_CONFLICTS=newsbeuter
TERMUX_PKG_REPLACES=newsbeuter

termux_step_pre_configure() {
	termux_setup_rust

	LDFLAGS+=" -liconv"

	export CXX_FOR_BUILD=g++
	export CXXFLAGS_FOR_BUILD="-O2"

	# Used by newsboat Makefile:
	export CARGO_BUILD_TARGET=$CARGO_TARGET_NAME

	export PKG_CONFIG_ALLOW_CROSS=1
}
