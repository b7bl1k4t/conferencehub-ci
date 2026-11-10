#!/bin/sh
set -eu
: "${BUILD_NUMBER:?Set BUILD_NUMBER}"
: "${GIT_COMMIT:?Set GIT_COMMIT}"
mkdir -p dist
cat > dist/conferencehub-release.txt <<EOF
application=ConferenceHub
build=$BUILD_NUMBER
commit=$GIT_COMMIT
mode=simulation
EOF
printf 'BUILD OK: dist/conferencehub-release.txt\n'
