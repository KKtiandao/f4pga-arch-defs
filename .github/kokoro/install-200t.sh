#!/bin/bash

# Copied from install.sh
# Only difference is INSTALL_DEVICE in CMAKE_FLAGS and tarball name

SCRIPT_SRC="$(realpath ${BASH_SOURCE[0]})"
SCRIPT_DIR="$(dirname "${SCRIPT_SRC}")"
INSTALL_DIR="$(pwd)/github/${KOKORO_DIR}/install"

export CMAKE_FLAGS="-GNinja -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DINSTALL_DEVICE=xc7a200t"
export BUILD_TOOL=ninja
source ${SCRIPT_DIR}/common.sh

echo
echo "========================================"
echo "Running install tests (make install)"
echo "----------------------------------------"
(
	source env/conda/bin/activate symbiflow_arch_def_base
	pushd build
	export VPR_NUM_WORKERS=${CORES}
	ninja -j${MAX_CORES} install
	popd
	cp environment.yml install/
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Running installed toolchain tests"
echo "----------------------------------------"
(
	source env/conda/bin/activate symbiflow_arch_def_base
	pushd build
	export VPR_NUM_WORKERS=${CORES}
	export CTEST_OUTPUT_ON_FAILURE=1
	ctest -R binary_toolchain_test_50t -j${MAX_CORES}
	ctest -R binary_toolchain_test_100t -j${MAX_CORES}
	ctest -R binary_toolchain_test_200t -j${MAX_CORES}
	popd
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Compressing and uploading install dir"
echo "----------------------------------------"
(
	rm -rf build
	du -ah install
	pushd install
	export GIT_HASH=$(git rev-parse --short HEAD)
	tar cfJv symbiflow-arch-defs-install-200t-${GIT_HASH}.tar.xz -C install bin share environment.yml
	tar cfJv symbiflow-arch-defs-benchmarks-200t-${GIT_HASH}.tar.xz -C install benchmarks
	popd
)
echo "----------------------------------------"
