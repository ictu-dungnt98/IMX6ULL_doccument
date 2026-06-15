# Chapter 8: System Boot

> Nguồn: `IMX6ULLRM.pdf` — trang 249–334

<!-- page 249 -->

Chapter 8
System Boot
8.1
Overview
The boot process begins at the Power-On Reset (POR) where the hardware reset logic
forces the Arm core to begin the execution starting from the on-chip boot ROM.
The boot ROM code uses the state of the internal register BOOT_MODE[1:0] as well as
the state of various eFUSEs and/or GPIO settings to determine the boot flow behavior of
the device.
The main features of the ROM include:
• Support for booting from various boot devices
• Serial downloader support (USB OTG and UART)
• Device Configuration Data (DCD) and plugin
• Digital signature and encryption based High-Assurance Boot (HAB)
• Wake-up from the low-power modes
The boot ROM supports these boot devices:
• NOR flash
• NAND flash
• OneNAND flash
• SD/MMC
• Serial (SPI) NOR flash and EEPROM
• QuadSPI (QSPI) flash
The boot ROM uses the state of the BOOT_MODE and eFUSEs to determine the boot
device. For development purposes, the eFUSEs used to determine the boot device may be
overridden using the GPIO pin inputs.
The boot ROM code also allows to download the programs to be run on the device. The
example is a provisioning program that can make further use of the serial connection to
provide a boot device with a new image. Typically, the provisioning program is
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
249

<!-- page 250 -->

downloaded to the internal RAM and allows to program the boot devices, such as the
SD/MMC flash. The ROM serial downloader uses a high-speed USB in a non-stream
mode connection and the UART in a stream mode connection.
The boot ROM allows waking up from the low-power modes. On reset, the ROM checks
the power gating status register. When waking from the low-power mode, the core skips
loading an image from the boot device and jumps to the address saved in
PERSISTENT_ENTRY0.
The Device Configuration Data (DCD) feature allows the boot ROM code to obtain the
SOC configuration data from an external program image residing on the boot device. As
an example, the DCD can be used to program the DDR controller for optimal settings,
improving the boot performance. The DCD is restricted to the memory areas and
peripheral addresses that are considered essential for the boot purposes (see Write data
command).
A key feature of the boot ROM is the ability to perform a secure boot, also known as a
High-Assurance Boot (HAB). This is supported by the HAB security library which is a
subcomponent of the ROM code. The HAB uses a combination of hardware and software
together with the Public Key Infrastructure (PKI) protocol to protect the system from
executing unauthorized programs. Before the HAB allows the user image to execute, the
image must be signed. The signing process is done during the image build process by the
private key holder and the signatures are then included as a part of the final program
image. If configured to do so, the ROM verifies the signatures using the public keys
included in the program image. In addition to supporting the digital signature verification
to authenticate the program images, the encrypted boot is also supported. The encrypted
boot can be used to prevent the cloning of the program image directly off the boot device.
A secure boot with HAB can be performed on all boot devices supported on the chip in
addition to the serial downloader. The HAB library in the boot ROM also provides the
API functions, allowing the additional boot chain components (bootloaders) to extend the
secure boot chain. The out-of-fab setting for the SEC_CONFIG is the open configuration,
in which the ROM/HAB performs the image authentication, but all authentication errors
are ignored and the image is still allowed to execute.
8.2
Boot modes
During reset, the chip checks the power gating controller status register.
During boot, the core's behavior is defined by the boot mode pin settings, as described in
Boot mode pin settings. When waking up from the low-power boot mode, the core skips
the clock settings. The boot ROM checks that the PERSISTENT_ENTRY0 (see
Boot modes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
250
NXP Semiconductors

<!-- page 251 -->

Persistent bits) is a pointer to a valid address space (OCRAM, DDR, QSPI, or EIM). If
the PERSISTENT_ENTRY0 is a pointer to a valid range, it starts the execution using the
entry point from the PERSISTENT_ENTRY0 register. If the PERSISTENT_ENTRY0 is
a pointer to an invalid range, the core performs the system reset.
8.2.1
Boot mode pin settings
The device has four boot modes (one is reserved for NXP use). The boot mode is selected
based on the binary value stored in the internal BOOT_MODE register.
The BOOT_MODE is initialized by sampling the BOOT_MODE0 and BOOT_MODE1
inputs on the rising edge of the POR_B. After these inputs are sampled, their subsequent
state does not affect the contents of the BOOT_MODE internal register. The state of the
internal BOOT_MODE register may be read from the BMOD[1:0] field of the SRC Boot
Mode Register (SRC_SBMR2). The available boot modes are: Boot From Fuses, serial
boot via USB, and Internal Boot. See this table for settings:
Table 8-1. Boot MODE pin settings
BOOT_MODE[1:0]
Boot Type
00
Boot From Fuses
01
Serial Downloader
10
Internal Boot
11
Reserved
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
251

<!-- page 252 -->

8.2.2
High-level boot sequence
The figure found here show the high-level boot ROM code flow.
Reset
Check CPU ID
(using Cortex-A7 MPIDR)
Check Reset
Type
Use wakeup handler and 
argument From SRC registers
Check wakeup handler
In valid range
Execute Image
System 
Reset
No
0
Yes
Download initial boot image 
(primary or secondary 
depending on persistent bit)
Authenticate Image
Download And Authenticate
Image via USB
Primary 
Image?
Set secondary image
Persistent bit and 
perform SW reset
End
Download And Authenticate
Image from Serial EEPROM
Primary boot
device is Serial EEPROM 
/Flash
No
Fail
Fail
Pass
Pass
Yes
Pass
Internal
No
Normal
Serial
Yes
Fail
Fail
Check Boot Mode 
(using fuses and/or 
GPIOs)
Is Wakeup allowed
Clear Power Low
Power Status
Yes
No
/Flash
Figure 8-1. Boot flow
8.2.3
Boot From Fuses mode (BOOT_MODE[1:0] = 00b)
A value of 00b in the BOOT_MODE[1:0] register selects the Boot From Fuses mode.
Boot modes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
252
NXP Semiconductors

<!-- page 253 -->

This mode is similar to the Internal Boot mode described in Internal Boot mode
(BOOT_MODE[1:0] = 0b10) with one difference. In this mode, the GPIO boot override
pins are ignored. The boot ROM code uses the boot eFUSE settings only. This mode also
supports a secure boot using HAB.
If set to Boot From Fuses, the boot flow is controlled by the BT_FUSE_SEL eFUSE
value. If BT_FUSE_SEL = 0, indicating that the boot device (for example, flash, SD/
MMC) was not programmed yet, the boot flow jumps directly to the Serial Downloader.
If BT_FUSE_SEL = 1, the normal boot flow is followed, where the ROM attempts to
boot from the selected boot device.
The first time a board is used, the default eFUSEs may be configured incorrectly for the
hardware on the platform. In such case, the Boot ROM code may try to boot from a
device that does not exist. This may cause an electrical/logic violation on some pads.
Using the Boot From Fuses mode addresses this problem.
Setting the BT_FUSE_SEL=0 forces the ROM code to jump directly to the Serial
Downloader. This allows a bootloader to be downloaded which can then provision the
boot device with a program image and blow the BT_FUSE_SEL and the other boot
configuration eFUSEs. After the reset, the boot ROM code determines that the
BT_FUSE_SEL is blown (BT_FUSE_SEL = 1) and the ROM code performs an internal
boot according to the new eFUSE settings. This allows the user to set
BOOT_MODE[1:0]=00b on a production device and burn the fuses on the same device
(by forcing the entry to the Serial Downloader), without changing the value of the
BOOT_MODE[1:0] or the pullups/pulldowns on the BOOT_MODE pins.
8.2.4
Serial Downloader
The Serial Downloader provides a means to download a program image to the chip over
the USB and UART serial connection.
In this mode, the ROM programs the WDOG1 for a time-out specified by the fuse
WDOG Time-out Select (See fusemap for details) if the WDOG_ENABLE eFuse is 1
and continuously polls for the USB and UART connection. If no activity is found on the
USB OTG1and UART 1/2 and the watchdog timer expires, the Arm core is reset.
NOTE
After the downloaded image is loaded, it is responsible for
managing the watchdog resets properly.
This figure shows the USB and UART boot flow:
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
253

<!-- page 254 -->

START
Reset
UART Serial Download
function is enabled
Configure UART 1 / 2
Program WDOG for X seconds
(Default is 64 seconds)
Poll UART 1 / 2
Complete UART 1 / 2
Initialization
Ready for Serial
Download
Configure USB OTG1
UART Serial Download
function is enabled
Poll USB OTG1
UART 1 / 2 Activity 
Detected
Complete USB HID enumeration, 
due to activity detected 
WDOG_ENABLE==1 
&& WDOG timeout
USB OTG1 Activity
Detected
Yes
Yes
Yes
Yes
Yes
Yes
No
No
No
No
No
WDOG_ENABLE==1
Figure 8-2. Serial Downloader boot flow
Boot modes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
254
NXP Semiconductors

<!-- page 255 -->

8.2.5
Internal Boot mode (BOOT_MODE[1:0] = 0b10)
A value of 0b10 in the BOOT_MODE[1:0] register selects the Internal Boot mode. In
this mode, the processor continues to execute the boot code from the internal boot ROM.
The boot code performs the hardware initialization, loads the program image from the
chosen boot device, performs the image validation using the HAB library (see Boot
security settings), and then jumps to an address derived from the program image. If an
error occurs during the internal boot, the boot code jumps to the Serial Downloader (see
Serial Downloader). A secure boot using the HAB is possible in all the three boot modes.
When set to the Internal Boot, the boot flow may be controlled by a combination of
eFUSE settings with an option of overriding the fuse settings using the General Purpose
I/O (GPIO) pins. The GPIO Boot Select FUSE (BT_FUSE_SEL) determines whether the
ROM uses the GPIO pins for a selected number of configuration parameters or eFUSEs
in this mode.
• If BT_FUSE_SEL = 1, all boot options are controlled by the eFUSEs described in
Table 8-2.
• If BT_FUSE_SEL = 0, the specific boot configuration parameters may be set using
the GPIO pins rather than eFUSEs. The fuses that can be overridden when in this
mode are indicated in the GPIO column of Table 8-2. Table 8-3 provides the details
of the GPIO pins.
The use of the GPIO overrides is intended for development since these pads are used for
other purposes in the deployed products. NXP recommends controlling the boot
configuration by the eFUSEs in the deployed products and reserving the use of the GPIO
mode for the development and testing purposes only.
8.2.6
Boot security settings
The internal boot modes use one of three security configurations.
• Closed: This level is intended for use with shipping-secure products. All HAB
functions are executed and the security hardware is initialized (the Security
Controller or SNVS enters the Secure state), the DCD is processed if present, and the
program image is authenticated by the HAB before its execution. All detected errors
are logged, and the boot flow is aborted with the control being passed to the serial
downloader. At this level, the execution does not leave the internal ROM unless the
target executable image is authenticated.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
255

<!-- page 256 -->

• Open: This level is intended for use in non-secure products or during the
development phases of a secure product. All HAB functions are executed as for a
closed device. The security hardware is initialized (except for the SNVS which is left
in the Non-Secure state), the DCD is processed if present, and the program image is
authenticated by the HAB before its execution. All detected errors are logged, but
have no influence on the boot flow which continues as if the errors did not occur.
This configuration is useful for a secure product development because the program
image runs even if the authentication data is missing or incorrect, and the error log
can be examined to determine the cause of the authentication failure.
• Field Return: This level is intended for the parts returned from the shipped products.
8.3
Device configuration
This section describes the external inputs that control the behavior of the Boot ROM
code.
This includes the boot device selection (SPI, EIM, NOR, SD, MMC, QSPI, and so on),
boot device configuration (SD bus width, speed, and so on), and other. In general, the
source for this configuration comes from the eFUSEs embedded inside the chip.
However, certain configuration parameters can be sourced from the GPIO pins, allowing
further flexibility during the development process.
8.3.1
Boot eFUSE descriptions
This table is a comprehensive list of the configuration parameters that the ROM uses.
Table 8-2. Boot eFUSE descriptions
Fuse
Config
uratio
n
Definition
GPIO1
Shipped
value
Settings2
DIR_BT_DIS
OEM
Disables the NXP reserved
modes.
NA
0
0—The reserved NXP modes are enabled.
1—The reserved NXP modes are disabled.
This fuse must be blown to 1 for normal
operation.
BT_FUSE_SEL
OEM
In the Internal Boot mode
BOOT_MODE[1:0] = 10,
the BT_FUSE_SEL fuse
determines whether the
boot settings indicated by a
Yes in the GPIO column are
controlled by the GPIO pins
NA
0
If BOOT_MODE[1:0] = 0b10:
• 0—The bits of the SBMR are
overridden by the GPIO pins.
• 1—The specific bits of the SBMR are
controlled by the eFUSE settings.
If BOOT_MODE[1:0] = 0b00
Table continues on the next page...
Device configuration
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
256
NXP Semiconductors

<!-- page 257 -->

Table 8-2. Boot eFUSE descriptions
(continued)
Fuse
Config
uratio
n
Definition
GPIO1
Shipped
value
Settings2
or the eFUSE settings in
the On-Chip OTP Controller
(OCOTP).
In the Boot From Fuse
mode BOOT_MODE[1:0] =
00, the BT_FUSE_SEL fuse
indicates whether the bit
configuration eFuses are
programmed.
• 0—The BOOT configuration eFuses
are not programmed yet. The boot
flow jumps to the serial downloader.
• 1—The BOOT configuration eFuses
are programmed. The regular boot
flow is performed.
SEC_CONFIG[1:0]
SEC_C
ONFIG[
0] -
NXP
SEC_C
ONFIG[
1] -
OEM
Security Configuration, as
defined in Boot security
settings
NA
01
00—Reserved
01—Open (allows any program image,
even if the authentication fails)
1x—Closed (The program image executes
only if authenticated)
FIELD_RETURN
OEM
Enables the NXP reserved
modes.
0—The NXP reserved modes are enabled/
disabled based on the DIR_BT_DIS value.
1—The NXP reserved modes are enabled.
SRK_HASH[255:0]
OEM
256-bit hash value of the
super root key
(SRK_HASH)
NA
0
Settings vary—used by HAB
UNIQUE_ID[63:0]
NXP
Device Unique ID, 64-bit
UID
NA
Unique
ID
Settings vary—used by HAB
BT_MMU_DISABLE
OEM
The MMU/L1 D Cache/
PL310 disable bit used by
the boot ROM for fast HAB
processing.
No
0
0—MMU/L1 D Cache/PL310 is enabled by
the ROM during the boot.
1—MMU/L1 D Cache/PL310 is disabled by
the ROM during the boot.
L1 I-Cache DISABLE
OEM
L1 I Cache disable bit used
by the boot during the entire
execution.
No
0
0—L1 I Cache is enabled by the ROM
during the boot.
1—L1 I Cache is disabled by the ROM
during the boot.
BT_FREQ
OEM
Boot frequency selection
Yes
0
0—Arm—396 MHz, DDR—396 MHz, AXI—
198 MHz
1—Arm—198 MHz, DDR—307 MHz, AXI—
153 MHz
BOOT_CFG1[7:0]
OEM
Boot configuration 1
Yes
0
Specific to the selected boot mode
BOOT_CFG2[7:0]
OEM
Boot configuration 2
Yes
0
Specific to the selected boot mode
BOOT_CFG4[6:0]
OEM
Boot configuration 4
0
Specific to the selected boot mode
BOOT_CFG4[7]
OEM
Infinite Loop Enable at the
start of the boot ROM. Used
for debugging purposes.
Ignored if the DIR_BT_DIS
Yes
0
0—Disabled
1—Enabled
Table continues on the next page...
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
257

<!-- page 258 -->

Table 8-2. Boot eFUSE descriptions
(continued)
Fuse
Config
uratio
n
Definition
GPIO1
Shipped
value
Settings2
is 1 and FIELD_RETURN is
0.
LPB_BOOT
OEM
USB Low-Power Boot
No
0
00—396 MHz
01—396 MHz
10—198 MHz
11—99 MHz
BT_LPB_POLARITY
OEM
USB Low-Power Boot GPIO
polarity
No
0
0—Low on the GPIO pad indicates the low-
power condition.
1—High on the GPIO pad indicates the
low-power condition.
WDOG_ENABLE
OEM
Watchdog reset counter
enable
No
0
0—The watchdog reset counter is disabled
during the serial downloader.
1—The watchdog reset counter is enabled
during the serial downloader.
SRK_REVOKE[2:0]
OEM
SRK revocation mask
No
0
SRK revocation mask
DISABLE_SDMMC_M
FG
OEM
Disable the SDMMC
manufacture mode
Yes
0
0—enable the SD/MMC MFG mode
1—disable the SD/MMC MFG mode
PAD_SETTINGS
OEM
Override values for the
SD/MMC and NAND boot
modes
No
0
Override these IO PAD settings:
• PAD_SETTINGS[0]—Slew Rate
• PAD_SETTINGS[3:1]—Drive
Strength
• PAD_SETTINGS[5:4]—Speed
Settings
.
1.
This setting can be overridden by the GPIO settings when the BT_FUSE_SEL fuse is intact. See GPIO Boot Overrides for
the corresponding GPIO pin.
2.
0 = intact fuse and 1= blown fuse
8.3.2
GPIO boot overrides
This table provides a list of the GPIO boot overrides:
Table 8-3. GPIO override contact assignments
Package pin
Direction on reset
eFuse
BOOT_MODE1
Input
Boot mode selection
BOOT_MODE0
Input
Table continues on the next page...
Device configuration
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
258
NXP Semiconductors

<!-- page 259 -->

Table 8-3. GPIO override contact assignments (continued)
Package pin
Direction on reset
eFuse
LCD1_DATA00
Input
BOOT_CFG1[0]
LCD1_DATA01
Input
BOOT_CFG1[1]
LCD1_DATA02
Input
BOOT_CFG1[2]
LCD1_DATA03
Input
BOOT_CFG1[3]
LCD1_DATA04
Input
BOOT_CFG1[4]
LCD1_DATA05
Input
BOOT_CFG1[5]
LCD1_DATA06
Input
BOOT_CFG1[6]
LCD1_DATA07
Input
BOOT_CFG1[7]
LCD1_DATA08
Input
BOOT_CFG2[0]
LCD1_DATA09
Input
BOOT_CFG2[1]
LCD1_DATA10
Input
BOOT_CFG2[2]
LCD1_DATA11
Input
BOOT_CFG2[3]
LCD1_DATA12
Input
BOOT_CFG2[4]
LCD1_DATA13
Input
BOOT_CFG2[5]
LCD1_DATA14
Input
BOOT_CFG2[6]
LCD1_DATA15
Input
BOOT_CFG2[7]
LCD1_DATA16
Input
BOOT_CFG4[0]
LCD1_DATA17
Input
BOOT_CFG4[1]
LCD1_DATA18
Input
BOOT_CFG4[2]
LCD1_DATA19
Input
BOOT_CFG4[3]
LCD1_DATA20
Input
BOOT_CFG4[4]
LCD1_DATA21
Input
BOOT_CFG4[5]
LCD1_DATA22
Input
BOOT_CFG4[6]
LCD1_DATA23
Input
BOOT_CFG4[7]
The input pins provided are sampled at boot, and can be used to override the
corresponding eFUSE values, depending on the setting of the BT_FUSE_SEL fuse.
8.3.3
Device Configuration Data (DCD)
The DCD is the configuration information contained in the program image (external to
the ROM) that the ROM interprets to configure various on-chip peripherals. See Device
Configuration Data (DCD) for more details on DCD.
8.4
Device initialization
This section describes the details of the ROM and provides the initialization details.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
259

<!-- page 260 -->

This includes details on:
• The ROM memory map
• The RAM memory map
• On-chip blocks that the ROM must use or change the POR register default values
• Clock initialization
• Enabling the MMU/L2 cache
• Exception handling and interrupt handling
8.4.1
Internal ROM/RAM memory map
These figures show the iROM memory map:
ROM Boot Strap
0x00000000
0x00000200
OCRAM Free Area
(68KB)
Reserved 
(28KB)
0x00900000
ROM Memory Map
RAM Memory Map
Reset Exception Handler
ROM Version and 
Copyright Information
0x00000080
HAB API Vector Table
0x00000100
0x00907000
MMU Table
(20KB)
0x00918000
Stack
(8120 bytes)
0x0091D000
0x0091FFB8
ROM API Vector Table
0x00000180
Log Buffer Pointer
0x000001E0
RAM Exception Vector
0x0091FFFF
0x00017FFF
Reserved
( 4KB )
0x0091E000
Figure 8-3. Internal ROM and RAM memory map
NOTE
The entire OCRAM region can be used freely after the boot.
Device initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
260
NXP Semiconductors

<!-- page 261 -->

8.4.2
Boot block activation
The boot ROM affects a number of different hardware blocks which are activated and
play a vital role in the boot flow.
The ROM configures and uses the following blocks (listed in an alphabetical order)
during the boot process. Note that the blocks actually used depend on the boot mode and
the boot device selection:
• APBH—the DMA engine to drive the GPMI module
• BCH—40-bit error correction hardware engine with the AXI bus master and a
private connection to the GPMI
• CCM—Clock Control Module
• ECSPI—Enhanced Configurable Serial Peripheral Interface
• EIM—External Interface Module used for the NOR and OneNAND devices
• GPMI—NAND controller pin interface
• OCOTP_CTRL—On-Chip OTP Controller; the OCOTP contains the eFUSEs
• IOMUXC—I/O Multiplexer Control which allows the GPIO use to override the
eFUSE boot settings;
• IOMUXC GPR—I/O Multiplexer Control General-Purpose Registers
• DCP—Data Co-Processor
• QSPI—QuadSPI flash
• SNVS—Secure Non-Volatile Storage
• SRC—System Reset Controller
• UART—Universal Asynchronous Receiver/Transmitter controller
• USB—used for the serial download of a boot device provisioning program
• USDHC—Ultra-Secure Digital Host Controller
• WDOG-1—Watchdog timer
8.4.3
Clocks at boot time
The table below show the various clocks and their sources used by the ROM.
Table 8-4. Normal frequency clocks configuration
Clock
CCM signal
Source
Frequency (MHz)
BT_FREQ=0
Frequency (MHz)
BT_FREQ=1
ARM PLL
pll1_sw_clk
396
396
System PLL
pll2_sw_clk
528
528
USB PLL
pll3_sw_clk
480
480
AHB
ahb_clk_root
528 MHz PLL/PFD352
132
88
IPG
ipg_clk_root
528 MHz PLL/PFD352
66
44
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
261

<!-- page 262 -->

After the reset, each Arm core has access to all peripherals. The ROM code disables the
clocks listed in the following table, except for the boot devices listed in the second
column.
Table 8-5. List of disabled clocks
Clock name
Enabled for boot device
CCGR0_APBHDMA_CLK_SEL
NAND
CCGR0_ASRC_CLK_SEL
CCGR0_CAN1_CLK_SEL
CCGR0_CAN1_SERIAL_CLK_SEL
CCGR0_CAN2_CLK_SEL
CCGR0_CAN2_SERIAL_CLK_SEL
CCGR0_UART2_CLK_SEL
UART2
CCGR1_ECSPI1_CLK_SEL
ECSPI1
CCGR1_ECSPI2_CLK_SEL
ECSPI2
CCGR1_ECSPI3_CLK_SEL
ECSPI3
CCGR1_ECSPI4_CLK_SEL
ECSPI4
CCGR1_EPIT1_CLK_SEL
CCGR1_EPIT2_CLK_SEL
CCGR1_ADC1_CLK_SEL
CCGR1_ADC2_CLK_SEL
CCGR1_UART3_CLK_SEL
CCGR1_UART4_CLK_SEL
CCGR2_CSI_CLK_SEL
CCGR3_CSI_CORE_CLK_SEL
CCGR2_I2C1_CLK_SEL
CCGR2_I2C2_CLK_SEL
CCGR2_I2C3_CLK_SEL
CCGR2_LCD_CLK_SEL
CCGR2_PXP_CLK_SEL
CCGR3_ENET_CLK_SEL
CCGR3_LCDIF_PIX_CLK_SEL
CCGR3_QSPI1_CLK_SEL
QSPI1
CCGR3_UART5_CLK_SEL
CCGR3_UART6_CLK_SEL
CCGR4_PWM1_CLK_SEL
CCGR4_PWM2_CLK_SEL
CCGR4_PWM3_CLK_SEL
CCGR4_PWM4_CLK_SEL
CCGR4_RAWNAND_U_BCH_INPUT_A_CLK_SEL
NAND
CCGR4_RAWNAND_U_GPMI_BCH_INPUT_BCG_CLK_SEL
NAND
CCGR4_RAWNAND_U_GPMI_BCH_INPUT_GPMI_CLK_SEL
NAND
Table continues on the next page...
Device initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
262
NXP Semiconductors

<!-- page 263 -->

Table 8-5. List of disabled clocks (continued)
Clock name
Enabled for boot device
CCGR4_RAWNAND_U_GPMI_INPUT_APB_CLK_SEL
NAND
CCGR4_TSC_CLK_SEL
CCGR5_SDMA_CLK_SEL
CCGR5_SPDIF_CLK_SEL
CCGR5_SPBA_CLK_SEL
CCGR5_UART1_CLK_SEL
CCGR5_UART7_CLK_SEL
CCGR5_KPP_CLK_SEL
CCGR5_SAI1_CLK_SEL
CCGR5_SAI2_CLK_SEL
CCGR5_SAI3_CLK_SEL
CCGR6_USBOH3_CLK_SEL
USB
CCGR6_USDHC1_CLK_SEL
USDHC1
CCGR6_USDHC2_CLK_SEL
USDHC2
CCGR6_EMI_SLOW_CLK_SEL
NOR, OneNAND
CCGR6_PWM8_CLK_SEL
CCGR6_SIM1_CLK_SEL
CCGR6_SIM2_CLK_SEL
CCGR6_I2C4_SERIAL_CLK_SEL
CCGR6_PWM5_CLK_SEL
CCGR6_PWM6_CLK_SEL
CCGR6_PWM7_CLK_SEL
CCGR6_UART8_CLK_SEL
8.4.4
Enabling MMU and caches
The boot ROM includes a feature that enables the Memory Management Unit (MMU)
and the caches to improve the boot speed.
The L1 instruction cache is enabled at the start of the image download. The L1 data
cache, L2 cache, and MMU are enabled during the image authentication. When the HAB
authentication completes, the ROM disables the L1 data cache, L2 cache, and MMU.
The L1 Instruction cache, L1 data cahce, L2 cache, and MMU is controlled by eFuse. By
default, these features are enabled.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
263

<!-- page 264 -->

Enabling the MMU when booting non-securely with SEC_CONFIG=Open and setting
the CSF pointer in the Image Vector Table to NULL has no impact on the boot
performance. With this configuration, it is recommended to blow the
BT_MMU_DISABLE fuse.
8.4.5
Exception handling
The exception vectors located at the start of the ROM are used to map all the Arm
exceptions (except the reset exception) to a duplicate exception vector table in the
internal RAM.
During the boot phase of CPU0, the RAM vectors point to the serial downloader in the
ROM.
After the boot, the program image can overwrite the vectors as required. The code shown
below is used to map the ROM exception vector table to the duplicate exception vector
table in the RAM.
Mapping ROM Exception Vector Table
;; Define linker area for ROM exception vector table
AREA IROM_VECTORS, CODE, READONLY
LDR     PC, Reset_Addr
LDR     PC, Undefined_Addr
LDR     PC, SWI_Addr
LDR     PC, Prefetch_Addr
LDR     PC, Abort_Addr
NOP                         ; Reserved vector
LDR     PC, IRQ_Addr
LDR     PC, FIQ_Addr
;; Define exception vector table
Reset_Addr      DCD     start_address
Undefined_Addr  DCD     iRAM_Undefined_Handler
SWI_Addr        DCD     iRAM_SWI_Handler
Prefetch_Addr   DCD     iRAM_Prefetch_Handler
Abort_Addr      DCD     iRAM_Abort_Handler
                DCD     0               ; Reserved vector
IRQ_Addr        DCD     iRAM_IRQ_Handler
FIQ_Addr        DCD     iRAM_FIQ_Handler
start_address DCD start ;reset handler vector
8.4.6
Interrupt handling during boot
No special interrupt-handling routines are required during the boot process. The
interrupts are disabled during the boot ROM execution and may be enabled in a later boot
stage.
Device initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
264
NXP Semiconductors

<!-- page 265 -->

8.4.7
Persistent bits
Some modes of the boot ROM require the registers that keep their values after a warm
reset. The SRC General-Purpose registers are used for this purpose.
See this table for persistent bits list and description:
Table 8-6. Persistent bits
Bit name
Bit location
Description
PERSIST_SECONDARY_BOOT
SRC_GPR10[30]
This bit identifies which image must be used—
primary and secondary. Used only for the boot
modes that support redundant boot.
PERSIST_BLOCK_REWRITE
SRC_GPR10[29]
This bit is used as a warning. It identifies that there
are errors in the NAND blocks that hold the
application image.
See NAND flash for more details.
PERSISTENT_ENTRY0[31:0]
SRC_GPR1[31:0]
Holds the entry function for the CPU0 to wake up
from the low-power mode.
PERSISTENT_ARG0[31:0]
SRC_GPR2[31:0]
Holds the argument of entry function for the CPU0
to wake up from the low-power mode.
PERSIST_OVERRIDE_SBMR1
SRC_GPR10[28]
This bit instructs the ROM code to use the
SRC_GPR9 register as if it is the SBMR1. This
allows the software to override the fuse bits and
boot from an alternative boot source. This feature
is vaild for a WDOG time-out reset only, and can
be disabled if the DIR_BT_DIS fuse is blown.
PERSIST_SBMR1_VALUE
SRC_GPR9
The value to override the SBMR1.
8.5
Boot devices (internal boot)
The chip supports these boot flash devices:
• NOR flash with the External Interface Module (EIM), located on CS0, 16-bit bus
width.
• OneNAND flash with the EIM interface, located on CS0, 16-bits bus width.
• Raw NAND (MLC and SLC), and Toggle-mode NAND flash through GPMI-2
interface. Page sizes of 2 KB, 4 KB, and 8 KB. The bus widths of 8-bit with 2
through 40-bit BCH hardware ECC (Error Correction) are supported.
• Quad SPI flash.
• SD/MMC/eSD/SDXC/eMMC4.4 via USDHC interface, supporting high capacity
cards.
• EEPROM boot via SPI (serial flash).
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
265

<!-- page 266 -->

The selection of the external boot device type is controlled by the BOOT_CFG1[7:4]
eFUSEs. See this table for more details:
Table 8-7. Boot device selection
BOOT_CFG1[7:4]
Boot device
0000
NOR/OneNAND (EIM)
0001
QSPI
0011
Serial ROM (SPI)
010x
SD/eSD/SDXC
011x
MMC/eMMC
1xxx
Raw NAND
8.5.1
NOR flash/OneNAND using EIM interface
The External Interface Module (EIM) works in the asynchronous mode, and supports
either muxed, Address/Data, or non-muxed schemes, based on the fuse settings.
Table 8-8. EIM boot eFUSE descriptions
Fuse
Config
Definition
GPIO1
Shipped
value
Settings
BOOT_CFG1[7:4]
OEM
Boot device selection
Yes
0000
0000—boot from the EIM interface
BOOT_CFG1[3]
OEM
NOR/OneNAND selection
Yes
0
0—NOR
1—OneNAND
BOOT_CFG2[7:6]
OEM
Muxing scheme
Yes
00
00—muxed, 16-bit data (low half)
interface
01—reserved
10—not muxed, 16-bit data (low half)
interface
11—reserved
BOOT_CFG2[5:4]
OEM
OneNAND page size
Yes
00
00—1 KB
01—2 KB
10—4 KB
11—reserved
1.
This setting can be overridden by the GPIO settings when the BT_FUSE_SEL fuse is intact. See GPIO Boot Overrides for
the corresponding GPIO pin.
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
266
NXP Semiconductors

<!-- page 267 -->

8.5.1.1
NOR flash boot operation
Booting from the NOR flash is supported via the EIM interface. The ROM reads the
Image Vector Table and Boot Data structures to determine if the image can be executed
directly from the EIM address space or copied to another memory.
The start field of the Boot Data Structure specifies the final location of the image (see
Image Vector Table and Boot Data).
8.5.1.2
OneNAND flash boot operation
At system power-up, the OneNAND device automatically copies the Initial Load Region
of 1 KB from the start of the flash array (sector 0 and sector 1, page 0, block 0) to its
Boot RAM (OneNAND's internal RAM).
NOTE
The OneNAND boot RAM memory containing the Initial 1-KB
Load Region must contain the IVT, DCD, and the Boot Data
structures.
Next, the ROM processes the DCD and then proceeds to copy the program image
contents to the application destination pointer (located in the start entry of the Boot Data
(see Image Vector Table and Boot Data). The ROM determines the size of the program
image by the length specified by the size entry in the Boot Data structure (see Image
Vector Table and Boot Data). A failure in loading data from the OneNAND device for
any reason forces the chip to enter the Serial Downloader. Otherwise, the booting from
the OneNAND device continues.
This figure illustrates the layout of the program image on the OneNAND boot device:
Initial Load Region 1 Kbyte
- Boot Data beginning at 
Block-0
Remainder of Image
Figure 8-4. Program image layout on the OneNAND flash device
Before accessing the OneNAND device, the chip waits approximately 500 μs after the
Power-On Reset. This delay is required for the OneNAND device to become ready. After
this initial 500 μs delay, it can take additional 70 μs for the OneNAND device to load the
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
267

<!-- page 268 -->

Initial Load Region of 1 KB into its boot RAM. The chip polls the OneNAND device
Interrupt Status Register to confirm that the first 1 KB was loaded to the OneNAND boot
RAM before continuing with the boot flow.
8.5.1.3
IOMUX configuration for EIM devices
The EIM interface uses the dedicated contacts on the IC.
The contacts assigned to the data signals used by the EIM are shown in this table:
Table 8-9. EIM IOMUX pin configuration
Signal
A/D16 (Muxed, 16-bit data interface)
A+D (Not muxed, 16-bit data interface)
DATA0
CSI_DATA00.alt4
LCD_DATA08.alt4
DATA1
CSI_DATA01.alt4
LCD_DATA09.alt4
DATA2
CSI_DATA02.alt4
LCD_DATA10.alt4
DATA3
CSI_DATA03.alt4
LCD_DATA11.alt4
DATA4
CSI_DATA04.alt4
LCD_DATA12.alt4
DATA5
CSI_DATA05.alt4
LCD_DATA13.alt4
DATA6
CSI_DATA06.alt4
LCD_DATA14.alt4
DATA7
CSI_DATA07.alt4
LCD_DATA15.alt4
DATA8
NAND_DATA00.alt4
LCD_DATA16.alt4
DATA9
NAND_DATA01.alt4
LCD_DATA17.alt4
DATA10
NAND_DATA02.alt4
LCD_DATA18.alt4
DATA11
NAND_DATA03.alt4
LCD_DATA19.alt4
DATA12
NAND_DATA04.alt4
LCD_DATA20.alt4
DATA13
NAND_DATA05.alt4
LCD_DATA21.alt4
DATA14
NAND_DATA06.alt4
LCD_DATA22.alt4
DATA15
NAND_DATA07.alt4
LCD_DATA23.alt4
ADDR0
CSI_DATA00.alt4
ADDR1
CSI_DATA01.alt4
ADDR2
CSI_DATA02.alt4
ADDR3
CSI_DATA03.alt4
ADDR4
CSI_DATA04.alt4
ADDR5
CSI_DATA05.alt4
ADDR6
CSI_DATA06.alt4
ADDR7
CSI_DATA07.alt4
ADDR8
NAND_DATA00.alt4
ADDR9
NAND_DATA01.alt4
ADDR10
NAND_DATA02.alt4
ADDR11
NAND_DATA03.alt4
ADDR12
NAND_DATA04.alt4
Table continues on the next page...
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
268
NXP Semiconductors

<!-- page 269 -->

Table 8-9. EIM IOMUX pin configuration (continued)
Signal
A/D16 (Muxed, 16-bit data interface)
A+D (Not muxed, 16-bit data interface)
ADDR13
NAND_DATA05.alt4
ADDR14
NAND_DATA06.alt4
ADDR15
NAND_DATA07.alt4
ADDR16
NAND_CLE.alt4
ADDR17
NAND_ALE.alt4
ADDR18
NAND_CE1_B.alt4
ADDR19
SD1_CMD.alt4
ADDR20
SD1_CLK.alt4
ADDR21
SD1_DATA0.alt4
ADDR22
SD1_DATA1.alt4
ADDR23
SD1_DATA2.alt4
ADDR24
SD1_DATA3.alt4
ADDR25
ENET2_RXER.alt4
ADDR26
ENET2_CRS_DV.alt4
8.5.2
NAND flash
The boot ROM supports a number of MLC/SLC NAND flash devices from different
vendors and LBA NAND flash devices. The Error Correction and Control (ECC)
subblock (BCH) is used to detect the errors.
8.5.2.1
NAND eFUSE configuration
The boot ROM determines the configuration of the external NAND flash by parameters,
either provided by the eFUSE, or sampled on the GPIO pins during boot. See Table 8-10
for parameters details.
NOTE
BOOT_CFGx sampled on the GPIO pins depends on the
BT_FUSE_SEL setting. See Boot Fusemap for details.
NOTE
For BOOT_CFG[3:2], although ROM always boots from
CS0_B, for multiple chip selects, such as some NAND chips
which consist of multi CS. This fuse must be burned correctly.
The number of devices means the number of chip selects.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
269

<!-- page 270 -->

Table 8-10. NAND boot eFUSE descriptions
Fuse
Config
Definition
GPIO1
Shipped
value
Settings
BOOT_CFG1[7]
OEM
Boot device selection
Yes
0
1—boot from the NAND
Interface
BOOT_CFG1[6]
OEM
BT_TOGGLEMODE
Yes
0
0—raw NAND
1—toggle mode NAND
BOOT_CFG1[5:4]
OEM
Pages in block
Yes
0
00—128
01—64
10—32
11—256
BOOT_CFG1[3:2]
OEM
Number of devices
Yes
00
00—1 device
01—2 device
10—4 device
11—Reserved
BOOT_CFG1[1:0]
OEM
Row address cycles
Yes
00
00—3
01—2
10—4
11—5
BOOT_CFG2[7:5]
OEM
Toggle mode 33 MHz
preamble delay, read latency
Yes
000
000—16 GPMICLK cycles
001—1 GPMICLK cycles
010—2 GPMICLK cycles
011—3 GPMICLK cycles
100—4 GPMICLK cycles
101—5 GPMICLK cycles
110—6 GPMICLK cycles
111—7 GPMICLK cycles
BOOT_CFG2[4:3]
OEM
Boot search count
Yes
00
00—2
01—2
10—4
11—8
BOOT_CFG2[2]
OEM
Boot frequencies (ARM/DDR)
Yes
0
0—500/400 MHz
1—250/200 MHz
BOOT_CFG2[1]
OEM
Reset time
Yes
0
0—12 ms
1—22 ms (LBA NAND)
0x470[0]
OEM
Override pad settings
Yes
0
Override NAND pad settings
0—use the default values
1—use the PAD_SETTINGS
value
0x6D0[5:0]
OEM
PAD_SETTINGS[5:0]
Yes
0
NAND pad settings value
Table continues on the next page...
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
270
NXP Semiconductors

<!-- page 271 -->

Table 8-10. NAND boot eFUSE descriptions (continued)
Fuse
Config
Definition
GPIO1
Shipped
value
Settings
0x6D0[11:8]
OEM
READ_RETRY_SEQ_ID[3:0]
Yes
0000
0000—don't use the ROM
embedded read-retry sequence
0001—use Micron 20 nm read-
retry sequence
0010—use Toshiba A19 nm
read-retry sequence
0011—use Toshiba 19 nm read-
retry sequence
0100—use SanDisk 19 nm read-
retry sequence
0101—use SanDisk 1ynm read-
retry sequence
0110—use Hynix 20 nm A die
read-retry sequence
0111—use Hynix 26 nm read-
retry sequence
1000—use Hynix 20 nm B die
read-retry sequence
1001—use Hynix 20 nm C die
read-retry sequence
1010 to 1111—reserved
1.
The setting can be overridden by the GPIO settings when the BT_FUSE_SEL fuse is intact. See Table 3 for the
corresponding GPIO pin.
8.5.2.2
NAND flash boot flow and Boot Control Blocks (BCB)
There are two BCB data structures:
• FCB
• DBBT
As a part of the NAND media initialization, the ROM driver uses safe NAND timings to
search for the Firmware Configuration Block (FCB) that contains the optimum NAND
timings, the page address of the Discovered Bad Block Table (DBBT) Search Area, and
the start page address of the primary and secondary firmware.
The hardware ECC level to use is embedded inside the FCB block. The FCB data
structure is also protected using the ECC. The driver reads raw 2112 bytes of the first
sector and runs through the software ECC engine that determines whether the FCB data is
valid or not.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
271

<!-- page 272 -->

If the FCB is found, the optimum NAND timings are loaded for further reads. If the ECC
fails, or the fingerprints do not match, the Block Search state machine increments the
page number to the Search Stride number of pages to read for the next BCB until the
SearchCount pages have been read.
If the search fails to find a valid FCB, the NAND driver responds with an error and the
boot ROM enters the serial download mode.
The FCB contains the page address of the DBBT Search Area, and the page address for
primary and secondary boot images. The DBBT is searched in the DBBT Search Area,
just like the FCB is searched. After the FCB is read, the DBBT is loaded, and the primary
or secondary boot image is loaded using the starting page address from the FCB.
This figure shows the state diagram of the FCB search:
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
272
NXP Semiconductors

<!-- page 273 -->

START
Read 4K, ReadCount++
Is Valid FCB?
YES
NO
Current Page = 0,
Search Stride = Stride Size Fuse Value,
Search Count = Boot Search Count Fuse Value
Current Page += Search 
Stride
NCB Found
Read Count < 
Search Count
YES
Recovery Device/
Serial Loader
NO
Figure 8-5. FCB search flow
When the FCB is found, the boot ROM searches for the Discovered Bad Blocks Table
(DBBT). If the DBBT Search Area is 0 in the FCB, the ROM assumes that there are no
bad blocks on the NAND device boot area. See this figure for the DBBT search flow:
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
273

<!-- page 274 -->

START
Read 4K, ReadCount++
Is Valid DBBT?
YES
NO
Current Page = DBBT Start Page,
Search Stride = Stride Size Fuse Value,
Search Count = 4
Current Page += Search 
Stride
DBBT Found
Read Count < 
Search Count
YES
DBBT Not Found
NO
DBBT Found, Copy to IRAM 
Figure 8-6. DBBT search flow
The BCB search and load function also monitors the ECC correction threshold and sets
the PERSIST_BLOCK_REWRITE persistent bit if the threshold exceeds the maximum
ECC correction ability.
If there is a page with a number of errors higher than ECC can correct during the primary
image read, the boot ROM turns on the PERSIST_SECONDARY_BOOT bit and
performs the software reset (After the software reset, the secondary image is used).
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
274
NXP Semiconductors

<!-- page 275 -->

If there is a page with number of errors higher than ECC can correct during secondary
image read, the boot ROM goes to the serial loader.
8.5.2.3
Firmware configuration block
The FCB is the first sector in the first good block. The FCB must be present at each
search stride of the search area.
The search area contains copies of the FCB at each stride distance, so, in case the first
NAND block becomes corrupted, the ROM finds its copy in the next NAND block. The
search area must span over at least two NAND blocks. The location information for the
DBBT search area, FW1, and FW2 are all specified in the FCB. This table shows the
flash control block structure:
Table 8-11. Flash control block structure
Name
Start byte
Size in bytes
Description
Reserved
0
4
Reserved for Fingerprint #1(Checksum)
FingerPrint
4
4
32-bit word with a value of 0x20424346, in ascii
"FCB"
Version
8
4
32-bit version number; this version of FCB is
0x00000001
m_NANDTiming
12
8
8 B of data for eight NAND timing parameters
from the NAND datasheet. The eight
parameters are:
m_NandTiming[0]=data_setup,
m_NandTiming[1]=data_hold,
m_NandTiming[2]=address_setup,
m_NandTiming[3]=dsample_time,
m_NandTiming[4]=nand_timing_state,
m_NandTiming[5]=REA,
m_NandTiming[6]=RLOH,
m_NandTiming[7]=RHOH.
The ROM only uses the first four parameters,
but the FCB provides space for other four
parameters to be used by the bootloader or
other applications.
PageDataSize
20
4
The number of bytes of data in a page.
Typically, this is 2048 bytes for 2112 bytes
page size or 4096 bytes for 4314/4224 bytes
page size or 8192 for 8568 bytes page size.
TotalPageSize
24
4
The total number of bytes in a page. Typically,
2112 for 2-KB page or 4224 or 4314 for 4-KB
page or 8568 for 8-KB page.
Table continues on the next page...
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
275

<!-- page 276 -->

Table 8-11. Flash control block structure (continued)
Name
Start byte
Size in bytes
Description
SectorsPerBlock
28
4
The number of pages per block. Typically 64 or
128 or depending on the NAND device type.
NumberOfNANDs
32
4
Not used by ROM
TotalInternalDie
36
4
Not used by ROM
CellType
40
4
Not used by ROM
EccBlockNEccType
44
4
Value from 0 to 20 is used to set the BCH Error
Corrrection level 0, 2, 4, .. or 40 for Block BN of
ECC page, used in configuring the BCH40
page layout registers.
EccBlock0Size
48
4
Size of block B0 used in configuring the BCH40
page-layout registers.
EccBlockNSize
52
4
Size of block BN used in configuring the
BCH40 page-layout registers.
EccBlock0EccType
56
4
Value from 0 to 20 used to set the BCH Error
Corrrection level 0, 2, 4, .. or 40 for Block BN of
ECC page, used in configuring the BCH40
page layout registers.
MetadataBytes
60
4
Size of metadata bytes used in configuring the
BCH40 page-layout registers.
NumEccBlocksPerPage
64
4
Number of the ECC blocks BN not including
B0. This value is used in configuring the
BCH40 page-layout registers.
EccBlockNEccLevelSDK
68
4
Not used by ROM
EccBlock0SizeSDK
72
4
Not used by ROM
EccBlockNSizeSDK
76
4
Not used by ROM
EccBlock0EccLevelSDK
80
4
Not used by ROM
NumEccBlocksPerPageSDK
84
4
Not used by ROM
MetadataBytesSDK
88
4
Not used by ROM
EraseThreshold
92
4
Not used by ROM
Firmware1_startingPage
104
4
Page number address where the first copy of
bootable firmware is located.
Firmware2_startingPage
108
4
Page number address where the second copy
of bootable firmware is located.
PagesInFirmware1
112
4
Size of the first copy of firmware in pages.
PagesInFirmware2
116
4
Size of the second copy of firmware in pages.
DBBTSearchAreaStartAddress
120
4
Page address for the bad block table search
area.
BadBlockMarkerByte
124
4
This is an input offset in the BCH page for the
ROM to swap with the first byte of metadata
after reading a page using the BCH40. The
ROM supports the restoration of manufacturer-
marked bad block markers in the page and this
offset is the bad block marker offset location.
Table continues on the next page...
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
276
NXP Semiconductors

<!-- page 277 -->

Table 8-11. Flash control block structure (continued)
Name
Start byte
Size in bytes
Description
BadBlockMarkerStartBit
128
4
This is an input bit offset in the
BadBlockMarkerByte for the ROM to use when
swapping eight bits with the first byte of
metadata.
BBMarkerPhysicalOffset
132
4
This is the offset where the manufacturer
leaves the bad block marker on a page.
BCHType
136
4
0 for BCH20 and 1 for BCH40. The chip is
backwards compatible to BCH20 and this field
tells the ROM to use the BCH20 or BCH40
block.
TMTiming2_ReadLatency
140
4
Toggle mode NAND timing parameter read
latency, the ROM uses this value to configure
the timing2 register of the GPMI.
TMTiming2_PreambleDelay
144
4
Toggle mode NAND timing parameter
Preamble Delay. The ROM uses this value to
configure the timing2 register of the GPMI.
TMTiming2_CEDelay
148
4
Toggle mode NAND timing parameter CE
Delay. The ROM uses this value to configure
the timing2 register of the GPMI.
TMTiming2_PostambleDelay
152
4
Toggle mode NAND timing parameter
Postamble Delay. The ROM uses this value to
configure the timing2 register of the GPMI.
TMTiming2_CmdAddPause
156
4
Toggle mode NAND timing parameter Cmd
Add Pause. The ROM uses this value to
configure the timing2 register of the GPMI.
TMTiming2_DataPause
160
4
Toggle mode NAND timing parameter Data
Pause. The ROM uses this value to configure
the timing2 register of the GPMI.
TMSpeed
164
4
This is the toggle mode speed for the ROM to
configure the gpmi clock. 0 for 33 MHz, 1 for 40
MHz, and 2 for 66 MHz.
TMTiming1_BusyTimeout
168
4
Toggle mode NAND timing parameter Busy
Timeout. The ROM uses this value to configure
the timing1 register of the GPMI.
DISBBM
172
4
If 0, the ROM swaps the BadBlockMarkerByte
with metadata[0] after reading a page using the
BCH40. If the value is 1, the ROM does not
swap.
BBMark_spare_offset
176
4
The offset in the metadata place which stores
the data in the bad block marker place.
Onfi_sync_enable
180
4
Enable the Onfi nand sync mode support.
Onfi_sync_speed
184
4
Speed for the Onfi nand sync mode:
0 - 24 MHz, 1 - 33 MHz, 2 - 40 MHz, 3 - 50
MHz, 4 - 66 MHz, 5 - 80 MHz, 6 - 100 MHz, 7 -
133 MHz, 8 - 160 MHz, 9 - 200 MHz
Table continues on the next page...
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
277

<!-- page 278 -->

Table 8-11. Flash control block structure (continued)
Name
Start byte
Size in bytes
Description
Onfi_syncNANDData
188
28
The parameters for the Onfi nand sync mode
timing. They are read latency, ce_delay,
preamble_delay, postamble_delay,
cmdadd_pause, data_pause, and
busy_timeout.
DISBB_Search
216
4
Disable the bad block search function when
reading the firmware, only using DBBT.
Reserved
220
64
Reserved for future use.
8.5.2.4
Discovered Bad Block Table (DBBT)
See this table for the DBBT format:
Table 8-12. DBBT structure
Name
Start byte
Size in bytes
Description
reserved
0
4
-
FingerPrint
4
4
32-bit word with a value of 0x44424254,in
ascii "DBBT"
Version
8
4
32-bit version number; this version of
DBBT is 0x00000001
reserved
12
4
-
DBBT_NUM_OF_PAGES
16
4
Size of the DBBT in pages
reserved
20
4*PageSize-20
-
reserved
4*PageSize
4
-
Number of Entries
4*PageSize + 4
4
Number of bad blocks
Bad Block Number
4*PageSize + 8
4
First bad block number
Bad Block Number
4*PageSize + 12
4
Second bad block number
-
-
-
Next bad block number
-
-
-
-
Last bad block number
-
-
Last bad block number
8.5.2.5
Bad block handling in ROM
During the firmware boot, at the block boundary, the Bad Block table is searched for a
match to the next block.
If no match is found, the next block can be loaded. If a match is found, the block must be
skipped and the next block checked.
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
278
NXP Semiconductors

<!-- page 279 -->

If the Bad Block table start page is null, check the manufactory made Bad Block marker.
The location of the Bad Block maker is at the first three or last three pages in every block
of the NAND flash. The NAND manufacturers normally use one byte in the spare area of
certain pages within a block to mark that a block is bad or not. A value of 0xFF means
good block, non-FF means bad block.
To preserve the BI (bad block information), the flash updater or gang programmer
applications must swap the Bad Block Information (BI) data to byte 0 of the metadata
area for every page before programming the NAND flash. When the ROM loads the
firmware, it copies back the value at metadata[0] to the BI offset in the page data. This
figure shows how the factory bad block marker is preserved:
2 KB Main area
parity
parity
parity
parity
Swap byte
meta
data
Bad block information at 
column address 2048
Bad block information at 
fourth block of data area
64 B 
spare
512 main
512 main
512 main
512 main
Figure 8-7. Factory bad block marker preservation
In the FCB structure, there are two elements (m_u32BadBlockMarkerByte and
m_u32BadBlockMarkerStartBit) to indicate the byte and bit place in the page data that
the manufacturer marked the bad block marker.
8.5.2.6
Read-retry handling in the ROM
The read-retry is used to recover the bit errors beyond the ECC correction threshold from
NAND. If reading of a page failed and the read_retry_enable field in FCB is set to 1, the
ROM issues a read-retry command sequence to shift the read level before reading the
page again. If the previous reading failed, the ROM continues to shift the read level until
the reading succeeds or all levels were tried. The state diagram of the read-retry is shown
in this figure:
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
279

<!-- page 280 -->

 
 
 
 
 
 
 
 
 
No 
 
 
 
 
 
 
 
 
 
 
 
Yes 
 
 
 
 
 
 
START
 
Succeed
 
Fail
Read Page
Check the read retry
shift level
Shift to the next read
retry level
Fail?
All levels tried?
Yes
No
Figure 8-8. Read-retry flow
Different vendors and different processes may have different read-retry sequences. At
this time, the ROM supports five read-retry sequences. Blowing the
READ_RETRY_SEQ_ID[3:0] fuse can help to determine which sequence to use.
The read-retry sequences are listed in this table:
Table 8-13. Read-retry sequences
Vendor
Process
READ_RETRY_SEQ_I
D[3:0]
Comment
Micron
20nm
2’b0001
The detail of this RR sequence is documented in
“64 Gb, 128 Gb, 256 Gb, 512 Gb Asynchronous/
Synchronous NAND Features(Release:
4/20/12)”, contact Micron for that document.
Table continues on the next page...
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
280
NXP Semiconductors

<!-- page 281 -->

Table 8-13. Read-retry sequences (continued)
Vendor
Process
READ_RETRY_SEQ_I
D[3:0]
Comment
Toshiba
A19nm
2’b0010
The detail of this RR sequence is documented in
“TOSHIBA Technical Information A19nm MLC
NAND Retry Read Sequence”, contact Toshiba
for that document.
19nm
2’b0011
The detail of this RR sequence is documented in
“TOSHIBA Technical Information 19nm MLC
NAND Read Retry Sequence Rev1.6”, contact
Toshiba for that document.
SanDisk
19nm
2’b0100
The detail of this RR sequence is documented in
“App Note 023 (v1.0) 19nm eX2 ABL Dynamic
Read Sequence & Parameter Table”, contact
SanDisk for that document.
1ynm
2’b0101
The detail of this RR sequence is documented in
“Application Note 1y_023 19nm eX2 ABL
Dynamic Read Sequence & Parameter Table”,
contact SanDisk for that document.
Hynix
26nm
2’b0111
The detail of this RR sequence is documented in
“ 26nm 32Gb MLC RAWNAND”, contact Hynix
for that document.
20nm A Die
2’b0110
The detail of this RR sequence is documented in
“ 20nm 32Gb MLC C-die Application Note”,
contact Hynix for that document.
20nm B Die
2’b1000
The detail of this RR sequence is documented in
“ 20nm 32Gb MLC C-die Application Note”,
contact Hynix for that document.
20nm C Die
2’b1001
The detail of this RR sequence is documented in
“ 20nm 32Gb MLC C-die Application Note”,
contact Hynix for that document.
8.5.2.7
Toggle mode DDR NAND boot
If the BT_TOGGLEMODE efuse is blown, the ROM does the following to boot from the
Samsung's toggle mode DDR NAND.
8.5.2.7.1
GPMI and BCH clocks configuration
The ROM sets the clock source and the dividers in the CCM registers.
If the BOOT_CFG1[6] is set (toggle mode), the GPMI/BCH CLK source is PLL2PFD4,
and running at 66 MHz, otherwise the GPMI/ BCH CLK souce is PLL3, running at 24
MHz. The ROM sets the default values to timing0, timing1, and timing2 gpmi registers
for 24 MHz clock speed. It uses the BOOT_CFG fuse to configure the GPMI timing2
register parameters preamble delay and read latency. The default value for these
parameters is 2 when the fuses are not blown.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
281

<!-- page 282 -->

The default timing parameter values used by the ROM for the toggle-mode device are:
• Timing0.ADDRESS_SETUP = 5
• Timing0.DATA_SETUP = 10
• Timing0.DATA_HOLD = 10
• Timing1.DEVICE_BUSY_TIMEOUT = 0 x 500
• Timing2.READ_LATENCY = BOOT_CFG2[7:5] if blown, otherwise 2
• Timing2.CE_DELAY = 2
• Timing2.PREAMBLE_DELAY = BOOT_CFG2[7:5] if blown, otherwise 2
• Timing2.POSTAMBLE_DELAY = 3
• Timing2.CMDADD_PAUSE = 4
• Timing2.DATA_PAUSE = 6
The default timing parameters can be overriden by the TMTiming2_ReadLatency,
TMTiming2_PreambleDelay, TMTiming2_CEDelay, TMTiming2_PostambleDelay,
TMTiming2_CmdAddPause, and TMTiming2_DataPause parameters of the FCB.
8.5.2.7.2
Setup DMA for DDR transfers
In the DMA descriptors, the GPMI is configured to read the page data at a double data
rate, the word length is set to 16, and the transfer count to a half of the page size.
8.5.2.7.3
Reconfigure timing and speed using values in FCB
After reading the FCB page with the GPMI set to default timings and a speed of 33 MHz,
the ROM reconfigures the CCM dividers to run the gpmi/bch clks to a desired speed
specified in the FCB for the rest of the boot process. The GPMI timing registers are also
reconfigured to the values specified in the FCB.
The GPMI speed can be configured using the FCB parameter TMSpeed:
• 0—24 MHz
• 1—33 MHz
• 2—40 MHz
• 3—50 MHz
• 4—66 MHz
• 5—80 MHz
• 6—100 MHz
• 7—133 MHz
• 8—160 MHz
• 9—200 MHz
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
282
NXP Semiconductors

<!-- page 283 -->

The GPMI timing0 register fields data_setup, data_hold, and address_setup are set to the
values specified for the data_setup and data_hold and address_setup in the FCB member
m_NANDTiming.
The GPMI timing1.DEVICE_BUSY_TIMEOUT is set to the value specified in the FCB
member TMTiming1_BusyTimeout.
The GPMI timing2 register values are set using the FCB members
TMTiming2.READ_LATENCY, CE_DELAY, PREAMBLE_DELAY,
POSTAMBLE_DELAY, CMDADD_PAUSE, and DATA_PAUSE.
8.5.2.8
Typical NAND page organization
8.5.2.8.1
BCH ECC page organization
The first data block is called block 0 and the rest of the blocks are called block N. A
separate ECC level scan is used for block 0 and block N.
The metadata bytes must be located at the beginning of a page, starting at byte 0,
followed by the data block 0, the ECC bytes for data block 0, the block 1 and its ECC
bytes, and so on, up until the N data blocks. The ECC level for the block 0 can be
different from the ECC level for the rest of the blocks.
For the NAND boot with page-size restrictions and the data block size restricted to 512
B, only few combinations of the ECC for block 0 and block N are possible.
This figure shows the valid layout for 2112-byte sized page.
M
Block0
512 bytes
EccB0
Block1
512 bytes
EccBN
Block2
512 bytes
EccBN
Block3
512 bytes
EccBN
Figure 8-9. Valid layout for 2112-byte sized page
The example below is for 13 bits of parity (GF13). The number of ECC bits required for
a data block is calculated using the (ECC_Correction_Level * 13) bits.
In the above layout, the ECC size for EccB0 and EccBN must be selected to not exceed a
total page size of 2112 bytes. The EccB0 and EccBN can be one of the 2, 4, 6, 8, 10, 12,
14, 16, 18, and 20 bits on the ECC correction level. The total bytes are:
[M + (data_block_size x 4) + ([EccB0 + (EccBN x 3)] x 13) / 8] <= 2112;
M = metadata bytes and data_block_size is 512.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
283

<!-- page 284 -->

There are four data blocks of 512 bytes each in a page of 2-KB page sized NAND. The
values of EccB0 and EccBN must be such that the above calculation does not result in a
value greater than 2112 bytes.
M
Block0
512 bytes
EccB0
Block1
512 bytes
EccBN
Block2
512 bytes
EccBN
Block3
512 bytes
EccBN
Block4
512 bytes
EccBN
Block5
512 bytes
EccBN
Block6
512 bytes
EccBN
Block7
512 bytes
EccBN
Figure 8-10. Valid layout for 4-KB sized page
Different NAND manufacturers have different sizes for a 4-KB page; 4314 bytes is
typical.
[M + (data_block_size x 8) + ([EccB0 + (EccBN x 7)] x 13) / 8] <= 4314;
M= metadata bytes and data_block_size is 512.
There are eight data blocks of 512 bytes each in a page of a 4-KB page sized NAND. The
values of the EccB0 and EccBN must be such that the above calculation does not result in
a value greater than the size of a page in a 4-KB page NAND.
8.5.2.8.2
Metadata
The number of bytes used for the metadata is specified in the FCB. The metadata for the
BCH encoded pages is placed at the beginning of a page. The ROM only cares about the
first byte of metadata to swap it with a bad block marker byte in the page data after each
page read; it is important to have at least one byte for the metadata bytes field in the FCB
data structure.
8.5.2.9
IOMUX configuration for NAND
The following table shows the RawNAND IOMUX pin configuration.
Table 8-14. NAND IOMUX pin configuration
Signal
Pad name
NAND.CLE
NAND_CLE.alt0
NAND.ALE
NAND_ALE.alt0
NAND.DATA00
NAND_DATA00.alt0
Table continues on the next page...
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
284
NXP Semiconductors

<!-- page 285 -->

Table 8-14. NAND IOMUX pin configuration (continued)
Signal
Pad name
NAND.DATA01
NAND_DATA01.alt0
NAND.DATA02
NAND_DATA02.alt0
NAND.DATA03
NAND_DATA03.alt0
NAND.DATA04
NAND_DATA04.alt0
NAND.DATA05
NAND_DATA05.alt0
NAND.DATA06
NAND_DATA06.alt0
NAND.DATA07
NAND_DATA07.alt0
NAND.RE_B
NAND_RE_B.alt0
NAND.WE_B
NAND_WE_B.alt0
NAND.CE1_B
NAND_CE1_B.alt0
NAND.CE0_B
NAND_CE0_B.alt0
NAND.DQS
NAND_DQS.alt0
NAND.READY_B
NAND_READY_B.alt0
NAND.CE2_B
CSI_MCLK.alt2
NAND.CE3_B
CSI_PIXCLK.alt2
NAND.WP_B
NAND.WP_B.alt0
8.5.3
Expansion device
The ROM supports booting from the MMC/eMMC and SD/eSD compliant devices.
8.5.3.1
Expansion device eFUSE configuration
The SD/MMC/eSD/eMMC/SDXC boot can be performed using either the USDHC ports,
based on the setting of the BOOT_CFG2[4:3] (Port Select) fuse or it is associated to the
GPIO input value at the boot.
All USDHC ports support the eMMC4.4 and eMMC4.5 fast boot. See this table for
details:
Table 8-15. USDHC boot eFUSE descriptions
Fuse
Config
Definition
GPIO
Shipped
value
Settings
0x450[7:6]
OEM
Boot device selection
Yes
00
01 - Boot from the USDHC interface
0x450[5]
OEM
SD/MMC selection
Yes
0
0 - SD/eSD/SDXC
1 - MMC/eMMC
0x450[4]
OEM
Fast boot support
Yes
0
0 - Normal boot
Table continues on the next page...
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
285

<!-- page 286 -->

Table 8-15. USDHC boot eFUSE descriptions
(continued)
Fuse
Config
Definition
GPIO
Shipped
value
Settings
1 - Fast boot
0x450[3:2]
OEM
SD/MMC speed mode, and
eMMC acknowledge
enabled selection
Yes
00
MMC
0x - Normal speed mode
1x - High-speed mode
x0 - eMMC fast boot acknowledge
enable
x1 - eMMC fast boot acknowledge
disable
SD
00 - Normal/SDR12
01 - High/SDR25
10 - SDR50
11 - SDR104
0x450[1]
OEM
SD power cycle enable/
eMMC reset enable
Yes
0
MMC
0 - No action
1 - eMMC reset enabled via the
SD_RST pad
SD
0 - No power cycle
1 - Power cycle enabled via the
SD_RST pad
0x450[0]
OEM
SD loopback clock source
sel (for SDR50 and
SDR104 only)
Yes
0
0 - through the SD pad
1 - direct
0x450[15:13]
OEM
SD MMC bus width
selection/SD calibration
step
Yes
00
SD/eSD/SDXC (BOOT_CFG1[5]=0)
Bus width
xx0 - 1-bit
xx1 - 4-bit
SD calibration step
00x - 1 delay cell
01x - 1 delay cell
10x - 2 delay cells
11x - 3 delay cells
MMC/eMMC (BOOT_CFG1[5]=1)
000 - 1-bit
001 - 4-bit
010 - 8-bit
Table continues on the next page...
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
286
NXP Semiconductors

<!-- page 287 -->

Table 8-15. USDHC boot eFUSE descriptions
(continued)
Fuse
Config
Definition
GPIO
Shipped
value
Settings
101 - 4-bit DDR (MMC 4.4)
110 - 8-bit DDR (MMC 4.4)
Else - Reserved
0x450[12:11]
OEM
USDHC port selection
Yes
00
00 - USDHC-1
01 - USDHC-2
1x - Reserved
0x450[9]
OEM
USDHC1 voltage selection
Yes
0
0 - 3.3 V
1 - 1.8 V
0x460[31:30]
OEM
Power cycle selection
Yes
00
00 - 20 ms
01 - 10 ms
10 - 5 ms
11 - 2.5 ms
0X460[29]
OEM
Power stable cycle
selection
Yes
0
0 - 5 ms
1 - 2.5 ms
0X460[24]
OEM
SD/MMC DLL enable
selection
Yes
0
0 - Disable DLL for SD/eMMC
1 - Enable DLL for SD/Emmc
0X470[7]
OEM
DLL override selection
Yes
0
0 - No override
1 - DLL override mode for SD/eMMC
(Override by MMC_DLL_DLY,
0x470[19:16])
0X470[6]
OEM
USDHC1 reset polarity
selection
Yes
0
0 - Reset active low
1 - Reset active high
0X470[5]
OEM
USDHC2 voltage selection
Yes
0
0 - 3.3 V
1 - 1.8 V
0X470[0]
OEM
SD/MMC pad settings
override selection
Yes
0
0 - No override
1 - Override (override by
PAD_SETTINGS, 0x6d0[5:0])
0X470[15]
OEM
USDHC2 reset polarity
selection
Yes
0
0 - Reset active-low
1 - Reset active-high
0X470[14]
OEM
eMMC4.4 pre-idle enabled
selection
Yes
0
0 - Issue pre-idle command
1 - Do not issue
0x470[13]
OEM
Override HYS bit for
SD/MMC pads
Yes
0
0 - No override
1 - Override HYS bit with 1
0X470[30:24]
OEM
MMC_DLL_DLY
Yes
0000000
Override number
0X6D0[5:0]
OEM
PAD_SETTINGS
Yes
000000
Override number
The boot code supports these standards:
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
287

<!-- page 288 -->

• MMCv4.4 or less
• eMMCv4.4 or less
• SDv2.0 or less
• eSDv2.10 rev-0.9, with or without FAST_BOOT
• SDXCv3.0
The MMC/SD/eSD/SDXC/eMMC can be connected to any of the USDHC blocks and
can be booted by copying 4 KB of data from the MMC/SD/eSD/eMMC device to the
internal RAM. After checking the Image Vector Table header value (0xD1) from
program image, the ROM code performs a DCD check. After a successful DCD
extraction, the ROM code extracts from the Boot Data Structure the destination pointer
and length of image to be copied to the RAM device from where the code execution
occurs.
The maximum image size to load into the SD/MMC boot is 32 MB. This is due to a
limited number of uSDHC ADMA Buffer Descriptors allocated by the ROM.
NOTE
The initial 4 KB of the program image must contain the IVT,
DCD, and the Boot Data structures.
Table 8-16. SD/MMC frequencies
SD
MMC
MMC (DDR mode)
Identification (KHz)
347.22
Normal-speed mode (MHz)
25
20
25
High-speed mode (MHz)
50
40
50
UHSI SDR50 (MHz)
100
UHSI SDR104 (MHz)
200
NOTE
The boot ROM code reads the application image length and the
application destination pointer from the image.
8.5.3.2
MMC and eMMC boot
This table provides the MMC and eMMC boot details.
Table 8-17. MMC and eMMC boot details
Normal boot mode
During the initialization (normal boot mode), the MMC
frequency is set to 347.22 KHz. When the MMC card enters
the identification portion of the initialization, the voltage
validation is performed, and the ROM boot code checks the
high-voltage settings and the card capacity. The ROM boot
Table continues on the next page...
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
288
NXP Semiconductors

<!-- page 289 -->

Table 8-17. MMC and eMMC boot details (continued)
code supports both the high-capacity and low-capacity MMC/
eMMC cards. After the initialization phase is complete, the
ROM boot code switches to a higher frequency (20 MHz in
the normal boot mode or 40 MHz in the high-speed mode).
The eMMC is also interfaced via the USDHC and follows the
same flow as the MMC.
The boot partition can be selected for an MMC4.x card after
the card initialization is complete. The ROM code reads the
BOOT_PARTITION_ENABLE field in the Ext_CSD[179] to get
the boot partition to be set. If there is no boot partition
mentioned in the BOOT_PARTITION_ENABLE field or the
user partition was mentioned, the ROM boots from the user
partition.
eMMC4.3 or eMMC4.4 device supporting special boot mode
If using an eMMC4.3 or eMMC4.4 device that supports the
special boot mode, it can be initiated by pulling the CMD line
low. If the BOOT ACK is enabled, the eMMC4.3/eMMC4.4
device sends the BOOT ACK via the DATA lines and the
ROM can read the BOOT ACK [S010E] to identify the
eMMC4.3/eMMC4.4 device. If the BOOT ACK is enabled, the
ROM waits 50 ms to get the BOOT ACK and if the BOOT
ACK is received by the ROM. If BOOT ACK is disabled ROM
waits 1 second for data. If the BOOT ACK or data was
received, the eMMC4.3/eMMC4.4 is booted in the "boot
mode", otherwise the eMMC4.3/eMMC4.4 boots as a normal
MMC card from the selected boot partition. This boot mode
can be selected by the BOOT_CFG1[4] (fast boot) fuse. The
BOOT ACK is selected by the BOOT_CFG2[1].
eMMC4.4 device
If using the eMMC4.4 device, the Double Data Rate (DDR)
mode can be used. This mode can be selected by the
BOOT_CFG2[7:5] (bus width) fuse.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
289

<!-- page 290 -->

Check data bus width fuse. Accordingly 
 
. 
eSDHC Software Reset, Set RSTA
Set Identification Frequency 
(Approx 400 KHz)
Check MMC and Fast Boot 
Selection Fuse
Set INITA to send 80 SDCLK to card
Card SW Reset   (CMD0) 
Command Successful?
Yes
No
Yes
No
Check SD/MMC Selection fuse
SD
MMC
1
6
5
2
Start 
do the IOMUX config
Figure 8-11. Expansion device boot flow (1 of 6)
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
290
NXP Semiconductors

<!-- page 291 -->

2
Set Strong pull-up
For CMD line
Start GPT with 1s delay 
for CMD1
Issue CMD1 with HV
Command Successful?
Busy Bit == 1
5
Loop Cntr < 3000 and 
looping period < 1s
Increment loop counter
Is Response OCR for 
HC
Card Is HC MMC
Card Is LC MMC
Yes
Yes
Yes
Yes
No
No
No
Get CID from card (Issue 
CMD2)
Command Successful?
Set RCA (Issue CMD3)
Command Successful?
Set Weak pull-up
For CMD line
Set MMC card CSD 
(Issue CMD9)
Set operating frequency 
to 20 MHz
Put card data Transfer 
Mode (Issue CMD7)
Command Successful?
Send CMD13 to read 
status
Card State == 
TRANS?
5
Spec ver >= 4.0?
Send CMD8 to get 
Ext_CSD
Extract the boot partition 
to set
Got valid partition?
Send switch command 
to select partition
Switch Successful?
Send switch command 
to set high frequency
Set operating frequency 
to 40 MHz
Bus width
fuse <> 1?
Send switch command 
to change bus width and 
DDR mode
Switch Successful?
Change ESDHC bus 
width
High Speed mode
fuse == 0?
4
No
No
No
No
No
No
No
No
No
No
Yes
Yes
Yes
Yes
Yes
Yes
Yes
Yes
Yes
Yes
Yes
Yes
Yes
MMC Boot
Voltage Validation
MMC Boot
Device Init
Send CMD6 with switch 
argument
Command Successful?
Set CMD13 poll timeout 
to 100ms
Send CMD13 to read 
status
Command Successful?
Switch succeeded
End
Switch failed
Card State == 
TRANS?
CMD13 Poll 
timeout?
Start
Switch failed
Yes
Yes
Yes
Yes
No
No
No
MMC Boot
Switch Command
Figure 8-12. Expansion device (MMC) boot flow (2 of 6)
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
291

<!-- page 292 -->

1
Issue CMD8 with HV 
(3.3V)
Command Successful?
Issue CMD8 with LV 
(1.8V)
Command Successful?
Card is HC/LC HV SD 
ver 2.x
FAST_BOOT 
selected?
Set ACMD41 ARG to HV 
and HC
Set ACMD41 ARG to LV 
and HC
Card is LC SD 
ver 2.x
Set ACMD41 ARG bit 29 
for FAST BOOT
Start GPT delay of 1s for 
ACMD41
Set ACMD41 ARG to HV 
and LC
Card is LC SD 
ver 1.x
Issue CMD55
Command Successful?
Issue ACMD41
Command Successful?
Busy Bit == 1
Is Response OCR for 
HC
Card is LC SD
Card is HC SD
2
Loop Cntr < 3000 and 
looping period < 1s
Issue ACMD41
SD Boot
Voltage Validation
No
No
No
No
No
No
No
Yes
Yes
Yes
Yes
Yes
Yes
UHSI mode
selected?
Set ACMD41 ARG bit 24 
for 1.8v switch
Set ACMD41 ARG bit 28 
for SDXC power control
Yes
No
UHSI mode
selected?
Bit 24 of response
0 set?
No
Yes
Yes
2
No
Yes
8
Figure 8-13. Expansion device (SD/eSD/SDXC) boot flow (3 of 6) part 1
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
292
NXP Semiconductors

<!-- page 293 -->

Send CMD11 to switch 
voltage
Command Successful?
Switch succeeded
2
Switch failed
DATA lines
driven high?
8
Yes
Yes
Yes
No
No
SD Boot
Switch Voltage
DATA lines driven low?
switch supply voltage 
to 1.8v
delay for 5ms
set DATA line voltage 
high poll timeout to 
1ms
Voltage high
poll timeout?
Yes
No
No
7
Figure 8-14. Expansion device (SD/eSD/SDXC) boot flow (3 of 6) part 2
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
293

<!-- page 294 -->

7
Get CID from card (Issue 
CMD2)
Command Successful?
Get RCA (Issue CMD3)
Command Successful?
Set operating frequency 
to 20 MHz
Put card data Transfer 
Mode (Issue CMD7)
Command Successful?
5
Send CMD13 to read 
status
Card State == 
TRANS?
Send CMD43 to select 
partition 1
Command Successful?
4
Card is eSD
FAST_BOOT 
selected?
Set CMD13 poll timeout 
to 15ms
Set CMD13 poll timeout 
to 1s
No
No
No
No
No
No
Yes
Yes
Yes
Yes
Yes
Check Status
Bus width
fuse <> 1?
Send CMD55
Command Successful?
Send ACMD6 with bus 
width argument
Command Successful?
Set CMD13 poll timeout 
to 100ms
Check Status
Success?
High Speed mode
fuse == 0?
Send CMD6 with high 
speed argument
Set operating frequency 
to 40 MHz
Command Successful?
Change USDHC bus 
width
Yes
Yes
Yes
Yes
Yes
No
Yes
Yes
No
No
No
No
No
SD Boot
Device Initialization
UHSI mode selected?
No
9
Yes
10
Check response of 
CMD7
Card is locked?
4
Init failed
9
No
Yes
SD Boot
UHSI init
11
Send CMD55
Command Successful?
Send ACMD6 with 
argument of 4 bit width
Command Successful?
No
Yes
No
Change USDHC bus 
width
Set CMD13 poll timeout 
to 100ms
Check Status
Success?
Yes
Get clock speed from 
fuse
No
Send CMD6 with clock 
speed argument
Command Successful?
No
Change USDHC clock 
speed
Yes
Loopback clock
fuse set?
Set loopback clock bit in 
USDHC register
Yes
No
Yes
Figure 8-15. Expansion device (MMCSD/eSD/SDXC) boot flow (4 of 6)
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
294
NXP Semiconductors

<!-- page 295 -->

Send CMD13 to read 
status
Command Successful?
Success
End
Failure
Card State == 
TRANS?
CMD13 Poll 
timeout?
Start
Failure
No
No
Yes
Yes
SD Boot
Check Status
4
Set block length 512 
bytes (Issue CMD16)
DDR Mode Selected?
Command Successful?
Init ADMA buffer 
descriptors
Send CMD18 (multiple 
block read)
Set CMD18 poll timeout 
to 1s
Wait for command 
completion or timeout
Command Successful?
End
5
SD/MMC Boot
Data Read
5
USB Flow
(Serial Boot)
No
Yes
Yes
Yes
No
No
USB Boot
Serial Boot
Figure 8-16. Expansion device (SD/eSD) boot flow (5 of 6)
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
295

<!-- page 296 -->

6
High Speed mode
fuse == 0?
Set operating frequency 
to 40 MHz
Set operating frequency 
to 20 MHz
Change ESDHC bus 
width and configure DLL
Setup ADMA BD[0] 
length to 2K and BD[1] 
to 32 bytes
Set CMD line low
Set ESDHC poll counter 
to 50ms
Wait for acknowledge 
token or timeout
Acknowledge token 
accepted?
2
Set GPT poll counter to 
1s
Wait for block gap or 
timeout
Reached block gap?
Wait for block gap or 
timeout
Analyze IVT and setup 
ADMA buffer descriptors 
to final destination
Continue data trasmition
Wait for block gap or 
timeout
End
eMMC 4.x Boot
Fast Boot
Get start point and 
ramping step from fuse
11
SD Boot
sample point tuning
Set the USDHC into 
tuning mode
Set the USDHC into 
tuning mode
Set delay cell number to 
current value
Configure the block 
length and block number
Send CMD19 to request 
the tuning block
Tuning passed?
Check the tuning status
Increase current value 
with ramping step
Exceed limit?
Tuning failed
4
No
Yes
Set bottom boundary to 
current value
Yes
No
Increase current value 
with ramping step
Exceed limit?
Set upper boundary to 
last value
Configure the block 
length and block number
Send CMD19 to request 
the tuning block
Check the tuning status
Tuning passed?
Yes
No
Yes
No
Set delay cell number to 
average of bottom and 
upper boundary value
Tuning passed
10
Figure 8-17. Expansion device boot flow (6 of 6)
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
296
NXP Semiconductors

<!-- page 297 -->

8.5.3.3
SD, eSD, and SDXC
After the normal boot mode initialization begins, the SD/eSD/SDXC frequency is set to
347.22 kHz. During the identification phase, the SD/eSD/SDXC card voltage validation
is performed. During the voltage validation, the boot code first checks with the high-
voltage settings; if that fails, it checks with the low-voltage settings.
The capacity of the card is also checked. The boot code supports the high-capacity and
low-capacity SD/eSD/SDXC cards after the voltage validation card initialization is done.
During the card initialization, the ROM boot code attempts to set the boot partition for all
SD, eSD, and SDXC devices. If this fails, the boot code assumes that the card is a normal
SD or SDXC card. If it does not fail, the boot code assumes it is an eSD card. After the
initialization phase is over, the boot code switches to a higher frequency (25 MHz in the
normal-speed mode or 50 MHz in the high-speed mode). The ROM also supports the
FAST_BOOT mode booting from the eSD card. This mode can be selected by the
BOOT_CFG1[4] (Fast Boot) fuse described in Table 8-15.
For the UHSI cards, the clock speed fuses can be set to SDR50 or SDR104 on USDHC1,
USDHC2, ports. This enables the voltage switch process to set the signaling voltage to
1.8 V during the voltage validation. The bus width is fixed at a 4-bit width and a
sampling point tuning process is needed to calibrate the number of the delay cells. If the
SD Loopback Clock eFuse is set, the feedback clock comes directly from the loopback
SD clock, instead of the card clock (by default). The SD clock speed can be selected by
the BOOT_CFG1[3:2], and the SD Loopback Clock is selected by the BOOT_CFG1[0].
The UHSI calibration start value (MMC_DLL_DLY[6:0]) and the step value
(BOOT_CFG2[7:5]) can be set to optimize the sample point tuning process.
If the SD Power Cycle Enable eFuse is 1, the ROM sets the SD_RST pad low, waits for 5
ms, and then sets the SD_RST pad high. If the SD_RST pad is connected to the SD
power supply enable logic on board, it enables the power cycle of the SD card. This may
be crucial in case the SD logic is in the 1.8 V states and must be reset to the 3.3 V states.
The SDR50 and SDR104 boots are not supported on the USDHC1 and USDHC2 ports
because there are no reset signals for those ports when connected in the IOMUX.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
297

<!-- page 298 -->

8.5.3.4
IOMUX configuration for SD/MMC
Table 8-18. SD/MMC IOMUX pin configuration
Signal
USDHC1
USDHC2
CLK
SD1_CLK.alt0
NAND_RE_B.alt1
CMD
SD1_CMD.alt0
NAND_WE_B.alt1
DATA0
SD1_DATA0.alt0
NAND_DATA00.alt1
DATA1
SD1_DATA1.alt0
NAND_DATA01.alt1
DATA2
SD1_DATA2.alt0
NAND_DATA02.alt1
DATA3
SD1_DATA3.alt0
NAND_DATA03.alt1
DATA4
NAND_READY_B.alt1
NAND_DATA04.alt1
DATA5
NAND_CE0_B.alt1
NAND_DATA05.alt1
DATA6
NAND_CE1_B.alt1
NAND_DATA06.alt1
DATA7
NAND_CLE.alt1
NAND_DATA07.atl1
VSELECT
GPIO1_IO05.alt4
GPIO1_IO08.alt4
RESET_B
GPIO1_IO09.alt5
NAND_ALE.alt5
CD_B
UART1_RTS_B.alt2
—
8.5.3.5
Redundant boot support for expansion device
The ROM supports the redundant boot for an expansion device. The primary or
secondary image is selected, depending on the PERSIST_SECONDARY_BOOT setting.
(see Table 8-6).
If the PERSIST_SECONDARY_BOOT is 0, the boot ROM uses address 0x0 for the
primary image.
If the PERSIST_SECONDARY_BOOT is 1, the boot ROM reads the secondary image
table from address 0x200 on the boot media and uses the address specified in the table.
Table 8-19. Secondary image table format
Reserved (chipNum)
Reserved (driveType)
tag
firstSectorNumber
Reserved (sectorCount)
Where:
• The tag is used as an indication of the valid secondary image table. It must be
0x00112233.
• The firstSectorNumber is the first 512-byte sector number of the secondary image.
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
298
NXP Semiconductors

<!-- page 299 -->

For the secondary image support, the primary image must reserve the space for the
secondary image table. See this figure for the typical structures layout on an expansion
device.
0x00000200
0x00000400
Reserved For MBR 
(optional)
Media Partitions
Program Image (Starting 
From IVT)
0x00000000
Reserved for Secondary 
Image Table (optional)
Figure 8-18. Expansion device structures layout
For the Closed mode, if there are failures during primary image authentication, the boot
ROM turns on the PERSIST_SECONDARY_BOOT bit (see Table 8-6) and performs the
software reset. (After the software reset, the secondary image is used.)
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
299

<!-- page 300 -->

8.5.4
Serial ROM through SPI
The chip supports booting from serial memory devices, such as EEPROM and serial
flash, using the SPI.
These ports are available for serial boot: eCSPI (eCSPI1, eCSPI2, eCSPI3, eCSPI4)
interfaces.
8.5.4.1
Serial ROM eFUSE configuration
The boot ROM code determines the type of device using the following parameters, either
provided by the eFUSE settings or sampled on the I/O pins, during boot.
See this table for details:
Table 8-20. Serial ROM boot eFUSE descriptions
Fuse
Config
Definition
GPIO1
Shipped
value
Settings
BOOT_CFG1[7:4]
OEM
Boot device selection
Yes
0000
0011 - Boot from the serial ROM
BOOT_CFG4[6]
OEM
EEPROM recovery
enable
Yes
0
0 - Disabled EEPROM recovery
1 - Enabled EEPROM recovery
BOOT_CFG4[5:4]
OEM
CS select (SPI only)
Yes
00
00 - ECSPIx_SS0
01 - ECSPIx_SS1
10 - ECSPIx_SS2
11 - ECSPIx_SS3
BOOT_CFG4[3]
OEM
SPI addressing (SPI
only)
Yes
0
0 - 2 B (16-bit)
1 - 3 B (24-bit)
BOOT_CFG4[2:0]
OEM
Port select
Yes
00
000 - ECSPI-1
001 - ECSPI-2
010 - ECSPI-3
011 - ECSPI-4
1xx - Reserved
1.
The setting can be overridden by the GPIO settings when the BT_FUSE_SEL fuse is intact. See GPIO Boot Overrides for
the corresponding GPIO pin.
The ECPSI-1/ECPSI-2/ECPSI-3/ECPSI-4 block can be used as a boot device using the
ECSPI interface for the serial ROM boot. The SPI interface is configured to operate at 15
MHz for 3-byte addressing devices and at 3.75 MHz for 2-byte addressing devices.
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
300
NXP Semiconductors

<!-- page 301 -->

The boot ROM copies 4 KB of data from the serial ROM device to the internal RAM.
After checking the Image Vector Table header value (0xD1) from the program image, the
ROM code performs a DCD check. After a successful DCD extraction, the ROM code
extracts the destination pointer and length of image from the Boot Data Structure to be
copied to the RAM device from where the code execution occurs.
NOTE
The Initial 4 KB of program image must contain the IVT, DCD,
and the Boot Data Structures.
8.5.4.2
ECSPI boot
The Enhanced Configurable SPI (ECSPI) interface is configured in the master mode and
the EEPROM device is connected to the ECSPI interface as a slave.
The boot ROM code copies 4 KB of data from the EEPROM device to the internal RAM.
If the DCD verification is successful, the ROM code copies the initial 4 KB of data, as
well as the rest of the image extracted from the application image, directly to the
application destination. The ECSPI can read data from the EEPROM using 2- or 3-byte
addressing. Its burst length is 32 B.
NOTE
The Serial ROM Chip Select Number is determined by the
BOOT_CFG4[5:4] (Chip Select) fuse.
When using the SPI as a boot device, the chip supports booting from both the serial
EEPROM and serial flash devices. The boot code determines which device is being used
by reading the appropriate eFUSE/I/O values at the boot (see Table 8-20 for details).
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
301

<!-- page 302 -->

EEPROM Read data 
no
yes
Set instruction length 
address cycle according 
to fuses
Send read instruction to 
read burst length of data 
Read  burst length  of 
data  and copy to 
destination pointer 
yes
Increment  destination 
pointer and reduce 
length of data read
NO
If read instruction status 
is CSPI_SUCCESS
yes
Assign MSB as read
 
Send read instruction to 
read remaining  length  
of data 
Read  remaining  length  
of data  and copy to 
destination pointer 
yes
If read instruction status 
is CSPI_SUCCESS
NO
NO
Disable CSPI
Configure CSPI clock
divider==success
If read data length>0
If read data length
greater than (burst 
length-instruction
length)
B
B
END
instruction (0x30)
and other 2/3 byte dest
address in data pointer
END
Start
Assign MSB as read 
instruction (0x30) and other
2/3 byte dest address 
in data pointer
Figure 8-19. CSPI flow chart
8.5.4.2.1
ECSPI IOMUX pin configuration
The contacts assigned to the signals used by the CSPI blocks are shown in this table:
Table 8-21. ECSPI IOMUX pin configuration
Signal
eCSPI1
eCSPI2
eCSPI3
eCSPI4
MISO
CSI_DATA07.alt3
CSI_DATA03.alt3
UART2_RTS_B.alt8
ENET2_TX_CLK.alt3
MOSI
CSI_DATA06.alt3
CSI_DATA02.alt3
UART2_CTS_B.alt8
ENET2_TX_EN.alt3
Table continues on the next page...
Boot devices (internal boot)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
302
NXP Semiconductors

<!-- page 303 -->

Table 8-21. ECSPI IOMUX pin configuration
(continued)
Signal
eCSPI1
eCSPI2
eCSPI3
eCSPI4
SCLK
CSI_DATA04.alt3
CSI_DATA00.alt3
UART2_RX_DATA.alt8
ENET2_TX_DATA1.alt
3
SS0
CSI_DATA05.alt3
CSI_DATA01.alt3
UART2_TX_DATA.alt8
ENET2_RX_ER.alt3
SS1
LCD_DATA05.alt8
LCD_HSYNC.alt8
NAND_ALE.alt8
NAND_DATA01.alt8
SS2
LCD_DATA06.alt8
LCD_VSYNC.alt8
NAND_RE_B.alt8
NAND_DATA02.alt8
SS3
LCD_DATA07.alt8
LCD_RESET.alt8
NAND_WE_B.alt8
NAND_DATA03.alt8
8.6
QuadSPI serial flash memory boot
8.6.1
QuadSPI eFUSE configuration
Table 8-22. QSPI Boot eFUSE descriptions
Fuse
Config
Definition
GPIO
Shipped
value
Settings
BOOT_CFG1[7:4]
OEM
Boot device selection
Yes
0001
0001 - Boot from QuadSPI
BOOT_CFG1[3]
OEM
QuadSPI interface
selection
Yes
0
0 - QSPI1
1 - Reserved
8.6.2
QuadSPI serial flash BOOT operation
The Boot ROM attempts to boot from the QuadSPI flash if the BOOT_CFG1[7:4] fuses
are programmed to 0001, as shown in the QuadSPI eFUSE configuration table. The ROM
initializes the requested QuadSPI Interface as selected in the Fuse bit BOOT_CFG1[3] in
the QuadSPI eFUSE configuration. The QuadSPI interface initialization is a two-step
process.
The ROM expects the QuadSPI configuration parameters (as explained in the QuadSPI
Configuration Parameters) to be present in the serial flash memory from the offset 0x400
of serial flash of length 512 bytes. The ROM reads these configuration parameters using
the default read command configured in the LUT of the QuadSPI interface with the
SCLOCK operating at 18 MHz.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
303

<!-- page 304 -->

In the second step, the ROM configures the selected QuadSPI interface with the
configuration parameters read from the serial flash and starts the boot procedure. Refer to
Table 19-12 for details on the QuadSPI configuration parameters and to the QuadSPI
boot flow chart for a detailed boot flow chart of the QuadSPI.
Both booting the XIP and non-XIP image is supported from the serial flash. For the XIP
boot, the image must be built for the QuadSPI address space, and for the non-XIP, the
image can be built to execute from the DDR or OCRAM.
For the QUAD mode boot, the Boot ROM expects the Quad Enable bit inside the QSPI
flash to be already set before the booting starts. Therefore, the QUAD enable bit must be
set in the non-volatile register of the flash at the time of programming.
NOTE
If the SPI flash device requires the quad enable command, it
can be sent via these configuration structure fields:
device_quad_mode_en, device_cmd, write_cmd_ipcr,
write_enable_ipcr, busy_bit_offset, and read_status_ipcr.
8.6.3
QuadSPI configuration parameters
The QuadSPI Configuration Parameters Table is built in the boot image at a fixed offset
of 0x400 from the QSPI NOR A1 base address (368 B). This table lists the various
QuadSPI configuration parameters:
Table 8-23. QuadSPI configuration parameters
Name
Offset
Size in
bytes
Description
DQS Loopback
0
4
DQS LoopBack Mode to enable the Dummy Pad, 0 - Disable, 1 - Enable
Hold Delay
4
4
Hold Delay for QSPI[0,1] A/B
Value
QSPI1 B
QSPI1 A
00
Disable
Disable
01
Disable
Enable
10
Enable
Disable
11
Enable
Enable
Reserved
8
4
Reserved to 0
Reserved
12
4
Reserved to 0
device_quad_mo
de_en
16
4
Send the Quad enable command to the SPI device.
device_cmd
20
4
Command to send to the SPI device.
Table continues on the next page...
QuadSPI serial flash memory boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
304
NXP Semiconductors

<!-- page 305 -->

Table 8-23. QuadSPI configuration parameters (continued)
Name
Offset
Size in
bytes
Description
write_cmd_ipcr
24
4
IPCR register value for a write command
write_enable_ipcr 28
4
IPCR register value for Enable
Chip Select hold
time
32
4
This is a chip-select hold time in terms of Serial clock (For Example 1 serial clock
cycle 0-15).
Chip Select setup
time
36
4
Chip select setup time in terms of Serial clock (For example 1 serial clock).
Serial Flash A1
size
40
4
Serial flash A1 size in units of bytes
Serial Flash A2
size
44
4
Serial flash A2 size in units of bytes
Serial Flash B1
size
48
4
Serial flash B1 size in units of bytes
Serial Flash B2
52
4
Serial flash B2 size in units of bytes
Serial Clock
Frequency
56
4
This is a serial clock frequency select parameter.
Value
Clock
00
18 MHz
01
49 MHz
02
55 MHz
03
60 MHz
04
66 MHz
05
76 MHz
06
99 MHz (only SDR mode)
busy_bit_offset
60
4
SPI flash device busy bit offset in its status register, used for enabling the Quad
mode of the SPI device
Mode of
operation of
serial Flash
64
4
This field describes the mode of operation of Serial flash
Value
Mode
01
Single
02
Dual
04
Quad
Serial Flash Port
B Selection
68
4
Port A is always available. This field informs the device ROM about the
availability of Port B.
0 – Port B is not used.
1 – Port B is used.
Dual Data Rate
mode enable
72
4
This field enables the device ROM to enable the DDR mode.
0 – DDR mode is disabled.
1 – DDR mode is enabled.
Table continues on the next page...
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
305

<!-- page 306 -->

Table 8-23. QuadSPI configuration parameters (continued)
Name
Offset
Size in
bytes
Description
Data Strobe
Signal enable in
Serial Flash
76
4
This field enables the Data Strobe signal in the Serial flash which supports it.
0 – Disable DQS
1 – Enable DQS
Parallel Mode
enable
80
4
This field enables the parallel mode. The data are read from the Serial flash in
the parallel mode. Refer to the QSP chapter for details.
0 – Disable Parallel mode in QSPI
1 – Enable Parallel Mode in QSPI
CS1 on Port A
84
4
This field enables CS1 on port A
0 – Disable CS1 on Port A
1 – Enable CS1 on Port A
CS1 on Port B
88
4
This field enables CS1 on port B
0 – Disable CS1 on Port B
1 – Enable CS1 on Port B
Full Speed Phase
Selection
92
4
Select the edge of the sampling clock valid for the full-speed commands:
0 - Select the sampling at the non-inverted clock
1 - Select the sampling at the inverted clock
This bit is also used to shift the dqs_enable when the DQS mode is selected.
Full Speed Delay
Selection
96
4
Select the delay w.r.t. the reference edge for the sample point valid for full-speed
commands:
0 - One clock cycle delay
1 - Two clock cycles delay
This bit is also used to shift the dqs_enable when the DQS mode is selected.
DDR Sampling
Point
100
4
Select the sampling point for the incoming data when the serial flash is in the
DDR mode.
NOTE: The valid values are (b000-b111)
LUT program
sequence
104
256
256 bytes of the Look-Up Table program sequence. The ROM programs the LUT
of QuadSPI with this parameter supplied.
It assumes that the optimize read command sequence which is used to read the
data from the Serial flash and fill the AHB buffer is programmed at index 0.
read_status_ipcr
360
4
IPCR value of Read Status Reg
enable_dqs_phas
e
364
4
Enable DQS Phase
Reserved
368
36
Not used
dqs_pad_setting_
override
404
4
DQS pin pad setting override
sclk_pad_setting
_override
408
4
SCLK pin pad setting override
data_pad_setting
_override
412
4
DATA pins pad setting override
Table continues on the next page...
QuadSPI serial flash memory boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
306
NXP Semiconductors

<!-- page 307 -->

Table 8-23. QuadSPI configuration parameters (continued)
Name
Offset
Size in
bytes
Description
cs_pad_setting_o
verride
416
4
CS pins pad setting override
dqs_loopback_int
ernal
420
4
0 - dqs loopback from pad
1 - dqs loopback internally
dqs_phase_sel
424
4
dqs phase selection
dqs_fa_delay_ch
ain_sel
428
4
dqs fa delay chain selection
dqs_fb_delay_ch
ain_sel
432
4
dqs fb delay chain selection
sclk_fa_delay_ch
ain_sel
436
4
sclk fa delay chain selection
sclk_fb_delay_ch
ain_sel
440
4
sclk fb delay chain selection
Reserved
444
64
Reserved
tag
508
4
End flag of the QSPI parameters area
8.6.4
IOMUX configuration for QSPI devices
The QSPI interface uses the dedicated contacts on the IC. The contacts assigned to the
data signals used by the QSPI are shown in these tables:
Table 8-24. QuadSPI IOMUX pin configuration
Signal
QSPI1
A_SCLK
NAND_WP_b.alt2
A_SS0_B
NAND_DQS.alt2
A_SS1_B
NAND_DATA07.alt2
A_DATA0
NAND_READY_B.alt2
A_DATA1
NAND_CE0_B.alt2
A_DATA2
NAND_CE1.B.alt2
A_DATA3
NAND_CLE.alt2
A_DQS
NAND_ALE.alt2
B_SCLK
NAND_RE_B.alt2
B_SS0_B
NAND_WE_B.alt2
B_SS1_B
NAND_DATA00.alt2
B_DATA0
NAND_DATA02.alt2
B_DATA1
NAND_DATA03.alt2
B_DATA2
NAND_DATA04.alt2
B_DATA3
NAND_DATA05.alt2
B_DQS
NAND_DATA01.alt2
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
307

<!-- page 308 -->

8.6.5
QuadSPI boot flow chart
start
Configure QuadSPI Pin mux and Clock to 18 Mhz to perform
basic read operation.
Get Configuration parameter.
Configure QSPI IOMUX as per the configuration parameter.
Configure QSPI Lookup table as received in the
configuration parameter
Configure QSPI controller as desired in the configuration
parameters.
Configure SCLOCK to 49, 55, 60, 66, 76 or 99 Mhz as desired
by the configuration parameter.
Set boot Device parameter. (i.e initial image address and its
range for desired QSPI interface)
Image == XIP
Execute the image from QuadSPI address Space.
Yes
No (NON XIP Image)
Copy Image to DDR or OCRAM
Execute Image from DDR or
OCRAM
End
Figure 8-20. QuadSPI boot flow chart
NOTE
If the flash is configured for the "high-performance mode"
(where the command is generated only once) in the LUT
program sequence, then the external reset must be routed to the
flash reset to allow rebooting in case of a device reset different
from the Power-On Reset. This high-performance mode must
QuadSPI serial flash memory boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
308
NXP Semiconductors

<!-- page 309 -->

be exited by the application before any low-power mode entry,
where the device is supposed to reboot from QSPI flash on the
low-power mode exit. In general, any preserved configuration
in the external flash is not understood by the device after the
reset.
8.7
Program image
This section describes the data structures that are required to be included in the user's
program image. The program image consists of:
• Image vector table—a list of pointers located at a fixed address that the ROM
examines to determine where the other components of the program image are
located.
• Boot data—a table that indicates the program image location, program image size in
bytes, and the plugin flag.
• Device configuration data—IC configuration data.
• User code and data.
8.7.1
Image Vector Table and Boot Data
The Image Vector Table (IVT) is the data structure that the ROM reads from the boot
device supplying the program image containing the required data components to perform
a successful boot.
The IVT includes the program image entry point, a pointer to Device Configuration Data
(DCD) and other pointers used by the ROM during the boot process.The ROM locates
the IVT at a fixed address that is determined by the boot device connected to the Chip.
The IVT offset from the base address and initial load region size for each boot device
type is defined in the table below. The location of the IVT is the only fixed requirement
by the ROM. The remainder or the image memory map is flexible and is determined by
the contents of the IVT.
Table 8-25. Image Vector Table Offset and Initial Load Region Size
Boot Device Type
Image Vector Table Offset
Initial Load Region Size
NOR
4 Kbyte = 0x1000 bytes
Entire Image Size
OneNAND
256 bytes = 0x100 bytes
1 Kbyte
SD/MMC/eSD/eMMC/SDXC
1 Kbyte = 0x400 bytes
4 Kbyte
SPI EEPROM
1 Kbyte = 0x400 bytes
4 Kbyte
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
309

<!-- page 310 -->

Initial
Load Region
Figure 8-21. Image Vector Table
8.7.1.1
Image vector table structure
The IVT has the following format where each entry is a 32-bit word:
Table 8-26. IVT format
header
entry: Absolute address of the first instruction to execute from the image
reserved1: Reserved and should be zero
dcd: Absolute address of the image DCD. The DCD is optional so this field may be set to NULL if no DCD is required. See
Device Configuration Data (DCD) for further details on the DCD.
boot data: Absolute address of the boot data
self: Absolute address of the IVT. Used internally by the ROM.
csf: Absolute address of the Command Sequence File (CSF) used by the HAB library. See High-Assurance Boot (HAB) for
details on the secure boot using HAB. This field must be set to NULL when not performing a secure boot
reserved2: Reserved and should be zero
Figure 8-22 shows the IVT header format:
Program image
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
310
NXP Semiconductors

<!-- page 311 -->

Tag
Length
Version
Figure 8-22. IVT header format
where:
Tag: A single byte field set to 0xD1
Length: a two byte field in big endian format containing the overall length of the IVT, 
in bytes, including the header. (the length is fixed and must have a value of 
32 bytes)
Version: A single byte field set to 0x40 or 0x41
8.7.1.2
Boot data structure
The boot data must follow the format defined in the table found here, each entry is a 32-
bit word.
Table 8-27. Boot data format
start
Absolute address of the image
length
Size of the program image
plugin
Plugin flag (see Plugin image)
8.7.2
Device Configuration Data (DCD)
Upon reset, the chip uses the default register values for all peripherals in the system.
However, these settings typically are not ideal for achieving the optimal system
performance and there are even some peripherals that must be configured before they can
be used.
The DCD is a configuration information contained in the program image (external to the
ROM) that the ROM interprets to configure various peripherals on the chip.
For example, the EIM default settings allow the core to interface to a NOR flash device
immediately after the reset. This allows the chip to interface with any NOR flash device,
but has the disadvantage of slow performance. Additionally, some components (such as
DDR) require some sequence of register programming as a part of the configuration
before it is ready to be used. The DCD feature can be used to program the EIM registers
and the MMDC registers to the optimal settings.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
311

<!-- page 312 -->

The ROM determines the location of the DCD table based on the information located in
the Image Vector Table (IVT). See Image Vector Table and Boot Data for more details.
The DCD table shown below is a big-endian byte array of the allowable DCD commands.
The maximum size of the DCD is limited to 1768 B.
Header
[CMD]
[CMD]
...
Figure 8-23. DCD data format
The DCD header is 4 B with the following format:
Tag
Length
Version
Figure 8-24. DCD header format
where:
Tag: A single-byte field set to 0xD2
Length: a two-byte field in the big-endian format containing the overall length of the DCD 
(in bytes) including the header
Version: A single-byte field set to 0x41
8.7.2.1
Write data command
The write data command is used to write a list of given 1-, 2- or 4-byte values (or
bitmasks) to a corresponding list of target addresses.
The format of the write data command (in a big-endian byte array) is shown in this table:
Table 8-28. Write data command format
Tag
Length
Parameter
Address
Value/Mask
Table continues on the next page...
Program image
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
312
NXP Semiconductors

<!-- page 313 -->

Table 8-28. Write data command format (continued)
[Address]
[Value/Mask]
...
[Address]
[Value/Mask]
where:
Tag: a single-byte field set to 0xCC
Length: a two-byte field in a big-endian format, containing the length of the Write Data 
Command (in bytes) including the header
Address: the target address to which the data must be written
Value/Mask: the data value (or bitmask) to be written to the preceding address
The parameter field is a single byte divided into the bitfields, as follows:
Table 8-29. Write data command parameter field
7
6
5
4
3
2
1
0
flags
bytes
where
bytes: the width of the target locations in bytes (either 1, 2, or 4)
flags: control flags for the command behavior
Data Mask = bit 3: if set, only specific bits may be overwritten at the target address 
(otherwise all bits may be overwritten)
Data Set = bit 4: if set, the bits at the target address are overwritten with this flag 
(otherwise it is ignored)
One or more target address and value/bitmask pairs can be specified. The same bytes' and
flags' parameters apply to all locations in the command.
When successful, this command writes to each target address in accordance with the flags
as follows:
Table 8-30. Interpretation of write data command flags
"Mask"
"Set"
Action
Interpretation
0
0
*address = val_msk
Write value
0
1
*address = val_msk
Write value
1
0
*address &= ~val_msk
Clear bitmask
1
1
*address |= val_msk
Set bitmask
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
313

<!-- page 314 -->

NOTE
If any of the target addresses does not have the same alignment
as the data width indicated in the parameter field, none of the
values are written.
If any of the values are larger or any of the bitmasks are wider
than permitted by the data width indicated in the parameter
field, none of the values are written.
If any of the target addresses do not lie within the allowed
region, none of the values are written. The list of allowable
blocks and target addresses for the chip are provided below.
Table 8-31. Valid DCD address ranges
Address range
Start address
Last address
IOMUX Control (IOMUXC) registers
0x020E0000
0x020E3FFF
IOMUXC GPR
0x020E4000
0x020E7FFF
CCM register set
0x020C4000
0x020C7FFF
ANADIG registers
0x020C8000
0x020C8FFF
MMDC register set
0x021B0000
0x021B3FFF
OCRAM free space
0x00907000
0x00917FF0
EIM registers
0x021B8000
0x021BBFFF
DDR
0x10000000
0xFFFF7FFF
EPIT
EPIT1: 0x020D0000
EPIT1: 0x020D3FFF
8.7.2.2
Check data command
The check data command is used to test for a given 1-, 2-, or 4-byte bitmasks from a
source address.
The check data command is a big-endian byte array with the format shown in this table:
Table 8-32. Check data command format
Tag
Length
Parameter
Address
Mask
[Count]
where:
Tag: a single-byte field set to 0xCF
Length: a two-byte field in the big-endian format containing the length of the check data 
command (in bytes) including the header
Program image
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
314
NXP Semiconductors

<!-- page 315 -->

Address: the source address to test
Mask: the bit mask to test
Count: an optional poll count; If the count is not specified, this command polls 
indefinitely 
until the exit condition is met. If count = 0, this command behaves as for the NOP.
The parameter field is a single byte divided into bitfields, as follows:
Table 8-33. Check data command parameter field
7
6
5
4
3
2
1
0
flags
bytes
where
bytes: the width of target locations in bytes (either 1, 2, or 4)
flags: control flags for the command behavior
Data Mask = bit 3: if set, only the specific bits may be overwritten at a target address 
(otherwise all bits may be overwritten)
Data Set = bit 4: if set, the bits at the target address are overwritten with this flag 
(otherwise it is ignored)
This command polls the source address until either the exit condition is satisfied, or the
poll count is reached. The exit condition is determined by the flags as follows:
Table 8-34. Interpretation of check data command flags
"Mask"
"Set"
Action
Interpretation
0
0
(*address & mask) == 0
All bits clear
0
1
(*address & mask) == mask
All bits set
1
0
(*address & mask)!= mask
Any bit clear
1
1
(*address & mask)!= 0
Any bit set
NOTE
If the source address does not have the same alignment as the
data width indicated in the parameter field, the value is not
read.
If the bitmask is wider than permitted by the data width
indicated in the parameter field, the value is not read.
8.7.2.3
NOP command
This command has no effect.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
315

<!-- page 316 -->

The format of the NOP command is a big-endian four-byte array, as shown in this table:
Table 8-35. NOP command format
Tag
Length
Undefined
where:
Tag: a single-byte field set to 0xC0
Length: a two-byte field in big endian containing the length of the NOP command in bytes 
(fixed to a 
value of 4)
Undefined: this byte is ignored and can be set to any value.
8.7.2.4
Unlock command
The unlock command is used to prevent specific engine features from being locked when
exiting the ROM.
The format of the unlock command (in a big-endian byte array) is shown in this table:
Table 8-36. Unlock command format
Tag
Length
Eng
Value
Value
...
Value
where:
Tag: a single-byte field set to 0xB2
Eng: the engine to be left unlocked
Values: [optional] the unlock values required by the engine
NOTE
This command may not be used in the DCD structure if the
SEC_CONFIG is configured as closed.
8.8
Plugin image
The ROM supports a limited number of boot devices. When using other devices as a boot
source (for example, Ethernet, CDROM, or USB), the supported boot device must be
used (typically serial ROM) as a firmware to provide the missing boot drivers.
Plugin image
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
316
NXP Semiconductors

<!-- page 317 -->

Additionally, the plugin can be customized to support boot drivers, which is more
flexible when performing the device initialization, such as condition judging, delay
assertion, or to apply custom settings to the boot device and memory system.
In addition to the standard images, the chip also supports plugin images. The plugin
images return the execution to the ROM whereas the standard image does not.
The boot ROM detects the image type using the plugin flag of the boot data structure (see
Boot data structure). If the plugin flag is 1, then the ROM uses the image as a plugin
function. The function must initialize the boot device and copy the program image to the
final location. At the end, the plugin function must return with the program image
parameters. (See High-level boot sequence for details about the boot flow).
The boot ROM authenticates the plugin image before running the plugin function and
then authenticates the program image.
The plugin function must follow the API described below:
typedef BOOLEAN (*plugin_download_f)(void **start, size_t *bytes, UINT32
*ivt_offset);
ARGUMENTS PASSED:
• start - the image load address on exit.
• bytes - the image size on exit.
• ivt_offset - the offset (in bytes) of the IVT from the image start address on exit.
RETURN VALUE:
• 1 - success
• 0 - failure
8.9
Serial Downloader
The Serial Downloader provides a means to download a program image to the chip over
the USB and UART serial connection.
In this mode, the ROM programs the WDOG1 for a time-out specified by the fuse
WDOG Time-out Select (See fusemap for details) if the WDOG_ENABLE eFuse is 1
and continuously polls for the USB and UART connection. If no activity is found on the
USB OTG1and UART 1/2 and the watchdog timer expires, the Arm core is reset.
NOTE
After the downloaded image is loaded, it is responsible for
managing the watchdog resets properly.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
317

<!-- page 318 -->

This figure shows the USB and UART boot flow:
Serial Downloader
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
318
NXP Semiconductors

<!-- page 319 -->

START
Reset
UART Serial Download
function is enabled
Configure UART 1 / 2
Program WDOG for X seconds
(Default is 64 seconds)
Poll UART 1 / 2
Complete UART 1 / 2
Initialization
Ready for Serial
Download
Configure USB OTG1
UART Serial Download
function is enabled
Poll USB OTG1
UART 1 / 2 Activity 
Detected
Complete USB HID enumeration, 
due to activity detected 
WDOG_ENABLE==1 
&& WDOG timeout
USB OTG1 Activity
Detected
Yes
Yes
Yes
Yes
Yes
Yes
No
No
No
No
No
WDOG_ENABLE==1
Figure 8-25. Serial Downloader boot flow
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
319

<!-- page 320 -->

8.9.1
USB
The USB support is composed of the USBOH3USBO2 (USB OTG1USB OTG core
controller, compliant with the USB 2.0 specification) and the USBPHY (HS USB
transceiver).
The ROM supports the USB OTG port for boot purposes. The other USB ports on the
chip are not supported for boot purposes.
The USB Driver is implemented as a USB HID class. A collection of four HID reports
are used to implement the SDP protocol for data transfers, as described in Table 8-37.
Table 8-37. USB HID reports
Report ID (first byte)
Transfer endpoint
Direction
Length
Description
1
control OUT
Host to device
17 B
SDP command from the
host to the device.
2
control OUT
Host to device
Up to 1025 B
Data associated with
the report 1 SDP
command.
3
interrupt
Device to host
5 B
HAB security
configuration. The
device sends
0x12343412 in the
closed mode and
0x56787856 in the
open mode.
4
interrupt
Device to host
Up to 65 B
Data in response to the
SDP command in report
1.
8.9.1.1
USB configuration details
The USB OTG function device driver supports a high speed (HS for UTMI) non-stream
mode with a maximal packet size of 512 B and a low-level USB OTG function.
The VID/PID and strings for the USB device driver are listed in the following table.
Table 8-38. VID/PID and strings for USB device driver
Descriptor
Value
VID
0x15A2
(NXP vendor ID)
PID1
0x007D
Table continues on the next page...
Serial Downloader
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
320
NXP Semiconductors

<!-- page 321 -->

Table 8-38. VID/PID and strings for USB device driver (continued)
Descriptor
Value
String Descriptor1 (manufacturer)
NXP Semiconductors
String Descriptor2 (product)
S Blank
SE Blank
NS Blank
String Descriptor4
NXP Flash
String Descriptor5
NXP Flash
1.
Allocation based on the BPN (Before Part Number)
8.9.1.2
IOMUX configuration for USB
The interface signals of the UTMI PHY are not configured in the IOMUX. The UTMI
PHY interface uses the dedicated contacts on the IC. See the chip data sheet for details.
8.9.2
UART
The ROM supports the UART1 and UART2 ports for boot purposes. The other UART
ports on the chip are not supported for boot purposes.
If an event of data ready in the UART FIFO is detected, the ROM enters the UART serial
download boot mode, and starts to read the data from the UART port which reports the
data ready event. The noise on the UART RX data pad may cause a “data ready” event
reported by the UART controller, and further cause the ROM to enter the UART serial
download mode. Hardware designers must take care to avoid such exception.
8.9.2.1
UART configuration details
Table 8-39. UART configuration details
Transmission protocol
RS232
Start bit
1 bit
Stop bit
1 bit
Parity bit
No needed
Flow control
No needed
Baud rate
115200 bps
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
321

<!-- page 322 -->

8.9.2.2
UART eFUSE configuration
Table 8-40. UART eFUSE configuration
Fuse
Config
Definition
GPIO
Shipped value
Settings
0x470[4]
OEM
UART Serial Download
Disabled Selection
Yes
0
0 - UART serial download
enabled
1 - disabled
8.9.2.3
IOMUX configuration for UART
Table 8-41. IOMUX configuration for UART
Signal
UART1
UART2
TXD
UART1_TX_DATA.alt0
UART2_TX_DATA.alt0
RXD
UART1_RX_DATA.alt0
UART2_RX_DATA.alt0
8.9.3
Serial Download Protocol (SDP)
The 16-byte SDP command from the host to device is sent using the HID report 1.
This table describes the 16-byte SDP command data structure:
Table 8-42. 16-byte SDP command data structure
BYTE offset
Size
Name
Description
0
2
COMMAND TYPE
These commands are supported for the ROM:
• 0x0101 READ_REGISTER
• 0x0202 WRITE_REGISTER
• 0x0404 WRITE_FILE
• 0x0505 ERROR_STATUS
• 0x0A0A DCD_WRITE
• 0x0B0B JUMP_ADDRESS
• 0x0C0C SKIP_DCD_HEADER
2
4
ADDRESS
Only relevant for these commands:
READ_REGISTER, WRITE_REGISTER, WRITE_FILE,
DCD_WRITE, and JUMP_ADDRESS.
Table continues on the next page...
Serial Downloader
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
322
NXP Semiconductors

<!-- page 323 -->

Table 8-42. 16-byte SDP command data structure (continued)
BYTE offset
Size
Name
Description
For the READ_REGISTER and WRITE_REGISTER
commands, this field is the address to a register. For the
WRITE_FILE and JUMP_ADDRESS commands, this
field is an address to the internal or external memory
address.
6
1
FORMAT
Format of access, 0x8 for an 8-bit access, 0x10 for a 16-
bit access, and 0x20 for a 32-bit access. Only relevant
for the READ_REGISTER and WRITE_REGISTER
commands.
7
4
DATA COUNT
Size of the data to read or write. Only relevant for the
WRITE_FILE, READ_REGISTER, WRITE_REGISTER,
and DCD_WRITE commands. For the WRITE_FILE and
DCD_WRITE commands, the DATA COUNT is in the
byte units.
11
4
DATA
The value to write. Only relevant for the
WRITE_REGISTER command.
15
1
RESERVED
Reserved
8.9.3.1
SDP commands
The SDP commands are described in the following sections.
8.9.3.1.1
READ_REGISTER
The transaction for the READ_REGISTER command consists of these reports: Report1
for the command, Report3 for the security configuration, and Report4 for the response or
the register value.
The register to read is specified in the ADDRESS field of the SDP command. The first
device sends Report3 with the security configuration followed by the Report4 with the
bytes read at a given address. If the count is greater than 64, multiple reports with the
report id 4 are sent until the entire data requested by the host is sent. The STATUS is
either 0x12343412 for the closed parts and 0x56787856 for the open or field return parts.
Report1, Command, Host to Device:
1
Valid values for the READ_REGISTER COMMAND, ADDRESS, FORMAT, DATA_COUNT
ID 16-byte SDP command
Report3, Response, Device to Host:
3
Four bytes indicating the security configuration
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
323

<!-- page 324 -->

ID 4 bytes status
Report4, Response, Device to Host: first response report
4
Register value
ID 4 bytes of data containing the register value. If the number of bytes requested is less
than 4, the remaining bytes must be ignored by the host.
Multiple reports of the report id 4 are sent until the entire requested data is sent.
Report4, Response, Device to Host: last response report
4
Register value
ID 64 bytes of data containing the register value. If the number of bytes requested is less
than 64, the remaining bytes must be ignored by the host.
8.9.3.1.2
WRITE_REGISTER
The transaction for the WRITE_REGISTER command consists of these reports: Report1
for the command, Report3 for the security configuration and Report4 for the write status.
The host sends Report1 with the WRITE_REGISTER command. The register to write is
specified in the ADDRESS field of the SDP command of Report1, with the FORMAT
field set to the data type (number of bits to write, either 8, 16, or 32) and the value to
write in the DATA field of the SDP command. The device writes the DATA to the
register address and returns the WRITE_COMPLETE code using Report4 and the
security configuration using Report3 to complete the transaction.
Report1, Command, Host to Device:
1
Valid values for WRITE_REGISTER COMMAND, ADDRESS, FORMAT, DATA_COUNT and DATA
ID 16-byte SDP command
Report3, Response, Device to Host:
3
4 bytes indicating the security configuration
ID 4 bytes status
Report4, Response, Device to Host:
Serial Downloader
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
324
NXP Semiconductors

<!-- page 325 -->

4
WRITE_COMPLETE (0x128A8A12) status
ID 64 bytes data with the first 4 bytes to indicate that the write is completed with code
0x128A8A12. On failure, the device reports the HAB error status.
8.9.3.1.3
WRITE_FILE
The transaction for the WRITE_FILE command consists of these reports: Report1 for the
command phase, Report2 for the data phase, Report3 for the HAB mode, and Report4 to
indicate that the data are received in full.
The size of each Report2 is limited to 1024 bytes (limitation of the USB HID protocol).
Hence, multiple Report2 packets are sent by the host in the data phase until the entire
data is transferred to the device. When the entire data (DATA_COUNT bytes) is
received, the device sends Report3 with the HAB mode and Report4 with 0x88888888,
indicating that the file download completed.
Report1, Host to Device:
1
Valid values for WRITE_FILE COMMAND, ADDRESS, DATA_COUNT
ID 16-byte SDP command
========================Optional Begin=================
Host sends the ERROR_STATUS command to query if the HAB rejected the address
======================== Optional End==================
Report2, Host to Device:
2
File data
ID Max 1024 bytes data per report
Report2, Host to Device:
2
File data
ID Max 1024 bytes data per report
Report3, Device to Host:
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
325

<!-- page 326 -->

3
4 bytes indicating security configuration
ID 4 bytes status
Report4, Response, Device to Host:
4
COMPLETE (0x88888888) status
ID 64 bytes data with the first four bytes to indicate that the file download completed
with code 0x88888888. On failure, the device reports the HAB error status.
8.9.3.1.4
ERROR_STATUS
The transaction for the SDP command ERROR_STATUS consists of three reports.
Report1 is used by the host to send the command; the device sends global error status in
four bytes of Report4 after returning the security configuration in Report3. When the
device receives the ERROR_STATUS command, it returns the global error status that is
updated for each command. This command is useful to find out whether the last
command resulted in a device error or succeeded.
Report1, Command, Host to Device:
1
ERROR_STATUS COMMAND
ID 16-byte SDP Command
Report3, Response, Device to Host:
3
Four bytes indicating the security configuration
ID 4 bytes status
Report4, Response, Device to Host:
4
Four bytes Error status
ID first 4 bytes status in 64 bytes Report4
Serial Downloader
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
326
NXP Semiconductors

<!-- page 327 -->

8.9.3.1.5
DCD_WRITE
The SDP command DCD_WRITE is used by the host to send multiple register writes in
one shot. This command is provided to speed up the process of programming the register
writes (such as to configure an external RAM device).
The command goes with Report1 from the host with COMMAND TYPE set to
DCD_WRITE, ADDRESS which is used as a temporary location of the DCD data, and
DATA_COUNT to the number of bytes sent in the data out phase. In the data phase, the
host sends the data for a number of registers using Report2. The device completes the
transaction with Report3 indicating the security configuration and Report4 with the
WRITE_COMPLETE code 0x12828212.
Report1, Command, Host to Device:
1
DCD_WRITE COMMAND, ADDRESS, DATA_COUNT
ID 16-byte SDP Command
Report2, Data, Host to Device:
2
DCD binary data
ID Max 1024 bytes per report
Report3, Response, Device to Host:
3
Four bytes indicating the security configuration
ID 4 bytes status
Report4, Response, Device to Host:
4
WRITE_COMPLETE (0x128A8A12) status
ID 64 bytes report with the first four bytes to indicate that the write completed with the
code 0x128A8A12. On failure, the device reports the HAB error status.
See Device Configuration Data (DCD) for the DCD format description.
8.9.3.1.6
SKIP_DCD_HEADER
The SDP command SKIP_DCD_HEADER is used by the host to inform the device to
skip the DCD configuration within the download image.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
327

<!-- page 328 -->

If the download image must be run on the DDR, the DCD configuration data must be
built into the image. In case the host issued DCD_WRITE to push the DCD configuration
data to the device for the DDR initialization, the image with the DCD information causes
the ROM to initialize the DDR twice, and may cause the initialization processing to hang.
The SKIP_DCD_HEADER command informs the device to skip the DCD configuration
within the download image and avoid this issue.
This command is typically sent after JUMP_ADDRESS. This command is sent by the
host in the command-phase of the transaction using Report1, there is no data phase for
this command. The device completes the transaction with Report3 indicating the security
configuration and Report4 with the OK_ACK code 0x900DD009.
Report1, Command, Host to Device:
1
SKIP_DCD_HEADER
ID 16-byte SDP Command
Report3, Response, Device to Host:
3
Four bytes indicating the security configuration
ID 4 bytes status
Report4, Response, Device to Host:
4
OK_ACK (0x900DD009)
8.9.3.1.7
JUMP_ADDRESS
The SDP command JUMP_ADDRESS is the last command that the host can send to the
device. After this command, the device jumps to the address specified in the ADDRESS
field of the SDP command and starts to execute.
This command usually follows after the WRITE_FILE command. The command is sent
by the host in the command-phase of the transaction using Report1. There is no data
phase for this command, but the device sends the status Report3 to complete the
transaction. If the authentication fails, it also sends Report4 with the HAB error status.
Report1, Command, Host to Device:
1
JUMP_ADDRESS COMMAND, ADDRESS
Serial Downloader
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
328
NXP Semiconductors

<!-- page 329 -->

ID 16-byte SDP Command
Report3, Response, Device to Host:
3
Four bytes indicating the security configuration
ID 4 bytes status
This report is sent by the device only in case of an error jumping to the given address, or
if the device reports error in Report4, Response, Device to Host:
4
Four bytes HAB error status
ID 4 bytes status, 64 bytes report length
8.10
Recovery devices
The chip supports recovery devices. If the primary boot device fails, the boot ROM tries
to boot from the recovery device using one of the ECSPI ports.
To enable the recovery device, the BOOT_CFG4[6] fuse must be set. Additionally, the
serial EEPROM fuses must be set as described in Serial ROM through SPI.
8.11
USB low-power boot
The ROM supports the USB low-power boot. This feature enables a device with a dead
or weak battery to power up and boot if the device is connected to a USB upstream port,
no matter if the upstream port is a USB charger or a USB host/hub.
If a USB dedicated charger or a host/hub charger are connected, as soon as the device is
connected to the upstream port, a stable current (max.1.5 A) can be supplied by the
charger. If a USB host/hub is connected, a maximal current of 100 mA is supplied to the
device and the device is able to power up to boot the image with less than 100 mA.
If the LPB_BOOT fuses are blown, the chip checks if there is a low-power condition via
the UART3_CTS (as GPIO1_26) pad. If there is a low-power boot condition, the USB
charger detection is activated. If there is no USB charger, the ROM initializes the USB as
a device and applies division factors on the Arm, DDR, AXI, and AHB root clocks based
on the LPB_BOOT fuses value (see the table below). The polarity of the low-power boot
condition on the UART3_CTS (as GPIO1_26) pad is set by the BT _LPB_POLARITY
fuse (see the following figure).
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
329

<!-- page 330 -->

Table 8-43. USB low-power bus boot frequencies
LPB_BOOT
Boot Frequencies=0
Boot Frequencies=1
0
MMDC_CLK_ROOT = 396 MHz
FABRIC_CLK_ROOT = 198 MHz AHB_CLK_ROOT
= 132 MHz
MMDC_CLK_ROOT = 307 MHz
FABRIC_CLK_ROOT = 153 MHz AHB_CLK_ROOT
= 102 MHz
1
MMDC_CLK_ROOT = 396 MHz
FABRIC_CLK_ROOT = 198 MHz AHB_CLK_ROOT
= 132 MHz
MMDC_CLK_ROOT = 307 MHz
FABRIC_CLK_ROOT = 153 MHz AHB_CLK_ROOT
= 102 MHz
10
MMDC_CLK_ROOT = 198 MHz
FABRIC_CLK_ROOT = 99 MHz AHB_CLK_ROOT =
66 MHz
MMDC_CLK_ROOT = 153 MHz
FABRIC_CLK_ROOT = 76 MHz AHB_CLK_ROOT =
51 MHz
11
Reserved
Reserved
Table 8-44. USB low-power CPU boot frequencies
LPB_BOOT
Boot Frequencies=0
Boot Frequencies=1
0
ARM_CLK_ROOT = 396 MHz
ARM_CLK_ROOT = 198 MHz
1
ARM_CLK_ROOT = 396 MHz
ARM_CLK_ROOT = 198 MHz
10
ARM_CLK_ROOT = 198 MHz
ARM_CLK_ROOT = 99 MHz
11
Reserved
Reserved
USB low-power boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
330
NXP Semiconductors

<!-- page 331 -->

Start
LPB_BOOT fuses equal 
00?
End
UART3_CTS
 
pad equals 
LPB_POLARITY fuse?
Start USB charger detection
USB Charger 
Connected?
Initialize USB OTG as device
Setup post dividers and root 
clock selectors according to 
Boot Freqiencies and 
LPB_BOOT fuses
Enable PLLs
Setup post dividers and root 
clock selectors according to 
Boot Freqiencies fuse
No
Yes
No
Yes
No
Yes
Figure 8-26. USB low-power boot flow
8.12
SD/MMC manufacture mode
When the internal boot and recover boot (if enabled) failed, the
SDMMC_MFG_DISABLE fuse bit isn't set and the EEPROM recovery fuse bit is set,
the boot goes to the SD/MMC manufacture mode before the serial download mode. In the
manufacture mode, one bit bus width is used despite of the fuse setting.
In the manufacture mode, the SD or MMC card will be scanned on the uSDHC1. If a card
is detected and a valid boot image is found in the card, the boot image is loaded and
executed. Pad of SD1_CD is used to detect whether a card is inserted or not.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
331

<!-- page 332 -->

By default, the SD/MMC manufacture mode is enabled. Blow the fuse of the
DISABLE_SDMMC_MFG to disable it.
NOTE
A secondary boot is not supported in the SD/MMC manufacture
mode.
BOOT_MODE==0 and
BT_FUSE_SEL==0
BOOT_MODE==1
BOOT_MODE==2
USB download mode
SDMMC MFG 
mode disabled?
SDMMC MFG mode boot
success?
internal primary boot
success?
EEPROM recovery
 enabled?
EEPROM recovery
success?
application entry
Y
N
N
Y
N
N
Y
Y
Y
N
Figure 8-27. SD/MMC manufacture boot flow
8.13
High-Assurance Boot (HAB)
The High Assurance Boot (HAB) component of the ROM protects against the potential
threat of attackers modifying the areas of code or data in the programmable memory to
make it behave in an incorrect manner. The HAB also prevents the attempts to gain
access to features which must not be available.
The integration of the HAB feature with the ROM code ensures that the chip does not
enter an operational state if the existing hardware security blocks detected a condition
that may be a security threat or if the areas of memory deemed to be important were
modified. The HAB uses the RSA digital signatures to enforce these policies.
High-Assurance Boot (HAB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
332
NXP Semiconductors

<!-- page 333 -->

SNVS
DCP
Core Processor
HAB
ROM
Flash
RAM
Figure 8-28. Secure boot components
The figure above illustrates the components used during a secure boot using HAB. The
HAB interfaces with the SNVS to make sure that the system security state is as expected.
The HAB includes a software implementation of SHA-256 for cases where a hardware
accelerator can't be used. The RSA key sizes supported are 1024, 2048, and 3072 bits.
The RSA signature verification operations are performed by a software implementation
contained in the HAB library. The main features supported by the HAB are:
• X.509 public key certificate support
• CMS signature format support
NOTE
NXP provides the reference Code Signing Tool (CST) for key
generation, certificate generation, and code signing for use with
the HAB library. The CST can be found by searching for
"IMX_CST_TOOL" at http://www.nxp.com.
NOTE
For further details on using the secure boot feature using HAB,
contact your local NXP representative.
8.13.1
HAB API vector table addresses
For devices that perform a secure boot, the HAB library may be called by the boot stages
that execute after the ROM code.
The RVT table contains the pointers to the HAB API functions and is located at
0x00000100.
Chapter 8 System Boot
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
333

<!-- page 334 -->

NOTE
For additional information on the secure boot including the
HAB API, contact your local NXP representative.
High-Assurance Boot (HAB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
334
NXP Semiconductors

