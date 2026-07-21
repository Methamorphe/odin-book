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

  # The arithmetic package is validated through the Chapter 8 application,
  # which supplies the local `project:` collection required by its import.
  if [[ "$relative_dir" == "examples/08-packages/arithmetic" ]]; then
    continue
  fi

  check_args=(check "$package_dir")
  test_args=(test "$package_dir")

  if [[ "$relative_dir" == "examples/08-packages/app" ]]; then
    collection_arg="-collection:project=$EXAMPLES_DIR/08-packages"
    check_args+=("$collection_arg")
    test_args+=("$collection_arg")
  fi

  echo "::group::odin ${check_args[*]}"
  if odin "${check_args[@]}"; then
    checked=$((checked + 1))
  else
    failed=$((failed + 1))
  fi
  echo "::endgroup::"

  if grep -Rqs --include='*.odin' '@(test)' "$package_dir"; then
    echo "::group::odin ${test_args[*]}"
    if odin "${test_args[@]}"; then
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
