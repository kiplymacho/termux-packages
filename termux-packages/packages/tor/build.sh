TERMUX_PKG_HOMEPAGE=https://www.torproject.org
TERMUX_PKG_DESCRIPTION="The Onion Router anonymizing overlay network"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.4.8.11"
TERMUX_PKG_SRCURL=https://www.torproject.org/dist/tor-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=8f2bdf90e63380781235aa7d604e159570f283ecee674670873d8bb7052c8e07
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libevent, liblzma, openssl, resolv-conf, zlib"
TERMUX_PKG_BUILD_DEPENDS="libandroid-glob"
# We're not using '--enable-android' as it just defines 'USE_ANDROID', which
# makes Tor writes the log to Android's logcat instead of to stdout/stderr, not
# helpful in our case. Although it would be good to go through the source and
# ensure that in future there is not any other Android specific behaviour which
# affects security/anonymity.
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--disable-zstd --disable-unittests"
TERMUX_PKG_CONFFILES="etc/tor/torrc"
TERMUX_PKG_SERVICE_SCRIPT=("tor" 'exec tor 2>&1')

termux_step_post_make_install() {
	# use default config
	mv "$TERMUX_PREFIX/etc/tor/torrc.sample" "$TERMUX_PREFIX/etc/tor/torrc"
}
