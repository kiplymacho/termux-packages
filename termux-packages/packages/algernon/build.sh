TERMUX_PKG_HOMEPAGE=https://algernon.roboticoverlords.org/
TERMUX_PKG_DESCRIPTION="Small self-contained web server with Lua, Markdown, QUIC, Redis and PostgreSQL support"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.16.0"
TERMUX_PKG_SRCURL="https://github.com/xyproto/algernon/archive/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=68a14413df39f78d8e3baeffdac4e3829f0a49f4f32af5efa4a233d7dd25eaa7
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make() {
	termux_setup_golang

	export GOPATH="${TERMUX_PKG_BUILDDIR}"
	mkdir -p "${GOPATH}"/src/github.com/xyproto
	ln -sf "${TERMUX_PKG_SRCDIR}" "${GOPATH}"/src/github.com/xyproto/algernon

	cd "${GOPATH}"/src/github.com/xyproto/algernon || exit 1

	go build
}

termux_step_make_install() {
	install -Dm700 \
		"${GOPATH}"/src/github.com/xyproto/algernon/algernon \
		"${TERMUX_PREFIX}"/bin/

	# Offline samples may be useful to get started with Algernon.
	rm -rf "${TERMUX_PREFIX}"/share/doc/algernon
	mkdir -p "${TERMUX_PREFIX}"/share/doc/algernon
	cp -a "${GOPATH}"/src/github.com/xyproto/algernon/samples \
		"${TERMUX_PREFIX}"/share/doc/algernon/
}
