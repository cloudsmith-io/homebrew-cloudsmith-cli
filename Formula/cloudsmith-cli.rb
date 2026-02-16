# Copyright 2026 Cloudsmith Ltd
class CloudsmithCli < Formula
  desc "Official Cloudsmith Command-Line Interface - Be Awesome. Automate Everything"
  homepage "https://help.cloudsmith.io/docs/cli/"
  url "https://github.com/cloudsmith-io/cloudsmith-cli/releases/download/v1.13.0/cloudsmith.pyz"
  sha256 "4daeb37e0fecacc3b90150b4d61be97065d9dbfdbd015eb8df9baf5c212df997"
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