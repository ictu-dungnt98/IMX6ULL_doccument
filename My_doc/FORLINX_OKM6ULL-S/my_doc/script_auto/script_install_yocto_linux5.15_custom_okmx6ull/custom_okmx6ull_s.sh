
#!/usr/bin/env bash

# =========================================================
# custom okmx6ull base in imx6ull 14x14 evk
# =========================================================

set -eo pipefail

LEARN_YOCTO_kirkstone="$HOME/yocto/imx-yocto-kirkstone"

cd "$LEARN_YOCTO_kirkstone"

if [ "${CLEAN_BUILD_CACHE:-1}" = "1" ]; then
    echo "Cleanup temporary Yocto cache: build-fb/tmp build-fb/cache"
    rm -rf build-fb/tmp build-fb/cache
fi

MACHINE=imx6ull14x14evk \
DISTRO=fsl-imx-fb \
EULA=1 \
ACCEPT_FSL_EULA=1 \
source imx-setup-release.sh -b build-fb

CPU_THREADS="$(nproc)"
AVAILABLE_RAM_KIB="$(awk '/MemAvailable:/ { print $2 }' /proc/meminfo)"
AVAILABLE_RAM_GIB="$((AVAILABLE_RAM_KIB / 1024 / 1024))"

CPU_LIMIT="$((CPU_THREADS * 2 / 3))"
RAM_LIMIT="$((AVAILABLE_RAM_GIB / 4))"

[ "$CPU_LIMIT" -lt 1 ] && CPU_LIMIT=1
[ "$RAM_LIMIT" -lt 1 ] && RAM_LIMIT=1

AUTO_BUILD_JOBS="$CPU_LIMIT"
[ "$RAM_LIMIT" -lt "$AUTO_BUILD_JOBS" ] && AUTO_BUILD_JOBS="$RAM_LIMIT"

BUILD_JOBS="${BUILD_JOBS:-$AUTO_BUILD_JOBS}"

echo "Detected CPU threads : $CPU_THREADS"
echo "Available RAM        : ${AVAILABLE_RAM_GIB} GiB"
echo "CPU job limit        : $CPU_LIMIT"
echo "RAM job limit        : $RAM_LIMIT"
echo "Build jobs selected  : $BUILD_JOBS"

sed -i \
    '/^BB_NUMBER_THREADS = /d; /^PARALLEL_MAKE = /d; /^PARALLEL_MAKEINST = /d; /^PARALLEL_MAKE:pn-rust-llvm/d; /^PARALLEL_MAKE:pn-rust-llvm-native/d' \
    conf/local.conf
{
    echo "BB_NUMBER_THREADS = \"$BUILD_JOBS\""
    echo "PARALLEL_MAKE = \"-j $BUILD_JOBS\""
    echo "PARALLEL_MAKEINST = \"-j $BUILD_JOBS\""
    echo "PARALLEL_MAKE:pn-rust-llvm = \"-j 1\""
    echo "PARALLEL_MAKE:pn-rust-llvm-native = \"-j 1\""
} >> conf/local.conf

bitbake core-image-base



