@echo off

if %0 EQU "%~dpnx0" (
  cmake -G "Visual Studio 16 2019" -A "x64" ^
    -DCMAKE_CONFIGURATION_TYPES="Debug;Release" ^
    -DCMAKE_INSTALL_PREFIX="%~dp0build\install" ^
    -DCMAKE_TOOLCHAIN_FILE="%~dp0res\toolchain.cmake" ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE="release" ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG="debug" ^
    -B "build/windows"
  if %errorlevel% == 0 (
    for %%f in (build\windows\*.sln) do (
      %%f
      goto :eof
    )
  )
  pause
  goto :eof
)

if "%__VS_VCVARS64%" == "1" goto :make

set __VS_LOCATION=%ProgramFiles(x86)%\Microsoft Visual Studio\2019
set __VS_EDITIONS=Enterprise,Professional,Community
for %%i in (%__VS_EDITIONS%) do (
  if exist "%__VS_LOCATION%\%%i\VC\Auxiliary\Build\vcvarsall.bat" (
    call "%__VS_LOCATION%\%%i\VC\Auxiliary\Build\vcvarsall.bat" x64
    set __VS_VCVARS64=1
    goto :cleanup
  )
)

:cleanup
set __VS_LOCATION=
set __VS_EDITIONS=

:make
nmake /nologo system=windows %*
