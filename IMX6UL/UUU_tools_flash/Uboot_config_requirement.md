# 10. Uboot Config Requirement

To communicate with UUU, uboot needs to have fastboot enabled. Fastboot must also auto-run when a USB boot is detected.

---

## 10.1 Fastboot Configuration

```kconfig
CONFIG_CMD_FASTBOOT=y
CONFIG_USB_FUNCTION_FASTBOOT=y
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_DOWNLOAD=y
CONFIG_USB_GADGET_MANUFACTURER="FSL"
CONFIG_USB_GADGET_VENDOR_NUM=0x0525
CONFIG_USB_GADGET_PRODUCT_NUM=0xa4a5
CONFIG_CI_UDC=y                          # UDC varies by system — some use CONFIG_USB_DWC3, some use CONFIG_USB_CDNS3
CONFIG_FSL_FASTBOOT=y
CONFIG_FASTBOOT=y
CONFIG_FASTBOOT_BUF_ADDR=0x83800000      # Address varies by system; generally same as ${LOADADDR}
CONFIG_FASTBOOT_BUF_SIZE=0x40000000
CONFIG_FASTBOOT_FLASH=y
CONFIG_FASTBOOT_FLASH_MMC_DEV=1
CONFIG_EFI_PARTITION=y
CONFIG_ANDROID_BOOT_IMAGE=y
```

---

## 10.2 SPL / SDP Configuration

If using SPL, SDP must be enabled:

```kconfig
CONFIG_SPL_USB_HOST_SUPPORT=y
CONFIG_SPL_USB_GADGET_SUPPORT=y
CONFIG_SPL_USB_SDP_SUPPORT=y
CONFIG_SDP_LOADADDR=0x40400000           # Address varies by system — choose free memory
```

---

## 10.3 UUU-Related Patches

Patches are available at:
https://source.codeaurora.org/external/imx/uboot-imx/log/?h=imx_v2017.03_4.9.123_imx8mm_ga

**About Fastboot enable:**

| Commit | Description |
|---|---|
| `719651a` | MLK-18257-1: Enable fastboot support in QXP MEK board |
| `d5226a3` | MLK-18257-2: Fix fastboot build warning |
| `219c989` | MLK-18257-3: Run fastboot if initramfs is in validate |
| `09b1876` | MLK-18257-4: Use another method to check if need run `bootcmd_mfg` |
| `3b1fa9d` | MLK-18257-5: Enhance fastboot uboot cmd |
| `ca96e0b` | MLK-18406: Fastboot support all partition |

**About Uboot SDP enable:**

| Commit | Description |
|---|---|
| `192a26d` | MLK-18707-1: SDP: use `CONFIG_SDP_LOADADDR` as default load address |
| `9764fb2` | MLK-18707-2: iMX8M enable fastboot as default |
| `db9a634` | MLK-18862: iMX8MM UUU can write eMMC by fastboot |

---

## 10.4 Additional Environment Variables

The following uboot environment variables must be defined for UUU built-in scripts to work correctly:

| Variable | Used In | Description |
|---|---|---|
| `emmc_dev` | emmc burn | eMMC device number |
| `sd_dev` | burn sd | SD slot device number |
| `kboot` | boot kernel / burn nand | Kernel boot command — `booti` for ARM64, `bootz` for ARM32 |
| `weim_uboot` | burn weim nor | Uboot burn position on WEIM NOR flash |
| `weim_base` | burn weim nor | WEIM base address |
| `mtdparts` | burn nand | NAND flash partition configuration, e.g. `mtdparts=8000000.nor:1m(boot),-(rootfs)\;gpminand:64m(nandboot),16m(nandkernel),16m(nandrootfs)` |
| `spi_bus` | burn spi (not qspi/fspi) | SPI NOR flash bus number |
| `spi_uboot` | burn spi (not qspi/fspi) | SPI NOR flash uboot offset |