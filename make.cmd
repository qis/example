@echo off

where /Q cl
if %errorlevel% equ 0 goto :make

set __VS_LOCATION=%ProgramFiles(x86)%\Microsoft Visual Studio\2019
set __VS_EDITIONS=Preview,Enterprise,Professional,Community,BuildTools
for %%i in (%__VS_EDITIONS%) do (
  if exist "%__VS_LOCATION%\%%i\VC\Auxiliary\Build\vcvarsall.bat" (
    call "%__VS_LOCATION%\%%i\VC\Auxiliary\Build\vcvarsall.bat" x64
    goto :cleanup
  )
)

:cleanup
set __VS_LOCATION=
set __VS_EDITIONS=

:make
set CURDIR=%CD:\=/%
nmake /nologo SYSTEM=windows %*
