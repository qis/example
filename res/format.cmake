set(ProgramFilesX86 "ProgramFiles(x86)")
set(ProgramFilesX86 "$ENV{${ProgramFilesX86}}")

find_program(clang_format NAMES clang-format PATHS
  $ENV{VCPKG_ROOT}/triplets/toolchains/llvm/bin
  $ENV{ProgramW6432}/LLVM/bin
  $ENV{ProgramFiles}/LLVM/bin
  ${ProgramFilesX86}/LLVM/bin)

if(NOT clang_format)
  message(FATAL_ERROR "Could not find executable: clang-format")
endif()

file(GLOB_RECURSE sources include/*.hpp include/*.h src/*.hpp src/*.cpp src/*.h src/*.c)

if(sources)
  foreach(file_absolute ${sources})
    file(RELATIVE_PATH file_relative ${CMAKE_CURRENT_SOURCE_DIR} ${file_absolute})
    file(TIMESTAMP "${file_relative}" file_timestamp_original UTC)
    execute_process(COMMAND "${clang_format}" -i ${file_relative})
    file(TIMESTAMP "${file_relative}" file_timestamp_modified UTC)
    if(NOT file_timestamp_original STREQUAL file_timestamp_modified)
      message(STATUS "${file_relative}")
    endif()
  endforeach()
endif()
