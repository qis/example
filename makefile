config = debug
system = linux
target = application

all: build/$(system)/$(config)/rules.ninja
	@cmake --build build/$(system)/$(config)

run: build/$(system)/$(config)/rules.ninja
	@cmake --build build/$(system)/$(config)
	@cmake -E chdir build/$(system)/$(config) ./$(target)

test: build/$(system)/debug/rules.ninja build/$(system)/release/rules.ninja
	@cmake --build build/$(system)/debug --target tests
	@cmake --build build/$(system)/release --target tests
	@cmake -E chdir build/$(system)/debug ctest
	@cmake -E chdir build/$(system)/release ctest

benchmark: build/$(system)/release/rules.ninja
	@cmake --build build/$(system)/release --target benchmarks
	@cmake -E chdir build/$(system)/release ./benchmarks

install: build/$(system)/release/rules.ninja
	@cmake --build build/$(system)/release --target install

package: build/$(system)/$(config)/rules.ninja
	@cmake --build build/$(system)/$(config) --target package

format:
	@cmake -P "$(VCPKG_ROOT)/triplets/toolchains/format.cmake"

clean:
	@cmake -E remove_directory build/$(system)

build/$(system)/debug/rules.ninja: CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Debug \
	  -DCMAKE_TOOLCHAIN_FILE="$(VCPKG_ROOT)/triplets/toolchains/$(system).cmake" \
	  -DCMAKE_INSTALL_PREFIX="build/install" \
	  -DCMAKE_CXX_CLANG_TIDY="clang-tidy" \
	  -B build/$(system)/debug

build/$(system)/release/rules.ninja: CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(VCPKG_ROOT)/triplets/toolchains/$(system).cmake" \
	  -DCMAKE_INSTALL_PREFIX="build/install" \
	  -DCMAKE_CXX_CLANG_TIDY="clang-tidy" \
	  -B build/$(system)/release
