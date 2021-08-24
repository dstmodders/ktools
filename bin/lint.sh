#!/usr/bin/env sh

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "${BASE_DIR}/.." || exit 1

cmake-lint \
  ./**/CMakeLists.txt \
  ./cmake/*.cmake \
  ./cmake_uninstall.cmake.in

find ./src/ \( -iname '*.cpp' -o -iname '*.hpp' \) -exec \
  clang-format -i {} \;
