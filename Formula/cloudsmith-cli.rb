# Copyright 2026 Cloudsmith Ltd
#
# Template for the Homebrew formula published to the Homebrew tap
# repository. Rendered by the release workflow (publish-homebrew job);
# do not edit the rendered copy in the tap by hand.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.28.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.28.0/cloudsmith-1.28.0-macos-arm64.tar.gz"
    sha256 "eb596af23c7965e1c9f9f420aa2b06d90f9b259b0957e39d1e53795cf33801f1"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.28.0/cloudsmith-1.28.0-macos-x86_64.tar.gz"
    sha256 "d963680ce76649c4e591b19266db82746540150de3fb1e9551bb78920443d2c4"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.28.0/cloudsmith-1.28.0-linux-aarch64-gnu.tar.gz"
    sha256 "b44f78a328fc04214e278b4a67a00914d0d2e07b87b89c57363dd10d4f73e660"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.28.0/cloudsmith-1.28.0-linux-x86_64-gnu.tar.gz"
    sha256 "bb5e8302c970157e5415d9e954af690f24fffe76254bdfd9fe4f8fa70fdd723b"
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
