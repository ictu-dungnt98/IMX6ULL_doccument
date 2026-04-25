# UUU Documentation Index

Hướng dẫn tra cứu nhanh các tài liệu UUU (Universal Update Utility) trong thư mục này.

---

## 📋 Mục lục

| STT | Tên file | Mô tả | Đường dẫn |
|-----|----------|-------|-----------|
| 1 | [Introduction](#1-introduction) | Giới thiệu tổng quan về UUU, môi trường chạy, cách sử dụng cơ bản | [`Introduction.md`](Introduction.md) |
| 2 | [Syntactic](#2-syntactic) | Cú pháp lệnh, protocols, commands, built-in scripts | [`Syntactic.md`](Syntactic.md) |
| 3 | [Usage Examples](#3-usage-examples) | Các ví dụ thực tế về cách dùng UUU | [`Usage_Example.md`](Usage_Example.md) |
| 4 | [Supported Protocols](#4-supported-protocols) | Danh sách protocols được hỗ trợ, VID/PID, chi tiết từng protocol | [`Supported_protocol.md`](Supported_protocol.md) |
| 5 | [Migration from MFGTool](#5-migration-from-mfgtool) | Hướng dẫn chuyển đổi từ MFGTool ucl2.xml sang UUU | [`Migration_from_mfgtool.md`](Migration_from_mfgtool.md) |
| 6 | [U-Boot Config Requirement](#6-uboot-config-requirement) | Cấu hình U-Boot cần thiết để chạy UUU | [`Uboot_config_requirement.md`](Uboot_config_requirement.md) |

---

## 1. Introduction

**File:** [`Introduction.md`](Introduction.md)

**Nội dung chính:**
- Giới thiệu về UUU (Universal Update Utility)
- Môi trường chạy (Windows 10/Ubuntu 16.04+)
- Cách sử dụng cơ bản
- Firmware cần thiết cho từng tác vụ
- Tự động hoàn thành command (bash/PowerShell)

**Tìm nhanh:**
- Cài đặt môi trường: Xem phần **1.1 Running Environment**
- Lệnh cơ bản: Xem phần **1.2 Typical Usage**
- Firmware cần thiết: Xem bảng **1.5 What Firmware Is Needed**

---

## 2. Syntactic

**File:** [`Syntactic.md`](Syntactic.md)

**Nội dung chính:**
- Command line options (`-d`, `-v`, `-m`, `-s`, `-h`)
- Built-in scripts (`-b emmc`, `-b qspi`, `-b sd`, ...)
- Command format: `PROTOCOL: COMMAND ARG`
- Các protocols: CFG, SDPS, SDP, FB, FBK

**Tìm nhanh:**
- Cú pháp lệnh: Xem phần **2.1 Command Line Usage**
- Built-in scripts: Xem phần **2.2 Built-in Scripts** và bảng scripts
- Protocol SDP commands: Xem phần **5.1 SDP**
- Protocol Fastboot: Xem phần **5.5 FB**
- Protocol Fastboot Kernel: Xem phần **5.6 FBK**

---

## 3. Usage Examples

**File:** [`Usage_Example.md`](Usage_Example.md)

**Nội dung chính:**
- Ví dụ cơ bản (download bootloader, burn images)
- Built-in scripts với tham số cụ thể
- Multi-board support (nhiều board cùng lúc)
- Giao tiếp với Fastboot (boot kernel, write to eMMC)

**Tìm nhanh:**
- Download bootloader iMX6/7: Phần **3.1.1**
- Download bootloader iMX8QXP: Phần **3.1.2**
- Burn Android/Yocto image: Phần **3.1.4** và **3.1.5**
- Burn với built-in scripts: Phần **3.2** (bảng đầy đủ)
- Chạy nhiều board: Phần **3.3**
- Boot Linux kernel qua FB: Phần **3.4.1**
- Write image to eMMC: Phần **3.4.2**

---

## 4. Supported Protocols

**File:** [`Supported_protocol.md`](Supported_protocol.md)

**Nội dung chính:**
- Bảng VID/PID cho từng chip và protocol
- Mapping giữa UUU protocol và USB low-level
- Chi tiết từng protocol: SDP, SDPU/SDPV, SDPS, FB, FBK
- HABv4 closed chip support
- Migration guide từ MFGTool

**Tìm nhanh:**
- VID/PID của chip nào: Xem bảng **Built-in Config Table** (phần đầu)
- Protocol dùng HID hay WinUSB: Xem bảng **Protocol to USB Low-Level Map**
- SDP commands: Phần **5.1 SDP**
- Fastboot commands: Phần **5.5 FB**
- Fastboot Kernel (FBK): Phần **5.6 FBK**
- Chuyển đổi từ MFGTool: Phần **6. Migration from MFGTool ucl2.xml**

---

## 5. Migration from MFGTool

**File:** [`Migration_from_mfgtool.md`](Migration_from_mfgtool.md)

**Nội dung chính:**
- Bảng ánh xạ chi tiết từ ucl2.xml sang UUU script
- Ví dụ minh họa từng loại lệnh

**Tìm nhanh:**
- Xem bảng mapping đầy đủ trong file — mỗi dòng là một lệnh MFGTool và UUU tương ứng

---

## 6. U-Boot Config Requirement

**File:** [`Uboot_config_requirement.md`](Uboot_config_requirement.md)

**Nội dung chính:**
- Cấu hình Fastboot cần thiết trong U-Boot
- Cấu hình SPL/SDP
- Các patches UUU-related cho U-Boot
- Environment variables cần định nghĩa

**Tìm nhanu201c:**
- Fastboot kconfig: Phần **10.1 Fastboot Configuration**
- SPL/SDP config: Phần **10.2 SPL / SDP Configuration**
- Patches có sẵn: Phần **10.3 UUU-Related Patches** và bảng commits
- Environment variables cần thiết: Bảng **10.4 Additional Environment Variables**

---

## 🔍 Mẹo tra cứu nhanh

### Tôi cần...

**Biết firmware cần thiết cho tác vụ X** → Đọc [Introduction.md](Introduction.md) phần **1.5 What Firmware Is Needed**

**Tìm command cho protocol Y** → Đọc [Syntactic.md](Syntactic.md) phần **2.4 Protocols** hoặc [Supported_protocol.md](Supported_protocol.md) phần **5.x**

**Xem built-in scripts nào có sẵn** → Đọc [Syntactic.md](Syntactic.md) phần **2.2 Built-in Scripts** (bảng)

**Burn image lên eMMC/SD/QSPI** → Đọc [Usage_Example.md](Usage_Example.md) phần **3.2** (built-in scripts)

**Chạy nhiều board cùng lúc** → Đọc [Usage_Example.md](Usage_Example.md) phần **3.3**

**Chuyển từ MFGTool sang UUU** → Đọc [Migration_from_mfgtool.md](Migration_from_mfgtool.md)

**Cấu hình U-Boot để hỗ trợ UUU** → Đọc [Uboot_config_requirement.md](Uboot_config_requirement.md)

**Biết VID/PID của chip X** → Đọc [Supported_protocol.md](Supported_protocol.md) bảng **Built-in Config Table**

**Biết protocol nào dùng HID/WinUSB** → Đọc [Supported_protocol.md](Supported_protocol.md) bảng **Protocol to USB Low-Level Map**

---

## 📂 Vị trí các file

Thư mục hiện tại: `embedded_linux_ai_first/docs/uuu/`

```bash
# Đường dẫn tương đối từ docs/
docs/uuu/
├── Introduction.md
├── Syntactic.md
├── Usage_Example.md
├── Supported_protocol.md
├── Migration_from_mfgtool.md
└── Uboot_config_requirement.md
```

---

*File index này được tạo để tra cứu nhanh các tài liệu UUU. Mỗi file đã được đọc và phân tích để cung cấp mô tả ngắn gọn cùng đường dẫn cụ thể.*
