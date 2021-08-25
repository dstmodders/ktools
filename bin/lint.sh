#!/usr/bin/env sh

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "${BASE_DIR}/.." || exit 1

# cmake-lint
find . -iname 'CMakeLists.txt' -exec cmake-lint --suppress-decorations {} \;
cmake-lint --suppress-decorations \
  ./cmake/*.cmake \
  ./cmake_uninstall.cmake.in

# clang-format
find ./src/ \( -iname '*.cpp' -o -iname '*.hpp' \) -exec \
  clang-format --dry-run --Werror {} \;
clang-format --dry-run --Werror ./config.h.in
