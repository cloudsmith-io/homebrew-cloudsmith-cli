# Cloudsmith CLI Homebrew Tap

This is the official Homebrew tap for installing the [Cloudsmith CLI](https://docs.cloudsmith.com/developer-tools/cli).

The formula installs the released `cloudsmith.pyz` PEX/zipapp from [`cloudsmith-io/cloudsmith-cli`](https://github.com/cloudsmith-io/cloudsmith-cli/releases), exposes it as the `cloudsmith` command, and uses Homebrew's `python@3.10` runtime dependency to execute it.

## Installation

```bash
brew tap cloudsmith-io/cloudsmith-cli
brew install cloudsmith-cli
```

To upgrade an existing installation:

```bash
brew upgrade cloudsmith-cli
```

To verify the installed CLI:

```bash
cloudsmith --version
```

## Platform Support

This formula uses the official [Cloudsmith CLI PEX/zipapp distribution](https://github.com/cloudsmith-io/cloudsmith-cli/releases), which supports:

- **Linux x86_64** (glibc) - Debian, Ubuntu, RHEL, CentOS
- **Linux ARM64** (glibc) - ARM-based Linux servers
- **Linux x86_64** (musl) - Alpine Linux
- **Linux ARM64** (musl) - Alpine Linux ARM
- **macOS ARM64** - Apple Silicon

**Python versions:** 3.10, 3.11, 3.12, 3.13, 3.14

For the full platform matrix, see [`.github/.platforms`](https://github.com/cloudsmith-io/cloudsmith-cli/tree/master/.github/.platforms) in the Cloudsmith CLI repository.

## Bumping the CLI Version

The normal maintainer workflow is to use the release helper:

```bash
./scripts/bump-cloudsmith-cli.sh
```

The helper finds the latest Cloudsmith CLI release, downloads `cloudsmith.pyz`, calculates the SHA256 used by Homebrew, creates a release branch, updates `Formula/cloudsmith-cli.rb`, runs quick checks, stages the formula change, and prints the commit, push, and PR commands for final review.

To bump to a specific version:

```bash
./scripts/bump-cloudsmith-cli.sh --version v1.17.0
```

Review the staged diff before running the printed commands:

```bash
git diff --cached
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full release bump workflow and local testing commands.

## License

This tap is provided under the [Apache License 2.0](LICENSE).
