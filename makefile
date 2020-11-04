SYSTEM = linux
TARGET = application

# Build
all: configure
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja
	@ninja -C build/$(SYSTEM) -f build-Release.ninja

# Configure
build/$(SYSTEM)/build.ninja: CMakeLists.txt
	@cmake -G "Ninja Multi-Config" \
	  -DCMAKE_CONFIGURATION_TYPES="Debug;Release" \
	  -DCMAKE_TOOLCHAIN_FILE="$(VCPKG_ROOT)/triplets/toolchains/$(SYSTEM).cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/build/install" \
	  -DVCPKG_TARGET_TRIPLET="x64-$(SYSTEM)-xnet" \
	  -B build/$(SYSTEM)

configure: build/$(SYSTEM)/build.ninja

# Run
run: configure
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja main
	@cmake -E chdir build/$(SYSTEM)/Debug ./$(TARGET)

# Test
test: configure
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Debug ./tests
	@ninja -C build/$(SYSTEM) -f build-Release.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Release ./tests

# Benchmark
benchmark: configure
	@ninja -C build/$(SYSTEM) -f build-Release.ninja benchmarks
	@cmake -E chdir build/$(SYSTEM)/Release ./benchmarks

# Install
install: configure
	@ninja -C build/$(SYSTEM) -f build-Release.ninja install

# Package
package: configure
	@ninja -C build/$(SYSTEM) -f build-Release.ninja package

# Format
format:
	@cmake -P res/format.cmake src

# Clean
clean:
	@cmake -E remove_directory build/$(SYSTEM)
