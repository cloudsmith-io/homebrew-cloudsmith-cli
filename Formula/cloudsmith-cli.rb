# Copyright 2026 Cloudsmith Ltd
#
# Template for the Homebrew formula published to the Homebrew tap
# repository. Rendered by the release workflow (publish-homebrew job);
# do not edit the rendered copy in the tap by hand.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.23.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.23.0/cloudsmith-1.23.0-macos-arm64.tar.gz"
    sha256 "16cced31e4ce84fd8d67be741663cd29b1b6ade61666d496562d8f23be2c471b"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.23.0/cloudsmith-1.23.0-macos-x86_64.tar.gz"
    sha256 "f9b5db7075031b1391f40a8dfead7aab53f8278c4dd5d3896a0374c7f359227c"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.23.0/cloudsmith-1.23.0-linux-aarch64-gnu.tar.gz"
    sha256 "4170d3cd7ffb7b89773dc06d3f304bd2ab75d7c5fbc95646411489e3211cd1af"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.23.0/cloudsmith-1.23.0-linux-x86_64-gnu.tar.gz"
    sha256 "10d43dfaf963e72fee318e4379ab42fe816850395b96f9fc4a41fc890ef5edb6"
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
