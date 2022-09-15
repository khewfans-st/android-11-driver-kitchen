#!/bin/sh

ROOT_DIR=$(pwd)

cd $ROOT_DIR/AIK-Linux/
cp $ROOT_DIR/images/magisk_patched-25200_b4J8w.img .
sudo ./unpackimg.sh magisk_patched-25200_b4J8w.img
sudo cp $ROOT_DIR/kernel/out/arch/arm64/boot/Image split_img/magisk_patched-25200_b4J8w.img-kernel
./repackimg.sh --original --origsize

