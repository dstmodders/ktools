# Ensures that we do an out of source build
macro(ENSURE_OUT_OF_SOURCE_BUILD default_dir)
  string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" insource)
  get_filename_component(PARENTDIR ${CMAKE_SOURCE_DIR} PATH)
  string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${PARENTDIR}" insourcesubdir)
  if(insource OR insourcesubdir)
    set(CMAKE_BINARY_DIR "${default_dir}")
  endif(insource OR insourcesubdir)
endmacro()
