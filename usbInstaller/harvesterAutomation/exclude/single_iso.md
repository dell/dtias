# harvesterAutomate/Single ISO Approach

## Generate A New Harvester Install ISO
- Assumes all gathered files are in your current director
- `xorriso` will fail is `-outdev` file already exists
```bash
xorriso \
-indev < ISO_name >.iso \
-outdev modharv.iso \
-map grub.cfg /boot/grub2/grub.cfg \
-map user-data /user-data \
-map meta-data /meta-data \
-map hauler/seeder.tar.zst /hauler/seeder.tar.zst \
-map hauler/collection.tar.zst /hauler/collection.tar.zst \
-map /usr/local/bin/hauler hauler/hauler \
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
```

Install Harvester from this ISO and it will both install and configure Harvester automatically.
