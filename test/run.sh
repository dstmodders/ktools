#!/usr/bin/env bash
#
# Run ktools test suites.
#
# Usage:
#   run.sh [flags]
#
# Examples:
#   run.sh
#   PATH="$PWD/releases/linux-amd64:$PATH" run.sh
#
# Flags:
#   -e, --expected <dir>   Forwarded to test.sh for optional output cmp
#   -h, --help             Show this help message
#
# Environment Variables:
#   KTOOLS_TEST_EXPECTED   Directory mirroring test/output for optional cmp
#                          (default unset; skipped when empty)
#
#   NO_COLOR               Set to 1 to disable terminal colors
#                          (see no-color.org, default "0")
#
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd "${BASE_DIR}/.." && pwd -P)"

readonly BASE_DIR ROOT_DIR

# shellcheck disable=SC1091
source "${ROOT_DIR}/bin/common.sh"

NO_COLOR="${NO_COLOR:-0}"

TEST_ARGS=()

run_tools_suite() {
  require_cmds ktech krane
  print_step 'Running ktech/krane tests' 'test.sh'
  printf '\n'
  print_separator
  if [ "${#TEST_ARGS[@]}" -gt 0 ]; then
    bash "${BASE_DIR}/test.sh" "${TEST_ARGS[@]}"
  else
    bash "${BASE_DIR}/test.sh"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -e | --expected)
      [ "$#" -ge 2 ] || die '-e/--expected requires a directory'
      TEST_ARGS+=(--expected "$2")
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      die 'unrecognized flag'
      ;;
    *)
      die "unrecognized argument '$1'"
      ;;
  esac
  shift
done

trap interrupt SIGINT

run_tools_suite
