#!/usr/bin/env python3
# Copyright 2026 Cloudsmith Ltd
#
# Move Formula/cloudsmith-cli.rb to a Cloudsmith CLI release.
#
# Reads the sha256 of each platform from the SHA256SUMS asset of the GitHub
# release, and checks each published download against it before it writes the
# formula. Removes the revision line, because a new version starts at revision 0.
# Changes nothing when the formula pins that version or a newer one.
#
# Usage: scripts/bump-cli-version.py VERSION
import hashlib
import importlib
import re
import sys
import time
import urllib.error
import urllib.request

render_formula_version = importlib.import_module("render-formula-version")

FORMULA_PATH = "Formula/cloudsmith-cli.rb"
SHA256SUMS_URL = "https://github.com/cloudsmith-io/cloudsmith-cli/releases/download/v{version}/SHA256SUMS"
VERSION = re.compile(r"\d+\.\d+\.\d+")
REVISION_LINE = re.compile(r"^  revision \d+\n", re.MULTILINE)
ARCHIVE_TARGET = re.compile(
    r'^\s*url ".*/cloudsmith-[\d.]+-([\w-]+)\.tar\.gz"$', re.MULTILINE
)
SUMS_LINE = re.compile(
    r"^([0-9a-f]{64})  cloudsmith-[\d.]+-([\w-]+)\.tar\.gz$", re.MULTILINE
)
DOWNLOAD = re.compile(r'^\s*url "(.+)"\n\s*sha256 "([0-9a-f]{64})"$', re.MULTILINE)
HTTP_TIMEOUT_SECONDS = 60
DOWNLOAD_ATTEMPTS = 10
RETRY_DELAY_SECONDS = 30


def version_key(version):
    return tuple(int(part) for part in version.split("."))


def bump(formula, version, sha256sums):
    """Return formula moved to version, or None when it pins version or a newer one."""
    pinned_version = render_formula_version.VERSION_LINE.search(formula).group(1)
    if version_key(version) <= version_key(pinned_version):
        return None

    shas = {target: sha256 for sha256, target in SUMS_LINE.findall(sha256sums)}
    missing = set(ARCHIVE_TARGET.findall(formula)) - shas.keys()
    if missing:
        raise SystemExit(f"SHA256SUMS has no sha256 for {', '.join(sorted(missing))}")
    return render_formula_version.rewrite(REVISION_LINE.sub("", formula), version, shas)


def fetch(url):
    """Return the body at url, and try again while the release syncs."""
    for attempt in range(1, DOWNLOAD_ATTEMPTS + 1):
        try:
            with urllib.request.urlopen(url, timeout=HTTP_TIMEOUT_SECONDS) as response:
                return response.read()
        except urllib.error.URLError as error:
            last_error = error
            print(f"attempt {attempt}: {url} is not ready", file=sys.stderr)
            if attempt < DOWNLOAD_ATTEMPTS:
                time.sleep(RETRY_DELAY_SECONDS)
    raise SystemExit(f"cannot download {url}: {last_error}")


def verify_downloads(formula):
    for url, expected_sha256 in DOWNLOAD.findall(formula):
        actual_sha256 = hashlib.sha256(fetch(url)).hexdigest()
        if actual_sha256 != expected_sha256:
            raise SystemExit(f"{url} has sha256 {actual_sha256}, not {expected_sha256}")
        print(f"verified {url}", file=sys.stderr)


def main():
    if len(sys.argv) != 2 or not VERSION.fullmatch(sys.argv[1]):
        raise SystemExit(f"usage: {sys.argv[0]} MAJOR.MINOR.PATCH")
    version = sys.argv[1]

    with open(FORMULA_PATH, encoding="utf-8") as formula_file:
        formula = formula_file.read()
    sha256sums = fetch(SHA256SUMS_URL.format(version=version)).decode()
    bumped = bump(formula, version, sha256sums)
    if bumped is None:
        print(
            f"{FORMULA_PATH} already pins Cloudsmith CLI {version} or newer",
            file=sys.stderr,
        )
        return
    verify_downloads(bumped)
    with open(FORMULA_PATH, "w", encoding="utf-8") as formula_file:
        formula_file.write(bumped)


if __name__ == "__main__":
    main()
