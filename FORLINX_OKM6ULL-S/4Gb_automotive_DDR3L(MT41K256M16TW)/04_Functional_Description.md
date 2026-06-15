# Functional Description

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 12–13

<!-- page 12 -->

Functional Description
DDR3 SDRAM uses a double data rate architecture to achieve high-speed operation.
The double data rate architecture is an 8n-prefetch architecture with an interface de-
signed to transfer two data words per clock cycle at the I/O pins. A single read or write
operation for the DDR3 SDRAM effectively consists of a single 8n-bit-wide, four-clock-
cycle data transfer at the internal DRAM core and eight corresponding n-bit-wide, one-
half-clock-cycle data transfers at the I/O pins.
The differential data strobe (DQS, DQS#) is transmitted externally, along with data, for
use in data capture at the DDR3 SDRAM input receiver. DQS is center-aligned with data
for WRITEs. The read data is transmitted by the DDR3 SDRAM and edge-aligned to the
data strobes.
The DDR3 SDRAM operates from a differential clock (CK and CK#). The crossing of CK
going HIGH and CK# going LOW is referred to as the positive edge of CK. Control, com-
mand, and address signals are registered at every positive edge of CK. Input data is reg-
istered on the first rising edge of DQS after the WRITE preamble, and output data is ref-
erenced on the first rising edge of DQS after the READ preamble.
Read and write accesses to the DDR3 SDRAM are burst-oriented. Accesses start at a se-
lected location and continue for a programmed number of locations in a programmed
sequence. Accesses begin with the registration of an ACTIVATE command, which is then
followed by a READ or WRITE command. The address bits registered coincident with
the ACTIVATE command are used to select the bank and row to be accessed. The ad-
dress bits registered coincident with the READ or WRITE commands are used to select
the bank and the starting column location for the burst access.
The device uses a READ and WRITE BL8 and BC4. An auto precharge function may be
enabled to provide a self-timed row precharge that is initiated at the end of the burst
access.
As with standard DDR SDRAM, the pipelined, multibank architecture of DDR3 SDRAM
allows for concurrent operation, thereby providing high bandwidth by hiding row pre-
charge and activation time.
A self refresh mode is provided, along with a power-saving, power-down mode.
Industrial Temperature
The industrial temperature (IT) device requires that the case temperature not exceed
–40°C or 95°C. JEDEC specifications require the refresh rate to double when TC exceeds
85°C; this also requires use of the high-temperature self refresh option. Additionally,
ODT resistance and the input/output impedance must be derated when TC is < 0°C or
>85°C.
Automotive Temperature
The automotive temperature (AT) device requires that the case temperature not exceed
–40°C or 105°C. JEDEC specifications require the refresh rate to double when TC exceeds
85°C; this also requires use of the high-temperature self refresh option. Additionally,
ODT resistance and the input/output impedance must be derated when TC is < 0°C or
>85°C.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Functional Description
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
12
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 13 -->

Utra-high Temperature
The Utra-high temperature (UT) device requires that the case temperature not exceed
–40°C or 125°C. JEDEC specifications require the refresh rate to double when TC exceeds
85°C; this also requires use of the high-temperature auto refresh option. When Tc >
+105C, the refresh rate must be increased to 8X. Self-refresh mode is not available for Tc
>+105°C. Additionally, ODT resistance and the input/output impedance must be derat-
ed when TC is < 0°C or >85°C.
General Notes
• The functionality and the timing specifications discussed in this data sheet are for the
DLL enable mode of operation (normal operation).
• Throughout this data sheet, various figures and text refer to DQs as “DQ.” DQ is to be
interpreted as any and all DQ collectively, unless specifically stated otherwise.
• The terms “DQS” and “CK” found throughout this data sheet are to be interpreted as
DQS, DQS# and CK, CK# respectively, unless specifically stated otherwise.
• Complete functionality may be described throughout the document; any page or dia-
gram may have been simplified to convey a topic and may not be inclusive of all re-
quirements.
• Any specific requirement takes precedence over a general statement.
• Any functionality not specifically stated is considered undefined, illegal, and not sup-
ported, and can result in unknown operation.
• Row addressing is denoted as A[n:0]. For example, 1Gb: n = 12 (x16); 1Gb: n = 13 (x4,
x8); 2Gb: n = 13 (x16) and 2Gb: n = 14 (x4, x8); 4Gb: n = 14 (x16); and 4Gb: n = 15 (x4,
x8).
• Dynamic ODT has a special use case: when DDR3 devices are architected for use in a
single rank memory array, the ODT ball can be wired HIGH rather than routed. Refer
to the Dynamic ODT Special Use Case section.
• A x16 device's DQ bus is comprised of two bytes. If only one of the bytes needs to be
used, use the lower byte for data transfers and terminate the upper byte as noted:
– Connect UDQS to ground via 1kΩ* resistor.
– Connect UDQS# to VDD via 1kΩ* resistor.
– Connect UDM to VDD via 1kΩ* resistor.
– Connect DQ[15:8] individually to either VSS, VDD, or VREF via 1kΩ resistors,* or float
DQ[15:8].
*If ODT is used, 1kΩ resistor should be changed to 4x that of the selected ODT.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Functional Description
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
13
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

