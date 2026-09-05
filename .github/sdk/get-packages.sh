#!/bin/bash
# Print what to compile: "all", "skip", or package directory names.
set -euo pipefail

case "${EVENT_NAME:-}" in
	workflow_dispatch) echo all; exit 0 ;;
	pull_request) base="${BASE_SHA:?}" ;;
	push)
		base="$(git tag -l '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]*' \
			--sort=-creatordate | grep -vxF "${GITHUB_REF_NAME:?}" | head -n1 || true)"
		[ -n "$base" ] || { echo all; exit 0; }
		;;
	*) echo all; exit 0 ;;
esac

git cat-file -e "$base^{commit}" 2>/dev/null || git fetch --depth=1 origin "$base" || { echo all; exit 0; }

files="$(git diff --name-only "$base"...HEAD || true)"
[ -n "$files" ] || { echo skip; exit 0; }

echo "$files" | grep -qE '^\.github/(sdk|workflows)/' && { echo all; exit 0; }

pkgs="$(echo "$files" | awk -F/ '{print $1}' | sort -u | while read -r top; do
	[ -f "$top/Makefile" ] && echo "$top"
done | paste -sd' ' -)"

if [ -n "$pkgs" ]; then
	echo "$pkgs"
else
	echo skip
fi
