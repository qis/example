# Time Zone Database
# http://www.iana.org/time-zones
#
# Usage:
#
#   list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_BINARY_DIR}/download/cmake)
#
#   find_package(date CONFIG REQUIRED)
#   target_link_libraries(main PRIVATE date::date date::tz)
#
#   include(tzdata)
#   tzdata(main 2020a ${CMAKE_CURRENT_SOURCE_DIR}/tzdata)
#
#   if(WIN32)
#     install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tzdata DESTINATION share)
#   endif()
#

include_guard(GLOBAL)

set(tzdata_sources ${CMAKE_CURRENT_LIST_DIR}/tzdata.cpp)

function(tzdata target version destination)
  if(NOT WIN32)
    return()
  endif()

  if(NOT EXISTS ${destination}/windowsZones.xml)
    if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/windowsZones.xml)
      message(STATUS "Downloading windowsZones.xml ...")
      file(DOWNLOAD "https://raw.githubusercontent.com/unicode-org/cldr/master/common/supplemental/windowsZones.xml"
        ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/windowsZones.xml)
    endif()
    file(COPY ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/windowsZones.xml DESTINATION ${destination})
  endif()

  set(tzdata_names
    africa
    antarctica
    asia
    australasia
    backward
    etcetera
    europe
    pacificnew
    northamerica
    southamerica
    systemv
    leapseconds
    version)

  foreach(name ${tzdata_names})
    if(NOT EXISTS ${destination}/${name})
      if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/${name})
        if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata${version}.tar.gz)
          message(STATUS "Downloading tzdata${version}.tar.gz ...")
          file(DOWNLOAD "https://data.iana.org/time-zones/releases/tzdata${version}.tar.gz"
            ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata${version}.tar.gz)
        endif()
        execute_process(COMMAND ${CMAKE_COMMAND} -E
          tar xf ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata${version}.tar.gz
          WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata)
      endif()
      file(COPY ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/${name} DESTINATION ${destination})
    endif()
  endforeach()

  target_sources(${target} PRIVATE ${tzdata_sources})
  set_property(SOURCE ${tzdata_sources} PROPERTY GENERATED ON)
endfunction()
