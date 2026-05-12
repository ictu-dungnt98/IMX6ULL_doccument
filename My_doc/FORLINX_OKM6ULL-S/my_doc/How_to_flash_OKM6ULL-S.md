# HƯỚNG DẪN FLASH LÊN BOARD OKM6ULL-S BẰNG UUU

- Tài liệu tham khảo: `/IMX6ULL/uuu_flash/uuu_flash.md`, hướng dẫn cách dùng `uuu`.

---

## I. Tạo file script UUU

Tạo một thư mục chứa `.wic`, `u-boot` và file script `.uuu` cùng cấp với nhau.

Ví dụ thư mục:

```text
flash_OKM_6ULL-S/
├── u-boot-imx6ull14x14evk_sd.imx
├── u-boot-emmc.imx
├── rootfs_wifi.wic
└── test.uuu
```

Sau khi có file `rootfs_wifi.wic` từ tài liệu:

```text
/OKM6ULL-S/my_doc/How_to_build_SDK.md
```

Cần tải thêm `u-boot-emmc.imx` từ hãng về, vì trong tài liệu base của hãng không build ra `u-boot`.

Link tải:

```text
https://onedrive.live.com/?redeem=aHR0cHM6Ly8xZHJ2Lm1zL2YvYy80ZTdjYWNlYmNmYWJjMmUwL0VnclFpWjJldE5GT2l4bGZ1eFY2aUFJQnNQS0VOVnRlQUxtQ2dtM2lIbXNGQlE%5FZT1mT05JSHo&id=4E7CACEBCFABC2E0%21s202273b474d0417c983cca3547533a3f&cid=4E7CACEBCFABC2E0&sb=name&sd=1
```

---

## II. Nội dung file `test.uuu`

Tạo một file tên là:

```text
test.uuu
```

Nội dung như sau:

```text
uuu_version 1.2.39

# Boot u-boot len RAM qua USB SDP
SDP: boot -f u-boot-imx6ull14x14evk_sd.imx

# Chon eMMC
FB[-t 15000]: ucmd setenv fastboot_dev mmc
FB[-t 15000]: ucmd setenv mmcdev 1
FB[-t 15000]: ucmd mmc dev 1

FB[-t 15000]: ucmd setenv fastboot_buffer ${loadaddr}
FB[-t 15000]: download -f u-boot-emmc.imx
FB[-t 15000]: ucmd mmc write ${loadaddr} 0x2 0x800

# Nap full eMMC image: boot FAT + rootfs ext4
FB[-t 120000]: flash -raw2sparse all rootfs_wifi.wic

FB: done
```

---

## III. Chạy UUU để flash

Sau đó lưu lại và tiến hành boot. Chúng ta cần chỉnh DIP chuyển mode sang serial download, xem tại tài liệu:

```text
/OKM6ULL-S/software/about.md
```

Lưu ý cắm kèm dây UART debug để xem có gặp lỗi gì không, nếu lỗi còn biết đường fix.

Chạy lệnh này để tool `uuu` bắt đầu thực thi:

```bash
uuu -v test.uuu
```

Sau khi xong nó sẽ hiện `Done`.

Sau đó chuyển DIP sang boot eMMC rồi tận hưởng, check xem chạy oke đúng những gì mình cần chưa, đúng config chưa.
