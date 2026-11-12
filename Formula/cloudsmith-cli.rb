# Copyright 2026 Cloudsmith Ltd
#
# The Bump Cloudsmith CLI workflow moves this formula to each Cloudsmith CLI
# release. It changes only the version, the sha256 values and the revision.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.31.1"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.31.1/cloudsmith-1.31.1-macos-arm64.tar.gz"
    sha256 "b029e8b50a21266f9fab803d0c7cc98a3bd14e4e907819a89e8ad3a1efbe70be"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.31.1/cloudsmith-1.31.1-macos-x86_64.tar.gz"
    sha256 "0ff086756eb16debeb46a1585b11b0c4d7d379b520969135a20f051d463a18be"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.31.1/cloudsmith-1.31.1-linux-aarch64-gnu.tar.gz"
    sha256 "d197c26cd3ade78e16adbb2f4ea58426ded0687ba04d807267923e06d2c7ea3d"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.31.1/cloudsmith-1.31.1-linux-x86_64-gnu.tar.gz"
    sha256 "8cfbafa736921a8986d9b598622c28ef4cd0978f7c9493dbb7d42c7a720d48d8"
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
