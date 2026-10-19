# Copyright 2026 Cloudsmith Ltd
import hashlib
import importlib
import io
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

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

    def test_needs_bump_only_for_a_newer_version(self):
        self.assertTrue(bump_cli_version.needs_bump(FORMULA, "1.30.0"))
        self.assertFalse(bump_cli_version.needs_bump(FORMULA, "1.29.0"))
        self.assertFalse(bump_cli_version.needs_bump(FORMULA, "1.28.9"))

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


class FetchTest(unittest.TestCase):
    @mock.patch.object(bump_cli_version.time, "sleep")
    @mock.patch.object(bump_cli_version.urllib.request, "urlopen")
    def test_tries_again_after_a_read_timeout(self, urlopen, _sleep):
        urlopen.side_effect = [TimeoutError("read timed out"), io.BytesIO(b"body")]

        self.assertEqual(bump_cli_version.fetch("https://example.com"), b"body")


class MainTest(unittest.TestCase):
    def test_does_not_fetch_for_a_pinned_version(self):
        with tempfile.TemporaryDirectory() as directory:
            formula_path = Path(directory, "cloudsmith-cli.rb")
            formula_path.write_text(FORMULA, encoding="utf-8")
            with mock.patch.multiple(
                bump_cli_version,
                FORMULA_PATH=str(formula_path),
                fetch=mock.Mock(side_effect=AssertionError("fetched")),
            ), mock.patch.object(sys, "argv", ["bump-cli-version.py", "1.29.0"]):
                bump_cli_version.main()

            self.assertEqual(formula_path.read_text(encoding="utf-8"), FORMULA)


if __name__ == "__main__":
    unittest.main()
