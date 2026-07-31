# Copyright 2026 Cloudsmith Ltd
#
# Pinnable rollback target covering every supported platform. Kept alongside
# cloudsmith-cli@1.19.0, which is the escape hatch from the PyInstaller
# packaging but ships macOS arm64 builds only.
#
# Intentionally frozen: this file describes 1.20.1 and should not be bumped.
class CloudsmithCliAT1201 < Formula
  desc "Official Cloudsmith Command-Line Interface (pinned 1.20.1)"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.20.1"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.20.1/cloudsmith-1.20.1-macos-arm64.tar.gz"
    sha256 "2c2580eb8725467877f2a296d675fd681abe01050099a6405d5b4c37c6f3b901"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.20.1/cloudsmith-1.20.1-macos-x86_64.tar.gz"
    sha256 "a8e959909caab7d8d6fac390d530cd2a4bff3e70c97e12e06e2587a5b7ddfc85"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.20.1/cloudsmith-1.20.1-linux-aarch64-gnu.tar.gz"
    sha256 "7ff869d1d059759a938d97bdc5173d7f481782dfa7677870797b8643bd09c95c"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.20.1/cloudsmith-1.20.1-linux-x86_64-gnu.tar.gz"
    sha256 "1738b6057cac7fb60dd9a6bd72fe335560ef51d93f79b052be2df379fb2fb385"
  end

  keg_only :versioned_formula

  preserve_rpath

  def install
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"cloudsmith"
  end

  test do
    assert_match "CLI Package Version: #{version}", shell_output("#{bin}/cloudsmith --version")
  end
end
