# Contributing to the Cloudsmith CLI Homebrew Tap

This repository is the Homebrew tap for the [Cloudsmith CLI](https://docs.cloudsmith.com/developer-tools/cli).

Everything here is maintained by hand. Each Cloudsmith CLI release changes only
the version, the sha256 values and the revision in `Formula/cloudsmith-cli.rb`.

## How the Main Formula Is Released

Each Cloudsmith CLI release sends a `cloudsmith-cli-release` event to this
repository. The `Bump Cloudsmith CLI` workflow then runs
`scripts/bump-cli-version.py`. The script reads the sha256 of each platform
from the `SHA256SUMS` asset of the CLI release. It verifies each published
download against its sha256, then writes the new version and the sha256 values
into the formula. The workflow opens a bump pull request as `cloudsmith-bot` and
squash-merges it when the checks pass.

To move to a CLI version by hand, run the `Bump Cloudsmith CLI` workflow with
that version. To see the change locally, run
`python3 scripts/bump-cli-version.py 1.29.1`. The workflow needs the
`DOWNSTREAM_RELEASE_PUSH_TOKEN` and `CLOUDSMITH_BOT_SSH_KEY` secrets of
`cloudsmith-bot`.

To fix the formula, change `Formula/cloudsmith-cli.rb` here. The next release
keeps the change. Add `revision 1` (or the next number) when the CLI version
itself has not changed, so that Homebrew treats it as an upgrade and existing
installs pick the fix up. The next release removes the revision.

## What Is Maintained Here

- `Formula/cloudsmith-cli@<version>.rb` — pinned rollback targets. The bump
  workflow does not touch these, so they persist across releases. See the
  [README](README.md#holding-or-rolling-back-a-version).
- `.github/workflows/formula-test.yml` — installs, uninstalls, upgrades,
  downgrades and pins the formulae on macOS arm64 and Intel. This is what catches
  breakage that a syntax check cannot, so trust it over local spot checks.
- `Aliases/`, `README.md`, and this file.

## Testing Locally

Homebrew only loads formulae from a tap, so work inside the tap checkout rather
than a plain clone:

```bash
brew tap cloudsmith-io/cloudsmith-cli
cd "$(brew --repository cloudsmith-io/cloudsmith-cli)"
```

Then, after editing:

```bash
brew style Formula/cloudsmith-cli.rb
brew audit --strict --online cloudsmith-cli
brew install cloudsmith-io/cloudsmith-cli/cloudsmith-cli
brew test cloudsmith-io/cloudsmith-cli/cloudsmith-cli
```

A prebuilt bundle can install cleanly and still be wrong in ways only the real
lifecycle shows, so let CI exercise the upgrade, downgrade and pin paths on both
architectures before merging.
