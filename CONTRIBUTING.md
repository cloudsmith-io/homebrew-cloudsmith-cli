# Contributing to the Cloudsmith CLI Homebrew Tap

This repository is the Homebrew tap for the [Cloudsmith CLI](https://docs.cloudsmith.com/developer-tools/cli).

`Formula/cloudsmith-cli.rb` is **generated**, not hand-maintained. Everything else here is maintained by hand.

## How the Main Formula Is Released

The Cloudsmith CLI release workflow owns `Formula/cloudsmith-cli.rb`. Its
`publish-homebrew` job renders
[`packaging/homebrew/cloudsmith-cli.rb.tmpl`](https://github.com/cloudsmith-io/cloudsmith-cli/blob/master/packaging/homebrew/cloudsmith-cli.rb.tmpl)
with the new version and each platform's SHA256, verifies those checksums against
the published downloads, and opens a bump pull request here as `cloudsmith-bot`.
Review it and merge with a squash merge. There is nothing to run in this
repository for a version bump.

Because that job copies the rendered file over `Formula/cloudsmith-cli.rb`
wholesale, **any change to the main formula must be made in the upstream
template**, or the next release will silently drop it.

If a formula fix is urgent, land it here to unblock users and open the matching
template change upstream in the same sitting. Add `revision 1` (or the next
number) when the CLI version itself has not changed, so that Homebrew treats it
as an upgrade and existing installs pick the fix up. The next release removes the
revision on its own.

## What Is Maintained Here

- `Formula/cloudsmith-cli@<version>.rb` — pinned rollback targets. The release
  job does not touch these, so they persist across releases. See the
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
