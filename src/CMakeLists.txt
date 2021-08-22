set(LOCAL_KTECH_SOURCES ktech/ktech.cpp ktech/ktech_options.cpp)

set(LOCAL_KTECH_HEADERS
    ktech/ktech.hpp
    ktech/ktech_common.hpp
    ktech/image_processing.hpp
    ktech/ktech_options.hpp
    common/compat.hpp
    common/compat/common.hpp
    common/compat/posix.hpp
    common/compat/fs.hpp
    common/metaprogramming.hpp
    common/ktools_common.hpp
    common/ktools_bit_op.hpp
    common/image_operations.hpp
    common/binary_io_utils.hpp
    common/ktex/ktex.hpp
    common/ktex/specs.hpp
    common/ktex/headerfield_specs.hpp
    common/file_abstraction.hpp
    common/ktools_options_customization.hpp)

set(LOCAL_KRANE_SOURCES
    krane/krane.cpp
    krane/krane_options.cpp
    krane/kbuild.cpp
    krane/kanim.cpp
    krane/kbuild_serialize.cpp
    krane/kanim_serialize.cpp
    krane/scml.cpp)

set(LOCAL_KRANE_HEADERS
    krane/krane.hpp
    krane/krane_common.hpp
    krane/krane_options.hpp
    krane/kbuild.hpp
    krane/kanim.hpp
    krane/scml.hpp
    krane/krane_options.hpp
    common/compat.hpp
    common/compat/common.hpp
    common/compat/posix.hpp
    common/compat/fs.hpp
    common/metaprogramming.hpp
    common/ktools_common.hpp
    common/ktools_bit_op.hpp
    common/image_operations.hpp
    common/binary_io_utils.hpp
    common/ktex/ktex.hpp
    common/ktex/specs.hpp
    common/ktex/headerfield_specs.hpp
    common/file_abstraction.hpp
    common/ktools_options_customization.hpp)

set(LOCAL_KTOOL_COMMON_SOURCES
    common/ktools_common.cpp common/file_abstraction.cpp common/ktex/ktex.cpp
    common/ktex/specs.cpp common/atlas.cpp
    common/ktools_options_customization.cpp)

set(LOCAL_KTOOL_COMMON_HEADERS
    common/metaprogramming.hpp
    common/ktools_common.hpp
    common/ktools_bit_op.hpp
    common/image_operations.hpp
    common/binary_io_utils.hpp
    common/file_abstraction.hpp
    common/ktex/ktex.hpp
    common/ktex/specs.hpp
    common/ktex/headerfield_specs.hpp
    common/atlas.hpp
    common/ktools_options_customization.hpp)

set(PREFIXED_KTECH_SOURCES)
set(PREFIXED_KTECH_HEADERS)

foreach(src ${LOCAL_KTECH_SOURCES})
  list(APPEND PREFIXED_KTECH_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/${src})
endforeach()
foreach(hdr ${LOCAL_KTECH_HEADERS})
  list(APPEND PREFIXED_KTECH_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/${hdr})
endforeach()

set(PREFIXED_KRANE_SOURCES)
set(PREFIXED_KRANE_HEADERS)

foreach(src ${LOCAL_KRANE_SOURCES})
  list(APPEND PREFIXED_KRANE_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/${src})
endforeach()
foreach(hdr ${LOCAL_KRANE_HEADERS})
  list(APPEND PREFIXED_KRANE_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/${hdr})
endforeach()

set(PREFIXED_KTOOL_COMMON_SOURCES)
set(PREFIXED_KTOOL_COMMON_HEADERS)

foreach(src ${LOCAL_KTOOL_COMMON_SOURCES})
  list(APPEND PREFIXED_KTOOL_COMMON_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/${src})
endforeach()
foreach(hdr ${LOCAL_KTOOL_COMMON_HEADERS})
  list(APPEND PREFIXED_KTOOL_COMMON_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/${hdr})
endforeach()

set(ktech_SOURCES
    "${PREFIXED_KTECH_SOURCES}"
    PARENT_SCOPE)
set(ktech_HEADERS
    "${PREFIXED_KTECH_HEADERS}"
    PARENT_SCOPE)

set(krane_SOURCES
    "${PREFIXED_KRANE_SOURCES}"
    PARENT_SCOPE)
set(krane_HEADERS
    "${PREFIXED_KRANE_HEADERS}"
    PARENT_SCOPE)

set(ktool_common_SOURCES
    "${PREFIXED_KTOOL_COMMON_SOURCES}"
    PARENT_SCOPE)
set(ktool_common_HEADERS
    "${PREFIXED_KTOOL_COMMON_HEADERS}"
    PARENT_SCOPE)
