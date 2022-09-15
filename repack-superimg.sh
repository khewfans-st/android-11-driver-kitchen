#!/bin/sh

## Author: Fan Sin KHEW
## Description: Unpack super.img, replace kernel modules and repack super.img
## https://forum.xda-developers.com/t/editing-system-img-inside-super-img-and-flashing-our-modifications.4196625/
##
## Prerequisites:
## 1) ./kernel/out 			-> compiled kernel modules
## 2) ./images/super.img 	-> original super image
## 3) ./otatools			-> unzip otatools.zip
##
## How to get the device super partition
## https://android.stackexchange.com/questions/247106/how-to-get-the-size-of-the-super-partition-on-the-device

ROOT_DIR=$(pwd)
OTATOOLS_BIN=$ROOT_DIR/otatools/bin
DEVICE_SUPER_PARTITION_SIZE=13115588608		# edit this based on your phone

echo "This script will take some times to be completed."
echo "------------------------------------------------------------"

chmod +x $OTATOOLS_BIN/*
cd $OTATOOLS_BIN

echo "Convert sparse image to ext4 image..."
./simg2img $ROOT_DIR/images/super.img super.ext4.img

echo "Unpack super ext4 image..."
./lpunpack super.ext4.img

echo "Delete super.ext4.img to save some disk space"
rm super.ext4.img
echo "Done unpacking super ext4 image"

echo "Modifying vendor image..."
echo "Allocate more spaces(3G) for vendor.img"
fallocate -l 3G vendor.img
resize2fs vendor.img 3G

rm -r vendor
rm -rf modules
mkdir modules
mkdir vendor

echo "Mount vendor image"
sudo mount -t ext4 -o loop vendor.img vendor
sleep 2
echo "Replacing kernel modules..."
find $ROOT_DIR/kernel/out | grep "**/*\.ko$" | xargs cp -t modules
sudo cp modules/*.ko vendor/lib/modules/
sleep 60
echo "Umount vendor image"
sudo umount vendor
sleep 2


echo "Resizing vendor image..."
./e2fsck -yf vendor.img
resize2fs -M vendor.img
./e2fsck -yf vendor.img
resize2fs -M vendor.img


echo "Calculating image size..."
SYSTEM_IMG_SIZE=$(stat -c "%s" system.img)
VENDOR_IMG_SIZE=$(stat -c "%s" vendor.img)
PRODUCT_IMG_SIZE=$(stat -c "%s" product.img)
ODM_IMG_SIZE=$(stat -c "%s" odm.img)
TOTAL_IMG_SIZE=$((SYSTEM_IMG_SIZE+VENDOR_IMG_SIZE+PRODUCT_IMG_SIZE+ODM_IMG_SIZE))

echo $SYSTEM_IMG_SIZE
echo $VENDOR_IMG_SIZE
echo $PRODUCT_IMG_SIZE
echo $ODM_IMG_SIZE
echo $TOTAL_IMG_SIZE

echo "Repacking super new image..."
./lpmake --metadata-size 65536 --super-name super --metadata-slots 1 --device super:$DEVICE_SUPER_PARTITION_SIZE --group main:$TOTAL_IMG_SIZE --partition system:readonly:$SYSTEM_IMG_SIZE:main --image system=./system.img --partition vendor:readonly:$VENDOR_IMG_SIZE:main --image vendor=./vendor.img --partition product:readonly:$PRODUCT_IMG_SIZE:main --image product=./product.img --partition odm:readonly:$ODM_IMG_SIZE:main --image odm=./odm.img --sparse --output ./super.new.img

echo "Cleaning up..."
rm system.img vendor.img product.img odm.img
rm -r vendor
rm -rf modules



