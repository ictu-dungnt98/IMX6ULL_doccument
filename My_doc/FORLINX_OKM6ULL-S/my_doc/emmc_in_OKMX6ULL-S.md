# Tổng Quan eMMC Hiện Tại — Forlinx OKMX6ULL-S

> Board: Forlinx OKMX6ULL-S
> SoC: NXP i.MX6ULL
> Storage: eMMC 8GB
> Bootloader: U-Boot custom
> Kernel: Linux Yocto Kirkstone

---

# 1. Tổng quan vật lý eMMC

eMMC của board được Linux nhận là:

```bash
/dev/mmcblk1
```

Dung lượng thực tế:

```text
7818182656 bytes
≈ 7.28 GiB
≈ 7.8GB marketing
```

---

# 2. Physical Layout của eMMC

eMMC không chỉ có 1 vùng duy nhất.

Bên trong chip thật sự gồm:

```text
eMMC Physical Layout
┌────────────────────────────────────────────┐
│ BOOT0      4MB                             │
├────────────────────────────────────────────┤
│ BOOT1      4MB                             │
├────────────────────────────────────────────┤
│ RPMB       4MB                             │
├────────────────────────────────────────────┤
│ USER AREA  ~7.4GB                          │
└────────────────────────────────────────────┘
```

---

# 3. Các vùng hiện tại

## BOOT0

```bash
/dev/mmcblk1boot0
```

Dung lượng:

```text
4MB
```

Hiện tại:

```text
KHÔNG dùng để boot
```

---

## BOOT1

```bash
/dev/mmcblk1boot1
```

Dung lượng:

```text
4MB
```

Hiện tại:

```text
KHÔNG dùng
```

---

## RPMB

```bash
/dev/mmcblk1rpmb
```

RPMB = Replay Protected Memory Block

Dùng cho:

* secure storage
* trusted key
* anti rollback

Hiện tại:

```text
KHÔNG dùng
```

---

# 4. USER AREA

Đây là vùng quan trọng nhất.

Linux thấy vùng này là:

```bash
/dev/mmcblk1
```

Bên trong USER AREA chứa:

* partition table
* U-Boot raw sectors
* FAT boot partition
* ext4 rootfs

---

# 5. Layout thực tế hiện tại

```text
/dev/mmcblk1  (USER AREA)
┌────────────────────────────────────────────┐
│ 0x00000000                                 │
│                                            │
│ MBR / Partition Table                      │
│                                            │
├────────────────────────────────────────────┤
│ 0x00000400 (offset 1KB)                    │
│                                            │
│ U-Boot .imx                                │
│                                            │
│ ghi bằng:                                  │
│   mmc write ${loadaddr} 0x2 0x800          │
│                                            │
│ size ~1MB                                  │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│ alignment / unused                         │
│                                            │
├────────────────────────────────────────────┤
│ Partition 1                                │
│ /dev/mmcblk1p1                             │
│ FAT32                                      │
│ ~120MB                                     │
│                                            │
│ chứa:                                      │
│   zImage                                   │
│   *.dtb                                    │
│   boot.scr                                 │
│                                            │
├────────────────────────────────────────────┤
│ Partition 2                                │
│ /dev/mmcblk1p2                             │
│ ext4                                       │
│ ~1.9GB                                     │
│                                            │
│ chứa root filesystem Linux                 │
│                                            │
│   /bin                                     │
│   /etc                                     │
│   /usr                                     │
│   /lib                                     │
│                                            │
│ app OTA MQTT hiện tại                      │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│ FREE UNUSED SPACE (~5GB)                   │
│                                            │
│ cực phù hợp cho OTA A/B                    │
│                                            │
└────────────────────────────────────────────┘
```

---

# 6. Partition hiện tại

## p1 — Boot partition

```bash
/dev/mmcblk1p1
```

Filesystem:

```text
FAT32
```

Mounted tại:

```bash
/run/media/mmcblk1p1
```

Dung lượng:

```text
120MB
```

Chứa:

```text
zImage
device tree (*.dtb)
boot scripts
```

---

## p2 — Root filesystem

```bash
/dev/mmcblk1p2
```

Filesystem:

```text
ext4
```

Mounted:

```bash
/
```

Dung lượng:

```text
~1.9GB
```

Đây là Linux rootfs chính.

---

# 7. U-Boot hiện đang nằm ở đâu?

Cực quan trọng:

```text
U-Boot KHÔNG nằm trong partition
```

Nó nằm:

```text
RAW sectors
```

tức là ghi trực tiếp xuống sector vật lý của eMMC.

---

# 8. UUU đang flash U-Boot như nào?

Trong file `.uuu`:

```text
mmc write ${loadaddr} 0x2 0x800
```

Giải thích:

```text
0x2 = sector 2
1 sector = 512 bytes
```

=> offset:

```text
2 * 512
= 1024 bytes
= 1KB
```

Nên:

```text
U-Boot bắt đầu tại offset 1KB
```

---

# 9. Tại sao U-Boot không nằm trong partition?

Vì ROM bootloader của i.MX6ULL:

* chưa biết FAT32
* chưa biết ext4
* chưa biết GPT/MBR

ROM chỉ biết:

```text
đọc raw sectors
```

nên U-Boot phải nằm ở fixed offset.

---

# 10. Boot flow hiện tại

## STEP 1

ROM Boot của i.MX6ULL chạy.

---

## STEP 2

ROM đọc:

```text
eMMC USER AREA
offset 1KB
```

---

## STEP 3

ROM tìm:

```text
IVT header
```

trong file `.imx`

---

## STEP 4

ROM copy U-Boot từ eMMC lên DDR RAM.

---

## STEP 5

U-Boot chạy trong RAM.

---

## STEP 6

U-Boot mount:

```text
mmc 1:1
```

tức là:

```text
/dev/mmcblk1p1
```

---

## STEP 7

U-Boot load:

```text
zImage
*.dtb
```

lên RAM.

Ví dụ:

```text
Kernel  -> 0x80800000
DTB     -> 0x83000000
```

---

## STEP 8

U-Boot jump vào Linux kernel.

---

## STEP 9

Linux mount:

```text
/dev/mmcblk1p2
```

làm root filesystem.

---

# 11. RAM layout lúc boot

DDR3 512MB:

```text
DDR RAM
┌────────────────────────────────────┐
│ U-Boot runtime                     │
├────────────────────────────────────┤
│ Device Tree                        │
├────────────────────────────────────┤
│ initrd (nếu có)                    │
├────────────────────────────────────┤
│ zImage kernel                      │
├────────────────────────────────────┤
│ Linux runtime                      │
├────────────────────────────────────┤
│ userspace                          │
└────────────────────────────────────┘
```

---

# 12. Ý nghĩa OTA hiện tại

## OTA kernel

Hiện app đang:

```text
download zImage mới
→ ghi đè zImage trong FAT partition
```

Tức là:

```text
/run/media/mmcblk1p1/zImage
```

---

## OTA rootfs

Hiện app đang:

```text
tar -xzf rootfs.tar.gz -C /
```

tức là overwrite live rootfs.

---

# 13. Rủi ro hiện tại

## Kernel OTA

Nếu mất điện giữa chừng:

```text
zImage corrupt
→ boot fail
```

---

## Rootfs OTA

Nếu extract fail:

```text
filesystem inconsistent
```

---

# 14. Hướng OTA đúng

## Kernel A/B

Trong FAT partition:

```text
zImage_A
zImage_B
```

U-Boot chọn slot boot.

---

## Rootfs A/B

Tạo:

```text
p2 = rootfs_A
p3 = rootfs_B
```

---

# 15. Layout OTA tương lai tao khuyên

```text
eMMC
┌────────────────────────────────────┐
│ U-Boot raw sectors                 │
├────────────────────────────────────┤
│ p1 FAT boot 256MB                  │
│   zImage_A                         │
│   zImage_B                         │
│   dtb_A                            │
│   dtb_B                            │
├────────────────────────────────────┤
│ p2 rootfs_A 2GB                    │
├────────────────────────────────────┤
│ p3 rootfs_B 2GB                    │
├────────────────────────────────────┤
│ p4 data/shared                     │
└────────────────────────────────────┘
```

---

# 16. Tóm tắt cực ngắn

## U-Boot

```text
nằm raw sectors
offset 1KB
không thuộc partition
```

---

## Kernel

```text
là file trong FAT partition
```

---

## Rootfs

```text
là filesystem ext4 partition
```

---

# 17. Các lệnh debug hữu ích

## Xem partition

```bash
fdisk -l /dev/mmcblk1
```

---

## Xem mount

```bash
mount
```

---

## Xem raw U-Boot

```bash
dd if=/dev/mmcblk1 bs=512 skip=2 count=8 | hexdump -C
```

---

## Xem bootargs

```bash
cat /proc/cmdline
```

---

## Xem environment U-Boot

Trong U-Boot shell:

```bash
printenv
```
