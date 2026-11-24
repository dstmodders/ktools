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
#   -h, --help   Show this help message
#
# Environment Variables:
#   NO_COLOR     Set to 1 to disable terminal colors
#                (see no-color.org, default "0")
#
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd "${BASE_DIR}/.." && pwd -P)"

readonly BASE_DIR ROOT_DIR

# shellcheck disable=SC1091
source "${ROOT_DIR}/bin/common.sh"

NO_COLOR="${NO_COLOR:-0}"

run_tools_suite() {
  require_cmds ktech krane
  print_step 'Running ktech/krane tests' 'test.sh'
  printf '\n'
  print_separator
  bash "${BASE_DIR}/test.sh"
}

if [ "$#" -gt 0 ]; then
  case "$1" in
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
fi

trap interrupt SIGINT

run_tools_suite
