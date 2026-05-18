# Contributing to the Cloudsmith CLI Homebrew Tap

This repository contains the Homebrew formula for installing the [Cloudsmith CLI](https://docs.cloudsmith.com/developer-tools/cli). Most maintenance work here is bumping the formula to a newly released Cloudsmith CLI version.

## Setup

Clone the tap repository:

```bash
git clone https://github.com/cloudsmith-io/homebrew-cloudsmith-cli.git
cd homebrew-cloudsmith-cli
```

Install the formula locally for testing:

```bash
brew install --build-from-source ./Formula/cloudsmith-cli.rb
```

To reinstall after formula changes:

```bash
brew uninstall cloudsmith-cli
brew install --build-from-source ./Formula/cloudsmith-cli.rb
```

Run Homebrew audit checks when this repository is your active Homebrew tap checkout:

```bash
brew audit --strict --online cloudsmith-cli
```

If you are working from a regular clone outside Homebrew's tap directory, `brew audit cloudsmith-cli` audits the tapped copy instead of this checkout.

## Bumping the CLI Version

Use the release helper from a clean, up-to-date `main` branch:

```bash
./scripts/bump-cloudsmith-cli.sh
```

This is the standard release bump workflow. The helper will:

1. Find the latest released version from [`cloudsmith-io/cloudsmith-cli`](https://github.com/cloudsmith-io/cloudsmith-cli/releases).
2. Download the released `cloudsmith.pyz` asset.
3. Calculate the SHA256 for the asset used by Homebrew.
4. Create a release branch named `release/cloudsmith-cli-v<version>`.
5. Update `Formula/cloudsmith-cli.rb`.
6. Run `ruby -c Formula/cloudsmith-cli.rb`.
7. Run `brew audit --strict --online cloudsmith-cli` when this checkout is the active Homebrew tap.
8. Stage the formula change.
9. Print the commit, push, and PR commands for you to run after review.

To target a specific version:

```bash
./scripts/bump-cloudsmith-cli.sh --version v1.17.0
```

To preview the release and SHA without editing files:

```bash
./scripts/bump-cloudsmith-cli.sh --dry-run
```

After the helper finishes, review the staged diff:

```bash
git diff --cached
```

Then run the commands printed by the helper. The script intentionally stops before committing or pushing so maintainers can do a final review first.

## Manual Fallback

If the helper cannot be used, update the `url` and `sha256` in `Formula/cloudsmith-cli.rb` manually. The SHA256 must be calculated from the released `cloudsmith.pyz` asset, not the source archive:

```bash
curl -L -o cloudsmith.pyz https://github.com/cloudsmith-io/cloudsmith-cli/releases/download/<VERSION>/cloudsmith.pyz
shasum -a 256 cloudsmith.pyz
```

Then run:

```bash
ruby -c Formula/cloudsmith-cli.rb
brew audit --strict --online cloudsmith-cli
git add Formula/cloudsmith-cli.rb
```

Only run the `brew audit` command from the active Homebrew tap checkout; otherwise use it after syncing the tap.
