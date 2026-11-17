# Copyright 2026 Cloudsmith Ltd
#
# The Bump Cloudsmith CLI workflow moves this formula to each Cloudsmith CLI
# release. It changes only the version, the sha256 values and the revision.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.31.3"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.31.3/cloudsmith-1.31.3-macos-arm64.tar.gz"
    sha256 "a8ca85ffa1b67f5328bc7a7b3ae1532a98c84dea494196c172334f60873e4751"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.31.3/cloudsmith-1.31.3-macos-x86_64.tar.gz"
    sha256 "305b2d0070d7405e8c8dee27307077fdac8b51e59fc98d6e6c6405de0d46ad12"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.31.3/cloudsmith-1.31.3-linux-aarch64-gnu.tar.gz"
    sha256 "450dbbedec49c4eadbbd5d9fceba0c8981eaf483acf0a6bbeb71cd84a9b481ed"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.31.3/cloudsmith-1.31.3-linux-x86_64-gnu.tar.gz"
    sha256 "eb1bc187543ce5e977a4a1733b5389118ee6ed1859acd35fc17b564ac77c80cf"
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
