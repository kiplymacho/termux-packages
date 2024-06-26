TERMUX_PKG_HOMEPAGE=https://sites.google.com/site/gogdownloader/
TERMUX_PKG_DESCRIPTION="Open source downloader to GOG.com for Linux users using the same API as the official GOGDownloader"
TERMUX_PKG_LICENSE="WTFPL"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="3.14"
TERMUX_PKG_SRCURL=https://github.com/Sude-/lgogdownloader/releases/download/v${TERMUX_PKG_VERSION}/lgogdownloader-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=2629c54e2549881cdd155b4f89b472c62617db7a9cfe6b68dbcb1753080b1448
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="boost, jsoncpp, libc++, libcurl, libhtmlcxx, libtinyxml2, rhash, tidy"
TERMUX_PKG_BUILD_DEPENDS="boost-headers"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DHELP2MAN=OFF"
