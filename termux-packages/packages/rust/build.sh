TERMUX_PKG_HOMEPAGE=https://www.rust-lang.org/
TERMUX_PKG_DESCRIPTION="Systems programming language focused on safety, speed and concurrency"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.78.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://static.rust-lang.org/dist/rustc-${TERMUX_PKG_VERSION}-src.tar.xz
TERMUX_PKG_SHA256=8065824f0255faa3901db8206e6f9423f6f8c07cec28bc6f2797c6c948310ece
_LLVM_MAJOR_VERSION=$(. $TERMUX_SCRIPTDIR/packages/libllvm/build.sh; echo $LLVM_MAJOR_VERSION)
_LLVM_MAJOR_VERSION_NEXT=$((_LLVM_MAJOR_VERSION + 1))
_LZMA_VERSION=$(. $TERMUX_SCRIPTDIR/packages/liblzma/build.sh; echo $TERMUX_PKG_VERSION)
TERMUX_PKG_DEPENDS="clang, libc++, libllvm (<< ${_LLVM_MAJOR_VERSION_NEXT}), lld, openssl, zlib"
TERMUX_PKG_BUILD_DEPENDS="wasi-libc"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_RM_AFTER_INSTALL="
bin/llc
bin/llvm-*
bin/opt
bin/sh
lib/liblzma.a
lib/liblzma.so
lib/liblzma.so.${_LZMA_VERSION}
lib/libtinfo.so.6
lib/libz.so
lib/libz.so.1
share/wasi-sysroot
"

termux_pkg_auto_update() {
	local e=0
	local api_url="https://releases.rs"
	local api_url_r=$(curl -Ls "${api_url}")
	local latest_version=$(echo "${api_url_r}" | grep "html" | sed -ne "s|.*Stable: \([0-9]*\+.\+[0-9]*\+.\+[0-9]*\) Beta:.*|\1|p")
	if [[ "${latest_version}" == "${TERMUX_PKG_VERSION}" ]]; then
		echo "INFO: Already up to date."
		return
	fi
	[[ -z "${api_url_r}" ]] && e=1
	[[ -z "${latest_version}" ]] && e=1

	local uptime_now=$(cat /proc/uptime)
	local uptime_s="${uptime_now//.*}"
	local uptime_h_limit=4
	local uptime_s_limit=$((uptime_h_limit*60*60))
	[[ -z "${uptime_s}" ]] && e=1
	[[ "${uptime_s}" == 0 ]] && e=1
	[[ "${uptime_s}" -gt "${uptime_s_limit}" ]] && e=1

	if [[ "${e}" != 0 ]]; then
		cat <<- EOL >&2
		WARN: Auto update failure!
		api_url_r=${api_url_r}
		latest_version=${latest_version}
		uptime_now=${uptime_now}
		uptime_s=${uptime_s}
		uptime_s_limit=${uptime_s_limit}
		EOL
		return
	fi

	sed \
		-e "s/^\tlocal BOOTSTRAP_VERSION=.*/\tlocal BOOTSTRAP_VERSION=${TERMUX_PKG_VERSION}/" \
		-i "${TERMUX_PKG_BUILDER_DIR}/build.sh"
	termux_pkg_upgrade_version "${latest_version}"
}

termux_step_pre_configure() {
	termux_setup_cmake
	termux_setup_rust

	# default rust-std package to be installed
	TERMUX_PKG_DEPENDS+=", rust-std-${CARGO_TARGET_NAME/_/-}"

	local p="${TERMUX_PKG_BUILDER_DIR}/0001-set-TERMUX_PKG_API_LEVEL.diff"
	echo "Applying patch: $(basename "${p}")"
	sed "s|@TERMUX_PKG_API_LEVEL@|${TERMUX_PKG_API_LEVEL}|g" "${p}" \
		| patch --silent -p1

	export RUST_LIBDIR=$TERMUX_PKG_BUILDDIR/_lib
	mkdir -p $RUST_LIBDIR

	# we can't use -L$PREFIX/lib since it breaks things but we need to link against libLLVM-9.so
	ln -vfst "${RUST_LIBDIR}" \
		${TERMUX_PREFIX}/lib/libLLVM-${_LLVM_MAJOR_VERSION}.so

	# rust tries to find static library 'c++_shared'
	ln -vfs $TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libc++_static.a \
		$RUST_LIBDIR/libc++_shared.a

	# https://github.com/termux/termux-packages/issues/18379
	# NDK r26 multiple ld.lld: error: undefined symbol: __cxa_*
	ln -vfst "${RUST_LIBDIR}" "${TERMUX_PREFIX}"/lib/libc++_shared.so

	# https://github.com/termux/termux-packages/issues/11640
	# https://github.com/termux/termux-packages/issues/11658
	# The build system somehow tries to link binaries against a wrong libc,
	# leading to build failures for arm and runtime errors for others.
	# The following command is equivalent to
	#	ln -vfst $RUST_LIBDIR \
	#		$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/lib{c,dl}.so
	# but written in a future-proof manner.
	ln -vfst $RUST_LIBDIR $(echo | $CC -x c - -Wl,-t -shared | grep '\.so$')

	# rust checks libs in PREFIX/lib. It then can't find libc.so and libdl.so because rust program doesn't
	# know where those are. Putting them temporarly in $PREFIX/lib prevents that failure
	# https://github.com/termux/termux-packages/issues/11427
	mv $TERMUX_PREFIX/lib/liblzma.a{,.tmp} || :
	mv $TERMUX_PREFIX/lib/liblzma.so{,.tmp} || :
	mv $TERMUX_PREFIX/lib/liblzma.so.${_LZMA_VERSION}{,.tmp} || :
	mv $TERMUX_PREFIX/lib/libtinfo.so.6{,.tmp} || :
	mv $TERMUX_PREFIX/lib/libz.so.1{,.tmp} || :
	mv $TERMUX_PREFIX/lib/libz.so{,.tmp} || :
}

termux_step_configure() {
	# it breaks building rust tools without doing this because it tries to find
	# ../lib from bin location:
	# this is about to get ugly but i have to make sure a rustc in a proper bin lib
	# configuration is used otherwise it fails a long time into the build...
	# like 30 to 40 + minutes ... so lets get it right

	# upstream tests build using versions N and N-1
	local BOOTSTRAP_VERSION=1.77.2
	if rustup install $BOOTSTRAP_VERSION; then
	rustup default $BOOTSTRAP_VERSION-x86_64-unknown-linux-gnu
	export PATH=$HOME/.rustup/toolchains/$BOOTSTRAP_VERSION-x86_64-unknown-linux-gnu/bin:$PATH
	else
	echo "WARN: $BOOTSTRAP_VERSION is unavailable, fallback to stable version!"
	rustup install stable
	rustup default stable-x86_64-unknown-linux-gnu
	export PATH=$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin:$PATH
	fi
	local RUSTC=$(command -v rustc)
	local CARGO=$(command -v cargo)

	sed \
		-e "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" \
		-e "s|@TERMUX_STANDALONE_TOOLCHAIN@|${TERMUX_STANDALONE_TOOLCHAIN}|g" \
		-e "s|@CARGO_TARGET_NAME@|${CARGO_TARGET_NAME}|g" \
		-e "s|@RUSTC@|${RUSTC}|g" \
		-e "s|@CARGO@|${CARGO}|g" \
		"${TERMUX_PKG_BUILDER_DIR}"/config.toml > config.toml

	local env_host=$(printf $CARGO_TARGET_NAME | tr a-z A-Z | sed s/-/_/g)
	export ${env_host}_OPENSSL_DIR=$TERMUX_PREFIX
	export RUST_LIBDIR=$TERMUX_PKG_BUILDDIR/_lib
	export CARGO_TARGET_${env_host}_RUSTFLAGS="-L${RUST_LIBDIR}"

	# x86_64: __lttf2
	case "${TERMUX_ARCH}" in
	x86_64)
		export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=$(${CC} -print-libgcc-file-name)" ;;
	esac

	# NDK r26
	export CARGO_TARGET_${env_host}_RUSTFLAGS+=" -C link-arg=-lc++_shared"

	export X86_64_UNKNOWN_LINUX_GNU_OPENSSL_LIB_DIR=/usr/lib/x86_64-linux-gnu
	export X86_64_UNKNOWN_LINUX_GNU_OPENSSL_INCLUDE_DIR=/usr/include
	export PKG_CONFIG_ALLOW_CROSS=1
	# for backtrace-sys
	export CC_x86_64_unknown_linux_gnu=gcc
	export CFLAGS_x86_64_unknown_linux_gnu="-O2"
}

termux_step_make() {
	:
}

termux_step_make_install() {
	unset CC CFLAGS CPP CPPFLAGS CXX CXXFLAGS LD LDFLAGS PKG_CONFIG RANLIB

	# remove version suffix: beta, nightly
	local TERMUX_PKG_VERSION=${TERMUX_PKG_VERSION//~*}

	# needed to workaround build issue that only happens on x86_64
	# /home/runner/.termux-build/rust/build/build/bootstrap/debug/bootstrap: error while loading shared libraries: /lib/x86_64-linux-gnu/libc.so: invalid ELF header
	if [[ "$TERMUX_ARCH" == "x86_64" ]]; then
		mv ${TERMUX_PREFIX}{,.tmp}
		$TERMUX_PKG_SRCDIR/x.py build --host x86_64-unknown-linux-gnu --stage 1 cargo
		[[ -d "${TERMUX_PREFIX}" ]] && termux_error_exit "Contaminated PREFIX found:\n$(find ${TERMUX_PREFIX} | sort)"
		mv ${TERMUX_PREFIX}{.tmp,}
	fi

	if ! :; then
	# speed up building rust for testing
	$TERMUX_PKG_SRCDIR/x.py install --stage 1 --target $CARGO_TARGET_NAME
	$TERMUX_PKG_SRCDIR/x.py dist rustc-dev --host $CARGO_TARGET_NAME --target $CARGO_TARGET_NAME
	else
	# otherwise always build all the supported targets
	$TERMUX_PKG_SRCDIR/x.py install --stage 1 --target aarch64-linux-android
	$TERMUX_PKG_SRCDIR/x.py install --stage 1 --target armv7-linux-androideabi
	$TERMUX_PKG_SRCDIR/x.py install --stage 1 --target i686-linux-android
	$TERMUX_PKG_SRCDIR/x.py install --stage 1 --target x86_64-linux-android
	$TERMUX_PKG_SRCDIR/x.py install --stage 1 std --target wasm32-unknown-unknown
	$TERMUX_PKG_SRCDIR/x.py install --stage 1 std --target wasm32-wasi

	$TERMUX_PKG_SRCDIR/x.py dist rustc-dev --host $CARGO_TARGET_NAME --target aarch64-linux-android
	$TERMUX_PKG_SRCDIR/x.py dist rustc-dev --host $CARGO_TARGET_NAME --target armv7-linux-androideabi
	$TERMUX_PKG_SRCDIR/x.py dist rustc-dev --host $CARGO_TARGET_NAME --target i686-linux-android
	$TERMUX_PKG_SRCDIR/x.py dist rustc-dev --host $CARGO_TARGET_NAME --target x86_64-linux-android
	$TERMUX_PKG_SRCDIR/x.py dist rustc-dev --host $CARGO_TARGET_NAME --target wasm32-unknown-unknown
	$TERMUX_PKG_SRCDIR/x.py dist rustc-dev --host $CARGO_TARGET_NAME --target wasm32-wasi
	fi

	tar -xvf build/dist/rustc-dev-$TERMUX_PKG_VERSION-$CARGO_TARGET_NAME.tar.gz
	./rustc-dev-$TERMUX_PKG_VERSION-$CARGO_TARGET_NAME/install.sh --prefix=$TERMUX_PREFIX

	cd "$TERMUX_PREFIX/lib"
	rm -f libc.so libdl.so
	mv liblzma.a{.tmp,} || :
	mv liblzma.so{.tmp,} || :
	mv liblzma.so.${_LZMA_VERSION}{.tmp,} || :
	mv libtinfo.so.6{.tmp,} || :
	mv libz.so.1{.tmp,} || :
	mv libz.so{.tmp,} || :

	ln -vfs rustlib/${CARGO_TARGET_NAME}/lib/*.so .
	ln -vfs lld ${TERMUX_PREFIX}/bin/rust-lld

	cd "$TERMUX_PREFIX/lib/rustlib"
	rm -fr \
		components \
		install.log \
		uninstall.sh \
		rust-installer-version \
		manifest-* \
		x86_64-unknown-linux-gnu

	cd "${TERMUX_PREFIX}/lib/rustlib/${CARGO_TARGET_NAME}/lib"
	echo "INFO: ${TERMUX_PKG_BUILDDIR}/rustlib-rlib.txt"
	ls *.rlib | tee "${TERMUX_PKG_BUILDDIR}/rustlib-rlib.txt"

	echo "INFO: ${TERMUX_PKG_BUILDDIR}/rustlib-so.txt"
	ls *.so | tee "${TERMUX_PKG_BUILDDIR}/rustlib-so.txt"

	echo "INFO: ${TERMUX_PKG_BUILDDIR}/rustc-dev-${TERMUX_PKG_VERSION}-${CARGO_TARGET_NAME}/rustc-dev/manifest.in"
	cat "${TERMUX_PKG_BUILDDIR}/rustc-dev-${TERMUX_PKG_VERSION}-${CARGO_TARGET_NAME}/rustc-dev/manifest.in" | tee "${TERMUX_PKG_BUILDDIR}/manifest.in"

	sed -e 's/^.....//' -i "${TERMUX_PKG_BUILDDIR}/manifest.in"
	local _included=$(cat "${TERMUX_PKG_BUILDDIR}/manifest.in")
	local _included_rlib=$(echo "${_included}" | grep '\.rlib$')
	local _included_so=$(echo "${_included}" | grep '\.so$')
	local _included=$(echo "${_included}" | grep -v "/rustc-src/")
	local _included=$(echo "${_included}" | grep -v '\.rlib$')
	local _included=$(echo "${_included}" | grep -v '\.so$')

	echo "INFO: _rlib"
	while IFS= read -r _rlib; do
		echo "${_rlib}"
		local _included_rlib=$(echo "${_included_rlib}" | grep -v "${_rlib}")
	done < "${TERMUX_PKG_BUILDDIR}/rustlib-rlib.txt"
	echo "INFO: _so"
	while IFS= read -r _so; do
		echo "${_so}"
		local _included_so=$(echo "${_included_so}" | grep -v "${_so}")
	done < "${TERMUX_PKG_BUILDDIR}/rustlib-so.txt"

	export _INCLUDED=$(echo -e "${_included}\n${_included_rlib}\n${_included_so}")
	echo -e "INFO: _INCLUDED:\n${_INCLUDED}"
}
