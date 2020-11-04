cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(application DESCRIPTION "Application" VERSION 0.1.0 LANGUAGES CXX)

# Version
set(PROJECT_VENDOR "Vendor")
configure_file(res/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/version.h LF)

# Sources
file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/${PROJECT_NAME}/*.[hc]pp)

# Objects
add_library(${PROJECT_NAME} OBJECT ${sources})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_20)

target_include_directories(${PROJECT_NAME} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/src>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include>)

if(WIN32)
  target_compile_definitions(${PROJECT_NAME} PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

# Dependencies
find_package(fmt CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC fmt::fmt)

find_package(Threads REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC Threads::Threads)

# Executable
add_executable(main src/main.cpp src/main.manifest src/main.rc)
set_target_properties(main PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
target_link_libraries(main PRIVATE ${PROJECT_NAME})

# Tests
find_package(doctest CONFIG REQUIRED)
add_executable(tests EXCLUDE_FROM_ALL src/test.cpp src/main.manifest)
target_link_libraries(tests PRIVATE ${PROJECT_NAME} doctest::doctest)

# Benchmarks
find_package(benchmark CONFIG REQUIRED)
add_executable(benchmarks EXCLUDE_FROM_ALL src/benchmark.cpp src/main.manifest)
target_link_libraries(benchmarks PRIVATE ${PROJECT_NAME} benchmark::benchmark)

# Install
if(NOT CMAKE_BUILD_TYPE MATCHES Debug)
  install(TARGETS main RUNTIME DESTINATION bin)

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
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc++1-10")
    set(CPACK_DEBIAN_PACKAGE_SECTION "misc")
  endif()
  include(CPack)
endif()
