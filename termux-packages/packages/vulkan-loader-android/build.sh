TERMUX_PKG_HOMEPAGE=https://source.android.com/devices/graphics/arch-vulkan
TERMUX_PKG_DESCRIPTION="Vulkan Loader for Android"
TERMUX_PKG_LICENSE="NCSA"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=26b
TERMUX_PKG_SRCURL=https://dl.google.com/android/repository/android-ndk-r${TERMUX_PKG_VERSION}-linux.zip
TERMUX_PKG_SHA256=ad73c0370f0b0a87d1671ed2fd5a9ac9acfd1eb5c43a7fbfbd330f85d19dd632
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_BUILD_IN_SRC=true

# Desktop Vulkan Loader
# https://github.com/KhronosGroup/Vulkan-Loader
# https://github.com/KhronosGroup/Vulkan-Loader/blob/master/loader/LoaderAndLayerInterface.md

# Android Vulkan Loader
# https://android.googlesource.com/platform/frameworks/native/+/master/vulkan
# https://android.googlesource.com/platform/frameworks/native/+/master/vulkan/libvulkan/libvulkan.map.txt

termux_step_host_build() {
	# Use NDK provided vulkan header version
	# instead of vulkan-loader-generic vulkan.pc
	# https://github.com/android/ndk/issues/1721
	cat <<- EOF > vulkan_header_version.c
	#include <stdio.h>
	#include "vulkan/vulkan_core.h"
	int main(void) {
		printf("%d.%d.%d\n",
			VK_HEADER_VERSION_COMPLETE >> 22,
			VK_HEADER_VERSION_COMPLETE >> 12 & 0x03ff,
			VK_HEADER_VERSION_COMPLETE & 0x0fff);
		return 0;
	}
	EOF
	rm -fr ./vulkan
	cp -fr "${TERMUX_PKG_SRCDIR}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/vulkan" ./vulkan
	cc vulkan_header_version.c -o vulkan_header_version
}

termux_step_post_make_install() {
	install -v -Dm644 \
		"toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/${TERMUX_HOST_PLATFORM}/${TERMUX_PKG_API_LEVEL}/libvulkan.so" \
		"${TERMUX_PREFIX}/lib/libvulkan.so"

	local vulkan_loader_version
	vulkan_loader_version="$(${TERMUX_PKG_HOSTBUILD_DIR}/vulkan_header_version)"
	if [[ -z "${vulkan_loader_version}" ]]; then
		termux_error_exit "ERROR: Host built vulkan_header_version is not printing version!"
	fi

	# https://github.com/KhronosGroup/Vulkan-Loader/blob/master/loader/vulkan.pc.in
	cat <<- EOF > "${TERMUX_PKG_TMPDIR}/vulkan.pc"
	prefix=${TERMUX_PREFIX}
	exec_prefix=\${prefix}
	libdir=\${exec_prefix}/lib
	includedir=\${prefix}/include
	Name: Vulkan-Loader
	Description: Vulkan Loader
	Version: ${vulkan_loader_version}
	Libs: -L\${libdir} -lvulkan
	Cflags: -I\${includedir}
	EOF
	install -Dm644 "${TERMUX_PKG_TMPDIR}/vulkan.pc" "${TERMUX_PREFIX}/lib/pkgconfig/vulkan.pc"
	echo "INFO: ========== vulkan.pc =========="
	cat "${TERMUX_PREFIX}/lib/pkgconfig/vulkan.pc"
	echo "INFO: ========== vulkan.pc =========="

	ln -fsv libvulkan.so "${TERMUX_PREFIX}/lib/libvulkan.so.1"
}

termux_step_create_debscripts() {
	local system_lib="/system/lib"
	[[ "${TERMUX_ARCH_BITS}" == "64" ]] && system_lib+="64"
	system_lib+="/libvulkan.so"
	local prefix_lib="${TERMUX_PREFIX}/lib/libvulkan.so"

	cat <<- EOF > postinst
	#!${TERMUX_PREFIX}/bin/sh
	if [ -e "${system_lib}" ]; then
	echo "Symlink ${system_lib} to ${prefix_lib} ..."
	ln -fsT "${system_lib}" "${prefix_lib}"
	fi
	EOF

	cat <<- EOF > postrm
	#!${TERMUX_PREFIX}/bin/sh
	rm -f "${prefix_lib}"
	EOF
}
