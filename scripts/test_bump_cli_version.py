# Copyright 2026 Cloudsmith Ltd
import hashlib
import importlib
import tempfile
import unittest
from pathlib import Path

bump_cli_version = importlib.import_module("bump-cli-version")

FORMULA = """\
class CloudsmithCli < Formula
  version "1.29.0"
  revision 1

  if OS.mac?
    url "https://dl.cloudsmith.io/cloudsmith-cli-macos-arm64/versions/1.29.0/cloudsmith-1.29.0-macos-arm64.tar.gz"
    sha256 "{old}"
  else
    url "https://dl.cloudsmith.io/cloudsmith-cli-linux-x86_64-gnu/versions/1.29.0/cloudsmith-1.29.0-linux-x86_64-gnu.tar.gz"
    sha256 "{old}"
  end

  livecheck do
    url "https://dl.cloudsmith.io/cloudsmith-cli-manifest-macos-arm64/versions/latest/manifest.txt"
  end
end
""".replace("{old}", "0" * 64)

SHA256SUMS = f"""\
{"1" * 64}  cloudsmith-1.30.0-linux-x86_64-gnu.tar.gz
{"2" * 64}  cloudsmith-1.30.0-linux-x86_64-musl.tar.gz
{"3" * 64}  cloudsmith-1.30.0-macos-arm64.tar.gz
{"4" * 64}  cloudsmith-1.30.0-windows-x86_64.zip
"""


class BumpTest(unittest.TestCase):
    def test_moves_version_and_checksums_and_drops_revision(self):
        bumped = bump_cli_version.bump(FORMULA, "1.30.0", SHA256SUMS)

        self.assertIn('  version "1.30.0"', bumped)
        self.assertNotIn("1.29.0", bumped)
        self.assertNotIn("revision", bumped)
        self.assertIn(
            'cloudsmith-1.30.0-macos-arm64.tar.gz"\n    sha256 "' + "3" * 64, bumped
        )
        self.assertIn(
            'cloudsmith-1.30.0-linux-x86_64-gnu.tar.gz"\n    sha256 "' + "1" * 64,
            bumped,
        )

    def test_keeps_a_formula_that_pins_the_version_or_a_newer_one(self):
        self.assertIsNone(bump_cli_version.bump(FORMULA, "1.29.0", SHA256SUMS))
        self.assertIsNone(bump_cli_version.bump(FORMULA, "1.28.9", SHA256SUMS))

    def test_fails_when_a_formula_target_has_no_checksum(self):
        sums = SHA256SUMS.replace("macos-arm64", "macos-x86_64")

        with self.assertRaises(SystemExit):
            bump_cli_version.bump(FORMULA, "1.30.0", sums)


class VerifyDownloadsTest(unittest.TestCase):
    def test_checks_each_download_against_its_checksum(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory, "cloudsmith-1.30.0-macos-arm64.tar.gz")
            archive.write_bytes(b"archive")
            good_sha256 = hashlib.sha256(b"archive").hexdigest()
            formula = f'    url "{archive.as_uri()}"\n    sha256 "{good_sha256}"\n'

            bump_cli_version.verify_downloads(formula)
            with self.assertRaises(SystemExit):
                bump_cli_version.verify_downloads(
                    formula.replace(good_sha256, "f" * 64)
                )


if __name__ == "__main__":
    unittest.main()
