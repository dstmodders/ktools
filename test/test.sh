#!/usr/bin/env bash
#
# Run ktools integration tests.
#
# Usage:
#   test.sh [flags]
#
# Examples:
#   PATH="$PWD/releases/linux-amd64:$PATH" test.sh
#   KTOOLS_TEST_EXPECTED=$PWD/test/expected test.sh
#   test.sh -e "$PWD/test/expected"
#   test.sh --expected "$PWD/test/expected"
#
# Flags:
#   -e, --expected <dir>   Compare outputs to an expected tree (optional)
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

# define constants
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd "${BASE_DIR}/.." && pwd -P)"
OUTPUT_DIR='./output'
SRC_DIR='./src'
LOG_FILE="${OUTPUT_DIR}/log.txt"

KRANE_OUTPUT_DIR="${OUTPUT_DIR}/chester"
KRANE_SRC_DIR="${SRC_DIR}/chester"
KTECH_SRC_FILENAME='minimap_atlas'
KTECH_SRC_PNG="${SRC_DIR}/${KTECH_SRC_FILENAME}.png"
KTECH_SRC_TEX="${SRC_DIR}/${KTECH_SRC_FILENAME}.tex"
KTECH_TRANSPARENCY_FILENAME='transparency_test'
KTECH_TRANSPARENCY_PNG="${SRC_DIR}/${KTECH_TRANSPARENCY_FILENAME}.png"

readonly BASE_DIR ROOT_DIR OUTPUT_DIR SRC_DIR LOG_FILE
readonly KRANE_OUTPUT_DIR KRANE_SRC_DIR KTECH_SRC_FILENAME
readonly KTECH_SRC_PNG KTECH_SRC_TEX KTECH_TRANSPARENCY_FILENAME
readonly KTECH_TRANSPARENCY_PNG

# shellcheck disable=SC1091
source "${ROOT_DIR}/bin/common.sh"

# define defaults for environment variables
EXPECTED_DIR="${KTOOLS_TEST_EXPECTED:-}"
NO_COLOR="${NO_COLOR:-0}"

print_title() {
  print_separator
  print_step "$1"
  printf '\n'
  print_separator
}

convert_png_to_tex_with_compression() {
  local src="$1"
  local compression="$2"

  print_title "PNG => TEX (${compression})"
  ktech \
    --verbose \
    --compression "${compression}" \
    "${src}" \
    "${OUTPUT_DIR}/minimap_atlas_${compression}.tex"
}

convert_png_to_tex_with_filter() {
  local src="$1"
  local filter="$2"

  print_title "PNG => TEX (${filter})"
  ktech \
    --verbose \
    --filter "${filter}" \
    --height 512 \
    --width 512 \
    "${src}" \
    "${OUTPUT_DIR}/minimap_atlas_${filter}.tex"
}

convert_generated_tex_to_png() {
  local to="$1"
  local name="$2"

  ktech "${OUTPUT_DIR}/${name}.tex" "${to}/${name}.tex.png"
}

run_ktech_tests() {
  # TEX => PNG
  print_title 'TEX info'
  ktech --verbose --info "${KTECH_SRC_TEX}"

  print_title 'TEX => PNG (default)'
  ktech --verbose "${KTECH_SRC_TEX}" "${OUTPUT_DIR}"

  print_title 'TEX => PNG (quality)'
  ktech \
    --verbose \
    --quality 10 \
    "${KTECH_SRC_TEX}" \
    "${OUTPUT_DIR}/${KTECH_SRC_FILENAME}_quality-10.png"

  print_title 'TEX => PNG (resize)'
  ktech \
    --verbose \
    --height 512 \
    --width 512 \
    "${KTECH_SRC_TEX}" \
    "${OUTPUT_DIR}/${KTECH_SRC_FILENAME}_512x512.png"

  print_title 'TEX => PNG (extend)'
  ktech \
    --verbose \
    --height 512 \
    --width 512 \
    --extend \
    "${KTECH_SRC_TEX}" \
    "${OUTPUT_DIR}/${KTECH_SRC_FILENAME}_512x512_extend.png"

  # PNG => TEX
  print_title 'PNG => TEX (default)'
  ktech --verbose "${KTECH_SRC_PNG}" "${OUTPUT_DIR}"

  print_title 'PNG => TEX (atlas)'
  ktech \
    --verbose \
    --atlas "${OUTPUT_DIR}/${KTECH_SRC_FILENAME}_atlas.xml" \
    "${KTECH_SRC_PNG}" \
    "${OUTPUT_DIR}/${KTECH_SRC_FILENAME}_atlas.tex"

  # compression
  convert_png_to_tex_with_compression "${KTECH_SRC_PNG}" 'dxt1'
  convert_png_to_tex_with_compression "${KTECH_SRC_PNG}" 'dxt3'
  convert_png_to_tex_with_compression "${KTECH_SRC_PNG}" 'dxt5'
  convert_png_to_tex_with_compression "${KTECH_SRC_PNG}" 'rgb'
  convert_png_to_tex_with_compression "${KTECH_SRC_PNG}" 'rgba'

  # filter
  convert_png_to_tex_with_filter "${KTECH_SRC_PNG}" 'bicubic'
  convert_png_to_tex_with_filter "${KTECH_SRC_PNG}" 'box'
  convert_png_to_tex_with_filter "${KTECH_SRC_PNG}" 'catrom'
  convert_png_to_tex_with_filter "${KTECH_SRC_PNG}" 'cubic'
  convert_png_to_tex_with_filter "${KTECH_SRC_PNG}" 'lanczos'
  convert_png_to_tex_with_filter "${KTECH_SRC_PNG}" 'mitchell'

  # transparency test
  print_title 'PNG => TEX (transparency test)'
  ktech \
    --verbose \
    "${KTECH_TRANSPARENCY_PNG}" \
    "${OUTPUT_DIR}/${KTECH_TRANSPARENCY_FILENAME}.tex"

  print_title 'PNG => TEX (transparency test with no-premultiply)'
  ktech \
    --verbose \
    --no-premultiply \
    "${KTECH_TRANSPARENCY_PNG}" \
    "${OUTPUT_DIR}/${KTECH_TRANSPARENCY_FILENAME}_no-premultiply.tex"
}

run_krane_tests() {
  print_title 'krane (default)'
  krane --verbose "${KRANE_SRC_DIR}" "${KRANE_OUTPUT_DIR}"

  print_title 'krane (mark-atlases)'
  krane \
    --verbose \
    --mark-atlases \
    "${KRANE_SRC_DIR}" \
    "${KRANE_OUTPUT_DIR}_mark-atlases"

  print_title 'krane (bank)'
  krane \
    --verbose \
    --bank chester \
    "${KRANE_SRC_DIR}" \
    "${KRANE_OUTPUT_DIR}_bank"

  print_title 'krane (rename)'
  krane \
    --verbose \
    --rename-bank chester_renamed \
    --rename-build chester_build_renamed \
    "${KRANE_SRC_DIR}" \
    "${KRANE_OUTPUT_DIR}_rename"
}

run_generated_tex_tests() {
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_atlas"

  # compression
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_dxt1"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_dxt3"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_dxt5"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_rgb"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_rgba"

  # filter
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_bicubic"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_box"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_catrom"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_cubic"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_lanczos"
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_mitchell"

  # transparency
  convert_generated_tex_to_png "${OUTPUT_DIR}" "${KTECH_TRANSPARENCY_FILENAME}"
  convert_generated_tex_to_png \
    "${OUTPUT_DIR}" \
    "${KTECH_TRANSPARENCY_FILENAME}_no-premultiply"
}

require_nonempty() {
  local path="$1"
  if [ ! -s "${path}" ]; then
    printf 'missing or empty output: %s\n' "${path}" >&2
    return 1
  fi
}

require_png() {
  local path="$1"
  require_nonempty "${path}" || return 1
  if ! head -c 8 "${path}" | cmp -s - <(printf '\x89PNG\r\n\x1a\n'); then
    printf 'not a PNG: %s\n' "${path}" >&2
    return 1
  fi
}

require_tex() {
  local path="$1"
  require_nonempty "${path}" || return 1
  if ! ktech --info "${path}" > /dev/null 2>&1; then
    printf 'ktech could not read TEX: %s\n' "${path}" >&2
    return 1
  fi
}

require_matches_expected() {
  local relative="$1"
  local actual="${OUTPUT_DIR}/${relative}"
  local expected="${EXPECTED_DIR}/${relative}"

  [ -n "${EXPECTED_DIR}" ] || return 0
  require_nonempty "${actual}" || return 1
  if [ ! -s "${expected}" ]; then
    printf 'missing expected file: %s\n' "${expected}" >&2
    return 1
  fi
  if ! cmp -s "${actual}" "${expected}"; then
    printf 'output differs from expected (%s)\n' "${relative}" >&2
    return 1
  fi
}

verify_ktech_outputs() {
  local compression filter relative

  for relative in \
    "${KTECH_SRC_FILENAME}.png" \
    "${KTECH_SRC_FILENAME}_quality-10.png" \
    "${KTECH_SRC_FILENAME}_512x512.png" \
    "${KTECH_SRC_FILENAME}_512x512_extend.png"; do
    require_png "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done

  for relative in \
    "${KTECH_SRC_FILENAME}.tex" \
    "${KTECH_SRC_FILENAME}_atlas.tex"; do
    require_tex "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done

  relative="${KTECH_SRC_FILENAME}_atlas.xml"
  require_nonempty "${OUTPUT_DIR}/${relative}" || return 1
  require_matches_expected "${relative}" || return 1

  for compression in dxt1 dxt3 dxt5 rgb rgba; do
    relative="${KTECH_SRC_FILENAME}_${compression}.tex"
    require_tex "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done
  for filter in bicubic box catrom cubic lanczos mitchell; do
    relative="${KTECH_SRC_FILENAME}_${filter}.tex"
    require_tex "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done

  for relative in \
    "${KTECH_TRANSPARENCY_FILENAME}.tex" \
    "${KTECH_TRANSPARENCY_FILENAME}_no-premultiply.tex"; do
    require_tex "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done
}

verify_krane_outputs() {
  local relative

  for relative in \
    'chester/chester_build.scml' \
    'chester_bank/chester_build.scml' \
    'chester_rename/chester_build_renamed.scml'; do
    require_nonempty "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done

  for relative in \
    'chester/chester_body/chester_body-0.png' \
    'chester_mark-atlases/atlas-0.png' \
    'chester_bank/chester_body/chester_body-0.png' \
    'chester_rename/chester_body/chester_body-0.png'; do
    require_png "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done
}

verify_tex_outputs() {
  local name compression filter relative

  for name in \
    "${KTECH_SRC_FILENAME}" \
    "${KTECH_SRC_FILENAME}_atlas" \
    "${KTECH_TRANSPARENCY_FILENAME}" \
    "${KTECH_TRANSPARENCY_FILENAME}_no-premultiply"; do
    relative="${name}.tex.png"
    require_png "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done
  for compression in dxt1 dxt3 dxt5 rgb rgba; do
    relative="${KTECH_SRC_FILENAME}_${compression}.tex.png"
    require_png "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done
  for filter in bicubic box catrom cubic lanczos mitchell; do
    relative="${KTECH_SRC_FILENAME}_${filter}.tex.png"
    require_png "${OUTPUT_DIR}/${relative}" || return 1
    require_matches_expected "${relative}" || return 1
  done
}

run_verify_step() {
  local label="$1"
  local verifier="$2"
  local err=''
  local status=0

  print_step_dotted "${label}"
  case "${verifier}" in
    verify_ktech_outputs)
      err="$(verify_ktech_outputs 2>&1)" || status=$?
      ;;
    verify_krane_outputs)
      err="$(verify_krane_outputs 2>&1)" || status=$?
      ;;
    verify_tex_outputs)
      err="$(verify_tex_outputs 2>&1)" || status=$?
      ;;
    *)
      die "unknown verifier: ${verifier}"
      ;;
  esac

  if [ "${status}" -eq 0 ]; then
    print_step_success
  else
    print_step_failed
    print_separator
    die "${err:-${label} failed}"
  fi
}

run_test_stage() {
  local label="$1"
  local stage="$2"
  local log_mode="$3"

  print_step_dotted "${label}"
  if [ "${log_mode}" = 'append' ]; then
    if KTOOLS_TEST_STAGE="${stage}" bash "${BASE_DIR}/test.sh" \
      --internal-stage "${stage}" >> "${LOG_FILE}" 2>&1; then
      print_step_success
    else
      print_step_failed
      print_separator
      die "${label} failed; see ${BASE_DIR}/${LOG_FILE#./}"
    fi
  elif KTOOLS_TEST_STAGE="${stage}" bash "${BASE_DIR}/test.sh" \
    --internal-stage "${stage}" > "${LOG_FILE}" 2>&1; then
    print_step_success
  else
    print_step_failed
    print_separator
    die "${label} failed; see ${BASE_DIR}/${LOG_FILE#./}"
  fi
}

if [ "${1:-}" = '--internal-stage' ]; then
  [ "$#" -eq 2 ] || die 'invalid internal test stage'
  cd "${BASE_DIR}"
  case "$2" in
    ktech) run_ktech_tests ;;
    krane) run_krane_tests ;;
    tex) run_generated_tex_tests ;;
    *) die 'unknown internal test stage' ;;
  esac
  exit 0
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    -e | --expected)
      [ "$#" -ge 2 ] || die '-e/--expected requires a directory'
      EXPECTED_DIR="$2"
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

cd "${BASE_DIR}"

if [ -n "${EXPECTED_DIR}" ]; then
  _expected_arg="${EXPECTED_DIR}"
  EXPECTED_DIR="$(cd "${_expected_arg}" 2> /dev/null && pwd -P)" \
    || die "expected directory not found: ${_expected_arg}"
  unset _expected_arg
fi

print_step_dotted 'Checking dependencies'
if ! is_installed 'krane'; then
  print_step_failed
  die 'krane is not installed'
fi
if ! is_installed 'ktech'; then
  print_step_failed
  die 'ktech is not installed'
fi
print_step_success

print_step_dotted 'Preparing output directory'
if rm -rf -- "${OUTPUT_DIR}" && mkdir -p -- "${OUTPUT_DIR}"; then
  print_step_success
else
  print_step_failed
  die 'could not prepare output directory'
fi

run_test_stage 'Generating ktech output' 'ktech' 'replace'
run_verify_step 'Verifying ktech output' verify_ktech_outputs
run_test_stage 'Generating krane output' 'krane' 'append'
run_verify_step 'Verifying krane output' verify_krane_outputs
run_test_stage 'Generating PNGs from generated TEXs' 'tex' 'append'
run_verify_step 'Verifying generated TEX PNGs' verify_tex_outputs

complete 2 'Tests completed'
