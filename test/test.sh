#!/usr/bin/env sh

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly BASE_DIR

readonly OUTPUT_DIR='./output'
readonly SRC_DIR='./src'

readonly KRANE_OUTPUT_DIR="${OUTPUT_DIR}/chester"
readonly KRANE_SRC_DIR="${SRC_DIR}/chester"
readonly KTECH_SRC_FILENAME='minimap_atlas'
readonly KTECH_SRC_PNG="${SRC_DIR}/${KTECH_SRC_FILENAME}.png"
readonly KTECH_SRC_TEX="${SRC_DIR}/${KTECH_SRC_FILENAME}.tex"
readonly KTECH_TRANSPARENCY_FILENAME='transparency_test'
readonly KTECH_TRANSPARENCY_PNG="${SRC_DIR}/${KTECH_TRANSPARENCY_FILENAME}.png"

error() {
  err="$1"
  printf "Error: %s\n" "${err}" >&2
  exit 1
}

is_installed() {
  cmd="$1"
  if command -v "${cmd}" > /dev/null; then
    return 0
  fi
  return 1
}

print_title() {
  title="$1"
  printf '\n%s:\n\n' "${title}"
}

png_to_tex_compression() {
  src="$1"
  compression="$2"
  printf '\nPNG => TEX (%s):\n\n' "${compression}"
  ktech \
    --verbose \
    --compression "${compression}" \
    "${src}" \
    "${OUTPUT_DIR}/minimap_atlas_${compression}.tex"
}

png_to_tex_filter() {
  src="$1"
  filter="$2"
  printf '\nPNG => TEX (%s):\n\n' "${filter}"
  ktech \
    --verbose \
    --filter "${filter}" \
    --height 512 \
    --width 512 \
    "${src}" \
    "${OUTPUT_DIR}/minimap_atlas_${filter}.tex"
}

png_from_generated_tex() {
  to="$1"
  name="$2"
  ktech "${OUTPUT_DIR}/${name}.tex" "${to}/${name}.tex.png"
}

cd "${BASE_DIR}" || exit 1

if ! is_installed 'krane'; then
  error 'krane is not installed'
fi

if ! is_installed 'ktech'; then
  error 'ktech is not installed'
fi

# prepare
rm -Rf "${OUTPUT_DIR}"
mkdir "${OUTPUT_DIR}"

# ktech
printf 'Generating ktech output...'
{
  # TEX => PNG
  printf 'TEX info:\n\n'
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
  png_to_tex_compression "${KTECH_SRC_PNG}" 'dxt1'
  png_to_tex_compression "${KTECH_SRC_PNG}" 'dxt3'
  png_to_tex_compression "${KTECH_SRC_PNG}" 'dxt5'
  png_to_tex_compression "${KTECH_SRC_PNG}" 'rgb'
  png_to_tex_compression "${KTECH_SRC_PNG}" 'rgba'

  # filter
  png_to_tex_filter "${KTECH_SRC_PNG}" 'bicubic'
  png_to_tex_filter "${KTECH_SRC_PNG}" 'box'
  png_to_tex_filter "${KTECH_SRC_PNG}" 'catrom'
  png_to_tex_filter "${KTECH_SRC_PNG}" 'cubic'
  png_to_tex_filter "${KTECH_SRC_PNG}" 'lanczos'
  png_to_tex_filter "${KTECH_SRC_PNG}" 'mitchell'

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
} > "${OUTPUT_DIR}/log.txt" 2>&1
printf ' Done\n'

# krane
printf 'Generating krane output...'
{
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
} >> "${OUTPUT_DIR}/log.txt" 2>&1
printf ' Done\n'

# create PNGs from generated TEXs
printf 'Generating PNGs from generated TEXs...'
{
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_atlas"

  # compression
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_dxt1"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_dxt3"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_dxt5"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_rgb"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_rgba"

  # filter
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_bicubic"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_box"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_catrom"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_cubic"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_lanczos"
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_SRC_FILENAME}_mitchell"

  # transparency
  png_from_generated_tex "${OUTPUT_DIR}" "${KTECH_TRANSPARENCY_FILENAME}"
  png_from_generated_tex \
    "${OUTPUT_DIR}" \
    "${KTECH_TRANSPARENCY_FILENAME}_no-premultiply"
} > /dev/null 2>&1
printf ' Done\n'
