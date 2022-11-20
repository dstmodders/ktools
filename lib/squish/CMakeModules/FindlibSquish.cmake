# Defines LIBSQUISH_FOUND LIBSQUISH_INCLUDE_DIR LIBSQUISH_LIBRARIES

find_path(
  LIBSQUISH_INCLUDE_DIR squish.h
  PATHS . squish .. ../squish
  DOC "Directory containing libSquish headers")
find_library(
  LIBSQUISH_LIBRARY
  NAMES squish libsquish
  PATHS . squish .. ../squish
  PATH_SUFFIXES lib lib64 release minsizerel relwithdebinfo
  DOC "Path to libSquish library")

set(LIBSQUISH_LIBRARIES ${LIBSQUISH_LIBRARY})

if(LIBSQUISH_LIBRARY AND LIBSQUISH_INCLUDE_DIR)
  set(LIBSQUISH_FOUND TRUE)
  message(STATUS "Found libSquish: ${LIBSQUISH_LIBRARY}")
endif(LIBSQUISH_LIBRARY AND LIBSQUISH_INCLUDE_DIR)
