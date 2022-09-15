#!/bin/sh

cd kernel
./build_q2q.sh

rm -rf output
cd ..
tar -xvzf AIK-Linux-v3.8-ALL.tar.gz
./repack-bootimg.sh

unzip -o otatools.zip
./repack-superimg.sh

mkdir output
mv AIK-Linux/image-new.img output/boot.img
mv otatools/bin/super.new.img output/super.img

cd output
echo "Creating flashable tar..."
tar -cf output-img.tar boot.img super.img

