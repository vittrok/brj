echo "Unpacking..."

KER=$(hexdump -C boot.img | grep "KERNEL" | cut --fields=3-10 -d' ');
NUMKER=$(od -A d -t x1 boot.img | grep "$KER" | cut -f1 -d' ');

REC=$(hexdump -C boot.img | grep "ROOTFS" | cut --fields=3-10 -d' ');
NUMREC=$(od -A d -t x1 boot.img | grep "$REC" | cut -f1 -d' ');

dd if=boot.img of=kernel bs=$NUMREC count=1
dd if=kernel of=kernel_no_header bs=$NUMKER skip=1

dd if=boot.img of=ramdisk bs=$NUMREC skip=1
NUMRAM=$(od -A d -t x1 ramdisk | grep "1f 8b 08 00" | cut -f1 -d' ');

dd if=ramdisk of=ram_header bs=$NUMRAM count=1
dd if=ramdisk of=ramdisk_no_header.gz bs=$NUMRAM skip=1

gunzip ./ramdisk_no_header.gz
mkdir rmdisk
cd rmdisk
cpio -i < ../ramdisk_no_header

echo "Done!"
