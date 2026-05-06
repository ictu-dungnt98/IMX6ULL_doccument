# Chapter 8 — System Tools

The default factory image includes commonly used system tools for viewing and managing system resources during debugging or in deployed products. These tools can also be called from shell scripts or other applications.

---

## 8.1. Compress and Decompress Tools

### 1) tar Tool

`tar` packages, compresses, views, adds, and extracts files.

#### Common Parameters

| Parameter | Description |
|---|---|
| `-c` | Create a compressed file |
| `-x` | Extract/unpack a compressed file |
| `-t` | List files in a tar archive |
| `-z` | Apply gzip compression |
| `-j` | Apply bzip2 compression |
| `-v` | Verbose output (show files during operation) |
| `-f` | Specify filename (must immediately follow `-f`) |
| `-p` | Preserve original file permissions |
| `-P` | Allow absolute paths in archive |
| `--exclude FILE` | Exclude FILE from compression |

> **Note:** `-c`, `-x`, and `-t` are mutually exclusive — use only one at a time.

#### Compress with tar

```bash
tar -czf test.tar.gz test.txt
ls
# test.tar.gz  test.txt  ...
```

`.tar.gz` or `.tgz` indicates a gzip-compressed tar archive.

#### Decompress with tar

```bash
tar -xvf test.tar.gz
# test.txt
```

---

### 2) gzip Tool

`gzip` is a simple file compression/decompression command.

```bash
# View syntax
gzip --help
# Usage: gzip [-cfkdt] [FILE]...
```

#### Compress

```bash
gzip test.txt
ls
# test.txt.gz
```

#### Decompress

```bash
gunzip test.txt.gz
ls
# test.txt
```

---

## 8.2. File System Tools

Common file system management tools: `mount`, `mkfs`, `fsck`, `dumpe2fs`.

### 1) mount

`mount` connects a partition to a directory, making the partition accessible via that path.

```bash
# Mount the 4th partition of an SD card to /mnt
root@myir:~# mount /dev/mmcblk1p4 /mnt/
# [10677.124115] EXT4-fs (mmcblk1p4): mounted filesystem with ordered data mode.
```

### 2) mkfs

`mkfs` creates a Linux filesystem on a partition (equivalent to formatting). **This operation erases all data on the partition.**

```bash
# Format partition 7 of SD card as ext3
root@myir:~# mkfs -t ext3 -V -c /dev/mmcblk1p7
mkfs.ext3 -c /dev/mmcblk1p7
Creating filesystem with 330532 1k blocks and 82656 inodes
Filesystem UUID: 46bd5bb8-1882-4a68-901a-e11b4e71924b
...
Writing superblocks and filesystem accounting information: done
```

> ⚠️ Formatting washes out all data on the partition and is **not recoverable**.

### 3) fsck

`fsck` checks file system correctness and attempts repair when the file system fails.

```bash
root@myir:~# fsck -a /dev/mmcblk1p7
fsck from util-linux 2.32.1
/dev/mmcblk1p7: clean, 11/82656 files, 20726/330532 blocks
```

### 4) dumpe2fs

`dumpe2fs` prints information about superblocks and block groups of an existing filesystem.

```bash
root@myir:~# dumpe2fs /dev/mmcblk1p7
Filesystem volume name: <none>
Filesystem UUID: 46bd5bb8-1882-4a68-901a-e11b4e71924b
Filesystem magic number: 0xEF53
Filesystem features: has_journal ext_attr resize_inode dir_index ...
```

#### Check Inode Size

```bash
dumpe2fs /dev/mmcblk1p7 | grep -i "inode size"
# Inode size: 128
```

#### Check Block Size

```bash
dumpe2fs /dev/mmcblk1p7 | grep -i "block size"
# Block size: 1024
```

> The OS reads disk in "blocks" (multiple sectors at once) — this is the minimum unit of file access. Inodes consume disk space; at 100% inode usage, no new files can be written even if disk space remains.

---

## 8.3. Disk Management Utils

Common disk management tools: `fdisk`, `dd`, `du`, `df`, `cfdisk`.

### 1) fdisk — Disk Partitioning Tool

```bash
# Partition the eMMC
root@myir:~# fdisk /dev/mmcblk2p2
Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.

Command (m for help):
```

### 2) dd — Disk Copy Tool

`dd` copies and converts files at the block level. Unlike `cp`, it can operate on raw devices and create disk mirror files.

**Syntax:**
```
dd [if=<input>] [of=<output>] [bs=<block size>] [count=<block count>]
```

#### Create a 2MB File

```bash
root@myir:~# time dd if=/dev/zero of=ffmpeg1 bs=2M count=1 conv=fsync
1+0 records in
1+0 records out
2097152 bytes (2.1 MB, 2.0 MiB) copied, 0.195515 s, 10.7 MB/s

real  0m 0.20s
user  0m 0.00s
sys   0m 0.05s
```

### 3) du — Disk Usage Tool

`du` displays disk space usage per file or directory.

| Parameter | Description |
|---|---|
| `-a` | Display size of all directories and files |
| `-h` | Human-readable units (K, M, G) |
| `-k` | Output in Kilobytes |
| `-m` | Output in Megabytes |

```bash
root@myir:~# du ffmpeg1
2048  ffmpeg1

root@myir:~# du -h ffmpeg1
2.0M  ffmpeg1
```

### 4) df — Filesystem Usage Tool

`df` displays disk usage statistics for file systems.

| Parameter | Description |
|---|---|
| `-h` | Human-readable units |
| `-i` | Show inode count and usage |
| `-T` | Print filesystem type |

#### View Inode Usage

```bash
root@myir:~# df -i
Filesystem       Inodes  IUsed   IFree   IUse%  Mounted on
devtmpfs          37543    477   37066      2%   /dev
/dev/mmcblk1p6   289600  25068  264532      9%   /
tmpfs             54499     17   54482      1%   /dev/shm
/dev/mmcblk1p4    16384     24   16360      1%   /boot
/dev/mmcblk1p7    65536    438   65098      1%   /usr/local
```

> When inode usage reaches 100%, no new files can be written to disk even if disk space is available.

---

## 8.4. Process Management Utils

Linux has three types of processes:

| Type | Description |
|---|---|
| **Interaction Process** | Started by a Shell; can run in foreground or background |
| **Batch Process** | No terminal connection; runs in a queue |
| **Monitor Process (Daemon)** | Always active in background; usually started automatically at boot |

All Linux processes derive from the `init` process (PID 1). New processes are forked from existing ones.

---

### 1) ps — Process Status

```bash
ps aux
```

```
USER  PID  %CPU  %MEM  VSZ    RSS   TTY  STAT  START  TIME  COMMAND
root    1   0.6   1.1  23804  4820  ?    Ss    06:57  0:07  /sbin/init
root    2   0.0   0.0  0      0     ?    S     06:57  0:00  [kthreadd]
...
```

| Field | Description |
|---|---|
| `VSZ` | Virtual memory size |
| `RSS` | Resident (physical) memory size |
| `STAT` | Process state |

**STAT values:**

| Code | Meaning |
|---|---|
| `R` | Running |
| `S` | Interruptible sleep |
| `D` | Uninterruptible sleep |
| `T` | Stopped |
| `Z` | Zombie process |
| `+` | Foreground process |
| `N` | Low priority |
| `l` | Multithreaded |

---

### 2) top — Dynamic Process Monitor

`top` displays real-time system performance and process information on a single screen. See **Section 2.1** for a usage example.

```bash
top -hv | -bcEHiOSs1 -d secs -n max -u|U user -p pid(s) -o field -w [cols]
```

---

### 3) vmstat — Virtual Memory Statistics

`vmstat` provides a snapshot of overall system performance including memory, swap, I/O, and CPU.

#### Basic Output

```bash
root@myir:~# vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd    free   buff  cache   si   so    bi    bo   in   cs  us sy id wa st
 0  0      0  200640  13556 131852    0    0    39    11  148  227   6  3  90  0  0
```

| Field | Description |
|---|---|
| `r` | Number of runnable processes |
| `b` | Number of processes blocked waiting for I/O |
| `in` | Number of system interrupts |
| `cs` | Number of context switches |
| `us` | CPU time consumed by user processes (%) |
| `sy` | CPU time consumed by system/kernel code (%) |
| `wa` | CPU time waiting for I/O (%) |
| `id` | CPU idle time (%) |

#### Detailed Statistics

```bash
root@myir:~# vmstat -s
435992 K total memory
 90008 K used memory
 82380 K active memory
200528 K free memory
 13556 K buffer memory
127150 pages paged in
 36195 pages paged out
969112 interrupts
1492562 CPU context switches
 10649 forks
```

| Field | Description |
|---|---|
| `total memory` | Total system memory |
| `used memory` | Currently used memory |
| `CPU ticks` | CPU time since boot (in tick units) |
| `forks` | Number of new processes created since boot |

---

### 4) kill — Terminate Processes

`kill` sends a signal to a process. Default signal is `SIGTERM (15)`. Use `SIGKILL (9)` to force-terminate.

**Syntax:**
```
kill [-s signal | -p] [-a] pid...
kill -l [signal]
```

| Parameter | Description |
|---|---|
| `-s` | Specify signal to send |
| `-p` | Simulate sending signal |
| `-l` | List signal names |
| `pid` | Process ID to terminate |

#### Find and Kill a Process by Name

```bash
# Find PID
root@myir:~# ps -ef | grep mxapp2
root  1045  1  15  15:51  ?  00:00:02  /home/mxapp2 -platform eglfs

# Kill by PID
root@myir:~# kill 1045
```

#### Kill All Processes by Name

```bash
root@myir:~# killall mxapp2
```

> `killall` terminates all processes in the same process group matching the given name — no PID needed.