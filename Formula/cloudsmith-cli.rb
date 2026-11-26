# Copyright 2026 Cloudsmith Ltd
#
# The Bump Cloudsmith CLI workflow moves this formula to each Cloudsmith CLI
# release. It changes only the version, the sha256 values and the revision.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.32.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.32.0/cloudsmith-1.32.0-macos-arm64.tar.gz"
    sha256 "7ff0f368a76fd1cbbc1175d81cb52d91ad771ed44b5c20a03848154e0babf091"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.32.0/cloudsmith-1.32.0-macos-x86_64.tar.gz"
    sha256 "7ac48202d456a780f1306b4e4276d600a8d314f5717d7f978a7e8d648861a11f"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.32.0/cloudsmith-1.32.0-linux-aarch64-gnu.tar.gz"
    sha256 "920c17f9d3d4470019790b7e9c5ce8c9d728e220b73332fa7e3cdd42b4f67ea4"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.32.0/cloudsmith-1.32.0-linux-x86_64-gnu.tar.gz"
    sha256 "154db0765e2e02e7ea8ed56040e7d46be0ba115db8e3c60c44340b524d6303d1"
  end

  # Placed after the url stanzas: a leading livecheck url is misdetected as the
  # stable url by audit when every real url is inside a conditional.
  livecheck do
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-manifest-macos-arm64/versions/latest/manifest.txt"
    regex(/^version=(\d+(?:\.\d+)+)$/i)
  end

  # The bundled libraries are private to the PyInstaller bundle and are resolved
  # via @rpath, so Homebrew must not rewrite their dylib IDs: the absolute Cellar
  # path does not fit in the Mach-O header padding of prebuilt wheels such as
  # pydantic_core, which fails the install.
  preserve_rpath

  def install
    # PyInstaller onedir bundle: the executable must stay next to _internal/.
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"cloudsmith"
  end

  test do
    assert_match "CLI Package Version: #{version}", shell_output("#{bin}/cloudsmith --version")
  end
end
