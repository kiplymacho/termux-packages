TERMUX_PKG_HOMEPAGE=https://www.aleksey.com/xmlsec/
TERMUX_PKG_DESCRIPTION="XML Security Library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="Copyright"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.3.4"
TERMUX_PKG_SRCURL=https://www.aleksey.com/xmlsec/download/xmlsec1-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=45ad9078d41ae76844ad2f8651600ffeec0fdd128ead988a8d69e907c57aee75
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libgcrypt, libxml2, libxslt, openssl"
TERMUX_PKG_BREAKS="xmlsec-dev"
TERMUX_PKG_REPLACES="xmlsec-dev"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-crypto-dl
--without-gnutls
--without-pedantic
"

termux_step_post_get_source() {
	echo >> src/openssl/symkeys.c
}
