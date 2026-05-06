# Chapter 4 — Network Applications

The MYD-Y6ULX development board includes a **10/100M Ethernet** interface and a **WiFi/Bluetooth Combo Module (WM-N-BM-02)**.

---

## 4.1. Ethernet

The factory image uses a static IP configuration stored at:

```bash
root@myd-y6ull14x14:~# ls -l /etc/systemd/network/
-rwxr-xr-x 1 root root 88 Sep 9 09:05 10-static-eth0.network
-rwxr-xr-x 1 root root 88 Sep 9 09:05 11-static-eth1.network
lrwxrwxrwx 1 root root  9 Sep 9 09:11 99-default.link -> /dev/null
```

### 1) Manual Temporary IP Configuration

#### Using `ifconfig`

Check current network interfaces:

```bash
root@myd-y6ull14x14:~# ifconfig -a
eth0  inet addr:192.168.30.202  Mask:255.255.255.0
eth1  inet addr:192.168.40.202  Mask:255.255.255.0
lo    inet addr:127.0.0.1       Mask:255.0.0.0
```

Set a manual IP address on `eth0`:

```bash
ifconfig eth0 192.168.0.100 netmask 255.255.255.0 up
```

Verify:

```bash
ifconfig eth0
# eth0  inet addr:192.168.0.100  Bcast:192.168.1.255  Mask:255.255.255.0
```

#### Using `iproute2`

```bash
# Clear existing address first
ip addr flush dev eth0

# Assign new address
ip addr add 192.168.0.101/24 brd + dev eth0

# Bring interface up
ip link set eth0 up
```

Verify:

```bash
ip addr show eth0
# inet 192.168.0.101/24 brd 192.168.1.255 scope global eth0
```

> For full iproute2 documentation: https://wiki.linuxfoundation.org/networking/iproute2

> **Note:** IP addresses configured via `ifconfig` or `ip` are lost on reboot. Use the methods below for permanent configuration.

---

### 2) Automatic Permanent IP Configuration

#### Dynamic IP via `ifupdown` (DHCP)

Edit `/etc/network/interfaces`:

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
pre-up /etc/network/nfs_check
wait-delay 15
```

On each boot, `eth0` will request a dynamic IP from the DHCP server and auto-configure IP, gateway, and DNS.

#### Dynamic IP via `systemd-networkd` (DHCP)

The default factory image uses `systemd-networkd`. Configuration file at `/lib/systemd/network/80-wired.network`:

```ini
[Match]
Name=en* eth*
KernelCommandLine=!nfsroot

[Network]
DHCP=yes

[DHCP]
RouteMetric=10
ClientIdentifier=mac
```

This automatically configures IP, gateway, and DNS via DHCP for any interface matching `en*` or `eth*`, as long as the kernel was not booted with `nfsroot`.

Full configuration reference: https://www.freedesktop.org/software/systemd/man/systemd.network.html

#### Static IP via `systemd-networkd` (Permanent)

Create `/etc/systemd/network/10-static-eth0.network`:

```ini
[Match]
Name=eth0

[Network]
Address=192.168.30.200/24
Netmask=255.255.255.0
Gateway=192.168.30.1
```

Apply the configuration:

```bash
systemctl restart systemd-networkd.service
ifconfig eth0
# eth0  inet addr:192.168.30.200  Bcast:192.168.30.255  Mask:255.255.255.0
```

---

## 4.2. Wi-Fi

The **WM-N-BM-02** Wi-Fi module supports two working modes:

| Mode | Description |
|---|---|
| **STA** | Connect the device to an external Wi-Fi hotspot |
| **AP** | Turn the device into a Wi-Fi hotspot for others to connect |

> **Note:** STA and AP modes cannot run simultaneously on this module.

### Verify Driver is Loaded

```bash
root@myd-y6ull14x14:~# lsmod
Module     Size    Used by
brcmfmac   176188  0
brcmutil   8416    1 brcmfmac
```

After the driver loads, Wi-Fi firmware from `/lib/firmware/brcm` is loaded and the `wlan0` network node is created:

```bash
ifconfig -a
# wlan0  Link encap:Ethernet  HWaddr C0:84:7D:B6:6B:3E
```

---

### 4.2.1. Manually Connect to a Wi-Fi Hotspot (STA Mode)

Example: Connect to hotspot `MYIR_TECH` (WPA2, password: `myir@2016`).

#### Step 1 — Bring up `wlan0`

```bash
ifconfig wlan0 up
```

#### Step 2 — Scan for Nearby Hotspots

```bash
iw dev wlan0 scan | grep SSID
# SSID: MI8
# SSID: MYIR_TECH
# ...
```

#### Step 3 — Generate WPA Config

```bash
wpa_passphrase MYIR_TECH myir@2016 >> /etc/wpa_supplicant.conf
cat /etc/wpa_supplicant.conf
```

```
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
    ssid="MYIR_TECH"
    #psk="myir@2016"
    psk=6a85bda077eebd8473c9b585b74c823199c6cbbe66a4f1d9e40c9b94e9605aa0
}
```

#### Step 4 — Stop Any Running `wpa_supplicant`

```bash
killall wpa_supplicant
```

#### Step 5 — Start `wpa_supplicant`

```bash
wpa_supplicant -B -D wext -c /etc/wpa_supplicant.conf -i wlan0
```

| Flag | Description |
|---|---|
| `-B` | Run as background daemon |
| `-D` | Driver name |
| `-c` | Path to configuration file |
| `-i` | Wi-Fi network device node |

#### Step 6 — Obtain IP via DHCP

```bash
udhcpc -i wlan0
# udhcpc: lease of 192.168.40.107 obtained, lease time 7200

ping www.baidu.com
# 64 bytes from 112.80.248.75: icmp_seq=1 ttl=56 time=28.8 ms
```

---

### 4.2.2. Auto-Connect to Wi-Fi on Boot

Manual connections are lost after reboot. To configure persistent auto-connection:

#### Step 1 — Create systemd-networkd Wireless Interface File

```bash
cat > /lib/systemd/network/10-wireless.network << EOF
[Match]
Name=wlan0

[Network]
DHCP=ipv4
EOF
```

#### Step 2 — Create wpa_supplicant Config for `wlan0`

```bash
mkdir -p /etc/wpa_supplicant/

cat > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf << EOF
ctrl_interface=/var/run/wpa_supplicant
eapol_version=1
ap_scan=1
fast_reauth=1
EOF

wpa_passphrase MYIR_TECH myir@2016 >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
```

#### Step 3 — Enable and Restart Services

```bash
systemctl enable wpa_supplicant@wlan0.service
systemctl restart wpa_supplicant@wlan0.service
systemctl restart systemd-networkd.service
```

After rebooting, `wlan0` will automatically connect to `MYIR_TECH` and obtain IP, gateway, and DNS via DHCP.