#!/bin/bash
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

echo -e "$red Building for Custom Roms $nocol"
echo -e "$cyan Cleaning Up $nocol"
rm -rf out
export KBUILD_BUILD_USER="Shekhawat2"
export KBUILD_BUILD_HOST="Builder"
export KBUILD_COMPILER_STRING=$(~/clang7/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export CLANG_PATH=~/clang7/bin/clang
make clean && make mrproper && ccache -c
BUILD_START=$(date +"%s")
KERNEL_DIR=$PWD
echo -e "$blue Starting $nocol"
make whyred_defconfig O=out ARCH=arm64
echo -e "$yellow Making $nocol"
make -j6 O=out ARCH=arm64 CC="$CCACHE $CLANG_PATH" HOSTCC="$CCACHE $CLANG_PATH" CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=~/linaro7/bin/aarch64-linux-gnu- | tee ../log.txt
echo "Done"
echo "Movings Files"
cd ../anykernel
git reset --hard HEAD
git checkout whyredo
mv $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb Image.gz-dtb
echo -e "$blue Making Zip"
BUILD_TIME=$(date +"%Y%m%d-%T")
zip -r KCUF-whyred-O-$BUILD_TIME *
cd ..
mv anykernel/KCUF-whyred-O-$BUILD_TIME.zip kernel/KCUF-whyred-O-$BUILD_TIME.zip
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
gdrive upload kernel/KCUF-whyred-O-$BUILD_TIME.zip
echo -e "$red Uploaded to Gdrive $nocol"
cd kcuf2
rm -rf out
