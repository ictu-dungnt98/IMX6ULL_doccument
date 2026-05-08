# 03 - Kiểm Tra Chức Năng Dòng Lệnh Của Bo Mạch Phát Triển

> **Lưu ý:** Bo mạch chủ hỗ trợ nhiều chức năng, không chỉ giới hạn ở những chức năng được đề cập trong tài liệu này. Feiling chỉ kiểm tra và xác minh các chức năng được liệt kê. Các chức năng không được đề cập không được đảm bảo; người dùng có thể tự kiểm tra và xác minh.

Chương này chủ yếu giải thích cách sử dụng giao diện mở rộng bên ngoài của bo mạch phát triển.

---

## 3.1 Kiểm Tra Chức Năng Dòng Lệnh

> **Đường dẫn mã nguồn chương trình kiểm thử:** `User Profile/Linux/Test Program Source Code`
> Các chương trình kiểm thử đã được tích hợp sẵn trong bản demo của Feiling.

---

### 3.1.1 Kiểm Tra Trình Điều Khiển Thẻ SDHC/MMC

> **Lưu ý:**
> - Hệ thống tệp NTFS không được hỗ trợ. Nên định dạng thẻ SD sang **FAT32** trước khi sử dụng.
> - Thẻ SD được gắn kết trong thư mục `/run/media` và hỗ trợ **cắm nóng**.
> - Đã kiểm thử với thẻ nhớ **SanDisk 8GB**.

**Các bước thực hiện:**

1. Lắp thẻ nhớ SD 8GB vào khe cắm. Sau khi nhận diện thành công, tên thiết bị sẽ hiển thị trong thông tin in.

2. Xem các tệp trong thư mục gắn kết `/run/media`:
   - `mmcblk0p1` là tên tệp sau khi thẻ SD được gắn kết.

3. Xem các tập tin trên thẻ SD bằng lệnh `ls`.

4. Ghi một tập tin vào thẻ SD:
   ```bash
   echo 1 > /run/media/mmcblk0p1/test.txt
   cat /run/media/mmcblk0p1/test.txt
   ```

5. Sau khi sử dụng, dùng lệnh `umount` để gỡ thẻ SD trước khi tháo.

> ⚠️ **Lưu ý:** Hãy thoát khỏi đường dẫn gắn thẻ SD trước khi lắp hoặc tháo thẻ.

---

### 3.1.2 Kiểm Tra Giao Diện USB

#### 3.1.2.1 Kiểm Tra Lưu Trữ USB HOST

> **Lưu ý:**
> - Hỗ trợ cắm nóng chuột, bàn phím USB và ổ USB flash.
> - Nên định dạng ổ USB sang **FAT32**.
> - Dung lượng hỗ trợ tối đa đã kiểm thử: **32GB**.
> - Ổ USB được gắn kết trong thư mục `/run/media`.

Bo mạch có **ba cổng USB HOST**, bất kỳ cổng nào cũng có thể dùng để thử nghiệm.

1. Cắm ổ USB; thông tin nhận diện sẽ hiển thị trên terminal.

2. Kiểm tra thiết bị — tên thiết bị sau khi gắn kết là `sda1`:
   ```bash
   ls /run/media/sda1
   ```

3. Ghi và đọc tệp:
   ```bash
   echo 2 > /run/media/sda1/test.txt
   cat /run/media/sda1/test.txt
   ```

4. Sau khi sử dụng, dùng lệnh `umount` để ngắt kết nối trước khi rút.

#### 3.1.2.2 Kiểm Tra OTG sang HOST

Kết nối ổ USB với cổng OTG bằng **cáp OTG sang Host** để đọc nội dung trên ổ USB.

#### 3.1.2.3 Kiểm Tra Giao Diện USB OTG g_mass_storage

Kết nối ổ USB flash hoặc thẻ SD với bo mạch phát triển, sửa đổi tham số `file=xxx` (ví dụ: `file=/dev/mmcblk0p1`), sau đó kết nối giao diện OTG với máy tính.

```bash
# Tải module
modprobe g_mass_storage file=/dev/mmcblk0p1

# Gỡ module
modprobe -r g_mass_storage
```

#### 3.1.2.4 Kiểm Tra Camera USB

> **Lưu ý:** Sản phẩm hỗ trợ camera USB **Webcam C270**.

1. Trước khi cắm camera, kiểm tra trạng thái USB và nút thiết bị:
   ```bash
   lsusb
   ls /dev/video*
   ```

2. Cắm camera USB và kiểm tra lại — thiết bị mới sẽ xuất hiện (ví dụ: `video2`).

3. Xem độ phân giải và tốc độ khung hình được hỗ trợ:
   ```bash
   cd /forlinx/cmdbin/
   ./luvcview -d /dev/video2 -L
   ```

4. Chụp ảnh ở chế độ **YUV**:
   ```bash
   ./luvcview -d /dev/video2 -f yuv -s 800x448 -i 25
   ```

5. Chụp ảnh ở chế độ **MJPEG** (đồng thời ghi video `xxx.avi`):
   ```bash
   ./luvcview -d /dev/video2 -f jpg -s 800x448 -i 30
   ```

---

### 3.1.3 Kiểm Tra Mạng Có Dây

#### 3.1.3.1 Kiểm Tra Lệnh Cơ Bản IPv4

> **Lưu ý:**
> - OKMX6ULL-S có hai card mạng: **eth0** và **eth1**.
> - **eth1 và eth0 không thể dùng trên cùng một mạng cục bộ.**

| Tấm đế (in lụa) | Thiết bị phần mềm |
|-----------------|-------------------|
| NET1 | eth1 |
| NET2 | eth0 |

**Địa chỉ IP mặc định:**
- Hệ thống tệp Console: `eth0` = `192.168.0.232`, `eth1` = `192.168.1.232` → chỉnh sửa `/etc/network/interfaces`
- Hệ thống tệp Qt: `eth0` = `192.168.0.232`, `eth1` = `192.168.2.232` → thêm vào `/etc/autorun.sh`:
  ```bash
  ifconfig eth0 192.168.10.232
  ```

**Các lệnh cơ bản (ví dụ với eth0):**

```bash
# Thiết lập địa chỉ IP tĩnh
ifconfig eth0 192.168.1.120

# Cấp phát IP động qua DHCP
udhcpc -i eth0

# Thay đổi địa chỉ MAC
ifconfig eth0 hw ether XX:XX:XX:XX:XX:XX

# Đặt mặt nạ mạng con
ifconfig eth0 netmask 255.255.255.0

# Đặt địa chỉ broadcast
ifconfig eth0 broadcast 192.168.1.255

# Thêm/xóa cổng mặc định
route add default gw 192.168.1.1
route del default gw 192.168.1.1

# Tắt/bật card mạng
ifconfig eth0 down
ifconfig eth0 up
```

#### 3.1.3.2 Kiểm Tra IPv6

1. Thiết lập địa chỉ IPv6 (ví dụ với eth1).

2. Cấu hình IPv6 trên máy tính:
   - Vào **Control Panel → Network and Internet → Change adapter settings**
   - Chọn **Ethernet** → chuột phải → **Properties**
   - Tắt IPv4, bật IPv6, cấu hình địa chỉ IPv6

3. Kết nối bo mạch và máy tính trực tiếp bằng cáp Ethernet, kiểm tra bằng lệnh `ping6`.

#### 3.1.3.3 Kiểm Tra Kết Nối USB với Mạng

1. Cắm bộ chuyển đổi **USB sang Ethernet** vào cổng USB.
2. Tham khảo phương pháp thử nghiệm IPv4 cơ bản.

---

### 3.1.4 Các Dịch Vụ Liên Quan Đến Ethernet

#### 3.1.4.1 Dịch Vụ FTP

> **Lưu ý:**
> - Tài khoản: `root`, không có mật khẩu mặc định.
> - Địa chỉ IP mặc định `eth0`: `192.168.0.232`.

1. Đặt mật khẩu cho tài khoản root (ví dụ: `forlinx`):
   ```bash
   passwd root
   ```

2. Đăng nhập bằng **FileZilla** trên máy tính:
   - Tạo "Trang web mới"
   - Nhập địa chỉ IP bo mạch làm máy chủ
   - Phương thức mã hóa: **FTP dạng văn bản thuần**
   - Loại đăng nhập: **Thông thường**
   - Nhập tên người dùng và mật khẩu → nhấp **Kết nối**

#### 3.1.4.2 Kiểm Thử SSH Client

> **Lưu ý:**
> - Hệ thống tệp Console: `eth0` = `192.168.10.232`, `eth1` = `192.168.1.232`
> - Hệ thống tệp Qt: `eth0` = `192.168.10.232`, `eth1` = `192.168.2.232`

Cấu hình ví dụ:
- Bo mạch phát triển: `192.168.0.232`
- Máy chủ Linux (Ubuntu): IP `192.168.0.149`, tên người dùng `forlinx`

```bash
# Truy cập máy chủ Linux từ bo mạch phát triển
ssh forlinx@192.168.0.149
```

---

### 3.1.5 Kiểm Tra Mạng Không Dây

#### 3.1.5.1 Kiểm Tra WIFI

**Các mô-đun WiFi được hỗ trợ:**

| Mô-đun | Hỗ trợ |
|--------|--------|
| RTL8188EUS | WiFi |
| RTL8723BU | WiFi |
| RTL8723DU | WiFi |

##### 3.1.5.1.1 Hướng Dẫn Sử Dụng USB WIFI RTL8188EUS

> **Lưu ý:** Card mạng USB WIFI là **mô-đun tùy chọn**. Liên hệ nhân viên bán hàng Feiling nếu cần.

**Bước 1:** Bật nguồn và khởi động hệ thống Linux.

**Bước 2:** Kết nối USB WIFI vào cổng USB HOST.

**Bước 3:** Kết nối mạng WiFi:
```bash
wifi.sh -i wlan0 -s <Tên_AP> -p <Mật_khẩu>
# Nếu không có mật khẩu:
wifi.sh -i wlan0 -s <Tên_AP> -p NONE
```
> Bộ định tuyến sử dụng mã hóa WPA. Xem `wifi.sh` để biết chi tiết.

**Bước 4:** Sau khi script chạy xong, hệ thống tự động gán IP và DNS.

**Bước 5:** Kiểm tra kết nối:
```bash
ping 8.8.8.8
ping www.google.com
```

**Bước 6:** Gỡ bỏ mô-đun khỏi nhân:
```bash
rmmod 8188eu
```

##### 3.1.5.1.2 Sử Dụng WIFI Tích Hợp (RTL8723BU/DU)

> **Lưu ý:**
> - Tần số WiFi: **2.4GHz**
> - Tương thích với cả trình điều khiển **8723bu** và **8723du**
> - Bộ định tuyến mặc định sử dụng mã hóa WPA

**Bước 1:** Hàn mô-đun vào bo mạch và kết nối ăng-ten.

**Bước 2:** Bật nguồn và kiểm tra trạng thái tải mô-đun:
```bash
lsmod
# Hiển thị "8723du" nếu dùng IC 8723du
```

**Bước 3 — Chế độ STA (kết nối như trạm):**
```bash
wifi.sh -i wlan0 -s <Tên_AP> -p <Mật_khẩu>
ping www.baidu.com
```

**Kiểm tra cường độ tín hiệu WiFi:**
```bash
iwconfig wlan0
```

**Chế độ AP:**

> **Lưu ý:** Hỗ trợ tối đa **8 người dùng** kết nối. Cần đảm bảo `eth0` kết nối được mạng bên ngoài trước.

```bash
# Cấu hình IP Ethernet và tường lửa
ifconfig eth0 192.168.0.232

# Bật AP (SSID và mật khẩu cấu hình trong hostapd.conf)
hostapd /etc/hostapd.conf &
```

Thông tin kết nối mặc định:
- **Tên AP:** `forlinxtest`
- **Mật khẩu:** `1234567890`

**Bước 4:** Gỡ bỏ mô-đun:
```bash
rmmod 8723du
```

#### 3.1.5.2 Mô-đun 4G Truy Cập Internet

> **Lưu ý:**
> - Hỗ trợ module 4G: **Huawei ME909** và **Quectel EC20**
> - Bo mạch mở rộng USB 4G là **mô-đun tùy chọn**

##### 3.1.5.2.1 Kiểm Tra 4G Huawei ME909S

1. Cắm bo mạch mở rộng USB 4G, lắp mô-đun ME909s-821, ăng-ten IPEX và thẻ SIM, bật nguồn.

2. Kiểm tra trạng thái USB và nút thiết bị:
   ```bash
   lsusb
   ls /dev/ttyUSB*
   ```

3. Thực hiện kết nối internet quay số.

4. Kiểm tra sau khi kết nối:
   ```bash
   ping www.baidu.com
   ```

5. Ngắt kết nối và đặt lại mô-đun:
   ```bash
   # Ngắt kết nối
   # Đặt lại và khởi động lại mô-đun
   ```

6. Cấu hình APN theo nhà mạng trong `fltest_cmd_me909.sh`:
   - **China Mobile:** `cmnet`
   - **China Unicom:** `3gnet`
   - **China Telecom:** `ctnet`

##### 3.1.5.2.2 Kiểm Thử Mô-đun EC20

> **Lưu ý:**
> - Khi dùng thẻ IoT, cần xác nhận **phiên bản firmware** của mô-đun (phiên bản thấp cần nâng cấp).
> - Script quay số `quectel-CM` nằm trong `/usr/bin`.
> - Xem hướng dẫn tham số: `quectel-CM --help`

1. Kiểm tra trạng thái USB:
   ```bash
   lsusb
   ls /dev/ttyUSB*
   ```

2. Quay số EC20 và kiểm tra kết nối:
   ```bash
   quectel-CM &
   ping www.baidu.com
   ```

#### 3.1.5.3 Kiểm Tra Mô-đun GPRS

> **Lưu ý:** Mô-đun GPRS kết nối qua **cổng nối tiếp**. Tính năng này **chưa được tích hợp trong phiên bản NAND** của hệ thống tập tin.

1. Kết nối mô-đun và bo mạch qua **UART3**, bật nguồn và nhập lệnh kiểm tra.

2. Nếu kết nối thành công, kiểm tra bằng lệnh ping:
   ```bash
   ping www.baidu.com
   ```
   > Nếu ping thất bại do cấu hình mạng trước đó, cần chạy lệnh reset mạng trước.

---

### 3.1.6 Kiểm Tra Watchdog (Giám Sát)

Bộ định thời giám sát (watchdog) được **vô hiệu hóa theo mặc định** trong cả uboot và kernel.

**Trong giai đoạn Uboot:**
- Nhấn phím cách khi bật nguồn → vào menu uboot → nhập `0` để vào dòng lệnh.

**Sau khi vào hệ thống:**

| Tham số | Ý nghĩa | Lưu ý |
|---------|---------|-------|
| `settimeout` | Kích hoạt watchdog, đặt thời gian reset, không cấp dữ liệu | Thời gian reset > 2 giây |
| `keepalive` | Kích hoạt watchdog, cấp dữ liệu mỗi 2 giây | Thời gian reset > 2 giây |

> ⚠️ Chỉ sử dụng **một trong hai tham số**. Kiểm tra bằng lệnh `ps` để đảm bảo chỉ có một tiến trình `fltest_wdt`.

```bash
# Đặt thời gian chờ 60 giây trước khi khởi động lại
fltest_wdt settimeout 60

# Cho chó ăn mỗi 2 giây (nếu dừng, hệ thống sẽ khởi động lại)
fltest_wdt keepalive 10 &
```

---

### 3.1.7 Kiểm Tra Trình Điều Khiển Đồng Hồ RTC

> **Lưu ý:** Đảm bảo **pin cúc áo** đã được lắp vào bo mạch và điện áp bình thường.

```bash
# Thiết lập thời gian phần mềm
date -s "2024-07-16 10:00:00"

# Ghi vào RTC phần cứng
hwclock -w

# Sau khi tắt/bật lại bo mạch, kiểm tra thời gian hệ thống
date
```

---

### 3.1.8 Kiểm Tra Âm Thanh/Video

OKMX6ULL-S sử dụng chip âm thanh **WM8960** hoặc **NAU88C22**, kết hợp khung âm thanh **ALSA**.

> - Bo mạch **OKMX6ULx-S V1.2** → Xem mục **3.1.8.1.1** (chip WM8960)
> - Bo mạch **OKMX6ULx-S V3.0** → Xem mục **3.1.8.1.2** (chip NAU88C22)

Bo mạch cung cấp hai đầu vào micro:
- **MIC1**: Micro tích hợp (mặc định)
- **CON25**: Giắc cắm stereo 3,5mm (khi cắm micro ngoài, MIC1 tự động ngắt)

#### 3.1.8.1.1 Kiểm Tra Chip Âm Thanh WM8960

```bash
# 1. Thiết lập tham số âm thanh
amixer ...

# 2. Phát lại âm thanh
aplay /forlinx/audio/test.wav

# 3. Ghi âm
# -r: tần số lấy mẫu | -f: định dạng | -c: kênh | -d: thời gian
arecord -r 44100 -f S16_LE -c 2 -d 10 record.wav

# 4. Phát bản ghi âm
aplay record.wav
```

#### 3.1.8.1.2 Kiểm Tra Chip Âm Thanh NAU88C22

```bash
# Tham khảo các lệnh tương tự chip WM8960
# Xem thêm: arecord --help
```

#### 3.1.8.2 Kiểm Tra Loa

Chip WM8960 tích hợp khuếch đại Class D, đầu ra qua **CON16** và **CON17** (XH2.54-2P), hỗ trợ loa **8Ω, công suất tối đa 1W**.

> ⚠️ Không cắm tai nghe khi kiểm tra loa.

#### 3.1.8.3 Kiểm Tra Phát Lại Video

```bash
# -fs: toàn màn hình | -vo fbdev: dùng Framebuffer
mplayer -fs -vo fbdev /forlinx/video/test.mp4
# Nhấn Ctrl+C để dừng
```

> **Lưu ý:** Do CPU không có bộ giải mã phần cứng, độ phân giải và tốc độ khung hình khi phát video bị giới hạn.

---

### 3.1.9 Kiểm Tra CMOS-OV9650

> **Lưu ý:**
> - Hỗ trợ độ phân giải: **320x240** và **640x480** (không hỗ trợ 1280x1024)
> - Hỗ trợ chụp ảnh và xem trước; **không hỗ trợ lấy nét tự động**
> - Giao diện song song 8-bit (DVP), kết nối qua ổ cắm 2.0mm 20P **CON23**

```bash
# Kiểm tra mô-đun đã tải chưa
lsmod | grep ov9650

# Tải thủ công nếu chưa có
modprobe mx6s_capture
modprobe ov9650_camera

# Chụp ảnh (màn hình 4.3 inch)
fltest_ov9650 capture ...

# Xem trước (màn hình 4.3 inch)
fltest_ov9650 preview ...
```

---

### 3.1.10 Kiểm Tra Cổng Nối Tiếp UART

> **Lưu ý:**
> - **UART1**: Dùng để gỡ lỗi (RS232 tích hợp)
> - **UART2** và **UART3**: Cổng nối tiếp thông thường
> - Tốc độ truyền tối đa đã kiểm thử: **256000 baud**
> - Hỗ trợ **7 hoặc 8 bit** dữ liệu, **1 hoặc 2 bit** dừng
> - Hỗ trợ điều khiển luồng phần cứng và kiểm tra chẵn lẻ

| Tấm đế (in lụa) | Thiết bị phần mềm |
|-----------------|-------------------|
| UART2 | ttymxc1 |
| UART3 | ttymxc2 |

**Các bước kiểm tra UART2:**

1. Kết nối UART2 với máy tính qua mô-đun **TTL sang USB**.
2. Mở tiện ích cổng nối tiếp trên máy tính: Baud **115200**, 8 bit dữ liệu, 1 bit dừng, không chẵn lẻ, không điều khiển luồng. Gửi chuỗi `"abcdefg"` mỗi 1 giây.
3. Chạy chương trình kiểm tra trên bo mạch — sẽ tự động gửi chuỗi `"abcdefgh"`.

---

### 3.1.11 Kiểm Tra USB sang Cổng Nối Tiếp Bốn Chiều

> **Lưu ý:**
> - Hỗ trợ chip chuyển đổi **XR21V1414**
> - Là **mô-đun tùy chọn**; liên hệ Feiling nếu cần

1. Kết nối mô-đun qua USB HOST — terminal in thông tin nhận diện.
2. Kiểm tra USB:
   ```bash
   lsusb
   ls /dev/ttyUSB*
   ```
3. Tham khảo phương pháp thử nghiệm tại mục **3.1.10 Kiểm tra UART**.

---

### 3.1.12 Kiểm Tra FlexCAN

Kết nối **CAN1** và **CAN2** trên bo mạch: H nối H, L nối L.

```bash
# Cấu hình CAN1 (baud rate 125000)
ip link set can0 type can bitrate 125000
ip link set can0 up

# Cấu hình CAN2 (baud rate 125000)
ip link set can1 type can bitrate 125000
ip link set can1 up

# CAN2 nhận dữ liệu
candump can1 &

# CAN1 truyền dữ liệu
cansend can0 123#DEADBEEF
```

---

### 3.1.13 Kiểm Tra Màn Hình LCD

#### 3.1.13.1 Màn Hình

Chọn kích thước và độ phân giải từ **menu uboot**. Màn hình bình thường khi: không có độ lệch dọc/ngang, màu sắc chính xác, không nhấp nháy.

#### 3.1.13.2 Kiểm Tra Đèn Nền

```bash
# Xem giá trị đèn nền tối đa (7)
cat /sys/class/backlight/*/max_brightness

# Xem giá trị đèn nền hiện tại (6)
cat /sys/class/backlight/*/brightness

# Đặt giá trị đèn nền (ví dụ: 3)
echo 3 > /sys/class/backlight/*/brightness
```

#### 3.1.13.3 Cảm Ứng

```bash
# Xem danh sách thiết bị đầu vào
cat /proc/bus/input/devices
# goodix-ts: cảm ứng điện dung
# iMX6UL: cảm ứng điện trở
```

> ⚠️ **Lưu ý:** Màn hình điện trở **8 inch (800x600)** và **10,4 inch (800x600)** có hướng cảm ứng khác nhau. Nếu dùng màn hình 10,4 inch, cần hoán đổi trục X và Y:

```bash
# Hoán đổi trục cảm ứng cho màn hình 10.4 inch
xinput set-prop "iMX6UL Touchscreen Controller" "Evdev Axes Swap" 1

# Để áp dụng mặc định, thêm vào /etc/rc.local
```

#### 3.1.13.4 Vào/Ra Chế Độ Chờ

```bash
# Vào chế độ chờ
echo 1 > /sys/class/graphics/fb0/blank

# Thoát chế độ chờ
echo 0 > /sys/class/graphics/fb0/blank
```

---

### 3.1.14 Kiểm Tra Đèn LED

OKMX6ULL-S có **LED1** và **LED2** trên tấm đế, tương ứng với `led1` và `led2` trong `/sys/class/leds`.

```bash
# Xem điều kiện kích hoạt
cat /sys/class/leds/led1/trigger

# Điều khiển thủ công (đặt trigger = none trước)
echo none > /sys/class/leds/led1/trigger

# Bật LED1
echo 1 > /sys/class/leds/led1/brightness

# Tắt LED1
echo 0 > /sys/class/leds/led1/brightness

# Bật LED2
echo 1 > /sys/class/leds/led2/brightness

# Tắt LED2
echo 0 > /sys/class/leds/led2/brightness

# Đặt chế độ nhịp tim (heartbeat)
echo heartbeat > /sys/class/leds/led1/trigger
```

---

### 3.1.15 Kiểm Thử Cơ Sở Dữ Liệu SQLite3

OKMX6ULL-S sử dụng **SQLite3 phiên bản 3.11.0** — cơ sở dữ liệu nhúng nhẹ, không cần tiến trình máy chủ.

```bash
# Khởi động SQLite3
sqlite3 test.db

# Thoát khỏi cơ sở dữ liệu
.quit
```

---

### 3.1.16 Thử Nghiệm Điều Chế Tần Số CPU

```bash
# Xem tất cả các chế độ cpufreq được hỗ trợ
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Xem dải tần số CPU hỗ trợ
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies

# Chuyển sang chế độ userspace và đặt tần số 792MHz
echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 792000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed

# Xem tần số hiện tại
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
```

---

### 3.1.17 Kiểm Tra Nhiệt Độ

> **Lưu ý:**
> - Ngưỡng điểm nối CPU: **105°C** (cấu hình trong uboot)
> - CPU **giảm tần số** khi nhiệt độ > **85°C**
> - CPU **khởi động lại** khi nhiệt độ > **105°C**

```bash
# Kiểm tra nhiệt độ CPU hiện tại
cat /sys/class/thermal/thermal_zone0/temp

# Kiểm tra ngưỡng giảm xung nhịp
cat /sys/class/thermal/thermal_zone0/trip_point_0_temp

# Kiểm tra ngưỡng khởi động lại
cat /sys/class/thermal/thermal_zone0/trip_point_1_temp
```

---

### 3.1.18 Kiểm Tra Bluetooth

Bo mạch tích hợp mô-đun **WiFi & BT RTL8723DU** (hoặc RTL8723BU).

> **Lưu ý:** Chỉ có **hệ thống tệp QT** hỗ trợ kiểm tra Bluetooth. Sử dụng **Bluez 5.37**.

```bash
# Khởi động tiến trình nền bluez
bluetoothd &

# Cấu hình Bluetooth
bluetoothctl
```

#### 3.1.18.1 Ghép Nối Thụ Động

1. Sau cấu hình, quét thiết bị Bluetooth từ điện thoại và nhấp ghép nối.
2. Trên bo mạch, nhập `yes` để xác nhận ghép nối.
3. Gỡ bỏ thiết bị đã ghép nối:
   ```bash
   bluetoothctl remove <địa_chỉ_MAC>
   ```

#### 3.1.18.2 Ghép Nối Chủ Động

Gửi yêu cầu ghép nối từ bo mạch tới điện thoại; điện thoại xác nhận, bo mạch nhập `yes`.

```bash
bluetoothctl pair <địa_chỉ_MAC_điện_thoại>
quit
```

#### 3.1.18.3 Nhận Tệp Qua Bluetooth

Gửi tệp từ điện thoại đến bo mạch qua Bluetooth. Tệp nhận được lưu tại `/home/root/`.

```bash
ls /home/root/
# IMG_20210710_103755.jpg
```

#### 3.1.18.4 Gửi Tệp Qua Bluetooth

```bash
# Khởi động obexd
obexctl

# Kết nối thiết bị Bluetooth
[obex]# connect BC:2E:F6:57:30:68

# Gửi tệp
[BC:2E:F6:57:30:68]# send /home/root/IMG_20210710_103755.jpg
```

Điện thoại nhận yêu cầu chấp nhận tệp → nhấp **Chấp nhận** để hoàn tất chuyển giao.

---

### 3.1.19 Cài Đặt Khởi Động Tự Động

Tệp `/etc/rc.local` chứa các lệnh tự động chạy khi hệ thống khởi động. Thêm các chương trình cần tự động chạy vào tệp này.

```bash
# Ví dụ: thêm lệnh vào /etc/rc.local
echo "your_command &" >> /etc/rc.local
```

> Tham khảo tài liệu hướng dẫn ứng dụng để biết các phương pháp cấu hình cụ thể.