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

  # The 1.19.0 zipapp bundles native wheels for macOS arm64 only: it carries no
  # macosx x86_64 build of rpds-py, pydantic-core or cffi, so it cannot run on an
  # Intel Mac. Fail with that up front rather than a PEX resolution dump.
  on_macos do
    depends_on arch: :arm64
  end

  def install
    libexec.install "cloudsmith.pyz"

    # Run the zipapp under the interpreter this formula depends on. Its
    # `#!/usr/bin/env python3` shebang would otherwise pick up whatever python3
    # comes first on PATH, which on some machines is older than the 3.10 the
    # zipapp requires.
    python = formula_opt_bin("python@3.10")/"python3.10"
    (bin/"cloudsmith").write <<~BASH
      #!/bin/bash
      exec "#{python}" "#{libexec}/cloudsmith.pyz" "$@"
    BASH
    chmod 0755, bin/"cloudsmith"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cloudsmith --version")
  end
end
