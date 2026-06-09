# Copyright 2026 Cloudsmith Ltd
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface - Be Awesome. Automate Everything"
  homepage "https://docs.cloudsmith.com/developer-tools/cli"
  url "https://github.com/cloudsmith-io/cloudsmith-cli/releases/download/v1.18.0/cloudsmith.pyz"
  sha256 "e24942f58539bececc34100008872c980babca1a422ffb9830adb9c6f3767d09"
  license "Apache-2.0"

  # The PEX/zipapp bundles all Python dependencies, so we only need Python 3.10
  depends_on "python@3.10"

  def install
    # Install the zipapp directly to libexec
    libexec.install "cloudsmith.pyz"

    # Make the zipapp executable
    chmod 0755, libexec/"cloudsmith.pyz"

    # Create a wrapper script in bin that executes the zipapp
    (bin/"cloudsmith").write_env_script libexec/"cloudsmith.pyz", {}
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cloudsmith --version")
  end
end
