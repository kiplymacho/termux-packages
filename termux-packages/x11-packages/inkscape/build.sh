TERMUX_PKG_HOMEPAGE=https://inkscape.org/
TERMUX_PKG_DESCRIPTION="Free and open source vector graphics editor"
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.3.2"
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=https://media.inkscape.org/dl/resources/file/inkscape-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=dbd1844dc443fe5e10d3e9a887144e5fb7223852fff191cfb5ef7adeab0e086b
TERMUX_PKG_DEPENDS="boost, double-conversion, fontconfig, freetype, gdk-pixbuf, glib, gsl, gtk3, gtkmm3, harfbuzz, libatkmm-1.6, libc++, libcairo, libcairomm-1.0, libgc, libglibmm-2.4, libiconv, libjpeg-turbo, libpangomm-1.4, libpng, libsigc++-2.0, libsoup, libx11, libxml2, libxslt, littlecms, pango, poppler, potrace, readline, zlib"
TERMUX_PKG_BUILD_DEPENDS="boost-headers"
TERMUX_PKG_RECOMMENDS="inkscape-extensions, inkscape-tutorials"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DWITH_GRAPHICS_MAGICK=OFF
-DWITH_GSPELL=OFF
-DWITH_IMAGE_MAGICK=OFF
-DWITH_LIBCDR=OFF
-DWITH_LIBVISIO=OFF
-DWITH_LIBWPG=OFF
"

termux_step_pre_configure() {
	CPPFLAGS+=" -DCMS_NO_REGISTER_KEYWORD -I${TERMUX_PREFIX}/include/libxml2 -include libxml/xmlmemory.h"
	LDFLAGS+=" -Wl,-rpath=$TERMUX_PREFIX/lib/inkscape"
}

termux_step_install_license() {
	local license_file="$TERMUX_PREFIX/share/inkscape/doc/COPYING"
	if [ ! -e "$license_file" ]; then
		termux_error_exit "License file $license_file not found."
	fi
	local doc_dir="$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME"
	mkdir -p "$doc_dir"
	ln -sf "$license_file" "$doc_dir"/
}
