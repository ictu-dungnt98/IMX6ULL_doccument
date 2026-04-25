# i.MX 6UltraLite (6UL) – Tóm tắt từ UG10164

> Trích lọc từ: *i.MX Yocto Project User's Guide – Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## 1. Thuộc dòng sản phẩm i.MX 6

i.MX 6UltraLite (6UL) thuộc **i.MX 6 Family**, bao gồm các SoC:

- 6QuadPlus, 6Quad, 6DualLite, 6SoloX, 6SLL, **6UltraLite**, **6ULL**, 6ULZ

---

## 2. Layer hỗ trợ

Các layer Yocto Project sau đây cung cấp hỗ trợ cho i.MX 6UL:

| Layer | Mô tả |
|-------|-------|
| `meta-freescale` | Hỗ trợ board base và i.MX Arm reference, bao gồm i.MX 6UL |
| `meta-freescale-distro` | Các tiện ích bổ sung cho phát triển và kiểm tra khả năng board |
| `meta-freescale-3rdparty` | Hỗ trợ board của bên thứ ba và đối tác |
| `meta-imx-bsp` | BSP chính: Kernel, U-Boot, firmware, GPU, VPU, bảo mật |

---

## 3. Tài liệu tham khảo liên quan đến i.MX 6UL

| Tài liệu | Mô tả |
|----------|-------|
| **i.MX Linux Release Notes** (RN00210) | Thông tin release, danh sách SoC được validate |
| **i.MX Linux User's Guide** (UG10163) | Cài đặt U-Boot, Linux OS, và các tính năng i.MX |
| **i.MX Yocto Project User's Guide** (UG10164) | Hướng dẫn build BSP bằng Yocto Project |
| **i.MX Porting Guide** (UG10165) | Hướng dẫn port BSP sang board mới |
| **i.MX Graphics User's Guide** (UG10159) | Mô tả các tính năng đồ họa |
| **i.MX Linux Reference Manual** (RM00293) | Thông tin Linux driver cho i.MX |
| **i.MX VPU API Linux Reference Manual** (RM00294) | Tham khảo VPU API trên i.MX 6 VPU |

---

## 4. Quick Start Guide

- **i.MX 6UltraLite EVK Quick Start Guide** – `IMX6ULTRALITEQSG`
- **i.MX 6ULL EVK Quick Start Guide** – `IMX6ULLQSG`

---

## 5. Tài nguyên & liên kết

| Tài nguyên | Link |
|-----------|------|
| i.MX 6 series | [nxp.com/iMX6series](https://www.nxp.com/iMX6series) |
| i.MX 6UltraLite | [nxp.com/iMX6UL](https://www.nxp.com/iMX6UL) |
| i.MX 6ULL | [nxp.com/iMX6ULL](https://www.nxp.com/iMX6ULL) |
| i.MX 6ULZ | [nxp.com/imx6ulz](https://www.nxp.com/imx6ulz) |
| Source code (GitHub) | [github.com/nxp-imx](https://github.com/nxp-imx) |
| BSP layer meta-imx | [github.com/nxp-imx/meta-imx](https://github.com/nxp-imx/meta-imx) |
| Manifest BSP | [github.com/nxp-imx/imx-manifest](https://github.com/nxp-imx/imx-manifest) |

---

## 6. Lưu ý quan trọng

- Phiên bản BSP mới nhất: **LF6.18.2_1.0.0**, dựa trên **Yocto Project 5.3 (Whinlatter)**
- Khi setup môi trường build, cần **đồng ý NXP EULA** để có thể untar các package từ i.MX mirror.
- Chi tiết SoC nào được validate trong release hiện tại: xem **i.MX Linux Release Notes (RN00210)**.