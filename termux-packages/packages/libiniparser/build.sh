TERMUX_PKG_HOMEPAGE=https://github.com/ndevilla/iniparser
TERMUX_PKG_DESCRIPTION="Offers parsing of ini files from the C level"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="4.2.2"
TERMUX_PKG_SRCURL=https://github.com/ndevilla/iniparser/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=82983d9712e321494ee67e1d90963545b6788c198611dab094804a7b7414b233
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBUILD_EXAMPLES=OFF
-DBUILD_TESTS=OFF
-DBUILD_DOCS=OFF
"