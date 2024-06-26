TERMUX_PKG_HOMEPAGE=https://gtkwave.sourceforge.net/
TERMUX_PKG_DESCRIPTION="A wave viewer which reads LXT, LXT2, VZT, GHW and VCD/EVCD files"
TERMUX_PKG_LICENSE="GPL-2.0, MIT"
TERMUX_PKG_LICENSE_FILE="COPYING, LICENSE.TXT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="3.3.119"
TERMUX_PKG_SRCURL=https://downloads.sourceforge.net/gtkwave/gtkwave-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=3cb53a291a300b442927a3ca1900f325a962c730c8eb7f8b9b4dfdb2e5406207
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="gdk-pixbuf, glib, gtk2, libandroid-shmem, libbz2, libc++, liblzma, pango, zlib"
TERMUX_PKG_RECOMMENDS="desktop-file-utils"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--disable-tcl --disable-mime-update"
