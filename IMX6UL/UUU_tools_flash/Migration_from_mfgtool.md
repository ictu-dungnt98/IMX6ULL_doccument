# 6. Migration from MFGTool ucl2.xml

In most cases, the uboot fastboot protocol can handle image programming. If you need to load a kernel to burn a full image, use the mapping below.

| ucl2.xml | UUU Script |
|---|---|
| `<CMD ... ifdev="MX8QXPB0"> Loading boot image</CMD>` | `SDPS: boot -f flash.bin` |
| `<CMD ... ifdev="MX8MM"> Loading U-boot</CMD>` | `SDP: boot -f flash.bin`<br>`SDPU: write -f flash.bin -offset 0x57c00`<br>`SDPU: jump` |
| Load `Image` to `0x80280000` | `FB: ucmd download -f Image` |
| Load `initramfs.cpio.gz.uboot` to `0x83800000` | `FB: ucmd download -f initramfs.cpio.gz.uboot` |
| Load `fsl-imx8qxp.dtb` to `0x83000000` | `FB: ucmd download -f fsl-imx8qxp.dtb` |
| `<CMD type="push" body="send" file="mksdcard.sh.tar">` | `FBK: ucp mksdcard.sh.tar t:/tmp` |
| `tar xf $FILE` | `FBK: ucmd tar xf /tmp/mksdcard.sh.tar -d /tmp` |
| `sh mksdcard.sh /dev/mmcblk%mmc%` | `FBK: ucmd mksdcard.sh /dev/mmcblk0mmc` |
| Send `imx-boot-imx8qxp-sd.bin` | `FBK: ucp imx-boot-imx8qxp-sd.bin t:/tmp` |
| `dd if=/dev/zero ... seek=4096` (clear u-boot arg) | `FBK: ucmd dd if=/dev/zero of=/dev/mmcblk0 bs=1k seek=4096 conv=fsync count=8` |
| `dd if=$FILE of=/dev/mmcblk0 bs=1k seek=33` | `FBK: ucmd dd if=/tmp/imx-boot-imx8qxp-sd.bin of=/dev/mmcblk0 bs=1k seek=33 conv=fsync` |
| Wait for partition ready | `FBK: ucmd while [ ! -e /dev/mmcblk0p1 ]; do sleep 1; echo waiting...; done` |
| `mkfs.vfat /dev/mmcblk0p1` | `FBK: ucmd mkfs.vfat /dev/mmcblk0p1` |
| `mkdir -p /mnt/mmcblk0p1` | `FBK: ucmd mkdir -p /mnt/mmcblk0p1` |
| `mount -t vfat /dev/mmcblk0p1 /mnt/mmcblk0p1` | `FBK: ucmd vfat /dev/mmcblk0p1 /mnt/mmcblk0p1` |
| Send `Image` (kernel) | `FBK: ucp Image t:/tmp` |
| `cp $FILE /mnt/mmcblk0p1/Image` | `FBK: ucmd /tmp/Image /mnt/mmcblk0p1/Image` |
| Send `fsl-imx8qxp.dtb` | `FBK: ucp fsl-imx8qxp.dtb /tmp` |
| `cp $FILE /mnt/mmcblk0p1/fsl-imx8qm.dtb` | `FBK: ucmd cp /tmp/fsl-imx8qxp.dtb /mnt/mmcblk0p1/` |
| `umount /mnt/mmcblk0p1` | `FBK: ucmd umount /mnt/mmcblk0p1` |
| `mkfs.ext3 -F -j /dev/mmcblk0p2` | `FBK: ucmd mkfs.ext3 -F -j /dev/mmcblk0p2` |
| `mkdir -p /mnt/mmcblk0p2` | `FBK: ucmd mkdir -p /mnt/mmcblk0p2` |
| `mount -t ext3 /dev/mmcblk0p2 /mnt/mmcblk0p2` | `FBK: ucmd mount -t ext3 /dev/mmcblk0p2 /mnt/mmcblk0p2` |
| `pipe tar -jxv -C /mnt/mmcblk0p2` (send rootfs) | `FBK: acmd tar -jxv -C /mnt/mmcblk0p2`<br>`FBK: ucp rootfs.tar.bz2 t:-` |
| Finish rootfs write (`frf`) | `FBK: sync` |
| `umount /mnt/mmcblk0p2` | `FBK: ucmd umount /mnt/mmcblk0p2` |
| `echo Update Complete!` | `done` |