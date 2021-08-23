#!/usr/bin/env sh

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR='./output'
SRC_DIR='./src'

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
  ktech "${OUTPUT_DIR}/${name}.tex" "${to}/${name}.png"
}

cd "${BASE_DIR}" || exit 1

# prepare
rm -Rf "${OUTPUT_DIR}"
mkdir "${OUTPUT_DIR}"

# ktech
src_png="${SRC_DIR}/minimap_atlas.png"
src_tex="${SRC_DIR}/minimap_atlas.tex"
printf 'Generating ktech output...'
{
  # TEX => PNG
  printf 'TEX info:\n\n'
  ktech --verbose --info ./src/minimap_atlas.tex

  print_title 'TEX => PNG (default)'
  ktech --verbose ./src/minimap_atlas.tex "${OUTPUT_DIR}"

  print_title 'TEX => PNG (quality)'
  ktech \
    --verbose \
    --quality 10 \
    "${src_tex}" \
    "${OUTPUT_DIR}/minimap_atlas_quality-10.png"

  print_title 'TEX => PNG (resize)'
  ktech \
    --verbose \
    --height 512 \
    --width 512 \
    "${src_tex}" \
    "${OUTPUT_DIR}/minimap_atlas_512x512.png"

  print_title 'TEX => PNG (extend)'
  ktech \
    --verbose \
    --height 512 \
    --width 512 \
    --extend \
    "${src_tex}" \
    "${OUTPUT_DIR}/minimap_atlas_512x512_extend.png"

  # PNG => TEX
  print_title 'PNG => TEX (default)'
  ktech --verbose "${src_png}" "${OUTPUT_DIR}"

  print_title 'PNG => TEX (atlas)'
  ktech \
    --verbose \
    --atlas "${OUTPUT_DIR}/minimap_atlas_atlas.xml" \
    "${src_png}" \
    "${OUTPUT_DIR}/minimap_atlas_atlas.tex"

  # compression
  png_to_tex_compression "${src_png}" 'dxt1'
  png_to_tex_compression "${src_png}" 'dxt3'
  png_to_tex_compression "${src_png}" 'dxt5'
  png_to_tex_compression "${src_png}" 'rgb'
  png_to_tex_compression "${src_png}" 'rgba'

  # filter
  png_to_tex_filter "${src_png}" 'bicubic'
  png_to_tex_filter "${src_png}" 'box'
  png_to_tex_filter "${src_png}" 'catrom'
  png_to_tex_filter "${src_png}" 'cubic'
  png_to_tex_filter "${src_png}" 'lanczos'
  png_to_tex_filter "${src_png}" 'mitchell'
} > "${OUTPUT_DIR}/log.txt" 2>&1
printf ' Done\n'

# krane
src_anim_dir="${SRC_DIR}/chester"
output_anim_dir="${OUTPUT_DIR}/chester"
printf 'Generating krane output...'
{
  print_title 'krane (default)'
  krane --verbose "${src_anim_dir}" "${output_anim_dir}"

  print_title 'krane (mark-atlases)'
  krane \
    --verbose \
    --mark-atlases \
    "${src_anim_dir}" \
    "${output_anim_dir}_mark-atlases"

  print_title 'krane (bank)'
  krane \
    --verbose \
    --bank chester \
    "${src_anim_dir}" \
    "${output_anim_dir}_bank"

  print_title 'krane (rename)'
  krane \
    --verbose \
    --rename-bank chester_renamed \
    --rename-build chester_build_renamed \
    "${src_anim_dir}" \
    "${output_anim_dir}_rename"
} >> "${OUTPUT_DIR}/log.txt" 2>&1
printf ' Done\n'

# create PNGs from generated TEXs
to="${OUTPUT_DIR}/png_from_generated_tex"
mkdir "${to}"
printf 'Generating PNGs from generated TEXs...'
{
  png_from_generated_tex "${to}" 'minimap_atlas'
  png_from_generated_tex "${to}" 'minimap_atlas_atlas'

  # compression
  png_from_generated_tex "${to}" 'minimap_atlas_dxt1'
  png_from_generated_tex "${to}" 'minimap_atlas_dxt3'
  png_from_generated_tex "${to}" 'minimap_atlas_dxt5'
  png_from_generated_tex "${to}" 'minimap_atlas_rgb'
  png_from_generated_tex "${to}" 'minimap_atlas_rgba'

  # filter
  png_from_generated_tex "${to}" 'minimap_atlas_bicubic'
  png_from_generated_tex "${to}" 'minimap_atlas_box'
  png_from_generated_tex "${to}" 'minimap_atlas_catrom'
  png_from_generated_tex "${to}" 'minimap_atlas_cubic'
  png_from_generated_tex "${to}" 'minimap_atlas_lanczos'
  png_from_generated_tex "${to}" 'minimap_atlas_mitchell'
} > /dev/null 2>&1
printf ' Done\n'
