# Copyright 2026 Cloudsmith Ltd
#
# Pinnable rollback target for the last release before the CLI switched to a
# PyInstaller bundle. Kept so that anyone broken by a newer release can return
# to a known-good version with `brew install cloudsmith-cli@1.19.0`, rather than
# reconstructing an old formula out of this tap's git history.
#
# Intentionally frozen: this file describes 1.19.0 and should not be bumped.
class CloudsmithCliAT1190 < Formula
  desc "Official Cloudsmith Command-Line Interface (pinned 1.19.0)"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  url "https://github.com/cloudsmith-io/cloudsmith-cli/releases/download/v1.19.0/cloudsmith.pyz"
  sha256 "c076e4b002ee07f26774c0f8a9134f52a73b16a3fb10adb31891475485e28038"
  license "Apache-2.0"

  keg_only :versioned_formula

  # The PEX/zipapp bundles all Python dependencies, so we only need Python 3.10.
  depends_on "python@3.10"

  def install
    libexec.install "cloudsmith.pyz"
    chmod 0755, libexec/"cloudsmith.pyz"
    (bin/"cloudsmith").write_env_script libexec/"cloudsmith.pyz", {}
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cloudsmith --version")
  end
end
