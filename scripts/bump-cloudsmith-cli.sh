#!/usr/bin/env bash
set -euo pipefail

CLI_REPO="cloudsmith-io/cloudsmith-cli"
FORMULA_PATH="Formula/cloudsmith-cli.rb"
ASSET_NAME="cloudsmith.pyz"

requested_version=""
dry_run=0
run_checks=1
create_branch=1
allow_dirty=0

usage() {
  cat <<'USAGE'
Usage: ./scripts/bump-cloudsmith-cli.sh [options]

Fetch the latest Cloudsmith CLI release, update the Homebrew formula URL and
sha256 for cloudsmith.pyz, create a release branch, run quick checks, stage the
formula change, and print the final commit/push/PR commands.

Options:
  --version VERSION   Bump to a specific tag, for example v1.17.0 or 1.17.0.
  --dry-run           Resolve the release and SHA without changing files.
  --skip-checks       Skip ruby syntax and brew audit checks.
  --no-branch         Do not create or switch to the release branch.
  --allow-dirty       Allow running with existing uncommitted changes.
  -h, --help          Show this help text.
USAGE
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

normalize_tag() {
  local tag="$1"

  case "$tag" in
    v*) ;;
    *) tag="v${tag}" ;;
  esac

  printf '%s' "$tag" | grep -Eq '^v[0-9]+(\.[0-9]+)+([-.][0-9A-Za-z.]+)?$' \
    || die "Version must look like v1.17.0; got ${tag}"

  printf '%s\n' "$tag"
}

fetch_latest_tag() {
  curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${CLI_REPO}/releases/latest" \
    | ruby -rjson -e '
        release = JSON.parse(STDIN.read)
        tag = release["tag_name"]
        abort "GitHub release response did not include tag_name" if tag.nil? || tag.empty?
        puts tag
      '
}

extract_formula_tag() {
  ruby -ne '
    if $_ =~ %r{github\.com/cloudsmith-io/cloudsmith-cli/releases/download/(v[^/]+)/cloudsmith\.pyz}
      puts $1
      exit
    end
  ' "$FORMULA_PATH"
}

extract_formula_sha() {
  ruby -ne '
    if $_ =~ /^\s*sha256 "([0-9a-f]{64})"/
      puts $1
      exit
    end
  ' "$FORMULA_PATH"
}

update_formula() {
  DOWNLOAD_URL="$1" TARGET_SHA="$2" FORMULA_PATH="$FORMULA_PATH" ruby <<'RUBY'
path = ENV.fetch("FORMULA_PATH")
download_url = ENV.fetch("DOWNLOAD_URL")
target_sha = ENV.fetch("TARGET_SHA")

content = File.read(path)
raise "Could not find formula url line" unless content.match?(/^  url ".*"$/)
raise "Could not find formula sha256 line" unless content.match?(/^  sha256 ".*"$/)

content = content.sub(/^  url ".*"$/, %(  url "#{download_url}"))
content = content.sub(/^  sha256 ".*"$/, %(  sha256 "#{target_sha}"))

File.write(path, content)
RUBY
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      [ "$#" -ge 2 ] || die "--version requires a value"
      requested_version="$2"
      shift 2
      ;;
    --version=*)
      requested_version="${1#*=}"
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --skip-checks)
      run_checks=0
      shift
      ;;
    --no-branch)
      create_branch=0
      shift
      ;;
    --allow-dirty)
      allow_dirty=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" \
  || die "Run this script from inside the homebrew-cloudsmith-cli repository"
cd "$repo_root"

[ -f "$FORMULA_PATH" ] || die "Formula not found: $FORMULA_PATH"

require_command curl
require_command git
require_command ruby
require_command shasum
require_command awk

if [ "$dry_run" -eq 0 ] && [ "$allow_dirty" -eq 0 ]; then
  if ! git diff --quiet --exit-code || ! git diff --cached --quiet --exit-code; then
    die "Working tree has uncommitted changes. Commit or stash them first, or re-run intentionally with --allow-dirty."
  fi
fi

current_tag="$(extract_formula_tag)"
[ -n "$current_tag" ] || die "Could not find the current cloudsmith.pyz release tag in $FORMULA_PATH"

current_sha="$(extract_formula_sha)"
[ -n "$current_sha" ] || die "Could not find the current sha256 in $FORMULA_PATH"

if [ -n "$requested_version" ]; then
  target_tag="$(normalize_tag "$requested_version")"
else
  printf 'Fetching latest Cloudsmith CLI release...\n'
  target_tag="$(normalize_tag "$(fetch_latest_tag)")"
fi

if [ "$current_tag" = "$target_tag" ]; then
  printf 'Formula already points at %s. Nothing to bump.\n' "$target_tag"
  exit 0
fi

download_url="https://github.com/${CLI_REPO}/releases/download/${target_tag}/${ASSET_NAME}"
branch_name="release/cloudsmith-cli-${target_tag}"
tmp_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

asset_path="${tmp_dir}/${ASSET_NAME}"

printf 'Downloading %s...\n' "$download_url"
curl -fsSL --retry 3 --retry-delay 2 -o "$asset_path" "$download_url"
target_sha="$(shasum -a 256 "$asset_path" | awk '{print $1}')"

printf '%s' "$target_sha" | grep -Eq '^[0-9a-f]{64}$' \
  || die "Calculated SHA256 does not look valid: ${target_sha}"

if [ "$dry_run" -eq 1 ]; then
  cat <<EOF

Dry run only. No files were changed.

Current formula:
  version: $current_tag
  sha256:  $current_sha

Target formula:
  version: $target_tag
  url:     $download_url
  sha256:  $target_sha
  branch:  $branch_name

The real run will update $FORMULA_PATH, run quick checks, stage the formula,
and print commit/push commands.
EOF
  exit 0
fi

if [ "$create_branch" -eq 1 ]; then
  current_branch="$(git branch --show-current)"
  if [ "$current_branch" != "$branch_name" ]; then
    if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
      git switch "$branch_name"
    else
      git switch -c "$branch_name"
    fi
  fi
fi

update_formula "$download_url" "$target_sha"

if [ "$run_checks" -eq 1 ]; then
  printf 'Running ruby syntax check...\n'
  ruby -c "$FORMULA_PATH"

  if command -v brew >/dev/null 2>&1; then
    printf 'Running brew audit...\n'
    brew audit --strict --online "$FORMULA_PATH"
  else
    printf 'Skipping brew audit because brew is not available on PATH.\n'
  fi
fi

git add "$FORMULA_PATH"
active_branch="$(git branch --show-current)"

cat <<EOF

Updated and staged $FORMULA_PATH

Version:
  $current_tag -> $target_tag

SHA256:
  $current_sha -> $target_sha

Review before committing:
  git diff --cached

Copy/paste when ready:
  git commit -m "Bump cloudsmith-cli to $target_tag"
  git push -u origin $active_branch
  gh pr create --fill
EOF
