# 02 - Khởi Động Nhanh

---

## 2.1 Chuẩn Bị Trước Khi Bật Nguồn

Bo mạch phát triển **OKMX6ULL-S** cung cấp hai phương thức đăng nhập hệ thống: đăng nhập qua **cổng nối tiếp** và đăng nhập qua **mạng**.

Chuẩn bị phần cứng trước khi khởi động hệ thống:

- Dây nguồn DC 5V 3A
- Cáp nối tiếp gỡ lỗi *(để đăng nhập qua cổng nối tiếp)*
  - Bo mạch phát triển có một cổng nối tiếp gỡ lỗi DB9 đực. Người dùng có thể sử dụng cáp nối tiếp chéo với hai đầu nối cái hoặc cáp nối tiếp USB sang RS232 để kết nối bo mạch phát triển với máy tính.
- Cáp mạng *(để đăng nhập mạng)*

> **Kiểm tra công tắc DIP chế độ khởi động:** Vui lòng kiểm tra các công tắc DIP trên bo mạch phát triển để đảm bảo chúng được đặt ở chế độ khởi động mong muốn. Tham khảo mục **1.3 Lập trình và cài đặt khởi động** để biết thêm chi tiết.

---

## 2.2 Phương Thức Đăng Nhập Qua Cổng Nối Tiếp

### 2.2.1 Đăng Nhập Qua Cổng Nối Tiếp

> **Lưu ý:**
> - Cài đặt cổng nối tiếp: **Tốc độ Baud 115200, 8 bit dữ liệu, 1 bit dừng, không kiểm tra chẵn lẻ, không điều khiển luồng.**
> - Đăng nhập bằng terminal sử dụng tài khoản **root**, không cần mật khẩu.
> - Yêu cầu phần mềm: Hệ điều hành Windows cần cài đặt phần mềm HyperTerminal hoặc bất kỳ phần mềm terminal nối tiếp nào quen thuộc.

Phần sau sử dụng **PuTTY** làm ví dụ:

**Bước 1:** Kết nối bo mạch phát triển với máy tính bằng cáp nối tiếp. Xác nhận số cổng nối tiếp trong **"Trình quản lý thiết bị"** của Windows.

**Bước 2:** Mở PuTTY và cấu hình. Chọn đúng cổng COM của máy tính và đặt tốc độ baud là **115200**.

**Bước 3:** Đăng nhập với tên tài khoản **root**, không có mật khẩu.

**Bước 4:** Xem thông tin phiên bản nhân hệ điều hành. Thông tin hiển thị xác nhận bo mạch chủ chứa ảnh hệ điều hành **Linux 4.1.15**.

### 2.2.2 Các Sự Cố Thường Gặp Khi Đăng Nhập Cổng Nối Tiếp

- Nếu máy tính không có cổng nối tiếp, có thể sử dụng cáp **USB-to-serial** (yêu cầu cài đặt trình điều khiển tương ứng).
- Nên sử dụng cáp nối tiếp chất lượng cao để tránh hiện tượng nhiễu ký tự.

---

## 2.3 Phương Thức Đăng Nhập Mạng

### 2.3.1 Kiểm Tra Kết Nối Mạng

> **Lưu ý về địa chỉ IP mặc định:**
> - **Hệ thống tệp Console:** `eth0` → `192.168.0.232` | `eth1` → `192.168.1.232`
>   - Để thay đổi: chỉnh sửa tệp `/etc/network/interfaces`
> - **Hệ thống tệp Qt:** Sử dụng địa chỉ IP động theo mặc định.
>   - Để đặt IP tĩnh, thêm lệnh sau vào `/etc/rc.local`:
>     ```
>     ifconfig eth0 192.168.0.232
>     ```

Ví dụ kiểm tra kết nối với card mạng `eth0` (IP máy tính thử nghiệm: `192.168.0.58`):

1. Kết nối chân `eth0` của bo mạch với máy tính bằng cáp mạng, bật nguồn bo mạch. Sau khi nhân khởi động, đèn báo màu xanh lam sẽ nhấp nháy.
2. Tắt tường lửa của máy tính và mở cửa sổ lệnh **cmd**.
3. Sử dụng lệnh `ping` để kiểm tra trạng thái kết nối giữa máy tính và bo mạch phát triển.

Nếu dữ liệu được trả về, kết nối mạng hoạt động bình thường.

### 2.3.2 SSH

> **Thông tin đăng nhập SSH mặc định:**
> - Tài khoản: `root`
> - Mật khẩu: *(không có)*
> - SSH sử dụng **Dropbear** — một máy chủ và máy khách SSH nhỏ gọn.

**Truy cập từ máy chủ Linux:**

Cấu hình ví dụ:
- Máy chủ Linux: IP `192.168.0.27`, tên người dùng `forlinx`, hostname `ubuntu`
- Bo mạch phát triển: IP `192.168.0.232`, tên người dùng `root`, hostname `fl-imx6ull`

1. Đảm bảo máy chủ Linux đã cài đặt và kích hoạt dịch vụ SSH.
2. Kiểm tra trạng thái kết nối mạng giữa máy chủ Linux và bo mạch.
3. Truy cập bo mạch từ máy chủ Linux qua SSH.
4. Thoát khỏi phiên SSH khi hoàn tất.

**Truy cập từ máy chủ Windows:**

Nhấp vào **"Mở"**, hộp thoại xác nhận sẽ hiện ra. Nhấp **"Có"** để vào giao diện đăng nhập.

---

## 2.4 Lựa Chọn Màn Hình

Nền tảng **OKMX6ULL-S** hỗ trợ các loại màn hình sau:

- Màn hình cảm ứng điện trở: **4,3 inch / 5,6 inch / 7 inch / 8 inch / 10,4 inch**
- Màn hình cảm ứng điện dung: **7 inch**
- Màn hình LVDS: **10,1 inch**

> **Mặc định:** Màn hình LCD 7 inch, độ phân giải **1024x600**.

> ⚠️ **Lưu ý:** Khi sử dụng màn hình cảm ứng điện trở Flylink 10,4 inch (800x600), vui lòng tham khảo mục **3.1.13.3 Cảm ứng**. Mặc định là màn hình 8 inch, độ phân giải 800x600, cảm ứng điện trở.

Có thể lựa chọn màn hình thông qua **menu U-boot** trong quá trình khởi động:

1. Mở PuTTY, bật nguồn bo mạch và nhấn **phím cách** để truy cập menu U-boot.
2. Các tùy chọn trong menu chính:

| Số thứ tự | Chức năng |
|-----------|-----------|
| `1` | Vào giao diện chọn màn hình *(mặc định: LCD 7 inch - 1024x600)* |
| `2` | Truy cập giao diện cài đặt hiệu chỉnh màn hình |
| `9` | Vào chế độ dòng lệnh khởi động |
| `0` | Thực hiện thao tác đặt lại |

- Nhấn **`1`** → Menu chọn màn hình (Switch Panel): cột 1 = số thứ tự, cột 2 = độ phân giải, cột 3 = kích thước & loại (`c` = điện dung, `r` = điện trở).
- Nhấn **`2`** → Menu kích hoạt hiệu chỉnh cảm ứng.

> ⚠️ **Lưu ý:** Nếu sử dụng màn hình thích ứng của nhà sản xuất, **"Menu lựa chọn màn hình"** sẽ không thể truy cập được.

---

## 2.5 Hiệu Chỉnh Cảm Ứng

Sau khi nạp hệ thống tệp Qt, màn hình LCD cần được hiệu chỉnh trong **lần khởi động đầu tiên** bằng cách chạm vào các vị trí **"+"** trên màn hình theo trình tự. Giao diện hiệu chỉnh sẽ không xuất hiện ở các lần khởi động tiếp theo.

### 2.5.1 Chỉnh Sửa Lại Hiệu Chỉnh *(Chỉ hỗ trợ phiên bản eMMC)*

**Phương pháp 1:**

Thực hiện lệnh xóa tệp hiệu chuẩn gốc, sau đó reset phần cứng hoặc khởi động lại phần mềm và làm theo hướng dẫn để hiệu chỉnh lại.

**Phương pháp 2:**

Sử dụng chương trình QT **"Calibrate Touchscreen"**:

1. Sau khi bo mạch khởi động, màn hình hiển thị giao diện desktop QT mặc định.
2. Nhấp vào **Forlinx** trên thanh menu → chọn **Tiện ích**.
3. Chọn **Calibrate Touchscreen** để vào giao diện hiệu chỉnh.
4. Chạm vào các vị trí **"+"** trên màn hình theo trình tự để hoàn tất.

---

## 2.6 Phân Vùng Hệ Thống

### Phân vùng eMMC 4GB

| Phân vùng | Tên | Offset | Kích thước | Hệ thống tệp | Nội dung |
|-----------|-----|--------|------------|--------------|----------|
| `/dev/mmcblk1boot0` | Bootloader *(Boot Partition)* | 1KB | 2MB | RAW | U-Boot |
| `/dev/mmcblk1p1` | Kernel *(Kernel Boot)* | 10MB | 500MB | FAT | Kernel, DTB, v.v. |
| `/dev/mmcblk1p2` | Filesystem Partition | Sau Boot | Còn lại | ext3 | Root Filesystem |

> *Mức sử dụng ổ đĩa và bộ nhớ chỉ mang tính tham khảo; vui lòng kiểm tra thông số thực tế.*

### Phân vùng NandFlash 256MB

| Phân vùng | Tên | Kích thước | Nội dung |
|-----------|-----|------------|----------|
| `/dev/mtd0` | Bootloader *(Boot Partition)* | 4MB | U-Boot |
| `/dev/mtd1` | Logo Partition | 2MB | Logo |
| `/dev/mtd2` | Environment | 1MB | ENV |
| `/dev/mtd3` | Device Tree Partition | 3MB | DTB |
| `/dev/mtd4` | Kernel *(Kernel Boot)* | 8MB | Kernel |
| `/dev/mtd5` | Filesystem Partition | 238MB | Filesystem |

### Kiểm tra dung lượng ổ đĩa

```bash
root@fl-imx6ull:~# df -m
Filesystem           1M-blocks      Used Available Use% Mounted on
/dev/root                  236       133       104  56% /
devtmpfs                   112         0       112   0% /dev
tmpfs                      112         0       112   0% /run
tmpfs                      112         0       112   0% /var/volatile
root@fl-imx6ull:~#
```

### Kiểm tra mức sử dụng bộ nhớ

```bash
root@fl-imx6ull:~# free
             total       used       free     shared    buffers     cached
Mem:        230312      31640     198672       176           0       11788
-/+ buffers/cache:      19852     210460
Swap:            0          0          0
root@fl-imx6ull:~#
```

---

## 2.7 Tắt Hệ Thống

Trong điều kiện bình thường, chỉ cần tắt nguồn là đủ. Tuy nhiên, nếu có liên quan đến việc **lưu trữ dữ liệu** hoặc các thao tác chức năng khác, không nên ngắt nguồn đột ngột để tránh làm hỏng dữ liệu không thể phục hồi.

Để đảm bảo ghi dữ liệu hoàn chỉnh, hãy nhập lệnh `sync` để đồng bộ hóa dữ liệu **trước khi tắt nguồn**:

```bash
sync
```

> ⚠️ **Lưu ý:** Nếu sản phẩm gặp sự cố mất điện đột ngột khiến hệ thống tắt bất thường, có thể tích hợp **biện pháp bảo vệ chống mất điện** vào thiết kế phần cứng.