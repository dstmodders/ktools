# Locate libzip This module defines LIBZIP_LIBRARY LIBZIP_FOUND, if false, do
# not try to link to libzip LIBZIP_INCLUDE_DIR, where to find the headers
#

find_path(
  LIBZIP_INCLUDE_DIR
  zip.h
  $ENV{LIBZIP_DIR}/include
  $ENV{LIBZIP_DIR}
  $ENV{OSGDIR}/include
  $ENV{OSGDIR}
  $ENV{OSG_ROOT}/include
  ~/Library/Frameworks
  /Library/Frameworks
  /usr/local/include
  /usr/include
  /sw/include # Fink
  /opt/local/include # DarwinPorts
  /opt/csw/include # Blastwave
  /opt/include
  [HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session\ Manager\\Environment;OSG_ROOT]/include
  /usr/freeware/include)

find_library(
  LIBZIP_LIBRARY
  NAMES libzip zip
  PATHS
    $ENV{LIBZIP_DIR}/lib
    $ENV{LIBZIP_DIR}
    $ENV{OSGDIR}/lib
    $ENV{OSGDIR}
    $ENV{OSG_ROOT}/lib
    ~/Library/Frameworks
    /Library/Frameworks
    /usr/local/lib
    /usr/lib
    /sw/lib
    /opt/local/lib
    /opt/csw/lib
    /opt/lib
    [HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session\ Manager\\Environment;OSG_ROOT]/lib
    /usr/freeware/lib64)

set(LIBZIP_FOUND "NO")
if(LIBZIP_LIBRARY AND LIBZIP_INCLUDE_DIR)
  set(LIBZIP_FOUND "YES")
endif(LIBZIP_LIBRARY AND LIBZIP_INCLUDE_DIR)
