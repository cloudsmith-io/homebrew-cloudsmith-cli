# Copyright 2026 Cloudsmith Ltd
#
# The Bump Cloudsmith CLI workflow moves this formula to each Cloudsmith CLI
# release. It changes only the version, the sha256 values and the revision.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.30.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.30.0/cloudsmith-1.30.0-macos-arm64.tar.gz"
    sha256 "f4e4aa194a218bca7d61c9645c65d8903144defb94fe48ad8fe4a23cadfb4b3b"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.30.0/cloudsmith-1.30.0-macos-x86_64.tar.gz"
    sha256 "a6e56297aeee17279c4c03393b975a2a974f3d6bd6f7992badb36c90c217e283"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.30.0/cloudsmith-1.30.0-linux-aarch64-gnu.tar.gz"
    sha256 "b2580bc0c348302e8a2f2d9bb3ddbf16207442047f4c6106c20f36a0d993af0e"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.30.0/cloudsmith-1.30.0-linux-x86_64-gnu.tar.gz"
    sha256 "21898e015ea167f5916a14ebd87b4a5c299f1484013cb45b0f82ec0c14aa000b"
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
