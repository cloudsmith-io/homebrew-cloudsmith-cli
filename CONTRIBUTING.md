# Contributing to the Cloudsmith CLI Homebrew Tap

Thanks for your interest in contributing to our Cloudsmith Homebrew tap! We welcome contributions that help improve the installation and usage of the Cloudsmith CLI via Homebrew.

## 🧰 Developer Setup

### 1. Clone the Tap Repository

```bash
git clone https://github.com/cloudsmith-io/homebrew-cloudsmith-cli.git
cd homebrew-cloudsmith-cli
```

### 2. Install Locally (for testing)

Use this to build and test the formula from source:

```bash
brew install --build-from-source ./Formula/cloudsmith-cli.rb
```

To uninstall and reinstall:

```bash
brew uninstall cloudsmith-cli
brew install --build-from-source ./Formula/cloudsmith-cli.rb
```

### 3. Run Audit Checks

Ensure your formula passes linting and validation:

```bash
brew audit --strict --online ./Formula/cloudsmith-cli.rb
```

---

## 🔁 Bumping the Version

When a new version of the Cloudsmith CLI is released:

1. Update the `url` and `sha256` in `Formula/cloudsmith-cli.rb`.
2. You can generate the SHA256 like this:

```bash
curl -L -o tmp.tar.gz https://github.com/cloudsmith-io/cloudsmith-cli/archive/refs/tags/<VERSION>.tar.gz
shasum -a 256 tmp.tar.gz
```

3. Update the formula and commit:

```bash
git add Formula/cloudsmith-cli.rb
git commit -m "Bump cloudsmith-cli to <VERSION>"
git push
```

---

## 💬 Need Help?

If you're unsure about something, feel free to open a GitHub issue or contact [support@cloudsmith.io](mailto:support@cloudsmith.io).