TERMUX_PKG_HOMEPAGE=https://tintin.mudhalla.net
TERMUX_PKG_DESCRIPTION="Classic text-based MUD client"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="2.02.41"
TERMUX_PKG_SRCURL=https://github.com/scandum/tintin/releases/download/$TERMUX_PKG_VERSION/tintin-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=b86b4af5a57b986d4ef5db41e64d38e027cf85004749479c9424f18df7642a49
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="ac_cv_file__dev_ptmx=no"
TERMUX_PKG_DEPENDS="pcre, libgnutls, zlib"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_REGEXP="\d+\.\d+\.\d+"

termux_step_post_get_source() {
	TERMUX_PKG_SRCDIR+="/src"
	TERMUX_PKG_BUILDDIR="$TERMUX_PKG_SRCDIR"
}

termux_step_pre_configure() {
	CFLAGS+=" $CPPFLAGS"
}
