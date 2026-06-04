#!/usr/bin/env bash

# =========================================================
# AUTO_INSTALL_YOCTO_AND_BSP_NXP
# =========================================================

# Yocto/NXP environment scripts reference optional unset variables, so do not
# enable Bash nounset (`set -u`) here.
set -eo pipefail

HOME_DIR="$HOME"    
LEARN_YOCTO_DIR="$HOME/yocto"

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run this script as root or with sudo."
    echo "Run it as a normal user: ./install_yocto_bsp_nxp.sh"
    exit 1
fi

CURRENT_USER="$(id -un)"
CURRENT_GROUP="$(id -gn)"

# Disable interactive pagers when Git/repo commands run from this script.
export GIT_PAGER=cat
export PAGER=cat

# Accept the NXP/Freescale EULA non-interactively for automated setup.
export EULA=1
export ACCEPT_FSL_EULA=1

#========================================


#=============================================
#CAI TOOLS
#=============================================

mkdir -p "$LEARN_YOCTO_DIR" 
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.repoconfig"

sudo chown -R "$CURRENT_USER:$CURRENT_GROUP" \
    "$HOME/bin" \
    "$HOME/.repoconfig" \
    "$LEARN_YOCTO_DIR"

sudo apt update

sudo apt install -y \
    build-essential chrpath cpio debianutils diffstat file gawk gcc git \
    iputils-ping libacl1 liblz4-tool locales python3 python3-git \
    python3-jinja2 python3-pexpect python3-pip python3-subunit socat \
    texinfo unzip wget xz-utils zstd curl

sudo locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

curl https://storage.googleapis.com/git-repo-downloads/repo \
    -o ~/bin/repo

chmod a+x ~/bin/repo

echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/bin:$PATH"

repo version

git config --global color.ui auto

#=============================================
#DOWNLOAD SOURCE NXP Yocto Kirkstone BSP
#=============================================
mkdir -p "$LEARN_YOCTO_DIR/imx-yocto-kirkstone" 
cd "$LEARN_YOCTO_DIR/imx-yocto-kirkstone"

repo init \
    -u https://github.com/nxp-imx/imx-manifest \
    -b imx-linux-kirkstone \
    -m imx-5.15.71-2.2.2.xml \
    --no-repo-verify

repo sync -j"$(nproc)"


#=============================================
#CONFIG-KIRKSTONE-MACHINE_DEFAULD-EMMC
#=============================================

cd "$LEARN_YOCTO_DIR/imx-yocto-kirkstone"

MACHINE=imx6ull14x14evk \
DISTRO=fsl-imx-fb \
EULA=1 \
ACCEPT_FSL_EULA=1 \
source imx-setup-release.sh -b build-fb-emmc

if ! grep -qxF 'ACCEPT_FSL_EULA = "1"' conf/local.conf; then
    echo 'ACCEPT_FSL_EULA = "1"' >> conf/local.conf
fi

if ! grep -qxF 'UBOOT_CONFIG = "emmc"' conf/local.conf; then
    echo 'UBOOT_CONFIG = "emmc"' >> conf/local.conf
fi

# Use about two thirds of the logical CPUs, then limit jobs to roughly one job
# per 2 GiB of available RAM. BUILD_JOBS can be set manually to override this.
CPU_THREADS="$(nproc)"
AVAILABLE_RAM_KIB="$(awk '/MemAvailable:/ { print $2 }' /proc/meminfo)"
AVAILABLE_RAM_GIB="$((AVAILABLE_RAM_KIB / 1024 / 1024))"

CPU_LIMIT="$((CPU_THREADS * 2 / 3))"
RAM_LIMIT="$((AVAILABLE_RAM_GIB / 2))"

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

sed -i '/^BB_NUMBER_THREADS = /d; /^PARALLEL_MAKE = /d' conf/local.conf
{
    echo "BB_NUMBER_THREADS = \"$BUILD_JOBS\""
    echo "PARALLEL_MAKE = \"-j $BUILD_JOBS\""
} >> conf/local.conf

#=============================================
#BUILD BASE IMX6ULL AFTER
#=============================================
bitbake core-image-base
