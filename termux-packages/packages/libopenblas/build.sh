TERMUX_PKG_HOMEPAGE="https://www.openblas.net"
TERMUX_PKG_DESCRIPTION="An optimized BLAS library based on GotoBLAS2 1.13 BSD"
TERMUX_PKG_GROUPS="science"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.3.27"
TERMUX_PKG_SRCURL="https://github.com/xianyi/OpenBLAS/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz"
TERMUX_PKG_SHA256=aa2d68b1564fe2b13bc292672608e9cdeeeb6dc34995512e65c3b10f4599e897
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS='
-DBUILD_SHARED_LIBS=ON
-DBUILD_STATIC_LIBS=ON
-DC_LAPACK=ON
'

termux_step_post_get_source() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION=0

	local v=$(echo ${TERMUX_PKG_VERSION#*:} | cut -d . -f 1)
	if [ "${v}" != "${_SOVERSION}" ]; then
		termux_error_exit "SOVERSION guard check failed."
	fi
}

termux_step_pre_configure() {
	if [ "$TERMUX_ARCH" = "x86_64" ] || [ "$TERMUX_ARCH" = "i686" ]; then
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+='-DTARGET=CORE2'
	fi
}

termux_step_post_make_install() {
	mkdir -p $TERMUX_PREFIX/lib/pkgconfig
	pushd $TERMUX_PREFIX/lib
	local _lib
	for _lib in blas cblas lapack lapacke; do
		rm -f lib${_lib}.a lib${_lib}.so lib${_lib}.so.3 pkgconfig/${_lib}.pc
		ln -s libopenblas.a lib${_lib}.a
		ln -s libopenblas.so lib${_lib}.so
		ln -s libopenblas.so lib${_lib}.so.3
		ln -s openblas.pc pkgconfig/${_lib}.pc
	done
	popd # $TERMUX_PREFIX/lib
}
