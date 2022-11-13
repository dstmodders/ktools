# cmake build file for squish by Stefan Roettger (stefan@stereofx.org) updated
# by Simon Brown (si@sjbrown.co.uk)

# features: Xcode: builds universal binaries, uses SSE2 on i386 and Altivec on
# ppc Unix and VS: SSE2 support is enabled by default use BUILD_SQUISH_WITH_SSE2
# and BUILD_SQUISH_WITH_ALTIVEC to override

project(squish)

cmake_minimum_required(VERSION 2.8.12)

if(CMAKE_GENERATOR STREQUAL "Xcode")
  set(CMAKE_OSX_ARCHITECTURES "i386;ppc")
else(CMAKE_GENERATOR STREQUAL "Xcode")
  if(BUILD_SQUISH_WITH_SSE2 AND NOT WIN32)
    add_definitions(-DSQUISH_USE_SSE=2 -msse2)
  endif(BUILD_SQUISH_WITH_SSE2 AND NOT WIN32)
  if(BUILD_SQUISH_WITH_ALTIVEC AND NOT WIN32)
    add_definitions(-DSQUISH_USE_ALTIVEC=1 -maltivec)
  endif(BUILD_SQUISH_WITH_ALTIVEC AND NOT WIN32)
endif(CMAKE_GENERATOR STREQUAL "Xcode")

set(SQUISH_HDRS squish.h)

set(SQUISH_SRCS
    alpha.cpp
    alpha.h
    clusterfit.cpp
    clusterfit.h
    colourblock.cpp
    colourblock.h
    colourfit.cpp
    colourfit.h
    colourset.cpp
    colourset.h
    maths.cpp
    maths.h
    rangefit.cpp
    rangefit.h
    simd.h
    simd_float.h
    simd_sse.h
    simd_ve.h
    singlecolourfit.cpp
    singlecolourfit.h
    singlecolourlookup.inl
    squish.cpp)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(squish ${SQUISH_SRCS} ${SQUISH_HDRS})

set_target_properties(
  squish
  PROPERTIES PUBLIC_HEADER "${SQUISH_HDRS}"
             VERSION 0.0
             SOVERSION 0.0
             DEBUG_POSTFIX "d"
             XCODE_ATTRIBUTE_GCC_PREPROCESSOR_DEFINITIONS
             "$(SQUISH_CPP_$(CURRENT_ARCH))"
             XCODE_ATTRIBUTE_OTHER_CFLAGS "$(SQUISH_CFLAGS_$(CURRENT_ARCH))"
             XCODE_ATTRIBUTE_SQUISH_CPP_i386 "SQUISH_USE_SSE=2"
             XCODE_ATTRIBUTE_SQUISH_CFLAGS_i386 ""
             XCODE_ATTRIBUTE_SQUISH_CPP_ppc "SQUISH_USE_ALTIVEC=1"
             XCODE_ATTRIBUTE_SQUISH_CFLAGS_ppc "-maltivec")

if(BUILD_SQUISH_EXTRA)
  set(SQUISHTEST_SRCS extra/squishtest.cpp)

  add_executable(squishtest ${SQUISHTEST_SRCS})
  set_target_properties(squishtest PROPERTIES DEBUG_POSTFIX "d")
  target_link_libraries(squishtest squish)

  set(SQUISHPNG_SRCS extra/squishpng.cpp)

  find_package(PNG)

  if(PNG_FOUND)
    set(CMAKE_PLATFORM_IMPLICIT_INCLUDE_DIRECTORIES)
    include_directories(${PNG_INCLUDE_DIR})
    add_executable(squishpng ${SQUISHPNG_SRCS})
    set_target_properties(squishpng PROPERTIES DEBUG_POSTFIX "d")
    target_link_libraries(squishpng squish ${PNG_LIBRARIES})
  endif(PNG_FOUND)
endif(BUILD_SQUISH_EXTRA)
