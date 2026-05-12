# MYD-Y6ULX Linux Software Evaluation Guide

> Document: MYIR-MYD-Y6ULX-SW-EG-EN-L5.10.9

The Linux software evaluation guide describes the testing steps and evaluation methods for core and peripheral resources running open source Linux systems on MYIR Electronics' development boards. This document can be used as a preliminary evaluation guide or as a test guide for general system developers.

---

## 1.1. Hardware Resources

This document applies to **MYD-Y6ULX series boards** of MYIR Electronics — a development platform based on the **i.MX6UL series**.

The platform consists of two parts:
- **Core board:** MYC-Y6ULX
- **Bottom board:** MYB-Y6ULX

For detailed hardware configuration parameters, refer to the **"MYD-Y6ULX Product Manual"**.

### Table 1-1. Optional Modules / Accessories

| Accessory | Interface | Description |
|---|---|---|
| Camera | USB | MY-CAM002U (2 MegaPixels) — http://www.myirtech.com/list.asp?id=462 |
| LCD | RGB | MY-TFT070CV2 (7-inch LCD with Capacitive Touch Panel) — http://www.myirtech.com/list.asp?id=477 |
| 4G Module (optional) | USB on Mini PCIe | EC20 — https://www.quectel.com/cn/product/lte-ec20-r2-1 |

---

## 1.2. Software Resources

The BSP of MYD-Y6ULX series is based on the transplantation and modification of the Linux BSP from NXP's official open source community edition. The system image is built using the **Yocto project**.

All software resources — Bootloader, Kernel, and file system — are open in the form of source code. Please check the **"MYD-Y6ULX SDK Release Notes"** for details.

> The development board ships pre-programmed with the **`myir-image-full`** image, so you only need to power it up and start using it.

---

## 1.3. Documents

Depending on the stage of use, the SDK contains different categories of documentation and manuals, including:

- Release Notes
- Evaluation Guides
- Development Guides
- Application Notes
- Frequently Asked Questions (FAQ)

Please refer to **Table 2-4 of "MYD-Y6ULX SDK Release Notes"** for the full document list.

---

## 1.4. Preparation

The following sections focus on how to evaluate and test the system's hardware resources, interfaces, and software functions — using common Linux tools, commands, and application examples provided by MYIR.

The software evaluation guide is divided into several parts:

- Core components
- Peripheral interfaces
- Network applications
- Multimedia applications
- Development support applications
- System tools

Each subsequent chapter provides a comprehensive explanation and detailed evaluation methods and steps for each resource area.