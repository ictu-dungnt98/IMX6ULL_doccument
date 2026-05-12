# Linux Kernel Build Guide

> **Lưu ý:**
> - Sau khi giải nén mã nguồn kernel lần đầu tiên, cần biên dịch toàn bộ mã nguồn;
> - Sau khi biên dịch toàn bộ, có thể biên dịch riêng lẻ tùy theo tình huống thực tế.

Chuyển sang tài khoản root và giải nén mã nguồn kernel đã sao chép vào thư mục `/home/forlinx/work` bằng lệnh `tar`:

```bash
forlinx@ubuntu:~/work$ sudo su                          # Chuyển sang quyền root
[sudo] password for forlinx:                            # Nhập mật khẩu (không hiển thị)
root@ubuntu:/home/forlinx/work# tar xvf linux-4.1.15.tar.bz2   # Giải nén mã nguồn
root@ubuntu:/home/forlinx/work# cd linux-4.1.15        # Vào thư mục mã nguồn
```

Đặt lại biến môi trường sau khi chuyển tài khoản:

```bash
. /opt/fsl-imx-x11/4.1.15-2.0.0/environment-setup-cortexa7hf-neon-poky-linux-gnueabi
```

---

## 4.2.1 Biên dịch toàn bộ Kernel Linux-4.1.15

Trong thư mục mã nguồn có script biên dịch tên `build.sh`. Chạy script này sẽ biên dịch toàn bộ mã nguồn:

```bash
root@ubuntu:/home/forlinx/work# cd linux-4.1.15
root@ubuntu:/home/forlinx/work/linux-4.1.15# ./imx6ull_c_build.sh
```

Sau khi biên dịch thành công:
- Các file module với đuôi `.ko` sẽ được tạo ra.
- File `zImage` sẽ được tạo tại `linux-4.1.15/arch/arm/boot/`.
- Các file `.dtb` sẽ được tạo tại `linux-4.1.15/arch/arm/boot/dts/`.

### Giải thích các lệnh trong `build.sh`

| Lệnh | Mô tả |
|------|-------|
| `make imx6ull_defconfig` | Nạp file cấu hình vào `.config`. File cấu hình kernel là `linux-4.1.15/arch/arm/configs/imx6ull_defconfig`. Cần thực hiện bước này khi dùng mã nguồn lần đầu. Nếu dùng `menuconfig`, cần chạy lệnh này trước. Sau khi lưu và thoát giao diện đồ họa, cấu hình mới nhất sẽ được cập nhật vào file `.config`. |
| `make zImage` | Biên dịch `zImage`. Sau khi thành công, file `zImage` sẽ được tạo tại `linux-4.1.15/arch/arm/boot/`. |
| `make dtbs` | Biên dịch device tree. Tạo file `.dtb` tại `linux-4.1.15/arch/arm/boot/dts/`. |
| `make modules` | Biên dịch các module. |
| `make distclean` | Xóa `.config` hiện tại. Sau thao tác này cần cấu hình lại kernel. |

---

## 4.2.2 Biên dịch riêng zImage

Thực hiện trong thư mục mã nguồn kernel (yêu cầu biến môi trường đã được thiết lập):

```bash
root@ubuntu:/home/forlinx/work/linux-4.1.15# make imx6ull_defconfig
root@ubuntu:/home/forlinx/work/linux-4.1.15# make zImage
```

Sau khi biên dịch thành công, `zImage` sẽ được tạo tại `linux-4.1.15/arch/arm/boot/`.

---

## 4.2.3 Biên dịch riêng Device Tree

```bash
root@ubuntu:/home/forlinx/work/linux-4.1.15# make dtbs
```

Các file device tree sẽ được tạo tại `linux-4.1.15/arch/arm/boot/dts/`:

| File Device Tree | File được tạo | Mô tả |
|-----------------|--------------|-------|
| `okmx6ULL-C-emmc.dts` | `okmx6ULL-C-emmc.dtb` | Dành cho SoM eMMC |
| `okmx6ULL-C-nand.dts` | `okmx6ULL-C-nand.dtb` | Dành cho SoM 256M-NAND |

---

## 4.2.4 Biên dịch Module độc lập

```bash
root@ubuntu:/home/forlinx/work/linux-4.1.15# make modules
```

Sau khi biên dịch thành công, file `.ko` sẽ được tạo tại thư mục driver tương ứng.

Dùng lệnh sau để xuất các module ra thư mục chỉ định `/home/forlinx/work/`:

```bash
make modules_install INSTALL_MOD_PATH=/home/forlinx/work/
```

Sau đó nén và đóng gói các module thành `modules.tar.bz2`, rồi thay thế file tương ứng trong công cụ burning khi nạp firmware.

---

## 4.3 Tạo File System

> **Lưu ý:**
> - Forlinx cung cấp hai loại file system: phiên bản Qt (`rootfs-qt.tar.bz2`) và phiên bản console (`rootfs-console.tar.bz2`);
> - File system dùng cho từng SoM khác nhau — xem phần mô tả trong tài liệu phần mềm.

Ví dụ với `rootfs-console.tar.bz2`:

### Bước 1: Tạo thư mục chứa rootfs

```bash
forlinx@ubuntu:~/work$ sudo mkdir rootfs
forlinx@ubuntu:~/work$ cd rootfs/
```

### Bước 2: Sao chép và giải nén file system

```bash
forlinx@ubuntu:~/work/rootfs$ sudo cp ../rootfs-console.tar.bz2 ./
forlinx@ubuntu:~/work/rootfs$ sudo tar xvf rootfs-console.tar.bz2
```

### Bước 3: Xóa file nén gốc

```bash
forlinx@ubuntu:~/work/rootfs$ sudo rm rootfs-console.tar.bz2
```

### Bước 4: Nén lại file system sau khi chỉnh sửa

Sau khi thực hiện các thay đổi cần thiết, dùng lệnh `tar` để nén lại. Nếu dùng tài khoản thường, cần dùng `fakeroot` để giả lập quyền root và tránh thay đổi quyền file:

```bash
forlinx@ubuntu:~/work/rootfs$ sudo fakeroot tar cvjf rootfs-console.tar.bz2 *
```

Dùng lệnh `ls` để kiểm tra file `rootfs-console.tar.bz2` đã được tạo — đây là file image filesystem có thể nạp vào bộ nhớ flash của board phát triển.