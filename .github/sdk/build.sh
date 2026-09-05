#!/bin/bash
# Build only packages from the mounted feed (this repo).
# PACKAGES=all or empty → every feed package; otherwise only those names.
# Unchanged apks are copied from /previous-feed before package/index.
set -euo pipefail

cd /builder

FEEDNAME=vianes
PKGARCH="${PKGARCH:?}"
PACKAGES="${PACKAGES:-all}"

feed_packages() {
	local mk
	for mk in /feed/*/Makefile; do
		[ -f "$mk" ] || continue
		basename "$(dirname "$mk")"
	done
}

if [ "$PACKAGES" = all ] || [ -z "$PACKAGES" ]; then
	PACKAGES="$(feed_packages | tr '\n' ' ')"
fi
PACKAGES="${PACKAGES% }"
[ -n "$PACKAGES" ] || { echo "no packages in /feed" >&2; exit 1; }

if [ -n "${PRIVATE_KEY:-}" ]; then
	printf '%s\n' "$PRIVATE_KEY" > private-key.pem
fi

sed \
	-e 's,https://git.openwrt.org/feed/,https://github.com/openwrt/,' \
	-e 's,https://git.openwrt.org/openwrt/,https://github.com/openwrt/,' \
	-e 's,https://git.openwrt.org/project/,https://github.com/openwrt/,' \
	feeds.conf.default > feeds.conf
echo "src-link $FEEDNAME /feed/" >> feeds.conf

./scripts/feeds update -a
for PKG in $PACKAGES; do
	./scripts/feeds install -p "$FEEDNAME" -f "$PKG"
done
make defconfig

MAKE_SIGN=()
[ -z "${PRIVATE_KEY:-}" ] || MAKE_SIGN=(CONFIG_SIGNED_PACKAGES=y)

run_make() {
	make BUILD_LOG=1 CONFIG_AUTOREMOVE=y "${MAKE_SIGN[@]}" -j "$(nproc)" "$@" || {
		mkdir -p /artifacts
		[ ! -d logs ] || cp -a logs /artifacts/
		exit 1
	}
}

for PKG in $PACKAGES; do
	run_make "package/$PKG/compile"
done

feed_dir="bin/packages/$PKGARCH/$FEEDNAME"
if [ -d /previous-feed ]; then
	mkdir -p "$feed_dir"
	for apk in /previous-feed/*.apk; do
		[ -e "$apk" ] || continue
		name="${apk##*/}"
		keep=1
		for PKG in $PACKAGES; do
			case "$name" in
				"$PKG"-*.apk) keep=0 ;;
			esac
		done
		[ "$keep" = 1 ] || continue
		cp -a "$apk" "$feed_dir/"
	done
fi

make "${MAKE_SIGN[@]}" package/index

mkdir -p /artifacts
cp -a bin /artifacts/
[ ! -d logs ] || cp -a logs /artifacts/

if ! find /artifacts/bin -name '*.apk' -print -quit | grep -q .; then
	echo "no .apk files produced" >&2
	exit 1
fi

