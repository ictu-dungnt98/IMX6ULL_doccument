# Chapter 3 — Peripheral Interfaces Evaluation

---

## 3.1. GPIO

GPIO pins on MYD-Y6ULX are defined in the form of `GPIOX_Y`. For the mapping between pin label names and `GPIOX_Y` format, refer to **"MYC-Y6ULX Pin list_V13.xlsx"**.

**Pin number conversion formula:**

```
pin_number = (X - 1) * 32 + Y
```

### 1) Export GPIO to User Space

```bash
root@myd-y6ull14x14:~# echo 24 > /sys/class/gpio/export
```

After successful export, directory `gpio24` will be generated under `/sys/class/gpio/`.

### 2) Set / View GPIO Direction

```bash
# Set as Input
echo "in" > /sys/class/gpio/gpio24/direction

# Set as Output
echo "out" > /sys/class/gpio/gpio24/direction

# View Direction
cat /sys/class/gpio/gpio24/direction
out
```

Returns `in` for input and `out` for output.

### 3) Set / View GPIO Value

```bash
# Set Output Low
echo "0" > /sys/class/gpio/gpio24/value

# Set Output High
echo "1" > /sys/class/gpio/gpio24/value

# View Value
cat /sys/class/gpio/gpio24/value
1
```

---

## 3.2. LED Lamp

The Linux LED subsystem provides file-based interfaces in `/sys/class/leds` for controlling LED devices from user space.

### 1) View Available LEDs

```bash
root@myd-y6ull14x14:~# ls /sys/class/leds/
cpu  mmc0::  mmc1::
```

### 2) Test a LED (example: `cpu` LED)

```bash
# Get LED Status (255 = on, 0 = off)
cat /sys/class/leds/cpu/brightness
255

# Turn Off LED
echo 0 > /sys/class/leds/cpu/brightness

# Turn On LED
echo 1 > /sys/class/leds/cpu/brightness

# Set Heartbeat Trigger (flashes like a heartbeat)
echo "heartbeat" > /sys/class/leds/cpu/trigger
```

> After enabling `heartbeat` trigger mode, the LED flashes at a default cycle of 1 Hz with 50% duty ratio.

---

## 3.3. RS232

Linux serial device driver nodes are named `/dev/ttymxcN` (N = 0, 1, 2, 3...).  
This section uses **J10 interface (UART2)** as an example, mapped to `/dev/ttymxc1`.

### Table 3-1. RS232 Interface Configuration

| Device Node | UART |
|---|---|
| `/dev/ttymxc0` | UART1 |
| `/dev/ttymxc1` | UART2 |
| `/dev/ttymxc2` | UART3 |

**Setup:** Connect a USB-RS232 converter to the PC's USB Host port. Connect RXD and TXD of J10 to TXD and RXD of the converter respectively.

### Send Data from Windows PC (SSCOM)

Use a serial debug tool (e.g., SSCOM) to send `"1234567890"` and verify receipt.

### Receive and Echo Test on Development Board

```bash
root@myd-y6ull14x14:~# uart_test -d /dev/ttymxc1 -b 115200
/dev/ttymxc1 RECV 10 total
/dev/ttymxc1 RECV: 1234567890
/dev/ttymxc1 RECV 10 total
/dev/ttymxc1 RECV: 1234567890
```

---

## 3.4. RS485

RS485 uses device alias Serial3, mapped to `/dev/ttymxc3`.  
**Setup:** Connect two development boards — link 485A to 485A and 485B to 485B of the other board.

### Sending Board

```bash
# rs485_write -d /dev/ttymxc3 -b 4800 -e 1
SEND[20]: 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f 0x10 0x11 0x12 0x13 0x14
SEND[20]: 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f 0x10 0x11 0x12 0x13 0x14
```

### Receiving Board

```bash
# rs485_read -d /dev/ttymxc3 -b 4800 -e 1
RECV[20]: 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f 0x10 0x11 0x12 0x13 0x14
RECV[20]: 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f 0x10 0x11 0x12 0x13 0x14
```

---

## 3.5. CAN

This section uses `cansend` and `candump` for SocketCAN communication testing between two development boards.  
**Setup:** Connect CANH and CANL pins of J10 on both boards to each other.

### 1) Initialize CAN Network Interface

```bash
# Set baud rate and enable CAN interface
root@myd-y6ull14x14:~# ip link set can0 type can bitrate 50000 triple-sampling on
root@myd-y6ull14x14:~# ifconfig can0 up
```

### 2) Send and Receive Data

```bash
# Send (Board 1) — send 8-byte fixed format string
root@myd-y6ull14x14:~# cansend can0 100#01.02.03.04.05.06.07.08

# Receive (Board 2)
root@myd-y6ull14x14:~# candump can0
can0  100  [8]  01 02 03 04 05 06 07 08
```

### 3) View CAN Interface Statistics

```bash
root@myd-y6ull14x14:~# ip -details -statistics link show can0
```

```
2: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN
    can state STOPPED (berr-counter tx 0 rx 0) restart-ms 0
    flexcan: tseg1 4..16 tseg2 2..8 sjw 1..4 brp 1..256 brp-inc 1
    clock 30000000
    re-started bus-errors arbit-lost error-warn error-pass bus-off
    0          0          0          0          0          0
RX: bytes  packets  errors  dropped  overrun  mcast
    0       0        0       0        0        0
TX: bytes  packets  errors  dropped  carrier  collsns
    0       0        0       0        0        0
```

| Field | Description |
|---|---|
| `clock` | CAN clock |
| `drop` | Lost packets |
| `overrun` | Bus overrun |
| `error` | Bus error |

---

## 3.6. Key

MYD-Y6ULX has three buttons:

| Button | Description |
|---|---|
| S3 | System reset button |
| K3 | Wake-up button (wkup) — not configured in A7 device tree |
| S1 | User key — configured in device tree |

Input devices are accessible via `/dev/input/eventXX`.

### 1) Device Tree Node

In `myb-imx6ul-14x14.dtsi`:

```dts
gpio-keys {
    compatible = "gpio-keys";
    pinctrl-names = "default";
    pinctrl-0 = <&pinctrl_gpio_key>;

    user {
        label = "User Button";
        gpios = <&gpio5 0 GPIO_ACTIVE_HIGH>;
        gpio-key,wakeup;
        linux,code = <KEY_1>;
    };
};
```

### 2) Test Keys

#### View Available Input Devices

```bash
root@myd-y6ull14x14:~# evtest
Available devices:
/dev/input/event0: 20cc000.snvs:snvs-powerkey
/dev/input/event1: generic ft5x06 (00)
/dev/input/event2: iMX6UL Touchscreen Controller
/dev/input/event3: gpio-keys
```

#### Test gpio-keys (Select event 3)

```
Select the device event number [0-3]: 3
Input device name: "gpio-keys"
Supported events:
  Event type 1 (EV_KEY)
    Event code 2 (KEY_1)

Testing ... (interrupt to exit)
Event: time 1599641292.878878, type 1 (EV_KEY), code 2 (KEY_1), value 0
Event: time 1599641293.049011, type 1 (EV_KEY), code 2 (KEY_1), value 1
Event: time 1599641293.718856, type 1 (EV_KEY), code 2 (KEY_1), value 0
Event: time 1599641293.858903, type 1 (EV_KEY), code 2 (KEY_1), value 1
```

Each key press prints the event code value to the terminal, confirming the key works normally.

---

## 3.7. USB

MYD-Y6ULX has **2 × USB 2.0** ports — one for OTG image download, the other expanded to 2 USB ports via an expansion chip.

### 1) Check Kernel Message on USB Insertion

Connect a USB flash drive to the USB Host interface:

```
[ 755.254972] usb 1-1.1: new high-speed USB device number 3 using ci_hdrc
[ 755.413421] usb 1-1.1: New USB device found, idVendor=058f, idProduct=6387
[ 755.437531] usb 1-1.1: Product: Mass Storage
[ 755.441955] usb 1-1.1: Manufacturer: Generic
[ 756.594293] sd 0:0:0:0: [sda] 31129600 512-byte logical blocks: (15.9 GB)
[ 756.711553] sd 0:0:0:0: [sda] Attached SCSI removable disk
```

The device is assigned as `sda`.

### 2) Mount and Read/Write USB Flash Disk

```bash
# Auto-mounted — no manual mount needed
ls /run/media/

# Write to USB
echo "myir udisk test" > /run/media/sda/test_file.txt

# Read from USB
cat /run/media/sda/test_file.txt
myir udisk test
```

> After writing, run `sync` to ensure data is fully flushed before unmounting.

---

## 3.8. Backlight

Backlight brightness is controlled via `/sys/class/backlight/`.

```bash
cd /sys/class/backlight/backlight-display/

# View current brightness
cat brightness
6

# View maximum brightness level
cat max_brightness
7

# Set brightness (must not exceed max_brightness)
echo 7 > brightness

# Attempting to exceed max returns an error:
echo 10 > brightness
sh: write error: Invalid argument
```

---

## 3.9. Touch Panel

MYD-Y6ULX supports both **capacitive** (FT5x16 IC) and **resistive** (i.MX6UL internal TSC/ADC) touch.

### 1) Calibration

> Capacitive screens do **not** need calibration. Resistive screens require calibration via `ts_calibrate`.

```bash
root@myd-y6ull14x14:~# ts_calibrate
xres = 800, yres = 480
Took 7 samples... Top left  : X = 3174 Y = 509
Took 5 samples... Top right : X = 3120 Y = 3715
Took 4 samples... Bot right : X =  843 Y = 3686
Took 7 samples... Bot left  : X =  855 Y =  483
Took 1 samples... Center    : X = 1992 Y = 2104
Calibration constants: -3494872 -171 14314 37598008 -10834 -11165536
```

### 2) Touch Test with evtest

```bash
root@myd-y6ull14x14:~# evtest
Available devices:
/dev/input/event0: 30370000.snvs:snvs-powerkey
/dev/input/event1: generic ft5x06 (00)
/dev/input/event2: gpio-keys
/dev/input/event3: bd718xx-pwrkey

Select the device event number [0-3]: 1
Input device name: "generic ft5x06 (00)"

Testing ... (interrupt to exit)
Event: time 1599614278.142778, type 3 (EV_ABS), code 57 (ABS_MT_TRACKING_ID), value 7
Event: time 1599614278.142778, type 3 (EV_ABS), code 53 (ABS_MT_POSITION_X), value 419
Event: time 1599614278.142778, type 3 (EV_ABS), code 54 (ABS_MT_POSITION_Y), value 367
Event: time 1599614278.142778, type 1 (EV_KEY), code 330 (BTN_TOUCH), value 1
```

### 3) Event Field Reference

| Event Code | Description |
|---|---|
| `EV_SYN` | Synchronous event |
| `EV_KEY` | Key event (e.g., `BTN_TOUCH` = touch button) |
| `EV_ABS` | Absolute coordinate event (reported by touchscreen) |
| `BTN_TOUCH` | Touch button pressed/released |
| `ABS_MT_TRACKING_ID` | Marks start/end of a touch contact collection |
| `ABS_X` / `ABS_Y` | Single-touch absolute X/Y coordinates |
| `ABS_MT_POSITION_X` | Multi-touch center point X coordinate |
| `ABS_MT_POSITION_Y` | Multi-touch center point Y coordinate |

---

## 3.10. Display

This section demonstrates Linux FrameBuffer device operation for LCD RGB color output and color synthesis testing. Connect the LCD to interface **J3** before testing.

### Table 3-2. Optional LCD Modules

| Model | Description |
|---|---|
| MY-TFT070CV2 | 7-inch Capacitive (default) |
| MY-TFT070RV2 | 7-inch Resistive |
| MY-TFT043RV2 | 4.3-inch Resistive |

### 1) Run FrameBuffer Test

```bash
# framebuffer_test
The framebuffer device was opened successfully.
vinfo.xres=480, vinfo.yres=272, vinfo.bits_per_pixel=16

color: red    rgb_val: 0000F800
color: green  rgb_val: 000007E0
color: blue   rgb_val: 0000001F
color: r & g  rgb_val: 0000FFE0
color: g & b  rgb_val: 000007FF
color: r & b  rgb_val: 0000F81F
color: white  rgb_val: 0000FFFF
color: black  rgb_val: 00000000
```

### 2) Switch to 4.3-inch LCD

Edit the device tree file: `arch/arm/boot/dts/myb-imx6ul-14x14.dtsi`

```dts
display-timings {
    /* Change native-mode to select display size */
    native-mode = <&timing0>;   /* 4.3-inch */
    /* native-mode = <&timing1>; */  /* 7.0-inch (default) */

    /* 4.3-inch timing */
    timing0: timing0 {
        clock-frequency = <9200000>;
        hactive = <480>;
        vactive = <272>;
        hfront-porch = <8>;
        hback-porch = <4>;
        hsync-len = <41>;
        vback-porch = <2>;
        vfront-porch = <4>;
        vsync-len = <10>;
        hsync-active = <0>;
        vsync-active = <0>;
        de-active = <1>;
        pixelclk-active = <0>;
    };

    /* 7.0-inch timing */
    timing1: timing1 {
        clock-frequency = <33000000>;
        hactive = <800>;
        vactive = <480>;
        hfront-porch = <210>;
        hback-porch = <46>;
        hsync-len = <1>;
        vback-porch = <22>;
        vfront-porch = <23>;
        vsync-len = <20>;
        hsync-active = <0>;
        vsync-active = <0>;
        de-active = <1>;
        pixelclk-active = <0>;
    };
};
```

After modifying `native-mode`, recompile the DTB and flash it to the board.