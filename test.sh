#!/bin/sh
set -eu
exit 1
: "${BUILD_NUMBER:?Set BUILD_NUMBER}"
: "${GIT_COMMIT:?Set GIT_COMMIT}"
artifact=dist/conferencehub-release.txt
test -s "$artifact"
grep -Fx 'application=ConferenceHub' "$artifact"
grep -Fx "build=$BUILD_NUMBER" "$artifact"
grep -Fx "commit=$GIT_COMMIT" "$artifact"
grep -Fx 'mode=simulation' "$artifact"
printf 'TEST OK: artifact metadata verified\n'
