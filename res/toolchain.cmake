# Determine vcpkg root directory.
if(NOT DEFINED VCPKG_ROOT)
  if(DEFINED ENV{VCPKG_ROOT})
    set(VCPKG_ROOT "$ENV{VCPKG_ROOT}")
  else()
    find_program(VCPKG vcpkg NO_CMAKE_PATH)
    get_filename_component(VCPKG_ROOT "${VCPKG}" DIRECTORY)
  endif()
endif()

# Determine vcpkg target triplet.
if(NOT VCPKG_TARGET_TRIPLET)
  if(DEFINED ENV{VCPKG_DEFAULT_TRIPLET})
    set(VCPKG_TARGET_TRIPLET "$ENV{VCPKG_DEFAULT_TRIPLET}" CACHE STRING "")
  else()
    if(WIN32)
      set(VCPKG_TARGET_TRIPLET "x64-windows" CACHE STRING "")
    else()
      set(VCPKG_TARGET_TRIPLET "x64-linux" CACHE STRING "")
    endif()
  endif()
endif()

# Include vcpkg triplet.
include("${VCPKG_ROOT}/triplets/${VCPKG_TARGET_TRIPLET}.cmake")

# Chainload internal vcpkg toolchain.
if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
  if(WIN32)
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/toolchains/windows.cmake")
  else()
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/toolchains/linux.cmake")
  endif()
endif()

# Include vcpkg toolchain.
include("${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")

# Declare vcpkg headers as system headers.
include_directories(AFTER SYSTEM "${VCPKG_ROOT}/installed/${VCPKG_TARGET_TRIPLET}/include")

if(WIN32)
  # Disable logo for compiler and linker.
  set(CMAKE_CL_NOLOGO "/nologo" CACHE STRING "")

  # Set assembler flags.
  set(CMAKE_ASM_MASM_FLAGS_INIT "/nologo")

  # Set resource compiler flags.
  set(CMAKE_RC_FLAGS "/nologo -c65001 /DWIN32" CACHE STRING "" FORCE)
  set(CMAKE_RC_FLAGS_DEBUG_INIT "-D_DEBUG")

  # Disable interface export warnings.
  add_compile_options(/wd4275)

  # Disable CMake PCH warning.
  add_link_options(/ignore:4042)

  # Add windows defines.
  add_compile_definitions(_WIN64 _WIN32_WINNT=0x0A00 WINVER=0x0A00)
  add_compile_definitions(_CRT_SECURE_NO_DEPRECATE _CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
  add_compile_definitions(_ATL_SECURE_NO_DEPRECATE _SCL_SECURE_NO_WARNINGS)
endif()

# Configure clang-tidy.
if(ENABLE_STATIC_ANALYSIS)
  find_program(clang-tidy NAMES clang-tidy)
  if(clang-tidy)
    set(CMAKE_CXX_CLANG_TIDY ${clang-tidy})
  else()
    message(FATAL_ERROR "Could not find program: clang-tidy")
  endif()
endif()
