#!/usr/bin/env bash
# Copyright 2026 Cloudsmith Ltd
#
# Assert that the cloudsmith CLI on PATH reports an expected version.
#
# Deliberately resolves the binary through PATH rather than through the keg, so
# that a formula which installs correctly but links the wrong version, or fails
# to link at all, is still caught.
set -euo pipefail

expected="${1:?usage: assert-cli-version.sh EXPECTED_VERSION}"

if ! command -v cloudsmith >/dev/null; then
  printf 'cloudsmith is not on PATH\n' >&2
  exit 1
fi

output="$(cloudsmith --version </dev/null)"
actual="$(printf '%s\n' "$output" | sed -n 's/^CLI Package Version: //p')"

if [ "$actual" != "$expected" ]; then
  printf 'expected CLI version %s, got "%s"\nfull output:\n%s\n' \
    "$expected" "$actual" "$output" >&2
  exit 1
fi

printf 'cloudsmith on PATH reports %s\n' "$actual"
