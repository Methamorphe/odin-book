#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXAMPLES_DIR="$ROOT_DIR/examples"

if ! command -v odin >/dev/null 2>&1; then
  echo "error: Odin is not available on PATH" >&2
  exit 1
fi

if [[ ! -d "$EXAMPLES_DIR" ]]; then
  echo "error: examples directory does not exist: $EXAMPLES_DIR" >&2
  exit 1
fi

echo "Odin compiler:"
odin version

echo
printf 'Discovering Odin example packages...\n'

mapfile -t package_dirs < <(
  find "$EXAMPLES_DIR" -type f -name '*.odin' -printf '%h\n' \
    | sort -u
)

if [[ ${#package_dirs[@]} -eq 0 ]]; then
  echo "error: no Odin examples were found" >&2
  exit 1
fi

checked=0
tested=0
failed=0

for package_dir in "${package_dirs[@]}"; do
  relative_dir="${package_dir#"$ROOT_DIR"/}"

  # A child directory can be imported by its parent example package. Checking
  # both remains useful because every package should also be valid in isolation.
  echo "::group::odin check $relative_dir"
  if odin check "$package_dir" -vet -warnings-as-errors; then
    checked=$((checked + 1))
  else
    failed=$((failed + 1))
  fi
  echo "::endgroup::"

  if grep -Rqs --include='*.odin' '@(test)' "$package_dir"; then
    echo "::group::odin test $relative_dir"
    if odin test "$package_dir" -vet -warnings-as-errors; then
      tested=$((tested + 1))
    else
      failed=$((failed + 1))
    fi
    echo "::endgroup::"
  fi
done

echo
printf 'Checked packages: %d\n' "$checked"
printf 'Test packages:    %d\n' "$tested"
printf 'Failures:         %d\n' "$failed"

if [[ $failed -ne 0 ]]; then
  exit 1
fi
