# i.MX 6UL – Chapter 6: Image Deployment

> Trích lọc từ: *i.MX Yocto Project User's Guide – Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## Thư mục output

Sau khi build xong, các image được deploy tới:

```
/tmp/deploy/images/
```

Mỗi image build tạo ra:
- **U-Boot**
- **Kernel**
- **SD card image** (`.wic`) – partitioned image chứa U-Boot, kernel, rootfs, sẵn sàng boot
- **Rootfs image** (`.tar`)

---

## 6.1 Flash SD Card

```bash
zstdcat <image>.wic.zst | sudo dd of=/dev/sd<X> bs=1M conv=fsync
```

> Thay `sd<X>` bằng đúng device của SD card (ví dụ: `sdb`).

Tham khảo thêm: mục **"Preparing an SD/MMC card to boot"** trong *i.MX Linux User's Guide (UG10163)*.

---

## Lưu ý

- Image SD card (`.wic`) đã bao gồm đầy đủ U-Boot, kernel, rootfs – phù hợp boot thẳng trên phần cứng.
- i.MX 6UL **không cần** thêm dung lượng rootfs cho eIQ ML (tính năng này không áp dụng cho 6UL).