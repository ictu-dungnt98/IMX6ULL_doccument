# Chapter 5 — Common Network Applications

The `myir-image-full` factory image includes several common network applications for development and debugging.

---

## 5.1. PING

PING tests network connectivity, latency, and packet loss rates. Once Ethernet is configured (see Chapter 4.1), PING can be used for quick network testing.

### Network Connection

When connecting via CAT6 cable, the kernel outputs connection info to console:

```
[ 6601.055679] SMSC LAN8710/LAN8720 20b4000.ethernet-1:01: attached PHY driver (mii_bus:phy_addr=20b4000.ethernet-1:01, irq=POLL)
```

### Ping Public Network

```bash
root@myd-y6ull14x14:~# ping www.baidu.com -I eth0
PING www.baidu.com (112.80.248.75) 56(84) bytes of data.
64 bytes from 112.80.248.75: icmp_seq=1 ttl=56 time=28.3 ms
64 bytes from 112.80.248.75: icmp_seq=2 ttl=56 time=26.4 ms
64 bytes from 112.80.248.75: icmp_seq=3 ttl=56 time=34.5 ms
```

> **Note:** Pinging public networks requires DNS to be working properly.

| Field | Description |
|---|---|
| `icmp_seq` | ICMP packet sequence number — if sequential, no packets were lost |
| `time` | Response latency — lower is better |

The `ping` command also works for testing Wi-Fi connectivity.

---

## 5.2. SSH

SSH (Secure Shell) provides encrypted remote login and network service sessions. The factory image ships with **OpenSSH 7.6P1** (both client and server).

### SSH Client Test

Connect from the development board to a remote SSH server at `192.168.30.185`:

```bash
ssh root@192.168.30.185
# The authenticity of host '192.168.30.185' can't be established.
# RSA key fingerprint is SHA256:8Pu4Od1+FdT34uG6eYpRgXbbvPeKOcUzyed/hnpEsHI.
# Are you sure you want to continue connecting (yes/no)? yes
root@myd-y6ull14x14:~#
```

After login, you enter the remote server console with the logged-in user's permissions. Run `exit` to disconnect.

### SSH Server Test

The development board also runs an SSH server by default. Connect from a PC:

```bash
PC $ ssh root@192.168.0.16
# myir
root@myir:~#
```

### Allow Root Passwordless Login (Debug Only)

Edit `/etc/ssh/sshd_config` on the SSH server device:

```
PermitRootLogin yes
PermitEmptyPasswords yes
```

> ⚠️ **Security Warning:** This configuration poses a significant security risk and should only be used during the debug phase. Disable it for production products.

---

## 5.3. SCP

SCP (Secure Copy) is a secure remote file copy command based on SSH, useful for file transfer during system debugging.

### Copy File from Remote to Local

```bash
# On PC: copy uboot.dtb to the development board
myir@myir-server1:~$ scp uboot.dtb root@192.168.30.202:/home/root/
uboot.dtb     100%  1499KB   1.5MB/s   00:00

# Verify on development board
root@myd-y6ull14x14:~# ls /home/root/
uboot.dtb
```

### Copy File from Local to Remote

```bash
root@myd-y6ull14x14:~# scp 1.sh roy@192.168.30.185:~/
roy@192.168.30.185's password:
1.sh     100%    0     0.0KB/s   00:00
```

> Add the `-r` flag to copy entire directories recursively.

---

## 5.4. FTP

FTP (File Transfer Protocol) uses a client-server model for file transfer over TCP port 21. The factory image includes:
- **FTP client:** `ftp`
- **FTP server:** `proftpd`

The FTP root directory on the target device is `/var/lib/ftp`.

### 1) Login from Host PC (Anonymous)

```
C:\Users\myir> ftp 192.168.30.185
220 ProFTPD Server (ProFTPD Default Installation) [192.168.30.185]
User: ftp
331 Anonymous login ok, send your complete email address as your password
Password: (any)
230 Anonymous access granted, restrictions apply
ftp>
```

### 2) Create Test Files on Target Device

```bash
cd /var/lib/ftp
touch aaa test
ls
# aaa  test
```

### 3) View Files from Host PC

```
ftp> ls
aaa
test
226 Transfer complete
```

### 4) Download Files from Target Device

```
ftp> mget aaa test
Mget aaa? y
150 Opening ASCII mode data connection for aaa
226 Transfer complete
Mget test? y
226 Transfer complete
```

### 5) Upload Files to Target Device (Root Login)

#### Set Root Password on Target

```bash
root@myir:~# passwd root
New password:
Retype new password:
passwd: password updated successfully
```

#### Enable Root Login in ProFTPD

Edit `/etc/proftpd.conf` and add:

```
RootLogin on
```

Restart the service:

```bash
systemctl restart proftpd
```

#### Upload via FTP

```
D:\01-Document> ftp 192.168.0.60
User: root
Password:
230 User root logged in
ftp> pwd
257 "/home/root" is the current directory

ftp> binary
200 Type set to I

ftp> put myapp
226 Transfer complete. 1024 bytes sent in 0.02 secs (63.7 kB/s)

ftp> bye
```

> ⚠️ FTP transmits login credentials and data in **plain text** — not suitable for use over the Internet. Use only in trusted LAN environments.

---

## 5.5. TFTP

TFTP (Trivial File Transfer Protocol) uses **UDP** with no authentication — simple and ideal for transferring firmware and configuration files. U-Boot supports TFTP for network booting.

### TFTP Client Syntax

```bash
tftp --help
# Usage: tftp [OPTIONS] HOST [PORT]
# -g  : Get (download)
# -p  : Put (upload)
# -l  : Local file
# -r  : Remote file
# HOST: Remote host name or IP
# PORT: Optional (default: 69)
```

### Setup TFTP Server on Ubuntu

#### Install

```bash
PC $ sudo apt-get install tftp-hpa tftpd-hpa
```

#### Configure

```bash
mkdir -p <WORKDIR>/tftpboot
chmod -R 777 <WORKDIR>/tftpboot
sudo vi /etc/default/tftpd-hpa
```

Add or modify:

```
TFTP_DIRECTORY="<WORKDIR>/tftpboot"
TFTP_OPTIONS="-l -c -s"
```

#### Restart Service

```bash
sudo service tftpd-hpa restart
```

### Download File from TFTP Server

```bash
# Downloads zImage from server to current directory on target
tftp -g -r zImage -l zImage 192.168.0.2
```

### Upload File to TFTP Server

```bash
# Uploads 'config' from target, saves as 'config_01' on server
tftp -p -l config -r config_01 192.168.0.2
```

---

## 5.6. UDHCPC

UDHCPC is a DHCP client that dynamically obtains IP address, subnet mask, gateway, and DNS from a DHCP server.

### Get IP Address via DHCP

```bash
root@myir:~# udhcpc -i eth0
udhcpc: started, v1.31.1
udhcpc: sending discover
udhcpc: sending select for 192.168.30.199
udhcpc: lease of 192.168.30.199 obtained, lease time 3600
/etc/udhcpc.d/50default: Adding DNS 223.5.5.5
/etc/udhcpc.d/50default: Adding DNS 201.104.111.114
```

Verify:

```bash
ifconfig eth0
# eth0  inet addr:192.168.30.199  Bcast:192.168.30.255  Mask:255.255.255.0

cat /etc/resolv.conf
# nameserver 223.5.5.5
# nameserver 201.104.111.114
```

---

## 5.7. IPTables

`iptables` is an administrative tool for IPv4 packet filtering and NAT in the Linux kernel. It processes packets based on rules: `accept`, `reject`, or `drop`.

Reference: https://linux.die.net/man/8/iptables

### 1) Block ICMP (Disable Ping Response)

```bash
iptables -A INPUT -p icmp --icmp-type 8 -j DROP
iptables -S
# -P INPUT ACCEPT
# -P FORWARD ACCEPT
# -P OUTPUT ACCEPT
# -A INPUT -p icmp -m icmp --icmp-type 8 -j DROP
```

### 2) Verify — Ping from Host PC

```bash
PC$ ping 192.168.30.185 -w 10
# 10 packets transmitted, 0 received, 100% packet loss
```

### 3) Clear iptables Rules

```bash
iptables -F
iptables -S
# -P INPUT ACCEPT
# -P FORWARD ACCEPT
# -P OUTPUT ACCEPT
```

### 4) Verify — Ping Again

```bash
PC$ ping 192.168.0.60 -w 5
# 64 bytes from 192.168.0.60: icmp_seq=1 ttl=64 time=0.254 ms
# 6 packets transmitted, 6 received, 0% packet loss
```

---

## 5.8. Ethtool

`ethtool` is used for viewing and modifying Ethernet device parameters, useful during network debugging.

### View Ethernet Card Info

```bash
root@myd-y6ull14x14:~# ethtool eth0
Settings for eth0:
  Supported link modes:   10baseT/Half 10baseT/Full
                          100baseT/Half 100baseT/Full
  Supports auto-negotiation: Yes
  Speed: 10Mb/s
  Duplex: Full
  Port: MII
  PHYAD: 1
  Transceiver: internal
  Auto-negotiation: on
  Link detected: yes
```

### Force 100Mbps Full Duplex (No Autoneg)

```bash
ethtool -s eth0 speed 100 duplex full autoneg off
```

> Full reference: http://man7.org/linux/man-pages/man8/ethtool.8.html

---

## 5.9. iPerf3

iPerf3 actively measures maximum network bandwidth over an IP network, supporting TCP and UDP with IPv4/IPv6.

**Test setup:** Ubuntu PC with gigabit NIC as server, development board as client. Connect directly via CAT6 (avoid routers/switches to prevent interference).

Install on server:

```bash
PC $ sudo apt-get install iperf3
```

### 5.9.1. TCP Mode Test

#### Server Side (192.168.30.3)

```bash
PC $ iperf3 -s -i 2
# Server listening on 5201
```

#### Client Side (192.168.30.185)

```bash
root@myd-y6ull14x14:~# iperf3 -c 192.168.30.3 -i 2 -t 60
```

| Parameter | Description |
|---|---|
| `-c <IP>` | Client mode — connect to server IP |
| `-i 2` | Report results every 2 seconds |
| `-t 60` | Total test duration: 60 seconds |

**Result summary:**

```
[ ID] Interval       Transfer    Bandwidth    Retr
[  4] 0.00-60.00 sec 674 MBytes  94.2 Mbits/sec  0  sender
[  4] 0.00-60.00 sec 673 MBytes  94.1 Mbits/sec     receiver
```

✅ TCP bandwidth ~**94 Mbps**, zero retransmissions.

---

### 5.9.2. UDP Mode Test

#### Server Side

```bash
PC $ iperf3 -s -i 2
# Server listening on 5201
```

#### Client Side

```bash
root@myd-y6ull14x14:~# iperf3 -c 192.168.30.3 -u -i 2 -t 60 -b 1G -R
```

| Parameter | Description |
|---|---|
| `-u` | UDP mode |
| `-b 1G` | Set target UDP bandwidth to 1G |
| `-R` | Reverse mode (server sends to client) |

**Result summary:**

```
[ ID] Interval       Transfer    Bandwidth     Jitter   Lost/Total
[  4] 0.00-60.00 sec 685 MBytes  95.7 Mbits/sec  0.177 ms  29/87640 (0.033%)
```

✅ UDP bandwidth ~**95.7 Mbps**, packet loss only **0.033%**.

> **Tip:** Increase `-b` progressively until packet loss appears to find the true UDP ceiling. Use `-t` for long stress tests or `-P` for parallel streams.

> Full iPerf3 documentation: https://iperf.fr/iperf-doc.php