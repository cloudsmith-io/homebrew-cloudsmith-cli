# Copyright 2026 Cloudsmith Ltd
#
# Template for the Homebrew formula published to the Homebrew tap
# repository. Rendered by the release workflow (publish-homebrew job);
# do not edit the rendered copy in the tap by hand.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.22.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.22.0/cloudsmith-1.22.0-macos-arm64.tar.gz"
    sha256 "ee002df6e4cb7a3b505b279ab99a81ee9e2172a93f9030bc8b274ff6d8e46731"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.22.0/cloudsmith-1.22.0-macos-x86_64.tar.gz"
    sha256 "71425d382b607fa40542d6f6abcd6a8af2c4f27d30e385ad084f789389e7ea37"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.22.0/cloudsmith-1.22.0-linux-aarch64-gnu.tar.gz"
    sha256 "43f71278b3af0bbe30618ddc0a582bef00822b8f5167c7b6fdd77377b080f3f6"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.22.0/cloudsmith-1.22.0-linux-x86_64-gnu.tar.gz"
    sha256 "657ff4cb228ea2d4b769cafaa605d9a9eeaa8d7b2093102c972f60e411e3135a"
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
