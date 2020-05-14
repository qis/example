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
	@cmake -E chdir build/$(system)/debug ./tests
	@cmake -E chdir build/$(system)/release ./tests

benchmark: build/$(system)/release/rules.ninja
	@cmake --build build/$(system)/release --target benchmark
	@cmake -E chdir build/$(system)/release ./benchmark

install: build/$(system)/release/rules.ninja
	@cmake --build build/$(system)/release --target install

package: build/$(system)/release/rules.ninja
	@cmake --build build/$(system)/release --target package

format:
	@cmake -P res/format.cmake

clean:
	@cmake -E remove_directory build/$(system)

build/windows/debug/rules.ninja: CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Debug \
	  -DCMAKE_INSTALL_PREFIX="$(MAKEDIR)\build\install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MAKEDIR)\res\toolchain.cmake" \
	  -B build/windows/debug

build/windows/release/rules.ninja: CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX="$(MAKEDIR)\build\install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MAKEDIR)\res\toolchain.cmake" \
	  -B build/windows/release

build/linux/debug/rules.ninja: CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Debug \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/build/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/res/toolchain.cmake" \
	  -B build/linux/debug

build/linux/release/rules.ninja: CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/build/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/res/toolchain.cmake" \
	  -B build/linux/release
