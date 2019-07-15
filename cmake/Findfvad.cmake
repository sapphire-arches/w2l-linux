message(STATUS "Looking for FVAD")

find_library(FVAD_LIB
  fvad
  ENV FVAD_ROOT_DIR
  PATHS
    $ENV{FVAD_ROOT_DIR}
  HINT
    ${FVAD_DIR}
    ${FVAD_LIB_DIR}
    $ENV{KENLM_ROOT_DIR}/lib
)

find_file(FVAD_HEADER
  fvad.h
  ENV FVAD_INC
  HINT
    ${FVAD_DIR}
    ${FVAD_DIR}/fvad
    $ENV{FVAD_INC}
    ${FVAD_LIB}
  )

if (FVAD_HEADER)
  message(STATUS "fvad header found in ${FVAD_HEADER}")
else()
  message(FATAL_ERROR "fvad header not found; please set CMAKE_INCLUDE_PATH or FVAD_INC")
endif()

get_filename_component(FVAD_INCLUDE_DIR ${FVAD_HEADER} DIRECTORY)
set(FVAD_LIBRARIES ${FVAD_LIB})
set(FVAD_INCLUDE_DIRS ${FVAD_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(fvad DEFAULT_MSG FVAD_INCLUDE_DIRS FVAD_LIBRARIES)

if (fvad_FOUND)
  message(STATUS "Found fvad (include: ${FVAD_INCLUDE_DIRS}, libraries: ${FVAD_LIBRARIES})")
  mark_as_advanced(FVAD_ROOT_DIR FVAD_INCLUDE_DIRS FVAD_LIBRARIES)
endif()
