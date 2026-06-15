# Studying

Folder chứa các nội dung học tập / giải đáp dựa trên tài liệu trong `FORLINX_OKM6ULL-S`
(eMMC datasheet, DDR3L SDRAM datasheet, i.MX 6ULL Reference Manual).

Các chủ đề sẽ được bổ sung khi có câu hỏi.

## Mục lục

- [01 — Quá trình Boot của i.MX6ULL (eMMC + DDR3L)](./01_boot_process_imx6ull_emmc_ddr3l.md)
  — Từ lúc cắm điện → Boot ROM → U-Boot (SPL/proper) → Linux kernel → `init` user space,
  bám theo phần cứng đã chọn (eMMC PS8225, DDR3L MT41K256M16).
