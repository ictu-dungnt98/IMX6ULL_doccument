# CÁCH FLASH VÀO NOR VÀ NẠP BOOTFS VÀO SDCARD

---

- Hãng có hai Tools dùng để flash và ghi vào sdcard:
    + mfgtools (có UI nhưng nó đã bị out date, không còn được hỗ trợ)
    + sử dụng uuu (tools được khuyến nghị nhất thời điểm hiện tại, nhẹ, vào sử dụng command, có thể xây thành tools sau này)

---

## I. Nạp uboot + kernel + dtb vào Nor bằng uuu

+ tạo 1 file script flash-qspi.uuu

+ lý do chia flash như này là theo format của hãng 
    0x000000    0x100000   U-Boot (1MB)
    0x100000    0x700000   Kernel (7MB)
    0x800000    0x100000   DTB (1MB)    

-> em xem trong tài liệu 1. i.MX Linux User's Guide 

```
uuu_version 1.2.39

# Step 1: Boot uboot lên RAM qua SDP
SDP: boot -f u-boot-imx6ull14x14evk_sd.imx

# Step 2: Flash uboot qspi1 vào NOR offset 0x0
FB[-t 15000]: ucmd sf probe
FB[-t 15000]: ucmd sf erase 0x0 0x100000
FB[-t 15000]: ucmd setenv fastboot_buffer ${loadaddr}
FB[-t 15000]: download -f u-boot-imx6ull14x14evk_qspi1.imx
FB[-t 15000]: ucmd sf write ${loadaddr} 0x0 ${fastboot_bytes}

# Step 3: Flash zImage vào NOR offset 0x100000
FB[-t 15000]: ucmd sf erase 0x100000 0x700000
FB[-t 15000]: ucmd setenv fastboot_buffer 0x81000000
FB[-t 15000]: download -f zImage-imx6ul7d.bin
FB[-t 15000]: ucmd sf write 0x81000000 0x100000 ${fastboot_bytes}

# Step 4: Flash dtb vào NOR offset 0x800000
FB[-t 15000]: ucmd sf erase 0x800000 0x100000
FB[-t 15000]: ucmd setenv fastboot_buffer 0x83000000
FB[-t 15000]: download -f imx6ull-14x14-evk.dtb
FB[-t 15000]: ucmd sf write 0x83000000 0x800000 ${fastboot_bytes}

# Step 5: Ghi rootfs wic vào SD card
FB[-t 60000]: ucmd setenv fastboot_dev mmc
FB[-t 60000]: ucmd setenv mmcdev ${sd_dev}
FB[-t 60000]: ucmd mmc dev ${sd_dev}
FB[-t 60000]: flash -raw2sparse all imx-image-multimedia-imx6ul7d.wic

FB: done
```

---
```
FB[-t 15000] : là timeout sau 15s 

ucmd sf probe : để detech flash của board

ucmd sf erase : xóa vùng nhớ

```



```
uuu flash-qspi.uuu
```

---

**Lưu ý:**
- `uuu_version 1.2.39`: phiên bản uuu, có thể bỏ qua
- `FB[-t 15000]`: timeout 15 giây cho mỗi lệnh
- `${loadaddr}`, `${fastboot_bytes}`: biến môi trường của U-Boot
- `-raw2sparse`: convert raw image sang sparse format cho fastboot
