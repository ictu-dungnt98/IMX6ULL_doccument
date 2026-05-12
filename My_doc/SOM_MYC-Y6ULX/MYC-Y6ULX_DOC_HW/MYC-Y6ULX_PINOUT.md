# MYC-Y6ULX Pin List

**Version:** 1.3 | **Date:** 2018.05.18

---

## Pin Table

| Num | Pin Name | BGA289 Ball | Signal Name | Mode | Power Rail | Comment |
|-----|----------|-------------|-------------|------|------------|---------|
| 1 | ONOFF | R8 | ONOFF | Default | 3.3V | if not use, let it floating |
| 2 | POR_B | P8 | POR_B | Default | 3.3V | 10K pull up to 3.3V on SOM |
| 3 | PMIC_ON_REQ | T9 | PMIC_ON_REQ | Default | 3.3V | if not use, let it floating |
| 4 | BOOT_MODE0 | T10 | src.BOOT_MODE[0] | Default / ALT0 / ALT5 (gpio5.IO10) | 3.3V | 10K pull up to 3.3V on SOM |
| 5 | BOOT_MODE1 | U10 | src.BOOT_MODE[1] | Default / ALT0 / ALT5 (gpio5.IO11) | 3.3V | 10K pull up to 3.3V on SOM |
| 6 | GND | — | — | — | — | — |
| 7 | SNVS_TAMPER8 | N9 | snvs_lp_wrapper.SNVS_TD1 / TAMPER8 / gpio5.IO8 | Default / ALT0 / ALT5 | 3.3V | — |
| 8 | SNVS_TAMPER7 | N10 | snvs_lp_wrapper.SNVS_TD1 / TAMPER7 / gpio5.IO7 | Default / ALT0 / ALT5 | 3.3V | — |
| 9 | SNVS_TAMPER6 | N11 | snvs_lp_wrapper.SNVS_TD1 / TAMPER6 / gpio5.IO6 | Default / ALT0 / ALT5 | 3.3V | — |
| 10 | SNVS_TAMPER5 | N8 | snvs_lp_wrapper.SNVS_TD1 / TAMPER5 / gpio5.IO5 | Default / ALT0 / ALT5 | 3.3V | — |
| 11 | SNVS_TAMPER4 | P9 | snvs_lp_wrapper.SNVS_TD1 / TAMPER4 / gpio5.IO4 | Default / ALT0 / ALT5 | 3.3V | — |
| 12 | SNVS_TAMPER3 | P10 | snvs_lp_wrapper.SNVS_TD1 / TAMPER3 / gpio5.IO3 | Default / ALT0 / ALT5 | 3.3V | — |
| 13 | SNVS_TAMPER2 | P11 | snvs_lp_wrapper.SNVS_TD1 / TAMPER2 / gpio5.IO2 | Default / ALT0 / ALT5 | 3.3V | — |
| 14 | SNVS_TAMPER1 | R9 | snvs_lp_wrapper.SNVS_TD1 / TAMPER1 / gpio5.IO1 | Default / ALT0 / ALT5 | 3.3V | — |
| 15 | SNVS_TAMPER0 | R10 | snvs_lp_wrapper.SNVS_TD1 / TAMPER0 / gpio5.IO0 | Default / ALT0 / ALT5 | 3.3V | — |
| 16 | GND | — | — | — | — | — |
| 17 | JTAG_TCK | M14 | sjc.TCK / gpt2.COMPARE2 / sai2.RX_DATA / ccm.OUT1 / pwm7.OUT / gpio1.IO[14] / osc32k.32K_OUT | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6 | 3.3V | 10K pull down to GND on SOM |
| 18 | JTAG_TDI | N16 | sjc.TDI / gpt2.COMPARE1 / sai2.TX_BCLK / ccm.OUT0 / pwm6.OUT / gpio1.IO[13] / mqs.LEFT | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6 | 3.3V | — |
| 19 | JTAG_NTRST | N14 | sjc.TRSTB / gpt2.COMPARE3 / sai2.TX_DATA / ccm.OUT2 / pwm8.OUT / gpio1.IO[15] / anatop.24M_OUT | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6 | 3.3V | — |
| 20 | JTAG_TMS | P14 | sjc.TMS / gpt2.CAPTURE1 / sai2.MCLK / ccm.CLKO1 / ccm.WAIT / gpio1.IO[11] / sdma.EXT_EVENT[1] / epit1.OUT | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT8 | 3.3V | — |
| 21 | JTAG_TDO | N15 | sjc.TDO / gpt2.CAPTURE2 / sai2.TX_SYNC / ccm.CLKO2 / ccm.STOP / gpio1.IO[12] / mqs.RIGHT / epit2.OUT | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT8 | 3.3V | — |
| 22 | JTAG_MOD | P15 | sjc.MOD / gpt2.CLK / spdif.OUT / anatop.ENET_REF_CLK_25M / ccm.PMIC_RDY / gpio1.IO[10] / sdma.EXT_EVENT[0] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6 | 3.3V | 10K pull down to GND on SOM |
| 23 | GND | — | — | — | — | — |
| 24 | USB_OTG2_VBUS | U12 | — | — | — | — |
| 25 | USB_OTG1_VBUS | T12 | — | — | — | — |
| 26 | GND | — | — | — | — | — |
| 27 | USB_OTG2_DP | U13 | — | — | — | — |
| 28 | USB_OTG2_DN | T13 | — | — | — | — |
| 29 | GND | — | — | — | — | — |
| 30 | USB_OTG1_DN | T15 | — | — | — | — |
| 31 | USB_OTG1_DP | U15 | — | — | — | — |
| 32 | GND | — | — | — | — | — |
| 33 | CLK1_N | P16 | — | — | — | — |
| 34 | CLK1_P | P17 | — | — | — | — |
| 35 | GND | — | — | — | — | — |
| 36 | GND | — | — | — | — | — |
| 37 | VDD_3V3 | — | — | — | — | 3.3V input |
| 38 | VDD_3V3 | — | — | — | — | 3.3V input |
| 39 | VDD_BAT | — | — | — | — | if not use, let it floating |
| 40 | GPIO1_IO00 | K13 | gpio1.IO[0] / i2c2.SCL / gpt1.CAPTURE1 / anatop.OTG1_ID / anatop.ENET_REF_CLK1 / mqs.RIGHT / gpio1.IO[0] / enet1.1588_EVENT0_IN / src.SYSTEM_RESET / wdog3.WDOG_B | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | Can be used as analog input, refer to i.MX6UL/6ULL user manual |
| 41 | GPIO1_IO01 | L15 | gpio1.IO[1] / i2c2.SDA / gpt1.COMPARE1 / usb.OTG1_OC / anatop.ENET_REF_CLK2 / mqs.LEFT / gpio1.IO[1] / enet1.1588_EVENT0_OUT / src.EARLY_RESET / wdog1.WDOG_B | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | Can be used as analog input |
| 42 | GPIO1_IO02 | L14 | gpio1.IO[2] / i2c1.SCL / gpt1.COMPARE2 / usb.OTG2_PWR / anatop.ENET_REF_CLK_25M / usdhc1.WP / gpio1.IO[2] / sdma.EXT_EVENT[0] / src.ANY_PU_RESET / uart1.TX | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | Can be used as analog input |
| 43 | GPIO1_IO03 | L17 | gpio1.IO[3] / i2c1.SDA / gpt1.COMPARE3 / usb.OTG2_OC / osc32k.32K_OUT / usdhc1.CD_B / gpio1.IO[3] / ccm.DI0_EXT_CLK / src.TESTER_ACK / uart1.RX | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | Can be used as analog input |
| 44 | GPIO1_IO04 | M16 | gpio1.IO[4] / anatop.ENET_REF_CLK1 / pwm3.OUT / usb.OTG1_PWR / anatop.24M_OUT / usdhc1.RESET_B / gpio1.IO[4] / enet2.1588_EVENT0_IN / ccm.PLL2_BYP / uart5.TX | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | Can be used as analog input |
| 45 | GPIO1_IO05 | M17 | gpio1.IO[5] / anatop.ENET_REF_CLK2 / pwm4.OUT / anatop.OTG2_ID / csi.FIELD / usdhc1.VSELECT / gpio1.IO[5] / enet2.1588_EVENT0_OUT / ccm.PLL3_BYP / uart5.RX | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | Can be used as analog input |
| 46 | MDIO | K17 | enet1.MDIO / enet2.MDIO | ALT0/ALT1 | 3.3V | Can only be used for ENET |
| 47 | MDC | L16 | enet1.MDC / enet2.MDC | ALT0/ALT1 | 3.3V | Can only be used for ENET |
| 48 | GPIO1_IO08 | N17 | gpio1.IO[8] / pwm1.OUT / wdog1.WDOG_B / spdif.OUT / csi.VSYNC / usdhc2.VSELECT / gpio1.IO[8] / ccm.PMIC_RDY / ecspi2.TESTER_TRIGGER / uart5.RTS_B | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | Can be used as analog input |
| 49 | GPIO1_IO09 | M15 | gpio1.IO[9] / pwm2.OUT / global_wdog / spdif.IN / csi.HSYNC / usdhc2.RESET_B / gpio1.IO[9] / usdhc1.RESET_B / ecspi3.TESTER_TRIGGER / uart5.CTS_B | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | Can be used as analog input |
| 50 | GND | — | — | — | — | — |
| 51 | UART1_TXD | K14 | gpio1.IO[16] / uart1.TX / enet1.RDATA[2] / i2c3.SCL / csi.DATA[2] / gpt1.COMPARE1 / gpio1.IO[16] / anatop.USBPHY1_TSTI_TX_LS_MODE / ecspi4.TESTER_TRIGGER / spdif.OUT / uart5.TX | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | Debug UART |
| 52 | UART1_RXD | K16 | gpio1.IO[17] / uart1.RX / enet1.RDATA[3] / i2c3.SDA / csi.DATA[3] / gpt1.CLK / gpio1.IO[17] / anatop.USBPHY1_TSTI_TX_HS_MODE / usdhc1.TESTER_TRIGGER / spdif.IN / uart5.RX | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | Debug UART |
| 53 | UART1_RTS | J14 | gpio1.IO[19] / uart1.RTS_B / enet1.TX_ER / usdhc1.CD_B / csi.DATA[5] / enet2.1588_EVENT1_OUT / gpio1.IO[19] / anatop.USBPHY1_TSTO_RX_SQUELCH / qspi.TESTER_TRIGGER / usdhc2.CD_B / uart5.RTS_B | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 54 | UART1_CTS | K15 | gpio1.IO[18] / uart1.CTS_B / enet1.RX_CLK / usdhc1.WP / csi.DATA[4] / enet2.1588_EVENT1_IN / gpio1.IO[18] / anatop.USBPHY1_TSTI_TX_DN / usdhc2.TESTER_TRIGGER / usdhc2.WP / uart5.CTS_B | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 55 | UART2_TXD | J17 | gpio1.IO[20] / uart2.TX / enet1.TDATA[2] / i2c4.SCL / csi.DATA[6] / gpt1.CAPTURE1 / gpio1.IO[20] / anatop.USBPHY1_TSTO_RX_DISCON_DET / rawnand.TESTER_TRIGGER / ecspi3.SS0 | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 56 | UART2_RXD | J16 | gpio1.IO[21] / uart2.RX / enet1.TDATA[3] / i2c4.SDA / csi.DATA[7] / gpt1.CAPTURE2 / gpio1.IO[21] / anatop.USBPHY1_TSTO_RX_HS_RXD / sjc.DONE / ecspi3.SCLK | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 57 | UART2_RTS | H14 | gpio1.IO[23] / uart2.RTS_B / enet1.COL / can2.RX / csi.DATA[9] / gpt1.COMPARE3 / gpio1.IO[23] / anatop.USBPHY1_TSTO_RX_FS_RXD / sjc.FAIL / ecspi3.MISO | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 58 | UART2_CTS | J15 | gpio1.IO[22] / uart2.CTS_B / enet1.CRS / can2.TX / csi.DATA[8] / gpt1.COMPARE2 / gpio1.IO[22] / anatop.USBPHY2_TSTO_RX_FS_RXD / sjc.DE_B / ecspi3.MOSI | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 59 | GND | — | — | — | — | — |
| 60 | UART3_TXD | H17 | gpio1.IO[24] / uart3.TX / enet2.RDATA[2] / csi.DATA[1] / uart2.CTS_B / gpio1.IO[24] / anatop.USBPHY1_TSTI_TX_DP / sjc.JTAG_ACT / anatop.OTG1_ID | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 61 | UART3_RXD | H16 | gpio1.IO[25] / uart3.RX / enet2.RDATA[3] / csi.DATA[0] / uart2.RTS_B / gpio1.IO[25] / anatop.USBPHY1_TSTI_TX_EN / sim_m.HADDR[0] / epit1.OUT | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 62 | UART3_RTS | G14 | gpio1.IO[27] / uart3.RTS_B / enet2.TX_ER / can1.RX / csi.DATA[11] / enet1.1588_EVENT1_OUT / gpio1.IO[27] / anatop.USBPHY2_TSTO_RX_HS_RXD / sim_m.HADDR[2] / wdog1.WDOG_B | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 63 | UART3_CTS | H15 | gpio1.IO[26] / uart3.CTS_B / enet2.RX_CLK / can1.TX / csi.DATA[10] / enet1.1588_EVENT1_IN / gpio1.IO[26] / anatop.USBPHY1_TSTI_TX_HIZ / sim_m.HADDR[1] / epit2.OUT | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 64 | UART4_TXD | G17 | gpio1.IO[28] / uart4.TX / enet2.TDATA[2] / i2c1.SCL / csi.DATA[12] / csu.CSU_ALARM_AUT[2] / gpio1.IO[28] / anatop.USBPHY1_TSTO_PLL_CLK20DIV / sim_m.HADDR[3] / ecspi2.SCLK | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 65 | UART4_RXD | G16 | gpio1.IO[29] / uart4.RX / enet2.TDATA[3] / i2c1.SDA / csi.DATA[13] / csu.CSU_ALARM_AUT[1] / gpio1.IO[29] / anatop.USBPHY2_TSTO_PLL_CLK20DIV / sim_m.HADDR[4] / ecspi2.SS0 / epdc.PWRCTRL[1] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 66 | UART5_TXD | F17 | gpio1.IO[30] / uart5.TX / enet2.CRS / i2c2.SCL / csi.DATA[14] / csu.CSU_ALARM_AUT[0] / gpio1.IO[30] / anatop.USBPHY2_TSTO_RX_SQUELCH / sim_m.HADDR[5] / ecspi2.MOSI / epdc.PWRCTRL[2] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 67 | UART5_RXD | G13 | gpio1.IO[31] / uart5.RX / enet2.COL / i2c2.SDA / csi.DATA[15] / csu.CSU_INT_DEB / gpio1.IO[31] / anatop.USBPHY2_TSTO_RX_DISCON_DET / sim_m.HADDR[6] / ecspi2.MISO / epdc.PWRCTRL[3] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 68 | GND | — | — | — | — | — |
| 69 | ETH1_LED1 | — | — | — | 3.3V | Built-in Ethernet PHY chip (LAN8720A) pin |
| 70 | ETH1_LED2 | — | — | — | 3.3V | Built-in Ethernet PHY chip (LAN8720A) pin |
| 71 | GND | — | — | — | — | — |
| 72 | ETH1_TXN | — | — | — | A | Built-in Ethernet PHY chip (LAN8720A) pin |
| 73 | ETH1_TXP | — | — | — | A | Built-in Ethernet PHY chip (LAN8720A) pin |
| 74 | GND | — | — | — | — | — |
| 75 | ETH1_RXN | — | — | — | A | Built-in Ethernet PHY chip (LAN8720A) pin |
| 76 | ETH1_RXP | — | — | — | A | Built-in Ethernet PHY chip (LAN8720A) pin |
| 77 | GND | — | — | — | — | — |
| 78 | ENET2_TX_CLK | D17 | gpio2.IO[14] / enet2.TX_CLK / uart8.CTS_B / ecspi4.MISO / anatop.ENET_REF_CLK2 / gpio2.IO[14] / kpp.ROW[7] / sim_m.HADDR[21] / anatop.OTG2_ID | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 79 | ENET2_RXD0 | C17 | gpio2.IO[8] / enet2.RDATA[0] / uart6.TX / i2c3.SCL / enet1.MDIO / gpio2.IO[8] / kpp.ROW[4] / sim_m.HADDR[15] / usb.OTG1_PWR / epdc.SDDO[8] | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 80 | ENET2_CRS_DV | B17 | gpio2.IO[10] / enet2.RX_EN / uart7.TX / i2c4.SCL / weim.ADDR[26] / gpio2.IO[10] / kpp.ROW[5] / sim_m.HADDR[17] / anatop.ENET_REF_CLK_25M / epdc.SDDO[10] | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 81 | ENET2_RXER | D16 | gpio2.IO[15] / enet2.RX_ER / uart8.RTS_B / ecspi4.SS0 / weim.ADDR[25] / gpio2.IO[15] / kpp.COL[7] / sim_m.HADDR[22] / global_wdog / epdc.SDDO[15] | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 82 | ENET2_RXD1 | C16 | gpio2.IO[9] / enet2.RDATA[1] / uart6.RX / i2c3.SDA / enet1.MDC / gpio2.IO[9] / kpp.COL[4] / sim_m.HADDR[16] / usb.OTG1_OC / epdc.SDDO[9] | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 83 | ENET2_TXEN | B15 | gpio2.IO[13] / enet2.TX_EN / uart8.RX / ecspi4.MOSI / weim.ACLK_FREERUN / gpio2.IO[13] / kpp.COL[6] / sim_m.HADDR[20] / usb.OTG2_OC / epdc.SDDO[13] | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 84 | ENET2_TXD1 | A16 | gpio2.IO[12] / enet2.TDATA[1] / uart8.TX / ecspi4.SCLK / weim.EB_B[3] / gpio2.IO[12] / kpp.ROW[6] / sim_m.HADDR[19] / usb.OTG2_PWR / epdc.SDDO[12] | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 85 | ENET2_TXD0 | A15 | gpio2.IO[11] / enet2.TDATA[0] / uart7.RX / i2c4.SDA / weim.EB_B[2] / gpio2.IO[11] / kpp.COL[5] / sim_m.HADDR[18] / anatop.24M_OUT / epdc.SDDO[11] | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 86 | GND | — | — | — | — | — |
| 87 | LCD_DATA0 | B9 | gpio3.IO[5] / lcdif.DATA[0] / pwm1.OUT / ca7_platform.TRACE[0] / enet1.1588_EVENT2_IN / i2c3.SDA / gpio3.IO[5] / src.BT_CFG[0] / sim_m.HADDR[28] / sai1.MCLK / epdc.SDDO[0] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 88 | LCD_DATA1 | A9 | gpio3.IO[6] / lcdif.DATA[1] / pwm2.OUT / ca7_platform.TRACE[1] / enet1.1588_EVENT2_OUT / i2c3.SCL / gpio3.IO[6] / src.BT_CFG[1] / sim_m.HADDR[29] / sai1.TX_SYNC / epdc.SDDO[1] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 89 | LCD_DATA2 | E10 | gpio3.IO[7] / lcdif.DATA[2] / pwm3.OUT / ca7_platform.TRACE[2] / enet1.1588_EVENT3_IN / i2c4.SDA / gpio3.IO[7] / src.BT_CFG[2] / sim_m.HADDR[30] / sai1.TX_BCLK / epdc.SDDO[2] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 90 | LCD_DATA3 | D10 | gpio3.IO[8] / lcdif.DATA[3] / pwm4.OUT / ca7_platform.TRACE[3] / enet1.1588_EVENT3_OUT / i2c4.SCL / gpio3.IO[8] / src.BT_CFG[3] / sim_m.HADDR[31] / sai1.RX_DATA / epdc.SDDO[3] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 91 | LCD_DATA4 | C10 | gpio3.IO[9] / lcdif.DATA[4] / uart8.CTS_B / ca7_platform.TRACE[4] / enet2.1588_EVENT2_IN / spdif.SR_CLK / gpio3.IO[9] / src.BT_CFG[4] / sim_m.HBURST[0] / sai1.TX_DATA / epdc.SDDO[4] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 10K pull up to 3.3V on SOM |
| 92 | LCD_DATA5 | B10 | gpio3.IO[10] / lcdif.DATA[5] / uart8.RTS_B / ca7_platform.TRACE[5] / enet2.1588_EVENT2_OUT / spdif.OUT / gpio3.IO[10] / src.BT_CFG[5] / sim_m.HBURST[1] / ecspi1.SS1 / epdc.SDDO[5] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | NAND: 10K pull down to GND on SOM; EMMC: 10K pull up to VCC on SOM |
| 93 | LCD_DATA6 | A10 | gpio3.IO[11] / lcdif.DATA[6] / uart7.CTS_B / ca7_platform.TRACE[6] / enet2.1588_EVENT3_IN / spdif.LOCK / gpio3.IO[11] / src.BT_CFG[6] / sim_m.HBURST[2] / ecspi1.SS2 / epdc.SDDO[6] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 10K pull up to 3.3V on SOM |
| 94 | LCD_DATA7 | D11 | gpio3.IO[12] / lcdif.DATA[7] / uart7.RTS_B / ca7_platform.TRACE[7] / enet2.1588_EVENT3_OUT / spdif.EXT_CLK / gpio3.IO[12] / src.BT_CFG[7] / sim_m.HMASTLOCK / ecspi1.SS3 / epdc.SDDO[7] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | NAND: 10K pull up to VCC on SOM; EMMC: 10K pull down to GND on SOM |
| 95 | GND | — | — | — | — | — |
| 96 | LCD_DATA8 | B11 | gpio3.IO[13] / lcdif.DATA[8] / spdif.IN / ca7_platform.TRACE[8] / csi.DATA[16] / weim.DATA[0] / gpio3.IO[13] / src.BT_CFG[8] / sim_m.HPROT[0] / can1.TX / epdc.PWRIRQ | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 10K pull down to GND on SOM |
| 97 | LCD_DATA9 | A11 | gpio3.IO[14] / lcdif.DATA[9] / sai3.MCLK / ca7_platform.TRACE[9] / csi.DATA[17] / weim.DATA[1] / gpio3.IO[14] / src.BT_CFG[9] / sim_m.HPROT[1] / can1.RX / epdc.PWRWAKE | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 10K pull down to GND on SOM |
| 98 | LCD_DATA10 | E12 | gpio3.IO[15] / lcdif.DATA[10] / sai3.RX_SYNC / ca7_platform.TRACE[10] / csi.DATA[18] / weim.DATA[2] / gpio3.IO[15] / src.BT_CFG[10] / sim_m.HPROT[2] / can2.TX / epdc.PWRCOM | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 10K pull down to GND on SOM |
| 99 | LCD_DATA11 | D12 | gpio3.IO[16] / lcdif.DATA[11] / sai3.RX_BCLK / ca7_platform.TRACE[11] / csi.DATA[19] / weim.DATA[3] / gpio3.IO[16] / src.BT_CFG[11] / sim_m.HPROT[3] / can2.RX / epdc.PWRSTAT | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | NAND: 10K pull down to GND on SOM; EMMC: 10K pull up to VCC on SOM |
| 100 | LCD_DATA12 | C12 | gpio3.IO[17] / lcdif.DATA[12] / sai3.TX_SYNC / ca7_platform.TRACE[12] / csi.DATA[20] / weim.DATA[4] / gpio3.IO[17] / src.BT_CFG[12] / sim_m.HREADYOUT / ecspi1.RDY / epdc.PWRCTRL[0] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 101 | LCD_DATA13 | B12 | gpio3.IO[18] / lcdif.DATA[13] / sai3.TX_BCLK / ca7_platform.TRACE[13] / csi.DATA[21] / weim.DATA[5] / gpio3.IO[18] / src.BT_CFG[13] / sim_m.HRESP / usdhc2.RESET_B / epdc.BDR[0] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 102 | LCD_DATA14 | A12 | gpio3.IO[19] / lcdif.DATA[14] / sai3.RX_DATA / ca7_platform.TRACE[14] / csi.DATA[22] / weim.DATA[6] / gpio3.IO[19] / src.BT_CFG[14] / sim_m.HSIZE[0] / usdhc2.DATA4 / epdc.SDSHR | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 103 | LCD_DATA15 | D13 | gpio3.IO[20] / lcdif.DATA[15] / sai3.TX_DATA / ca7_platform.TRACE[15] / csi.DATA[23] / weim.DATA[7] / gpio3.IO[20] / src.BT_CFG[15] / sim_m.HSIZE[1] / usdhc2.DATA5 / epdc.GDRL | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 104 | GND | — | — | — | — | — |
| 105 | LCD_DATA16 | C13 | gpio3.IO[21] / lcdif.DATA[16] / uart7.TX / ca7_platform.TRACE_CLK / csi.DATA[1] / weim.DATA[8] / gpio3.IO[21] / src.BT_CFG[24] / sim_m.HSIZE[2] / usdhc2.DATA6 / epdc.GDCLK | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 106 | LCD_DATA17 | B13 | gpio3.IO[22] / lcdif.DATA[17] / uart7.RX / ca7_platform.TRACE_CTL / csi.DATA[0] / weim.DATA[9] / gpio3.IO[22] / src.BT_CFG[25] / sim_m.HWRITE / usdhc2.DATA7 / epdc.GDSP | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 107 | LCD_DATA18 | A13 | gpio3.IO[23] / lcdif.DATA[18] / pwm5.OUT / ca7_platform.EVENTO / csi.DATA[10] / weim.DATA[10] / gpio3.IO[23] / src.BT_CFG[26] / tpsmp.CLK / usdhc2.CMD / epdc.BDR[1] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 108 | LCD_DATA19 | D14 | gpio3.IO[24] / lcdif.DATA[19] / pwm6.OUT / global_wdog / csi.DATA[11] / weim.DATA[11] / gpio3.IO[24] / src.BT_CFG[27] / tpsmp.HDATA_DIR / usdhc2.CLK / epdc.VCOM[0] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 109 | LCD_DATA20 | C14 | gpio3.IO[25] / lcdif.DATA[20] / uart8.TX / ecspi1.SCLK / csi.DATA[12] / weim.DATA[12] / gpio3.IO[25] / src.BT_CFG[28] / tpsmp.HTRANS[0] / usdhc2.DATA0 / epdc.VCOM[1] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 110 | LCD_DATA21 | B14 | gpio3.IO[26] / lcdif.DATA[21] / uart8.RX / ecspi1.SS0 / csi.DATA[13] / weim.DATA[13] / gpio3.IO[26] / src.BT_CFG[29] / tpsmp.HTRANS[1] / usdhc2.DATA1 / epdc.SDCE[1] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 111 | LCD_DATA22 | A14 | gpio3.IO[27] / lcdif.DATA[22] / mqs.RIGHT / ecspi1.MOSI / csi.DATA[14] / weim.DATA[14] / gpio3.IO[27] / src.BT_CFG[30] / tpsmp.HDATA[0] / usdhc2.DATA2 / epdc.SDCE[2] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 112 | LCD_DATA23 | B16 | gpio3.IO[28] / lcdif.DATA[23] / mqs.LEFT / ecspi1.MISO / csi.DATA[15] / weim.DATA[15] / gpio3.IO[28] / src.BT_CFG[31] / tpsmp.HDATA[1] / usdhc2.DATA3 / epdc.SDCE[3] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | 47K pull down to GND on SOM |
| 113 | GND | — | — | — | — | — |
| 114 | LCD_RESET | E9 | gpio3.IO[4] / lcdif.RESET / lcdif.CS / ca7_platform.EVENTI / sai3.TX_DATA / global_wdog / gpio3.IO[4] / anatop.TESTI[3] / sim_m.HADDR[27] / ecspi2.SS3 / epdc.GDOE | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 115 | LCD_VSYNC | C9 | gpio3.IO[3] / lcdif.VSYNC / lcdif.BUSY / uart4.RTS_B / sai3.RX_DATA / wdog2.WDOG_B / gpio3.IO[3] / anatop.TESTI[2] / sim_m.HADDR[26] / ecspi2.SS2 / epdc.SDCE[0] | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 116 | LCD_HSYNC | D9 | gpio3.IO[2] / lcdif.HSYNC / lcdif.RS / uart4.CTS_B / sai3.TX_BCLK / wdog3.WDOG_RST_B_DEB / gpio3.IO[2] / anatop.TESTI[1] / sim_m.HADDR[25] / ecspi2.SS1 / epdc.SDOE | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 117 | LCD_DE | B8 | gpio3.IO[1] / lcdif.ENABLE / lcdif.RD_E / uart4.RX / sai3.TX_SYNC / weim.CS3_B / gpio3.IO[1] / anatop.TESTI[0] / sim_m.HADDR[24] / ecspi2.RDY / epdc.SDLE | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 118 | LCD_PCLK | A8 | gpio3.IO[0] / lcdif.CLK / lcdif.WR_RWN / uart4.TX / sai3.MCLK / weim.CS2_B / gpio3.IO[0] / ocotp_ctrl_wrapper.FUSE_LATCHED / sim_m.HADDR[23] / wdog1.WDOG_RST_B_DEB / epdc.SDCLK | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 119 | NAND_DQS | E6 | gpio4.IO[16] / rawnand.DQS / csi.FIELD / qspiA_SS0_B / pwm5.OUT / weim.WAIT / gpio4.IO[16] / sdma.EXT_EVENT[1] / tpsmp.HDATA[17] / spdif.EXT_CLK | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 120 | NAND_CE1 | B5 | gpio4.IO[14] / rawnand.CE1_B / usdhc1.DATA6 / qspiA_DATA[2] / ecspi3.MOSI / weim.ADDR[18] / gpio4.IO[14] / anatop.TESTO[14] / tpsmp.HDATA[16] / uart3.CTS_B | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 121 | GND | — | — | — | — | — |
| 122 | SD1_DATA3 | A2 | gpio2.IO[21] / usdhc1.DATA3 / gpt2.CAPTURE2 / sai2.TX_DATA / can2.RX / weim.ADDR[24] / gpio2.IO[21] / ccm.CLKO2 / observe_mux.OUT[4] / anatop.OTG2_ID | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 123 | SD1_DATA2 | B1 | gpio2.IO[20] / usdhc1.DATA2 / gpt2.CAPTURE1 / sai2.RX_DATA / can2.TX / weim.ADDR[23] / gpio2.IO[20] / ccm.CLKO1 / observe_mux.OUT[3] / usb.OTG2_OC | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 124 | SD1_DATA1 | B2 | gpio2.IO[19] / usdhc1.DATA1 / gpt2.CLK / sai2.TX_BCLK / can1.RX / weim.ADDR[22] / gpio2.IO[19] / ccm.OUT2 / observe_mux.OUT[2] / usb.OTG2_PWR | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 125 | SD1_DATA0 | B3 | gpio2.IO[18] / usdhc1.DATA0 / gpt2.COMPARE3 / sai2.TX_SYNC / can1.TX / weim.ADDR[21] / gpio2.IO[18] / ccm.OUT1 / observe_mux.OUT[1] / anatop.OTG1_ID | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 126 | SD1_CMD | C2 | gpio2.IO[16] / usdhc1.CMD / gpt2.COMPARE1 / sai2.RX_SYNC / spdif.OUT / weim.ADDR[19] / gpio2.IO[16] / sdma.EXT_EVENT[0] / tpsmp.HDATA[18] / usb.OTG1_PWR | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 127 | SD1_CLK | C1 | gpio2.IO[17] / usdhc1.CLK / gpt2.COMPARE2 / sai2.MCLK / spdif.IN / weim.ADDR[20] / gpio2.IO[17] / ccm.OUT0 / observe_mux.OUT[0] / usb.OTG1_OC | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8 | 3.3V | — |
| 128 | GND | — | — | — | — | — |
| 129 | CSI_DATA7 | D1 | gpio4.IO[28] / csi.DATA[9] / usdhc2.DATA7 / ecspi1.MISO / weim.AD[7] / gpio4.IO[28] / sai1.TX_DATA / tpsmp.HDATA[31] / usdhc1.VSELECT / esai.TX0 | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 130 | CSI_DATA6 | D2 | gpio4.IO[27] / csi.DATA[8] / usdhc2.DATA6 / ecspi1.MOSI / weim.AD[6] / gpio4.IO[27] / sai1.RX_DATA / tpsmp.HDATA[30] / usdhc1.RESET_B / esai.TX5_RX0 | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 131 | CSI_DATA5 | D3 | gpio4.IO[26] / csi.DATA[7] / usdhc2.DATA5 / ecspi1.SS0 / weim.AD[5] / gpio4.IO[26] / sai1.TX_BCLK / tpsmp.HDATA[29] / usdhc1.CD_B / esai.TX_CLK | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 132 | CSI_DATA4 | D4 | gpio4.IO[25] / csi.DATA[6] / usdhc2.DATA4 / ecspi1.SCLK / weim.AD[4] / gpio4.IO[25] / sai1.TX_SYNC / tpsmp.HDATA[28] / usdhc1.WP / esai.TX_FS | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 133 | CSI_DATA3 | E1 | gpio4.IO[24] / csi.DATA[5] / usdhc2.DATA3 / ecspi2.MISO / weim.AD[3] / gpio4.IO[24] / sai1.RX_BCLK / tpsmp.HDATA[27] / uart5.CTS_B / esai.RX_CLK | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 134 | CSI_DATA2 | E2 | gpio4.IO[23] / csi.DATA[4] / usdhc2.DATA2 / ecspi2.MOSI / weim.AD[2] / gpio4.IO[23] / sai1.RX_SYNC / tpsmp.HDATA[26] / uart5.RTS_B / esai.RX_FS | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 135 | CSI_DATA1 | E3 | gpio4.IO[22] / csi.DATA[3] / usdhc2.DATA1 / ecspi2.SS0 / weim.AD[1] / gpio4.IO[22] / sai1.MCLK / tpsmp.HDATA[25] / uart5.RX / esai.RX_HF_CLK | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 136 | CSI_DATA0 | E4 | gpio4.IO[21] / csi.DATA[2] / usdhc2.DATA0 / ecspi2.SCLK / weim.AD[0] / gpio4.IO[21] / src.INT_BOOT / tpsmp.HDATA[24] / uart5.TX / esai.TX_HF_CLK | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 137 | CSI_VSYNC | F2 | gpio4.IO[19] / csi.VSYNC / usdhc2.CLK / i2c2.SDA / weim.RW / gpio4.IO[19] / pwm7.OUT / tpsmp.HDATA[22] / uart6.RTS_B / esai.TX4_RX1 | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 138 | CSI_HSYNC | F3 | gpio4.IO[20] / csi.HSYNC / usdhc2.CMD / i2c2.SCL / weim.LBA_B / gpio4.IO[20] / pwm8.OUT / tpsmp.HDATA[23] / uart6.CTS_B / esai.TX1 | Default/ALT0/ALT1/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 139 | CSI_PIXCLK | E5 | gpio4.IO[18] / csi.PIXCLK / usdhc2.WP / rawnand.CE3_B / i2c1.SCL / weim.OE / gpio4.IO[18] / snvs_hp_wrapper.VIO_5 / tpsmp.HDATA[21] / uart6.RX / esai.TX2_RX3 | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |
| 140 | CSI_MCLK | F5 | gpio4.IO[17] / csi.MCLK / usdhc2.CD_B / rawnand.CE2_B / i2c1.SDA / weim.CS0_B / gpio4.IO[17] / snvs_hp_wrapper.VIO_5_CTL / tpsmp.HDATA[20] / uart6.TX / esai.TX3_RX2 | Default/ALT0/ALT1/ALT2/ALT3/ALT4/ALT5/ALT6/ALT7/ALT8/ALT9 | 3.3V | — |

---

## Notes

- **Power Rail "A"**: Analog signal — part of built-in Ethernet PHY (LAN8720A)
- Pins marked **"if not use, let it floating"** should be left unconnected when unused
- GPIO pins (GPIO1_IO00–GPIO1_IO05, GPIO1_IO08–GPIO1_IO09) **can be used as analog inputs** — refer to i.MX6UL/6ULL user manual for details
- **MDIO / MDC** (pins 46–47): Can only be used for ENET
- **UART1_TXD / UART1_RXD** (pins 51–52): Debug UART
- LCD_DATA pins with NAND/EMMC comments have different pull resistor requirements depending on storage type used on the SOM