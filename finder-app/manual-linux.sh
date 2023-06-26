#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- clean
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs
    cp ./arch/${ARCH}/boot/Image ${OUTDIR}/Image
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
make -j4  ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu-
make -j4 CONFIG_PREFIX=${OUTDIR}/rootfs/  ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- install

echo "Library dependencies"
${CROSS_COMPILE}readelf -a busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a busybox | grep "Shared library"
CROSS_COMPILER_BASE_DIR=`which ${CROSS_COMPILE}readelf`
CROSS_COMPILER_BIN_DIR=`dirname ${CROSS_COMPILER_BASE_DIR}`
CROSS_COMPILER_LIBC_DIR=${CROSS_COMPILER_BIN_DIR}/../aarch64-none-linux-gnu/libc/lib
CROSS_COMPILER_LIBC64_DIR=${CROSS_COMPILER_BIN_DIR}/../aarch64-none-linux-gnu/libc/lib64


# TODO: Add library dependencies to rootfs
cp ${CROSS_COMPILER_LIBC_DIR}/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
cp ${CROSS_COMPILER_LIBC64_DIR}/libm.so.6 ${OUTDIR}/rootfs/lib64
cp ${CROSS_COMPILER_LIBC64_DIR}/libresolv.so.2 ${OUTDIR}/rootfs/lib64
cp ${CROSS_COMPILER_LIBC64_DIR}/libc.so.6 ${OUTDIR}/rootfs/lib64

# TODO: Make device nodes
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1

# TODO: Clean and build the writer utility
cd $FINDER_APP_DIR
make clean
make CROSS_COMPILE=aarch64-none-linux-gnu- 

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp autorun-qemu.sh start-qemu-app.sh  start-qemu-terminal.sh writer writer.sh finder.sh finder-test.sh dependencies.sh ${OUTDIR}/rootfs/home/
mkdir -p ${OUTDIR}/rootfs/home/conf
cp ./conf/username.txt ${OUTDIR}/rootfs/home/conf/
cp ./conf/assignment.txt ${OUTDIR}/rootfs/home/conf/

# TODO: Chown the root directory
#sudo chown $(id -u):$(id -g) ${OUTDIR}/rootfs
sudo chown -R root:root ${OUTDIR}/rootfs

# TODO: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f ${OUTDIR}/initramfs.cpio
