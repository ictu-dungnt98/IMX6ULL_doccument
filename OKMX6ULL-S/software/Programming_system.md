# 05 - Hệ Thống Lập Trình

Bo mạch phát triển **OKMX6ULL-S** hỗ trợ hai phương pháp nạp firmware: **OTG** và **thẻ SD**.

- Công cụ nạp firmware cho cả hai phương pháp nằm tại: `User Data/Linux/Flashing Tools`
- Người dùng có thể cập nhật **hình ảnh riêng lẻ** khi chỉ cần chỉnh sửa một phần.
- Khi gỡ lỗi nhân hệ điều hành, có thể sử dụng **cập nhật qua mạng** để tải ảnh xuống DRAM và chạy trực tiếp.

---

## 4.1 Hình Ảnh Cần Thiết Để Ghi

> **Lưu ý:**
> - **Bo mạch lõi NAND 256M**: Chỉ hỗ trợ hệ thống tập tin dạng **console** (không có Qt).
> - **Bo mạch lõi eMMC**: Hỗ trợ cả hệ thống tập tin **Qt** và **console**. Công cụ ghi mặc định sử dụng phiên bản Qt.
> - Đường dẫn ảnh gốc: `User Data\Linux\Image`

Bảng các hình ảnh cần ghi theo loại bo mạch:

| Hình ảnh | Bo mạch lõi eMMC | Bo mạch lõi NAND 256M |
|----------|------------------|----------------------|
| **Bootloader** | `u-boot-imx6ull14x14evk_emmc.imx` | `u-boot-imx6ull14x14evk_nand.imx` |
| **Kernel** | `zImage` | `zImage` |
| **Device Tree** | `okmx6ull-s-emmc.dtb` | `okmx6ull-s-nand.dtb` |
| **Logo** | `logo` | `logo` |
| **Filesystem** | `rootfs-console.tar` / `rootfs-qt.tar` | `rootfs-console.tar` |
| **Module files** | `modules.tar.bz2` *(giải nén vào filesystem khi ghi)* | `modules.tar.bz2` |

---

## 4.2 Hệ Thống Lập Trình Thẻ SD

> Lấy **OKMX6ULL-S+ (256M_256MNAND)** làm ví dụ để giải thích quy trình nạp NAND.
> Các bước thực hiện giống nhau cho tất cả phiên bản eMMC, nhưng phương pháp khởi động khác nhau.
> Tham khảo mục **1.3 Lập trình và Cài đặt Khởi động** để biết cài đặt công tắc DIP.

### 4.2.1 Tạo Thẻ Lập Trình SD

> ⚠️ **Lưu ý:** Vui lòng sử dụng **thẻ cơ chế ảo**, không phải thẻ cơ chế vật lý!

Đường dẫn công cụ ghi:
- NAND 256MB: `User Data\Linux\Burning Tools\nand-sdburn.tar.bz2`
- eMMC 4G/8G: `User Data\Linux\Burning Tools\emmc-sdburn.tar.bz2`

**Các bước thực hiện:**

**Bước 1:** Định dạng thẻ SD sang **FAT32** bằng công cụ định dạng.

**Bước 2:** Giải nén `nand-burnsd.zip` và sao chép vào thư mục trên Ubuntu, ví dụ:
```
/home/forlinx/work
```

**Bước 3:** Sử dụng đầu đọc thẻ USB để cắm thẻ SD vào máy tính.
> *Người dùng VMware: trỏ chuột vào biểu tượng USB bên dưới để kết nối ổ USB với máy ảo nếu không tự nhận diện.*

**Bước 4:** Sau khi máy ảo nhận diện thẻ SD, điều hướng đến thư mục và thực thi script:
```bash
cd /home/forlinx/work/nand-burnsd
sudo ./mksdburn.sh
```
Cửa sổ dòng lệnh sẽ hiển thị danh sách ổ đĩa. Chọn thẻ SD và nhấn Enter.

> 💡 **Mẹo:** Xác định ổ USB (sda/sdb/sdc) dựa trên dung lượng. Ví dụ: ổ 8GB có kích thước ≈ 7.761.920 KB. Không nên cắm nhiều ổ USB cùng lúc để tránh nhầm lẫn.

**Bước 5:** Sau khi tạo thành công, phân vùng khởi động sẽ chứa hai thư mục: `sdrun` và `target`.

---

### 4.2.2 Giới Thiệu Về Thẻ Lập Trình

> **Lưu ý:**
> - Hệ thống tập tin NAND 256M chỉ hỗ trợ phiên bản **Console**.
> - Hệ thống tập tin eMMC mặc định dùng phiên bản **Qt**. Để dùng Console, đổi tên `rootfs-console.tar.bz2` thành `rootfs.tar.bz2` và thay thế tệp cùng tên trong thư mục `target`.

Thẻ lập trình chứa hai thư mục:

- **`sdrun/`**: Dùng để khởi động và cập nhật hệ thống. Thông thường không cần chỉnh sửa.
- **`target/`**: Nội dung sẽ được ghi vào chip nhớ flash. Khi cần thay thế ảnh, chỉ cần thay tệp tương ứng trong thư mục này (giữ nguyên tên tệp).

Nội dung thư mục `target` của thẻ lập trình NAND SD:

| Tên tệp | Mô tả |
|---------|-------|
| `u-boot-imx6ull14x14evk_nand.imx` | Hình ảnh Bootloader |
| `zImage` | Hình ảnh Kernel |
| `okmx6ull-s-nand.dtb` | Hình ảnh Device Tree |
| `logo.bmp` | Hình ảnh logo khởi động *(định dạng BMP; xem Application Notes để thay thế)* |
| `rootfs-console.tar.bz2` | Hệ thống tập tin *(không có Qt)*; sau khi tạo mới, đổi tên thành `rootfs_nogup.tar.bz2` để thay thế |
| `modules.tar.bz2` | Các tệp mô-đun *(giải nén vào filesystem khi ghi)* |

---

### 4.2.3 Phương Pháp Ghi Dữ Liệu Vào Thẻ SD

1. Lắp thẻ SD đã chuẩn bị vào bo mạch.
2. Đặt công tắc DIP: **SW3, SW5, SW8 = BẬT** | **SW1, SW2, SW4, SW6, SW7 = TẮT** (chế độ ghi thẻ SD).
3. Bật nguồn — nội dung thư mục `target` sẽ được ghi vào bộ nhớ NAND Flash.

> Quá trình lập trình mất khá nhiều thời gian. Sau khi hoàn tất, cổng nối tiếp in thông báo xác nhận và **đèn LED1 nhấp nháy**.

4. Sau khi ghi xong, tắt nguồn và chuyển công tắc DIP sang chế độ khởi động NAND:
   - **SW4, SW5, SW8 = BẬT** | **SW1, SW2, SW3, SW6, SW7 = TẮT**
5. Bật nguồn lại để khởi động từ NAND Flash.

---

## 4.3 Hệ Thống Lập Trình OTG

### 4.3.1 Giới Thiệu Về Các Công Cụ Lập Trình OTG

> **Lưu ý:** Công cụ nạp firmware cho eMMC mặc định sử dụng hệ thống tập tin Qt. Để dùng Console, đổi tên `rootfs-console.tar.bz2` thành `rootfs-qt.tar.bz2` tại đường dẫn:
> `mfgtools\Profiles\Linux\OS Firmware\files\linux`

Công cụ sử dụng: **mfgtools** — do NXP phát triển, có thể nạp uboot, kernel, dtb, rootfs và các ảnh khác.

Đường dẫn gốc: `User Data\Linux\Flashing Tools\OTG Flashing\mfgtools`

| Tên tệp | Đường dẫn | Mô tả |
|---------|-----------|-------|
| `mx6ull-4gemmc-512mddr-qt5.6.vbs` | `mfgtools\` | Ghi ảnh cho bo mạch lõi **eMMC** |
| `mx6ull-256mnand-256mddr-cmd.vbs` | `mfgtools\` | Ghi ảnh cho bo mạch lõi **NAND 256M** |
| `ucl2.xml` | `mfgtools\Profiles\Linux\OS Firmware\` | Định nghĩa các bước nạp firmware; tham khảo để cập nhật một bước |
| Ảnh khởi động | `mfgtools\Profiles\Linux\OS Firmware\firmware\` | Dùng để khởi động và cập nhật; thường không cần chỉnh sửa |
| Ảnh ghi vào flash | `mfgtools\Profiles\Linux\OS Firmware\files\linux\` | Thay thế tệp cùng tên để ghi ảnh tùy chỉnh |

---

### 4.3.2 Phương Pháp Lập Trình OTG

> ⚠️ **Lưu ý:** Không lắp thẻ SD khi sử dụng chế độ lập trình OTG.

Đường dẫn công cụ: `User Data\Linux\Tools\OTG\mfgtools.rar`

Script tương ứng:
- `mx6ull-4gemmc-512mddr-qt5.6.vbs` → eMMC 4G + DDR 512M
- `mx6ull-256mnand-256mddr-cmd.vbs` → NAND 256M + DDR 256M

**Ví dụ: Ghi vào NAND Flash 256M**

**Bước 1:** Sao chép và giải nén công cụ Mfg vào thư mục cài đặt Windows:
```
User Data\Linux\Burning Tools\mfgtools.zip
```

**Bước 2:** Kết nối nguồn 5V.

**Bước 3:** Đặt công tắc DIP: **SW1, SW2 = BẬT** | các vị trí khác tùy ý (chế độ USB OTG).

**Bước 4:** Nhấp đúp vào `mx6ull-256mnand-256mddr-cmd.vbs`.

**Bước 5:** Lắp cáp USB OTG — thiết bị được tự động nhận dạng là **HID**.

**Bước 6:** Nhấp **"Start"** để bắt đầu nạp firmware.
> Nếu xuất hiện hộp thoại định dạng, nhấp **"Cancel"** hoặc bỏ qua cho đến khi quá trình hoàn tất.

**Bước 7:** Sau khi hoàn tất, màn hình hiển thị **"Done"** → nhấp **"Stop"** → nhấp **"Exit"**.

**Bước 8:** Tắt nguồn và chuyển công tắc DIP sang chế độ khởi động NAND:
- **SW4, SW5, SW8 = BẬT** | **SW1, SW2, SW3, SW6, SW7 = TẮT**

**Bước 9:** Bật nguồn lại để bắt đầu khởi động từ NAND Flash.

---

## 4.4 Cập Nhật Nhân Hệ Điều Hành Một Bước

### 4.4.1 Cập Nhật Hình Ảnh Riêng Lẻ Cho eMMC

Sau khi hệ thống khởi động, sao chép tệp cần cập nhật vào ổ USB, cắm vào bo mạch và liệt kê tệp:

```bash
ls /run/media/sda1/
```

**Cập nhật Uboot:**
```bash
# Ghi uboot vào eMMC boot partition
dd if=/run/media/sda1/u-boot-imx6ull14x14evk_emmc.imx of=/dev/mmcblk1 bs=1k seek=1
sync
reboot
```

**Cập nhật Kernel và Device Tree:**
```bash
# Sao chép zImage và dtb vào phân vùng boot
cp /run/media/sda1/zImage /boot/
cp /run/media/sda1/okmx6ull-s-emmc.dtb /boot/
sync
reboot
```
> Sau khi khởi động lại, chọn tệp dtb tương ứng trong giai đoạn uboot.

---

### 4.4.2 Cập Nhật Nhân Hệ Điều Hành NAND Một Bước

Sử dụng công cụ `kobs-ng` (do NXP cung cấp) để ghi uboot vào NAND Flash, và lệnh `nandwrite` để cập nhật DTB, kernel và logo.

Sao chép các tệp cần flash vào thư mục trên hệ thống tập tin (ví dụ: `/root`), sau đó thực hiện theo thứ tự sau:

**Cập nhật Uboot:**
```bash
flash_erase /dev/mtd0 0 0                                             # Xóa phân vùng uboot
kobs-ng init -x /run/media/mmcblk0p1/u-boot.imx                      # Ghi ảnh uboot
sync
reboot
```

**Cập nhật Kernel:**
```bash
flash_erase /dev/mtd4 0 0
nandwrite -p /dev/mtd4 /run/media/sda1/target/zImage
```

**Cập nhật DTB — Phiên bản 256M NAND:**
```bash
flash_erase /dev/mtd3 0 0
nandwrite -s 0x80000 -p /dev/mtd3 /run/media/sda1/target/okmx6ull-s-nand.dtb
```

**Cập nhật DTB — Phiên bản 1G NAND:**
```bash
flash_erase /dev/mtd3 0 0
nandwrite -p /dev/mtd3 /run/media/sda1/target/okmx6ull-s-1gnand.dtb
```

**Cập nhật Logo:**
```bash
flash_erase /dev/mtd1 0 0
nandwrite -p /dev/mtd1 /run/media/sda1/target/logo.bmp
```