# MYD-Y6ULX Yocto Linux System Development Guide

**Document:** MYIR-MYD-Y6ULX-SW-DG-EN-L5.10.9

---

## Overview

There are many open source system build frameworks on the Linux system platform. These frameworks make it easy for developers to build and customize embedded systems. At present, common similar software includes Buildroot, Yocto, OpenEmbedded, and others.

The Yocto project uses a more powerful and customized approach to build Linux systems suitable for embedded products. Yocto is not only a file system manufacturing tool, but also provides a complete set of Linux-based development and maintenance workflow, so that the embedded developers of the Underlying Software and the High-Level Application can develop under a unified framework, which solves the fragmented and unmanaged development mode in the traditional development mode.

This document mainly introduces the complete process of customizing a complete embedded Linux system based on Yocto project, including the configuration of development environment, how to get the source code, how to port bootloader and kernel, and how to customize rootfs suitable for their own application requirements.

First of all, we will introduce how to build a system image for MYD-Y6ULX development board based on the source code provided by us, and how to burn the prebuilt image to the development board. Then, we focus on the methods and key points of porting the system to the user's hardware platform. In addition, if you are developing a project based on MYC-Y6ULX CPU module, we will also take some actual BSP porting cases and rootfs customization cases as examples to guide users to quickly customize the system image suitable for their own base-board hardware.

> **Note:** This document does not include the introduction of Yocto project and the basic knowledge of Linux system. The user guide is suitable for embedded Linux development engineers with some development experience. For some specific functions that users may use in the process of secondary development, we also provide detailed application notes for reference. Please refer to Table 2-4 of *MYD-Y6ULX SDK Release Notes* for the detailed list of documents.

---

## 1.1 Software Resources

MYD-Y6ULX series development board runs an operating system based on the **Linux 5.10.9** kernel, which also provides a wealth of system resources and other software resources. The resource packages provided with the development board are as follows:

- A software development kit (SDK) for cross-development on a host PC.
- Distribution in source code: U-Boot, Linux Kernel and drivers of each module.
- Various debugging tools for Windows desktop and Linux desktop environments.
- Various peripherals application development samples, etc.

For specific software information, please refer to Table 2-4 of *MYD-Y6ULX SDK Release Notes* for the detailed list of documents.

---

## 1.2 Document Resources

According to the different stages of using the development board, the SDK contains different types of documents and manuals, such as:

- Release Notes
- Introduction Guide
- Evaluation Guide
- Development Guide
- Application Notes
- Frequently Asked Questions and Answers

For the detailed document list, please refer to Table 2-4 of *MYD-Y6ULX SDK Release Notes*.