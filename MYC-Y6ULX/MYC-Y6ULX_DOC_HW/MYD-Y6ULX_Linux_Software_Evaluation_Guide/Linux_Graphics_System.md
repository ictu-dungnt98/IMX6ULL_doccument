# Chapter 6 — Linux Graphics System

The Linux graphics system sits between the underlying display device drivers and upper-level user interface applications, masking hardware differences while providing a unified API.

---

## 6.1. QT

Qt is a cross-platform C++ GUI application development framework supporting both GUI and non-GUI programs (console tools, servers, etc.). It is object-oriented and uses special code-generation extensions and macros.

The factory image ships with the Qt runtime library and the **MEasy HMI 2.0** demonstration system. See **"MEasy HMI2.0 Development Manual"** for details.

---

### 1) Qt Running Environment Configuration

#### Platform Plugins

On embedded Linux, available platform plugins include: **EGLFS**, **LinuxFB**, **DirectFB**, and **Wayland**. Availability depends on the hardware platform and Qt build configuration. EGLFS is the default on many boards.

Set the platform plugin via environment variable:

```bash
export QT_QPA_PLATFORM=linuxfb
./mxapp2
```

Or pass it as a command-line argument:

```bash
./mxapp2 -platform linuxfb
```

#### Display Parameters Configuration

Qt apps use `QScreen` or `QDesktopWidget` to get screen parameters. If display elements don't match the actual screen size, configure the following EGLFS environment variables:

| Environment Variable | Description |
|---|---|
| `fb=/dev/fbN` | Specify the frame buffer device (for multi-monitor setups) |
| `size=<width>x<height>` | Override screen size in pixels |
| `mmsize=<width>x<height>` | Specify physical screen size in millimeters |
| `offset=<width>x<height>` | Set upper-left corner offset in pixels (default: 0,0) |
| `nographicsmodeswitch` | Skip switching the virtual terminal to graphics mode (KD_GRAPHICS) |
| `tty=/dev/ttyN` | Override the virtual console (only when `nographicsmodeswitch` is not set) |

> The default configuration usually works well. Adjust the above parameters only if there is a visible mismatch between displayed elements and the actual screen.

#### Input Devices Configuration

To enable **TSLIB** support:

- For **EGLFS:** `export QT_QPA_EGLFS_TSLIB=1`
- For **LinuxFB:** `export QT_QPA_FB_TSLIB=1`

Reference: https://github.com/libts/tslib/blob/master/README.md

> **Note:** The TSLIB input handler is typically used for resistive touchscreens. It generates mouse events, supports only **single touch**, and requires screen calibration before first use.

---

### 2) Start Qt Applications

Touch-based devices usually don't need to display a mouse cursor. Hide it via environment variable before launching the app:

```bash
# For eglfs platform plugin
export QT_QPA_EGLFS_HIDECURSOR=1

# For linuxfb platform plugin
export QT_QPA_FB_HIDECURSOR=1
```

The factory `myir-image-full` image uses the **linuxfb** platform plugin with an **EvdevTouch** handler. Launch the MEasy HMI demo:

```bash
root@myd-y6ull14x14:/home/root/# export QT_QPA_FB_HIDECURSOR=1
root@myd-y6ull14x14:/home/root/# ./mxapp2 -platform linuxfb &
qt.qpa.input: xkbcommon not available, not performing key mapping
qml: index=0
qml: currentIndex=0
libpng warning: iCCP: known incorrect sRGB profile
```

> `mxapp2` starts by default on boot. To run your own Qt application, stop `mxapp2` first before launching other applications.