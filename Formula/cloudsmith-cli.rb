# Copyright 2026 Cloudsmith Ltd
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface - Be Awesome. Automate Everything"
  homepage "https://help.cloudsmith.io/docs/cli/"
  url "https://github.com/cloudsmith-io/cloudsmith-cli/releases/download/v1.15.0/cloudsmith.pyz"
  sha256 "7b8b454deaa3d8c9149aab80adb25aa7fa2690f058bf37aad54b2edff100dfaa"
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