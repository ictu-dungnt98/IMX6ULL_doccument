# i.MX 6UL – Chapter 4: Yocto Project Setup

> Trích lọc từ: *i.MX Yocto Project User's Guide – Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## Cấu trúc thư mục BSP

Sau khi setup, thư mục BSP gồm:
- `sources/` – chứa toàn bộ Yocto Project layers và recipes
- Các script dùng để thiết lập môi trường build

---

## Tải BSP về máy

```bash
mkdir imx-yocto-bsp
cd imx-yocto-bsp
repo init -u https://github.com/nxp-imx/imx-manifest \
    -b imx-linux-whinlatter \
    -m imx-6.18.2-1.0.0.xml
repo sync
```

Sau khi hoàn tất, toàn bộ BSP được checkout vào thư mục `imx-yocto-bsp/sources`.

> **Danh sách đầy đủ manifest files** của release này:
> https://github.com/nxp-imx/imx-manifest/tree/imx-linux-whinlatter