#!/bin/bash
# create preconfigured iso from existing hauler iso

# source vars file
. ./variables

# tag setup.sh with the git version
commit_hash=$(git rev-parse --short HEAD)
sed -i s/GITVERSION/"Commit: $(git rev-parse --short HEAD)"/ user-data

# finally, mount and re-create iso
mkdir harvester_extracted 2>/dev/null
rm -f $output_iso
mount -o loop $stock_harv_iso harvester_extracted
xorriso -indev $stock_harv_iso -outdev $output_iso \
-volid $volume_id \
-map grub.cfg /boot/grub2/grub.cfg \
-map user-data /user-data \
-map meta-data /meta-data \
-map seeder.tar.zst /hauler/seeder.tar.zst \
-map seeder_files.tar.zst /hauler/seeder_files.tar.zst \
-map collection.tar.zst /hauler/collection.tar.zst \
-map /usr/local/bin/hauler hauler/hauler \
-map x11docker/xfce.tar xfce.tar \
-joliet on \
-padding 0 \
-boot_image grub bin_path="boot/x86_64/loader/eltorito.img" \
-boot_image grub grub2_mbr="harvester_extracted/boot/x86_64/loader/boot_hybrid.img" \
-boot_image grub grub2_boot_info=on \
-boot_image any partition_offset=16 \
-boot_image any cat_path="boot/x86_64/boot.catalog" \
-boot_image any cat_hidden=on \
-boot_image any boot_info_table=on \
-boot_image any platform_id=0x00 \
-boot_image any emul_type=no_emulation \
-boot_image any load_size=2048 \
-append_partition 2 0xef "harvester_extracted/boot/uefi.img" \
-boot_image any next \
-boot_image any efi_path=--interval:appended_partition_2:all:: \
-boot_image any platform_id=0xef \
-boot_image any emul_type=no_emulation
umount harvester_extracted
