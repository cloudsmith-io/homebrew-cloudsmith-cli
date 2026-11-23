# Copyright 2026 Cloudsmith Ltd
#
# The Bump Cloudsmith CLI workflow moves this formula to each Cloudsmith CLI
# release. It changes only the version, the sha256 values and the revision.
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  version "1.31.4"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-arm64/versions/1.31.4/cloudsmith-1.31.4-macos-arm64.tar.gz"
    sha256 "c15584633b77e2159a209c8f3b9a08cc5ed01dde51f4c04d51faae5a4493f0b1"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-macos-x86_64/versions/1.31.4/cloudsmith-1.31.4-macos-x86_64.tar.gz"
    sha256 "66c7a9559077bd73d8913ece041b3d73810736c5edbee1c25d5cadbf41a9ffe2"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-aarch64-gnu/versions/1.31.4/cloudsmith-1.31.4-linux-aarch64-gnu.tar.gz"
    sha256 "4ecbb68efd26c5f469693dc1293f9041823df9a486f3c2c61aa949fc97a75364"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://dl.cloudsmith.io/public/cloudsmith/cli/raw/names/cloudsmith-cli-linux-x86_64-gnu/versions/1.31.4/cloudsmith-1.31.4-linux-x86_64-gnu.tar.gz"
    sha256 "ff07f6874ef6b89f4a23f6b0d67e2acf590ac664ef06060155fe68f9402cecf0"
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
