# Copyright 2026 Cloudsmith Ltd
#
# Template for the Homebrew formula published to the Homebrew tap
# repository. Rendered by the release workflow (publish-homebrew job);
# do not edit the rendered copy in the tap by hand.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.24.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.24.0/cloudsmith-1.24.0-macos-arm64.tar.gz"
    sha256 "1a82d3756ab7ef5dc9a3b13a078056877dd978a3cfb2138a473f1d6d5cf80294"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.24.0/cloudsmith-1.24.0-macos-x86_64.tar.gz"
    sha256 "49739ced3557765d862ebff7ea6775f5b1a1833fa26d52c0923c1f14206a2bde"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.24.0/cloudsmith-1.24.0-linux-aarch64-gnu.tar.gz"
    sha256 "62348e231f3311d2c99a0ee1f34ed5dd4ac41259311219848d5a6358bfbd9e24"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.24.0/cloudsmith-1.24.0-linux-x86_64-gnu.tar.gz"
    sha256 "cd86c81c2796ab76983e038b052b2e894a096678300ba982c9e84574ed40ef67"
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
