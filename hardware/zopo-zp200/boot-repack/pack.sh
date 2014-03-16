cd rmdisk
find . | cpio -o -H newc | gzip > ../new_ram
cd ..
python cksum.py new_ram ram_header
mv ram_header.alt ram_header
dd if=./new_ram >> ./ram_header
mv ram_header ramdisk_new
./mkbootimg --kernel ./kernel_no_header --ramdisk ./ramdisk_new -o ./new_boot.img
rm -rf kernel rmdisk new_ram ramdisk ramdisk_no_header kernel_no_header ramdisk_new
