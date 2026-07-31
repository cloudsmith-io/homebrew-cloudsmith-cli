# Cloudsmith CLI Homebrew Tap

This is the official Homebrew tap for the [Cloudsmith CLI](https://docs.cloudsmith.com/developer-tools/cli).

The formula installs the standalone Cloudsmith CLI binary: a self-contained executable with no Python dependency.

## Installation

Install the CLI by using its full formula name:

```bash
brew install cloudsmith-io/cloudsmith-cli/cloudsmith-cli
```

Or install it by using the shorter `cloudsmith` alias:

```bash
brew install cloudsmith-io/cloudsmith-cli/cloudsmith
```

To upgrade an existing installation:

```bash
brew upgrade cloudsmith-cli
```

If you installed the CLI before v1.20.1, it was built on the Python-based `cloudsmith.pyz` zipapp. Upgrading to the standalone binary formula is automatic: Homebrew replaces the old installation with the new one. Afterward, the now-orphaned `python@3.10` dependency can be removed with:

```bash
brew autoremove
```

To verify the installed CLI:

```bash
cloudsmith --version
```

## Holding or Rolling Back a Version

To stay on the version you already have and stop `brew upgrade` moving it:

```bash
brew pin cloudsmith-cli
```

Use `brew unpin cloudsmith-cli` to release it again.

This tap keeps two older versions as pinnable rollback targets:

| Formula | Version | Platforms |
| --- | --- | --- |
| `cloudsmith-cli@1.20.1` | 1.20.1, standalone binary | all supported platforms |
| `cloudsmith-cli@1.19.0` | 1.19.0, last Python zipapp release | macOS arm64 and Linux |

`cloudsmith-cli@1.19.0` is unavailable on Intel macOS because that release
shipped no Intel macOS builds of its native dependencies.

To roll back, uninstall the current version and install the target:

```bash
brew uninstall cloudsmith-cli
brew install cloudsmith-io/cloudsmith-cli/cloudsmith-cli@1.20.1
brew pin cloudsmith-cli@1.20.1
```

To roll back to any other version, extract that version's formula from this
tap's history into a tap of your own:

```bash
brew tap-new <your-org>/cloudsmith-cli-versions
brew extract --version=1.20.1 cloudsmith-io/cloudsmith-cli/cloudsmith-cli <your-org>/cloudsmith-cli-versions
brew uninstall cloudsmith-cli
brew install <your-org>/cloudsmith-cli-versions/cloudsmith-cli@1.20.1
```

## Supported Platforms

| Platform | Architecture |
| --- | --- |
| macOS | arm64 (Apple Silicon), x86_64 (Intel) |
| Linux (glibc) | x86_64, aarch64 |

Homebrew on Linux targets glibc, so musl-based distributions such as Alpine aren't supported by this formula.

## Where the Binaries Come From

The binaries are built and published by the Cloudsmith CLI release pipeline and hosted on Cloudsmith.

## More Information

- CLI documentation: see the [Cloudsmith CLI docs](https://docs.cloudsmith.com/developer-tools/cli).
- CLI source and releases: see the [cloudsmith-cli repository](https://github.com/cloudsmith-io/cloudsmith-cli).
- Formula or tap issues: file them in [this repository's issues](https://github.com/cloudsmith-io/homebrew-cloudsmith-cli/issues).
- CLI bugs: file them in the [cloudsmith-cli repository's issues](https://github.com/cloudsmith-io/cloudsmith-cli/issues).

For maintainer instructions on bumping the formula to a new CLI release, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This tap is provided under the [Apache License 2.0](LICENSE).
