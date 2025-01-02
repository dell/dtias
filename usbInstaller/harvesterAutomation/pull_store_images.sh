#!/bin/bash
# build and pull images and store in tarballs via hauler

# source vars file
. ./variables

# build x11docker tarball
rm -vf x11docker/xfce.tar
docker build -t kpro/xfce x11docker/.
docker save kpro/xfce:latest -o x11docker/xfce.tar

# use hauler to download/save registry images
rm -rvf *tar.zst hauler/{seeder,seeder_files,collection}
hauler store sync -f hauler/seeder_images.yaml -s hauler/seeder
hauler store sync -f hauler/seeder_files.yaml -s hauler/seeder_files
hauler store sync -f hauler/collection.yaml -s hauler/collection
hauler store save --filename seeder.tar.zst -s hauler/seeder
hauler store save --filename seeder_files.tar.zst -s hauler/seeder_files
hauler store save --filename collection.tar.zst -s hauler/collection
