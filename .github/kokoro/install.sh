#!/bin/bash

SCRIPT_SRC="$(realpath ${BASH_SOURCE[0]})"
SCRIPT_DIR="$(dirname "${SCRIPT_SRC}")"
INSTALL_DIR="$(pwd)/github/${KOKORO_DIR}/install"

export CMAKE_FLAGS="-GNinja -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DINSTALL_FAMILIES=xc7"
export BUILD_TOOL=ninja
source ${SCRIPT_DIR}/common.sh

source ${SCRIPT_DIR}/steps/start_monitor.sh

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
	ctest -R binary_toolchain_test_xc7* -j${MAX_CORES}
	popd
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Compressing and uploading install dir"
echo "----------------------------------------"
(
	rm -rf build

	# Remove symbolic links and copy content of the linked files
	for file in $(find install -type l)
		do cp --remove-destination $(readlink $file) $file
	done

	du -ah install
	export GIT_HASH=$(git rev-parse --short HEAD)
	tar -I "pixz" -cvf symbiflow-arch-defs-install-${GIT_HASH}.tar.xz -C install bin share/symbiflow/techmaps share/symbiflow/scripts environment.yml
	tar -I "pixz" -cvf symbiflow-arch-defs-benchmarks-${GIT_HASH}.tar.xz -C install benchmarks
	for device in $(ls install/share/symbiflow/arch)
	do
		tar -I "pixz" -cvf symbiflow-arch-defs-$device-${GIT_HASH}.tar.xz -C install share/symbiflow/arch/$device
	done
	rm -rf install
)
echo "----------------------------------------"

source ${SCRIPT_DIR}/steps/stop_monitor.sh
