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

  # The Chapter 8 arithmetic package is validated through the app package that
  # imports it using the local project collection.
  if [[ "$relative_dir" == "examples/08-packages/arithmetic" ]]; then
    continue
  fi

  extra_args=()
  if [[ "$relative_dir" == "examples/08-packages/app" ]]; then
    extra_args+=("-collection:project=$EXAMPLES_DIR/08-packages")
  fi

  has_tests=false
  if grep -Rqs --include='*.odin' '@(test)' "$package_dir"; then
    has_tests=true
  fi

  # A test-only package does not need a main entry point. `odin test` performs
  # both compilation and execution, so a separate `odin check` would reject it.
  if [[ "$has_tests" == false ]]; then
    echo "::group::odin check $relative_dir"
    if odin check "$package_dir" "${extra_args[@]}"; then
      checked=$((checked + 1))
    else
      failed=$((failed + 1))
    fi
    echo "::endgroup::"
  fi

  if [[ "$has_tests" == true ]]; then
    echo "::group::odin test $relative_dir"
    if odin test "$package_dir" "${extra_args[@]}"; then
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
