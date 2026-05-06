# Chapter 7 — Multimedia Applications

---

## 7.1. Camera

This section uses the open source **uvc_stream** to demonstrate camera usage. MYD-Y6ULX provides a parallel Camera interface (**J9**) for connecting the **MY-CAM011B** camera module via FPC cable.

> ⚠️ **Warning:** Due to signal sequence differences, do not insert other camera models directly — this may damage the module or development board.

`uvc_stream` transmits data over the network. Configure the Ethernet IP of the board first (mapped to `eth0`).

### 1) View Device Topology

```bash
root@myd-y6ull14x14:~# ifconfig eth0 192.168.30.42

root@myd-y6ull14x14:~# v4l2-ctl --list-devices
i.MX6S_CSI (platform:21c4000.csi):
    /dev/video1
pxp (pxp_v4l2):
    /dev/video0
```

`i.MX6S_CSI` is the Camera controller — the MY-CAM011B device node is `/dev/video1`.

### 2) Start Display Server

```bash
./uvc_stream -d /dev/video1 -y -P 123456 -r 800x600
```

| Parameter | Description |
|---|---|
| `-d /dev/video1` | Camera device node |
| `-y` | Use YUYV capture format |
| `-P 123456` | Web interface login password |
| `-r 800x600` | Resolution (currently only 800×600 supported) |

> Default web interface username: `uvc_user`. Press `Ctrl+C` to stop.

### 3) View Stream in Browser

`uvc_stream` supports two web functions:

| Function | URL |
|---|---|
| Snapshot | `http://192.168.30.42:8080/snapshot.jpeg` |
| Live Stream | `http://192.168.30.42:8080/stream.mjpeg` |

Ensure the PC and board are on the same network, open a browser and navigate to the stream URL. Log in with username `uvc_user` and password `123456` to view the live video from MY-CAM011B.

---

## 7.2. Audio

MYD-Y6ULX uses the **WM8904CGEFL/V** audio encoding chip, providing:
- 3.5mm headphone output
- 1× audio linear input

The WM8904's I2S interface connects to the processor's **SAI2** controller, and its I2C interface connects to the CPU's **I2C2** bus.

### 1) Play Music via MEasy HMI 2.0

For HMI multimedia music playback, refer to **"MEasy HMI2.0 Development Manual"**.

### 2) Play Music via Command Line

```bash
root@myir:~/audio# aplay att16k.wav
Now playing /home/root/audio/att16k.wav
Redistribute latency...
0:00:14.9 / 0:00:14.9
Reached end of play list.
```

---

## 7.3. Video

### 1) Play Videos via MEasy HMI 2.0

For HMI multimedia video playback, refer to **"MEasy HMI2.0 Development Manual"**.