# i.MX 6UL – Chapter 3: Host Setup

> Trích lọc từ: *i.MX Yocto Project User's Guide – Rev. LF6.18.2_1.0.0, 26 March 2026*

---

## Yêu cầu dung lượng ổ cứng

| Mục đích | Dung lượng tối thiểu |
|----------|----------------------|
| Build cơ bản (Ubuntu) | 50 GB |
| Build tất cả backend | 120 GB (khuyến nghị) |
| Build thêm Machine Learning | 250 GB |

> **Lưu ý:** Ubuntu tối thiểu **22.04** trở lên.

> **Với i.MX 6UL:** Không cần build ML components, nên **120 GB là đủ**.

---

## Docker

- i.MX cung cấp script setup Docker tại repo **imx-docker** – xem readme để cài đặt host build machine bằng Docker.
- Docker on-board (chạy trên board) chỉ hỗ trợ **i.MX 8**, không áp dụng cho i.MX 6UL.

---

## Cài đặt Host Packages

Cài các package cần thiết cho Yocto Project build trên Ubuntu:

```bash
sudo apt-get install \
  build-essential chrpath cpio debianutils diffstat file gawk gcc git \
  iputils-ping libacl1 liblz4-tool locales python3 python3-git \
  python3-jinja2 python3-pexpect python3-pip python3-subunit socat \
  texinfo unzip wget xz-utils zstd efitools
```

> **Lưu ý về `grep`:** Công cụ cấu hình dùng phiên bản `grep` mặc định trên máy. Nếu có phiên bản `grep` khác trong `$PATH`, build có thể bị lỗi. Cách xử lý: đổi tên phiên bản đó thành tên không chứa từ `grep`.  