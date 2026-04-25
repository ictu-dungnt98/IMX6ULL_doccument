# i.MX 6UL – Chapter 2: Features

> Trích lọc từ: *i.MX Yocto Project User's Guide – Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## Linux Kernel

- Recipe nằm trong thư mục `recipes-kernel`, tích hợp source `linux-imx.git` từ i.MX GitHub.
- **LF6.18.2_1.0.0** là phiên bản Linux kernel được release cho Yocto Project.

---

## U-Boot

- Recipe nằm trong thư mục `recipes-bsp`, tích hợp source `uboot-imx.git` từ i.MX GitHub.
- i.MX 6 sử dụng **U-Boot v2025.04** trong release LF6.18.2_1.0.0.

---

## Graphics

- Recipe nằm trong thư mục `recipes-graphics`.
- i.MX 6 và i.MX 7 hỗ trợ **Frame Buffer (FB)** – các dòng khác (i.MX 8, 9) không có tính năng này.
- Với SoC có Vivante GPU: package `imx-gpu-viv` hỗ trợ các distro: Frame Buffer, XWayland, Wayland backend, Weston compositor.

> **Lưu ý:** i.MX 6UL **không có GPU Vivante** – tính năng graphics GPU không áp dụng. Chỉ các biến thể có GPU (như 6Quad) mới dùng `imx-gpu-viv`.

---

## Multimedia

- Recipe nằm trong `recipes-multimedia`.
- Các package proprietary như `imx-codec`, `imx-parser` được pull từ i.MX public mirror.
- Một số codec bị hạn chế license – cần liên hệ đại diện i.MX Marketing để lấy package riêng.

---

## Các recipe khác áp dụng được cho i.MX 6UL

| Recipe | Vị trí | Ghi chú |
|--------|---------|---------|
| Core recipes (udev rules,...) | `meta-imx-bsp` | Cập nhật policy hệ thống |
| Demo recipes | `meta-imx-sdk` | Ứng dụng demo, touch calibration |
| GoPoint demo | `meta-nxp-demo-experience` | Có trong tất cả full image release |

---

## Không áp dụng cho i.MX 6UL

| Recipe | Lý do |
|--------|-------|
| Machine learning (`meta-imx-ml`) | Chỉ dành cho i.MX 8/9 |
| Cockpit (`meta-imx-cockpit`) | Chỉ dành cho i.MX 8QuadMax |
| Mali GPU (`mali-imx`) | Chỉ dành cho i.MX 9 |