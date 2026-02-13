# Copyright 2026 Cloudsmith Ltd
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface - Be Awesome. Automate Everything"
  homepage "https://help.cloudsmith.io/docs/cli/"
  url "https://github.com/cloudsmith-io/cloudsmith-cli/releases/download/v1.12.1/cloudsmith.pyz"
  sha256 "78e70e148fabd17be225b345ad4dce0b7f686ecb1b24a1a34a3460d89a232f95"
  license "Apache-2.0"

  # The PEX/zipapp bundles all Python dependencies, so we only need Python 3
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
    assert_match "1.12.1", shell_output("#{bin}/cloudsmith --version")
  end
end
