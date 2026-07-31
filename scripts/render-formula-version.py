#!/usr/bin/env python3
# Copyright 2026 Cloudsmith Ltd
#
# Repoint a rendered formula at a different Cloudsmith CLI version.
#
# Used by the macOS formula workflow to produce the second version needed to
# exercise upgrade and downgrade transitions.
#
# Only the macOS sha256 values are rewritten, because the transitions run on
# macOS runners. The Linux sha256 values are deliberately left untouched and
# must not be relied on in the rendered output.
import re
import sys

SHA256_LINE = re.compile(r'^(\s*sha256 ")[0-9a-f]{64}(")$')
VERSION_LINE = re.compile(r'^  version "(.+)"$', re.MULTILINE)
MACOS_SHA_KEYS = ("macos-arm64", "macos-x86_64")


def rewrite(formula, version, shas):
    """Return formula repointed at version, with macOS sha256 values replaced.

    The version appears in the version stanza and in every url, so it is
    replaced as a plain string. Each sha256 is matched to a platform by the url
    line that precedes it, which is how the formula pairs them.
    """
    current_version = VERSION_LINE.search(formula)
    if not current_version:
        raise SystemExit("no version stanza found in formula")
    formula = formula.replace(current_version.group(1), version)

    rendered = []
    platform = None
    for line in formula.split("\n"):
        if '  url "' in line:
            platform = next((key for key in shas if key in line), None)
        sha256 = SHA256_LINE.match(line)
        if sha256 and platform:
            line = f"{sha256.group(1)}{shas[platform]}{sha256.group(2)}"
            platform = None
        rendered.append(line)
    return "\n".join(rendered)


def main():
    if len(sys.argv) != 5:
        raise SystemExit(
            f"usage: {sys.argv[0]} FORMULA VERSION ARM64_SHA256 X86_64_SHA256"
        )
    path, version, arm64_sha256, x86_64_sha256 = sys.argv[1:5]
    shas = dict(zip(MACOS_SHA_KEYS, (arm64_sha256, x86_64_sha256)))

    with open(path, encoding="utf-8") as formula:
        rendered = rewrite(formula.read(), version, shas)
    with open(path, "w", encoding="utf-8") as formula:
        formula.write(rendered)


if __name__ == "__main__":
    main()
