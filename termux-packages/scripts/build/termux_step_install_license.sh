termux_step_install_license() {
	[ "$TERMUX_PKG_METAPACKAGE" = "true" ] && return

	mkdir -p "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME"
	local LICENSE
	local COUNTER=0
	if [ ! "${TERMUX_PKG_LICENSE_FILE}" = "" ]; then
		INSTALLED_LICENSES=()
		COUNTER=1
		while read -r LICENSE; do
			[ -z "${LICENSE}" ] && continue
			if [ ! -f "$TERMUX_PKG_SRCDIR/$LICENSE" ]; then
				termux_error_exit "$TERMUX_PKG_SRCDIR/$LICENSE does not exist"
			fi
			if [[ " ${INSTALLED_LICENSES[@]} " =~ " $(basename $LICENSE) " ]]; then
				# We have already installed a license file named $(basename $LICENSE) so add a suffix to it
				TARGET="$TERMUX_PREFIX/share/doc/${TERMUX_PKG_NAME}/$(basename $LICENSE).$COUNTER"
				COUNTER=$((COUNTER + 1))
			else
				TARGET="$TERMUX_PREFIX/share/doc/${TERMUX_PKG_NAME}/$(basename $LICENSE)"
				INSTALLED_LICENSES+=("$(basename $LICENSE)")
			fi
			cp -f "${TERMUX_PKG_SRCDIR}/${LICENSE}" "$TARGET"
		done < <(echo "$TERMUX_PKG_LICENSE_FILE" | sed "s/,/\n/g")
	else
		local TO_LICENSE
		while read -r LICENSE; do
			# These licenses contain copyright information, so
			# we cannot use a generic license file
			if [ "$LICENSE" == "MIT" ] || \
				[ "$LICENSE" == "ISC" ] || \
				[ "$LICENSE" == "PythonPL" ] || \
				[ "$LICENSE" == "Openfont-1.1" ] || \
				[ "$LICENSE" == "ZLIB" ] || \
				[ "$LICENSE" == "Libpng" ] || \
				[ "$LICENSE" == "BSD" ] || \
				[ "$LICENSE" == "BSD 2-Clause" ] || \
				[ "$LICENSE" == "BSD 3-Clause" ] || \
				[ "$LICENSE" == "X11" ] || \
				[ "$LICENSE" == "curl" ] || \
				[ "$LICENSE" == "BSD Simplified" ]; then
			    for FILE in LICENSE \
                                            LICENSE.md \
                                            LICENSE.txt \
                                            LICENSE.TXT \
                                            COPYING \
                                            COPYRIGHT \
                                            Copyright.txt \
                                            Copyright \
                                            LICENCE \
                                            License \
                                            license \
                                            license.md \
                                            License.txt \
                                            license.txt \
                                            licence; do
					if [ -f "$TERMUX_PKG_SRCDIR/$FILE" ]; then
						if [[ $COUNTER -gt 0 ]]; then
							cp -f "${TERMUX_PKG_SRCDIR}/$FILE" "${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}/LICENSE.${COUNTER}"
						else
							cp -f "${TERMUX_PKG_SRCDIR}/$FILE" "${TERMUX_PREFIX}/share/doc/${TERMUX_PKG_NAME}/LICENSE"
						fi
						COUNTER=$((COUNTER + 1))
					fi
				done
			elif [ -f "$TERMUX_SCRIPTDIR/packages/termux-licenses/LICENSES/${LICENSE}.txt" ]; then
				if [ "$TERMUX_PACKAGE_LIBRARY" = "bionic" ]; then
					TO_LICENSE="../../LICENSES/${LICENSE}.txt"
				elif [ "$TERMUX_PACKAGE_LIBRARY" = "glibc" ]; then
					TO_LICENSE="../../../../share/LICENSES/${LICENSE}.txt"
				fi
				if [[ $COUNTER -gt 0 ]]; then
					ln -sf "$TO_LICENSE" "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/LICENSE.${COUNTER}"
				else
					ln -sf "$TO_LICENSE" "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/LICENSE"
				fi
				COUNTER=$((COUNTER + 1))
			fi
		done < <(echo "$TERMUX_PKG_LICENSE" | sed "s/,/\n/g")

		for LICENSE in "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME"/LICENSE*; do
			if [ "$LICENSE" = "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/LICENSE*" ]; then
				termux_error_exit "No LICENSE file was installed for $TERMUX_PKG_NAME"
			fi
		done
	fi
}
