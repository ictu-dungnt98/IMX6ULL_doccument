# 01 - Giới Thiệu Về Bo Mạch Phát Triển OKMX6ULL-S

---

## 1.1 Giới Thiệu Về Bo Mạch Phát Triển OKMX6ULL-S

Bo mạch phát triển **OKMX6ULL-S** sử dụng cấu trúc **bo mạch lõi + bo mạch nền**, dựa trên thiết kế bộ xử lý công suất thấp **i.MX6ULL** của NXP, với các đặc điểm chính:

- Tốc độ xung nhịp: **800MHz**
- Kiến trúc: **ARM Cortex-A7**
- Kiến trúc quản lý nguồn độc đáo giúp giảm tiêu thụ điện năng so với các bo mạch lõi dòng ARM9
- Cung cấp nhiều giao diện ngoại vi: **CAN, WIFI, USB, UART, IIC, Ethernet**

> 📌 **Vui lòng đọc trước:**
> Tài liệu hướng dẫn phần mềm này sẽ không mô tả các thông số phần cứng. Trước khi tham khảo tài liệu này để phát triển phần mềm, vui lòng đọc **"OKMX6ULL-S\_Hardware Manual"** trong thư mục `Hardware Data\User Manual` để hiểu các quy tắc đặt tên sản phẩm và thông tin cấu hình phần cứng. Điều này sẽ giúp bạn sử dụng sản phẩm hiệu quả hơn.

---

## 1.2 Đặc Điểm Tài Nguyên Phần Mềm Hệ Thống Linux 4.1.15

| Thiết bị | Vị trí mã nguồn trình điều khiển trong nhân | Tên thiết bị |
|----------|---------------------------------------------|--------------|
| Trình điều khiển card mạng | `drivers/net/ethernet/freescale/fec_main.c` | `/sys/class/net/eth*` |
| Trình điều khiển đèn nền LCD | `drivers/video/backlight/pwm_bl.c` | `/sys/class/backlight` |
| Bộ điều khiển LED | `drivers/leds/leds-gpio.c` | `/sys/class/leds/` |
| Ổ đĩa flash USB | `drivers/usb/chipidea/ci_hdrc_imx.c` | `/dev/sdx` |
| USB 4G | `drivers/usb/serial/` | `/dev/ttyUSB*` |
| Camera USB | `drivers/media/usb/uvc/uvc_video.c` | `/dev/videox` |
| Trình điều khiển thẻ SD | `drivers/mmc/host/sdhci-esdhc-imx.c` | `/dev/block/mmcblk0pX` |
| Bộ đệm khung LCD | `drivers/video/fbdev/mxsfb.c` | `/dev/fb0` |
| Cảm ứng điện dung FT5X06 | `drivers/input/touchscreen/edt-ft5x06.c` | `/dev/input/eventx` |
| Cảm ứng điện dung GT9xx | `drivers/input/touchscreen/gt9xx.c` | `/dev/input/eventx` |
| Trình điều khiển đồng hồ thực RTC | `drivers/rtc/rtc-pcf8563.c` | `/dev/rtcx` |
| Trình điều khiển cổng nối tiếp | `drivers/tty/serial/imx.c` | `/dev/ttymxc*` |
| Trình điều khiển Watchdog | `drivers/watchdog/imx2_wdt.c` | `/dev/watchdog` |
| Trình điều khiển CAN | `drivers/net/can/flexcan.c` | `/sys/class/net/can*` |
| WIFI | `drivers/net/wireless/realtek` | `wlan0` |
| Trình điều khiển âm thanh | `sound/soc/` | `/dev/snd/` |
| SPI | `drivers/spi/spi-imx.c` | `/dev/spidev0.0`, v.v. |
| MCP2515 | `drivers/net/can/spi/mcp251x.c` | `/dev/canx` |
| ADC | `drivers/iio/adc/vf610_adc.c` | `iio:device0` |

---

## 1.3 Lập Trình Và Cài Đặt Khởi Động

**OKMX6ULL-S** hỗ trợ hai phương pháp lập trình và hai phương pháp khởi động:

- **Phương pháp lập trình:** USB OTG và thẻ SD
- **Phương pháp khởi động:** NAND và eMMC

Chế độ được phân biệt bằng **công tắc DIP** (8 chân). Bảng cài đặt công tắc DIP:

| Chế độ | SW1 | SW2 | SW3 | SW4 | SW5 | SW6 | SW7 | SW8 |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|
| Ghi vào thẻ SD | TẮT | TẮT | BẬT | TẮT | BẬT | TẮT | TẮT | BẬT |
| Khởi động NAND | TẮT | TẮT | TẮT | BẬT | BẬT | TẮT | TẮT | BẬT |
| Lập trình USB OTG | BẬT | BẬT | TẮT | TẮT | TẮT | TẮT | TẮT | TẮT |
| Khởi động eMMC | TẮT | TẮT | BẬT | TẮT | TẮT | TẮT | TẮT | TẮT |