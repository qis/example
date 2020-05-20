# Application
C++ application project template.

## Dependencies
See [qis/toolchains](https://github.com/qis/toolchains) for vcpkg setup instructions.

```sh
vcpkg install benchmark catch2 date fmt
```

Install the [WiX Toolset](https://github.com/wixtoolset/wix3/releases) to create Windows packages.

## Build
Open the directory as a CMake project in Visual Studio or use [makefile](makefile) commands.

* `make` to build (debug)
* `make run` to run (debug)
* `make test` to run tests (debug and release)
* `make benchmark` to run benchmarks (release)
* `make install` to install into `build/install` (release)
* `make package` to create a package (release)
* `make format` to format code with [clang-format](https://llvm.org/builds/)
* `make clean` to remove build files

Add `config=release` to build in release mode.
