cmake_minimum_required(VERSION 3.16 FATAL_ERROR)
project(application DESCRIPTION "Application" VERSION 0.1.0 LANGUAGES CXX)

# Options
option(DISABLE_BENCHMARK "Disable benchmark" OFF)
option(DISABLE_TESTS "Disable tests" OFF)

# Version
set(PROJECT_VENDOR "Company")
configure_file(res/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/version.h LF)

# Modules
list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/res/cmake)

# Sources
file(GLOB_RECURSE sources src/${PROJECT_NAME}/*.[hc]pp)

# Objects
add_library(objects OBJECT ${sources})
target_precompile_headers(objects PRIVATE <${PROJECT_NAME}/common.hpp>)
target_compile_definitions(objects PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)
target_compile_features(objects PUBLIC cxx_std_20)

target_include_directories(objects PUBLIC
  ${CMAKE_CURRENT_BINARY_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/src)

# Dependencies
find_package(date CONFIG REQUIRED)
target_link_libraries(objects PUBLIC date::date date::date-tz)

find_package(fmt CONFIG REQUIRED)
target_link_libraries(objects PUBLIC fmt::fmt)

find_package(Threads REQUIRED)
target_link_libraries(objects PUBLIC Threads::Threads)

include(tzdata)
tzdata(objects 2020a ${CMAKE_CURRENT_BINARY_DIR}/tzdata)

# Executable
add_executable(${PROJECT_NAME} src/main.cpp src/main.manifest src/main.rc)
target_precompile_headers(${PROJECT_NAME} REUSE_FROM objects)
target_link_libraries(${PROJECT_NAME} PRIVATE objects)

# Benchmark
if(NOT DISABLE_BENCHMARK)
  file(GLOB_RECURSE benchmark_sources src/benchmark/*.[hc]pp)
  add_executable(benchmark EXCLUDE_FROM_ALL ${benchmark_sources})
  target_precompile_headers(benchmark REUSE_FROM objects)
  target_link_libraries(benchmark PRIVATE objects)

  find_package(benchmark CONFIG REQUIRED)
  target_link_libraries(benchmark PRIVATE benchmark::benchmark_main)
endif()

# Tests
if(NOT DISABLE_TESTS)
  file(GLOB_RECURSE tests_sources src/tests/*.[hc]pp)
  add_executable(tests EXCLUDE_FROM_ALL ${tests_sources})
  target_precompile_headers(tests REUSE_FROM objects)
  target_link_libraries(tests PRIVATE objects)

  find_package(Catch2 CONFIG REQUIRED)
  target_link_libraries(tests PRIVATE Catch2::Catch2)

  include(CTest)
  include(Catch)
  catch_discover_tests(tests)
endif()

# Install
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)

if(WIN32)
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tzdata DESTINATION share)
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    install(FILES
      $<TARGET_FILE_DIR:${PROJECT_NAME}>/fmt.dll
      $<TARGET_FILE_DIR:${PROJECT_NAME}>/tz.dll
      DESTINATION bin)
  endif()
endif()

# Package
if(NOT CMAKE_BUILD_TYPE MATCHES Debug)
  string(UUID PROJECT_GUID TYPE SHA1
    NAMESPACE 6BA7B814-9DAD-11D1-80B4-00C04FD430C8
    NAME "CN=${PROJECT_NAME}, O=${PROJECT_VENDOR}")

  set(CPACK_PACKAGE_VENDOR "${PROJECT_VENDOR}")
  set(CPACK_PACKAGE_DESCRIPTION "${PROJECT_DESCRIPTION}")
  set(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME}" "${PROJECT_DESCRIPTION}")
  set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}")
  set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}")
  if(WIN32)
    set(CPACK_GENERATOR "WIX")
    set(CPACK_WIX_UPGRADE_GUID "${PROJECT_GUID}")
    set(CPACK_PACKAGE_NAME "${PROJECT_DESCRIPTION}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_DESCRIPTION}")
    set(CPACK_WIX_PRODUCT_ICON "${CMAKE_CURRENT_SOURCE_DIR}/src/main.ico")
    set(CPACK_WIX_LICENSE_RTF "${CMAKE_CURRENT_SOURCE_DIR}/res/license.rtf")
    set(CPACK_WIX_UI_BANNER "${CMAKE_CURRENT_SOURCE_DIR}/res/bitmap/banner.bmp")
    set(CPACK_WIX_UI_DIALOG "${CMAKE_CURRENT_SOURCE_DIR}/res/bitmap/dialog.bmp")
    set(CPACK_WIX_PROGRAM_MENU_FOLDER ".")
  else()
    set(CPACK_GENERATOR "DEB")
    set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/${PROJECT_NAME}")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/res/license.txt")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_VENDOR}")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc++1-10, tzdata")
    set(CPACK_DEBIAN_PACKAGE_SECTION "misc")
  endif()
  include(CPack)
endif()
