# Copyright 2026 Cloudsmith Ltd
#
# Template for the Homebrew formula published to the Homebrew tap
# repository. Rendered by the release workflow (publish-homebrew job);
# do not edit the rendered copy in the tap by hand.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.27.0"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.27.0/cloudsmith-1.27.0-macos-arm64.tar.gz"
    sha256 "7fd6e900dd1e93397541b9f5476506da0e6e7c8e6f6db63d33689047eafbcc57"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.27.0/cloudsmith-1.27.0-macos-x86_64.tar.gz"
    sha256 "07ea2a903d7b0d392ec57a0bf93e659b5ff5224f683fe0a9f468c844d94fc5d3"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.27.0/cloudsmith-1.27.0-linux-aarch64-gnu.tar.gz"
    sha256 "5efc13d0566de875ec20d171fdb9f7ef1529a5bb13d1e02a72d897a494cd9046"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.27.0/cloudsmith-1.27.0-linux-x86_64-gnu.tar.gz"
    sha256 "cf714418c992d2e9a6a5d81c1523f4e0ac2e2cea0898e91f9df35a399254d014"
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
