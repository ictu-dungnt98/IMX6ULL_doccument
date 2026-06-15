# Chapter 51: System Reset Controller (SRC)

> Nguồn: `IMX6ULLRM.pdf` — trang 3497–3528

<!-- page 3497 -->

Chapter 51
System Reset Controller (SRC)
51.1
SRC Overview
The System Reset Controller (SRC) controls the reset and boot operation of the SoC.
It is responsible for the generation of all reset signals and boot decoding.
The reset controller determines the source and the type of reset, such as POR, WARM,
COLD, and performs the necessary reset qualification and stretching sequences. Based on
the type of reset, the reset logic generates the reset sequence for the entire IC. Whenever
the chip is powered on, the reset is issued through SRC_ONOFF signal and the entire
chip is reset.
51.1.1
Features
The SRC includes the following features.
• Receives and handles the resets from all the reset sources
• Resets the appropriate domains based upon the resets sources and the nature of the
reset
• Latches the SRC_BOOT_MODE pins and common configuration signals from the
internal fuse
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3497

<!-- page 3498 -->

51.2
External Signals
The following table describes the external signals of SRC.
Table 51-1. SRC External Signals
Signal
Description
Pad
Mode
Direction
SRC_BT_CFG0
Boot configuration signals
LCD_DATA00
ALT6
I
SRC_BT_CFG1
LCD_DATA01
ALT6
I
SRC_BT_CFG2
LCD_DATA02
ALT6
I
SRC_BT_CFG3
LCD_DATA03
ALT6
I
SRC_BT_CFG4
LCD_DATA04
ALT6
I
SRC_BT_CFG5
LCD_DATA05
ALT6
I
SRC_BT_CFG6
LCD_DATA06
ALT6
I
SRC_BT_CFG7
LCD_DATA07
ALT6
I
SRC_BT_CFG8
LCD_DATA08
ALT6
I
SRC_BT_CFG9
LCD_DATA09
ALT6
I
SRC_BT_CFG10
LCD_DATA10
ALT6
I
SRC_BT_CFG11
LCD_DATA11
ALT6
I
SRC_BT_CFG12
LCD_DATA12
ALT6
I
SRC_BT_CFG13
LCD_DATA13
ALT6
I
SRC_BT_CFG14
LCD_DATA14
ALT6
I
SRC_BT_CFG15
LCD_DATA15
ALT6
I
SRC_BT_CFG24
LCD_DATA16
ALT6
I
SRC_BT_CFG25
LCD_DATA17
ALT6
I
SRC_BT_CFG26
LCD_DATA18
ALT6
I
SRC_BT_CFG27
LCD_DATA19
ALT6
I
SRC_BT_CFG28
LCD_DATA20
ALT6
I
SRC_BT_CFG29
LCD_DATA21
ALT6
I
SRC_BT_CFG30
LCD_DATA22
ALT6
I
SRC_BT_CFG31
LCD_DATA23
ALT6
I
SRC_POR_B
Power on reset signal
POR_B
No Muxing
(ALT0)
I
SRC_ONOFF
ON/OFF signal
ONOFF
No Muxing
(ALT0)
I
SRC_BOOT_MODE0
Boot mode signals
BOOT_MODE0
No Muxing
I
SRC_BOOT_MODE1
BOOT_MODE1
No Muxing
I
51.3
Clocks
The table found here describes the clock sources for SRC.
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3498
NXP Semiconductors

<!-- page 3499 -->

Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 51-2. SRC Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
51.4
Top-level resets, power-up sequence and external
supply integration
Information found here defines chip resets, power-up sequence, and external supply
integration.
51.4.1
Reset and Power-up Flow
The chip presumes the following reset and power-up flow:
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3499

<!-- page 3500 -->

FSM
wake-up
alarm
irq
SNVS
ONOFF
(button)
PMU
POR
ipp_reset_b
SRC
ipp_user_reset_b
SoC resets
POR_B
PMIC_ON_REQ
enable
External
Regulator
(DCDC)
VDD_SNVS_IN
PMIC_ON_REQ acts as an active high-signal
1 or high Z  = ON
0 = OFF
analog
SRC_POR_B
TEST_MODE
VDD_HIGH_IN
Figure 51-1. Chip reset scheme under PMU control
Top-level resets, power-up sequence and external supply integration
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3500
NXP Semiconductors

<!-- page 3501 -->

PMU
POR
analog
ipp_reset_b
SRC
ipp_user_reset_b
SoC resets
POR_B
PMIC_ON_REQ
External
PMIC
PMIC_ON_REQ acts as power-on alarm:
0->1 = power-on by alarm
PMIC_STBY_REQ enters and exits PMIC standby 
0->1 = enter standby
1-> 0 = wake-up from standby
PMIC_STBY_REQ
FSM
wake-up
alarm
SNVS
irq
CCM
SRC_POR_B
VDD_SNVS_IN
(button)
ONOFF
(No Connect)
TEST_MODE
Figure 51-2. Chip reset scheme under external PMIC control
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3501

<!-- page 3502 -->

Interrupt service
Pre Off
SW
Interrupt
Debounce
Tamper
SW
controllable
OFF
SRTC
OFF
SNVS
Supply removed
SNVS
Supply present
SNVS
Power ON
Reset
Chip
Power present
Chip
Power ON
Reset
ON
Debounce
Timer wake-up
5s button
validation
ONOFF
Button
Figure 51-3. Chip on/off state flow diagram
Top-level resets, power-up sequence and external supply integration
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3502
NXP Semiconductors

<!-- page 3503 -->

51.4.2
Finite-State Machine (FSM)
ON
generate irq
emgergency off
log emgergency off
OFF
button pressed < 5s.
alarm negative edge
button pressed (any duration)
alarm positive edge
button pressed > 5s.
Figure 51-4. FSM
51.4.3
Power mode transitions
Table 51-3. Power mode transitions
Power mode
Configuration with external PMIC
Configuration with internal PMIC
ON, first time
1. Either coin cell or SoC power supply is
connected to SNVS.
2. When button is pressed, PMIC powers
on.
1. Either coin cell or SoC power supply is
connected to SNVS.
2. When button is pressed, 'state' goes ON,
PMIC_ON_REQ goes '1'.
3. External regulator is enabled.
Normal ON to OFF,
by button
1. Button is pressed for a short duration on
the external PMIC.
2. Interrupt request (irq) is sent to SoC from
external PMIC.
1. SoC button is pressed for a short duration.
2. Interrupt request (irq) is sent to SoC from FSM.
3. Alarm timer is set up by software routine and
started.
Table continues on the next page...
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3503

<!-- page 3504 -->

Table 51-3. Power mode transitions (continued)
Power mode
Configuration with external PMIC
Configuration with internal PMIC
3. SoC is programming PMIC for power off
when standby is asserted.
4. In CCM STOP mode, Standby is
asserted, PMIC gates SoC supplies.
4. Upon alarm_in assertion to '1',
PMIC_ON_REQ goes '0'.
5. External regulator goes OFF.
Emergency ON to
OFF, by button
1. Button is pressed for an extended time on
the external PMIC.
2. PMIC is powering off.
1. Button is pressed for longer than 5 seconds on
the SoC.
2. FSM validates button pressed for 5 seconds.
3. Emergency power off is logged,
PMIC_ON_REQ goes '0', alarm_mask goes '1'.
4. External regulator goes OFF.
OFF to ON, by
button
1. Button is pressed on the external PMIC.
2. PMIC powers ON.
1. Button is pressed on the SoC.
2. PMIC_ON_REQ goes '1', alarm_mask goes '0'.
3. External regulator powers ON.
OFF to ON, by timer
alarm
1. Timer alarm in SNVS is programmed by
software before SoC goes OFF.
2. SoC enters OFF mode.
3. Upon timer limit, wake up alarm goes '0'.
PMIC_ON_REQ goes '1'.
4. PMIC receives assertion of
PMIC_ON_REQ and wakes up.
1. Timer alarm in SNVS is programmed by
software before SoC goes OFF.
2. SoC enters OFF mode.
3. Upon timer limit, wake up alarm goes '0'.
PMIC_ON_REQ goes '1'.
4. External regulator is enabled by
PMIC_ON_REQ = 1.
51.5
Power-On Reset and power sequencing
This module generates an internal POR_B signal that is logically AND'ed with any
externally applied SRC_POR_B signal. The internal POR_B signal will be held low until
all of the following conditions are met:
• 4ms after the external power supply VDDHIGH_IN is valid
• 1ms after the VDD_SOC_CAP supply is valid
The 4ms and 1ms delays are derived from counting the 32 kHz RTC clock cycles; the
accuracy depends on the accuracy of the RTC. When the RTC crystal is either absent or
in the process of powering up, an internal ring oscillator will be the source of RTC, which
is not as accurate as the crystal.
51.5.1
External POR using SRC_POR_B
If the external SRC_POR_B signal is used to control the processor POR, SRC_POR_B
must remain low (asserted) until the VDD_ARM_CAP and VDD_SOC_CAP supplies
are stable.
Power-On Reset and power sequencing
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3504
NXP Semiconductors

<!-- page 3505 -->

51.5.2
Internal POR
If the external SRC_POR_B signal is not used (always held high or left unconnected), the
processor defaults to the internal POR function (PMU controls generation of the POR
based on the power supplies).
If the internal POR function is used, the following power supply requirements must be
met:
• VDD_ARM_IN and VDD_SOC_IN may be supplied from the same source, or
• VDD_SOC_IN can be supplied before VDD_ARM_IN with a maximum delay of 1
ms.
51.6
Functional Description
51.6.1
Reset Control
This section details the reset control of this device.
51.6.1.1
Reset inputs and outputs
The reset control logic receives reset requests from all potential reset sources. All the
immediate sources of reset are directly passed to the reset stretching block, whereas the
resets requiring qualification are passed on to the reset qualification logic before they are
sent to the reset stretching block.
All reset inputs and outputs are described in the following figure:
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3505

<!-- page 3506 -->

COLD
CSU Reset (csu_reset_b)
WARM
WDOGn_RST_B_DEB (wdog_rst_b)
POR (no SJC)
SJC_TRST_B (jtag_rst_b)
WARM
SJC S/W Reset (jtag_sw_rst) 
WARM
SRC_ONOFF (ipp_user_reset_b)
System module reset (system_early_rst_b)
Functional module reset (system_rst_b)
ARM Reset (arm_rst_b)
MMDC Reset (mmdc_rst_b)
ARM POR (arm_por_rst_b)
SJC Reset (sjc_por_rst_b)
SRTC Reset (srtc_rst_b)
SRC
POR
SRC_POR_B (ipp_reset_b)
EIM Reset (eim_rst_b)
WARM
Tempsensor Reset (tempsense_rst_b)
Figure 51-5. SRC inputs and outputs
The reset types and modules they affect are shown in Table 51-4. As there is no chip
POR, the POR_B is used to reset the entire chip including test logic and JTAG modules.
NOTE
All resets are expected to be active low except jtag_sw_rst.
Table 51-4. SRC reset functionality
SoC Modules
POR
COLD
WARM
System modules (PLLs, fuses, etc)
yes
yes
yes
Functional modules
yes
yes
yes
Arm
yes
yes
yes
Arm SoC
yes
yes
yes
MMDC
yes
yes
yes
Arm POR
yes
no
no
Arm debug
yes
no
no
SJC
yes
no
no
SRTC
yes
no
no
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3506
NXP Semiconductors

<!-- page 3507 -->

The reset priorities are POR (strongest), COLD and WARM (weakest). If a stronger reset
is asserted during the sequence of a weaker reset, then the weaker sequence will be
overridden, and the stronger reset sequence will commence. There is no priority within a
reset type (POR, etc). If a reset is asserted during the reset sequence of the same type, the
reset sequence will be interrupted and restarted.
The following lists the functionality of each of these reset outputs:
• system_early_rst_b - Resets the system modules that need to start first as CCM,
OCOTP_CTRL, FUSEBOX, MMDC, etc.
• system_rst_b - Resets functional modules
• arm_rst_b - Resets Arm module (on regular system reset)
• mmdc_rst_b - Resets MMDC
• arm_por_rst_b - Resets Arm POR input
• arm_soc_rst_b - Reset for Arm SOC
• arm_dbg_rst_b - Reset debug logic of Arm
• test_logic_rst_b - Reset test logic (IOMUXC, DAP)
• sjc_por_rst_b - Reset to SJC
• srtc_rst_b - Resets SRTC
NOTE
It is assumed that each reset source will deassert after its
assertion, either due to reset generated to the system from SRC,
or by negation of the reset source (if it came from an external
source to the chip). In the latter case, the reset source is
assumed to be held for at least 2 XTALI clocks so it can be
sampled by SRC.
51.6.1.2
Reset Handling
51.6.1.2.1
Reset Qualification
The reset qualification logic qualifies the reset source before sending it out to the chip as
a valid reset. WARM resets are in this category. All remaining reset sources are
immediate resets and are acknowledged by the reset circuitry the moment they are
asserted.
WARM resets are not immediate resets. WARM resets do reset the CCM, the source of
MMDC clock. So, if a WARM reset were to immediately reset the CCM, then the
MMDC clock would be shut off and this may cause the MMDC data to be lost. During
normal mode of operation of the chip, the protocol that is followed before shutting off the
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3507

<!-- page 3508 -->

MMDC clock is that an mmdc_dvfs_req signal is sent to MMDC and only after the
MMDC sends an acknowledge signal, mmdc_dvfs_ack, is the clock to the MMDC gated
off.
However, the implication here is that a valid WARM reset source condition will not be
able to cause a chip reset until the MMDC sends the acknowledge signal
(mmdc_dvfs_ack). For example, a JTAG reset event has occurred but the JTAG reset will
not be serviced until the mmdc_dvfs_ack signal is received. So, essentially all WARM
reset sources depend on the MMDC providing the mmdc_dvfs_ack acknowledge signal
before the reset is performed. When the MMDC is not used, mmdc_dvfs_ack is defaulted
high.
The occurrence of WARM reset results in the assertion of warm_reset signal before the
system resets are asserted to indicate to the MMDC that the reset occurred is a WARM
reset.
A reset source is updated in the Reset Status Register (SRC_SRSR) when it becomes
valid, provided it is asserted for the minimum amount of time after asserting. So, all
immediate resets are immediately updated in the Status Register (SRC_SRSR). WARM
resets would be updated when the mmdc_dvfs_ack signal is received from the MMDC.
Once the reset is qualified, depending on the source of the reset, internal resets are
asserted appropriately.
51.6.1.2.2
Reset Sequence and De-Assertion
The SRC_ONOFF will assert immediately after any reset source is recognized (except for
the case of WARM reset when MMDC needs to answer mmdc_dvfs_ack first). After all
of the reset sources are released, the SRC will start the following set of events depending
on the type of reset that occurred.
51.6.1.2.3
POR (SRC_POR_B)
SRC_POR_B is an external reset signal. When the chip is powered up, the reset signal is
passed through the POR_B pin indicating power-up sequence. The SRC resets the entire
chip including the JTAG (SJC) module. All SRC registers will be reset during the POR
sequence.
As soon as SRC_POR_B occurs, all resets are asserted and the entire chip is reset by
SRC. The SRC_POR_B is stretched for 2 XTALI cycles and the stretching sequence
takes place after 2 XTALI clocks of POR_B pin deassertion.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3508
NXP Semiconductors

<!-- page 3509 -->

The sjc_por_rst_b and srtc_rst_b signals are deasserted together with SRC_POR_B
signal. Those outputs are also deasserted after the stretching of SRC_POR_B has
deasserted.
Once the above resets deassert, system_early_rst_b reset is deasserted after 2 XTALI
clocks. The system_early_rst_b is used for the CCM and PLL-IPs to start generating PLL
clock ouputs and the system root clocks.
When the system root clocks are ready, the CCM will assert system_clk_ready signal.
This signal is generated during the start sequence in the CCM and it involves the
preparation of the PLLs to generate clock roots for functional operation.
SRC then enables OCOTP_CTRL and fusebox clocks, so that fuses can be loaded to
OCOTP_CTRL.
• SRC will prepare the boot information and then de assert mmdc_rst_b.
• SRC will wait 8 ipg clock cycles, and then SRC will enable MMDC clocks.
• SRC will wait 8 XTALI clocks to allow MMDC to generate fixed external clock to
external memory SDRAM.
• SRC will enable GPU clocks.
• After 8 ipg cycles, SRC will disable GPU clocks.
• After 8 ipg cycles, resets to all modules will be de-asserted (system_rst_b,
gpu_rst_b).
• After 8 ipg cycles, system clocks will be enabled (en_system_clk).
51.6.1.2.4
COLD RESET
The sequence is similar to SRC_POR_B except the memory repair operation is not
performed.
Once the reset source deasserts, system_early_rst_b reset is deasserted after at least 2
XTALI clocks. The system_early_rst_b is used for the CCM and PLL-IPs to start
generating PLL clock outputs and the system root clocks.
Once the system root clocks are ready, the CCM will assert system_clk_ready signal.
This signal is generated during the start sequence in the CCM and it involves the
preparation of the PLLs to generate clock roots for functional operation. See CCM for
more information.
Once system_clk_ready arrives at the SRC, it will enable OCOTP_CTRL and fusebox
clocks, so that fuses can be loaded to OCOTP_CTRL. OCOTP_CTRL will notify with
iim_ready_flag once the fusebox loading finishes.
• SRC will prepare the boot information and then deassert mmdc_rst_b.
• SRC will wait 8 ipg clock cycles, and then SRC will enable MMDC clocks.
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3509

<!-- page 3510 -->

• SRC will wait 8 XTALI clocks to allow MMDC to generate fixed external clock to
external memory SDRAM.
• SRC will enable GPU clocks so that reset will penetrate this module.
• After 8 ipg cycles, SRC will disable GPU clocks.
• After 8 ipg cycles resets to all modules will be deasserted (system_rst_b, gpu_rst_b).
• After 8 ipg cycles, system clocks will be enabled (en_system_clk).
51.6.1.2.5
WARM RESET
WARM reset will be enabled only if SRC_SCR[warm_reset_enable] bit is programmed.
Otherwise, all WARM reset sources will generate a COLD reset. This bit will be reset
only by a POR.
A WARM reset is similar to a COLD reset except that before the reset is sent, a signal to
MMDC is asserted mmdc_dvfs_req (generates DVFS assertion to MMDC) to request to
prepare MMDC to a WARM reset, finishing the transactions placing MMDC in self-
refresh. Another signal will be asserted to MMDC (warm_reset) that will wrap the
WARM reset sequence and will notify MMDC that a WARM reset is in process.
One of the sources of the WARM reset is SRC_ONOFF. If this is the case, it is qualified
for 4 XTALI edges. The WARM reset is initiated immediately after 4 XTALI edges. The
system does not come out of reset until the SRC_ONOFF is released.
In case the handshake mechanism with MMDC is stuck, meaning that no
mmdc_dvfs_ack is received, COLD reset will be generated after a number of XTALI
clocks. The number of XTALI clocks is defined in register the
SRC_SCR[warm_rst_bypass_count] bitfield (default of this bitfield is 16 XTALI counts.)
The following is a basic description of the WARM reset sequence:
1. ARM sets SRC_SCR[warm_reset_enable] bit to enable the WARM Reset
functionality. If this bit is not set, all WARM reset sources will result in COLD reset.
2. Assertion of one of the WARM reset sources.
3. The reset source is qualified in the SRC.
4. If mmdc_dvfs_ack signal is low, then SRC triggers the MMDC to switch to self-
refresh mode using mmdc_dvfs_req signal. This is done through the CCM to
combine with the DVFS sent from the CCM in case of frequency change of MMDC.
5. Wait for mmdc_dvfs_ack signal from the MMDC. If no ack is received during
warm_rst_bypass_count number of XTALI clocks, COLD reset will be generated.
6. Assert warm_reset signal to MMDC.
7. SRC asserts system resets
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3510
NXP Semiconductors

<!-- page 3511 -->

The deassertion sequence is exactly the same as in the Cold Reset except waiting for 8
XTALIs for MMDC to generate fixed external clock to external memory MMDC. This
stage is not needed in WARM reset since MMDC is held in self-refresh in WARM reset
and there is no need to reconfigure it when exiting WARM reset.
WARM BOOT
Software can save any needed information in the memory before initiating a WARM
reset. In this case, software will set SRC_SRSR[warm_boot] bit before initiating WARM
reset. After the system returns to run mode, the warm_boot bit will still be set, indicating
the software that data was saved in memory and can be reused.
NOTE
mmdc_dvfs_req and acknowledge during WARM reset can be
masked in the CCM by configuration of register CCDR[17:16].
51.6.2
Parallel Reset Requests
SRC will follow the following rules in the case of parallel reset requests:
1. The order of strength of resets is POR - strongest, cold - medium, warm - weakest.
2. If a stronger reset is asserted during weaker reset sequence, then the stronger reset
will take over and the stronger reset process will commence. The following cases fall
into this category:
• POR reset request in the middle of cold or warm reset process - the cold or warm
reset process will be stopped and the POR sequence will start.
• COLD reset request in the middle of warm reset process - the warm reset process
will be stopped and the cold sequence will start.
3. If a weaker reset is asserted during stronger reset sequence, then the stronger reset
sequence will continue without interference. If at the end of the stronger reset process
the weaker request is still asserted then the weaker sequence will commence. The
following cases fall into this category:
• COLD or WARM reset requests in the middle of POR reset process - the POR
process will continue without interference.
• WARM reset request in the middle of COLD reset process - the COLD process
will continue without interference.
4. If a similar reset request is asserted during the process of reset handling, then the
process of reset handling will start over (with the same process). The following cases
fall into this category:
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3511

<!-- page 3512 -->

• POR reset request in the middle of POR reset process - the POR process will
start over.
• COLD reset request in the middle of COLD reset process - the COLD process
will start over.
There is one exception to this category: WARM reset request in the middle of WARM
reset process. In this case, the new WARM reset process cannot restart because MMDC
is reset and there can't be a handshake with MMDC if it is reset. In this case the first
WARM reset will continue, and only if the second WARM reset is still asserted after the
first one has finished, the WARM sequence will start again.
51.6.3
Boot Mode Control
51.6.3.1
BOOT_MODE Pin Latching
The exact boot sequence is controlled by the values of the BOOT_MODE pins on this
device.
The value of the BOOT_MODE pins will be latched after the OCOTP_CTRL asserts the
fuse read completion flag. After latching, the values of the BOOT_MODE pins are used
to determine the booting options of the core as described in the SRC_SBMRx registers.
The boot mode general purpose bits can be provided to the SRC from either e-fuses or
GPIO signals. The gpio_bt_sel e-fuse defines the source to be used to derive the boot
information. When gpio_bt_sel is set, e-fuses are used. When cleared, GPIO signals are
used.
The boot information is provided in SRC_SBMR1 register. The figure below shows the
selection of boot mode information.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3512
NXP Semiconductors

<!-- page 3513 -->

BOOT_MODE1
BOOT_MODE0
BOOT_MODE0
BOOT_MODE1
GPIO_BT_SEL_FUSE
BOOT_MODE0
BOOT_MODE1
BOOT_CFG[23:16]
BOOT_CFG[15:8]
BOOT_CFG[7:0]
BOOT_CFG[23:16]
BOOT_CFG[15:8]
BOOT_CFG[7:0]
chip
fuses
e-fuse signals
0
1
SRC_SBMR1
Register
BOOT_CFG[31:24]
BOOT_CFG[31:24]
Figure 51-6. Boot mode information
51.7
SRC Memory Map/Register Definition
SRC memory map
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20D_8000
SRC Control Register (SRC_SCR)
32
R/W
0000_0521h
51.7.1/3514
20D_8004
SRC Boot Mode Register 1 (SRC_SBMR1)
32
R
0000_0000h
51.7.2/3517
20D_8008
SRC Reset Status Register (SRC_SRSR)
32
R/W
0000_0001h
51.7.3/3517
20D_8014
SRC Interrupt Status Register (SRC_SISR)
32
R
0000_0000h
51.7.4/3520
20D_801C
SRC Boot Mode Register 2 (SRC_SBMR2)
32
R
0000_0000h
51.7.5/3522
20D_8020
SRC General Purpose Register 1 (SRC_GPR1)
32
R/W
0000_0000h
51.7.6/3523
20D_8024
SRC General Purpose Register 2 (SRC_GPR2)
32
R/W
0000_0000h
51.7.7/3524
20D_8028
SRC General Purpose Register 3 (SRC_GPR3)
32
R/W
0000_0000h
51.7.8/3524
20D_802C
SRC General Purpose Register 4 (SRC_GPR4)
32
R/W
0000_0000h
51.7.9/3525
Table continues on the next page...
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3513

<!-- page 3514 -->

SRC memory map (continued)
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20D_8030
SRC General Purpose Register 5 (SRC_GPR5)
32
R/W
0000_0000h
51.7.10/
3525
20D_8034
SRC General Purpose Register 6 (SRC_GPR6)
32
R/W
0000_0000h
51.7.11/
3526
20D_8038
SRC General Purpose Register 7 (SRC_GPR7)
32
R/W
0000_0000h
51.7.12/
3526
20D_803C
SRC General Purpose Register 8 (SRC_GPR8)
32
R/W
0000_0000h
51.7.13/
3527
20D_8040
SRC General Purpose Register 9 (SRC_GPR9)
32
R/W
0000_0000h
51.7.14/
3527
20D_8044
SRC General Purpose Register 10 (SRC_GPR10)
32
R/W
0000_0000h
51.7.15/
3528
51.7.1
SRC Control Register (SRC_SCR)
The Reset control register (SCR), contains bits that control operation of the reset
controller.
Address: 20D_8000h base + 0h offset = 20D_8000h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
mask_wdog3_rst
mix_rst_strch
dbg_rst_msk_pg
wdog3_rst_optn
0
cores_dbg_rst
0
core0_dbg_rst
0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
core0_rst
Reserved
eim_rst
mask_wdog_rst
warm_rst_
bypass_
count
Reserved
warm_reset_enable
W
Reset
0
0
0
0
0
1
0
1
0
0
1
0
0
0
0
1
SRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3514
NXP Semiconductors

<!-- page 3515 -->

SRC_SCR field descriptions
Field
Description
31–28
mask_wdog3_rst Mask wdog3_rst_b source. If these 4 bits are coded from A to 5 then, the wdog3_rst_b input to SRC will
be masked and the wdog3_rst_b will not create a reset to the chip.
NOTE: During the time the WDOG3 event is masked using SRC logic, it is likely that the WDOG3 Reset
Status Register (WRSR) bit 1 (which indicates a WDOG3 timeout event) will get asserted.
Software / OS developer must prepare for this case. Re-enabling the WDOG3 is possible, by un-
masking it in SRC, though it must be preceded by servicing the WDOG3. However, for the case
that the event has been asserted, the status bit (WRSR bit-1) will remain asserted, regardless of
servicing the WDOG3 module.
NOTE: Hardware reset is the only way to cause the de-assertion of that bit. Any other code than 0101
will be coded to 1010 i.e. wdog3_rst_b is not masked
0101
wdog3_rst_b is masked
1010
wdog3_rst_b is not masked
27–26
mix_rst_strch
SoC mix (Audio, ENET, uSDHC, EIM, QSPI, OCRAM, MMDC, etc) power up reset stretch mix reset width
= (mix_rst_strtch +1)* 88 ipg_clk cycles
00
mix reset width is 88 ipg_cycle cycles
01
mix reset width is 2 * 88 ipg_cycle cycles
10
mix reset width is 3 * 88 ipg_cycle cycles
11
mix reset width is 4 * 88 ipg_cycle cycles
25
dbg_rst_msk_pg
Do not assert debug resets after power gating event of core
0
do not mask core debug resets (debug resets will be asserted after power gating event)
1
mask core debug resets (debug resets won't be asserted after power gating event)
24
wdog3_rst_optn
Wdog3_rst_b option
0
Wdog3_rst_b asserts M4 reset (default)
1
Wdog3_rst_b asserts global reset
23–22
Reserved
This read-only field is reserved and always has the value 0.
21
cores_dbg_rst
Software reset for debug of arm platform only.
NOTE: This is a self clearing bit. Once it is set to 1, the reset process will begin, and once it finishes, this
bit will be self cleared.
0
do not assert arm platform debug reset
1
assert arm platform debug reset
20–18
Reserved
This read-only field is reserved and always has the value 0.
17
core0_dbg_rst
Software reset for core0 debug only.
NOTE: This is a self clearing bit. Once it is set to 1, the reset process will begin, and once it finishes, this
bit will be self cleared.
0
do not assert core0 debug reset
1
assert core0 debug reset
16–14
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3515

<!-- page 3516 -->

SRC_SCR field descriptions (continued)
Field
Description
13
core0_rst
Software reset for core0 only.
NOTE: This is a self clearing bit. Once it is set to 1, the reset process will begin, and once it finishes, this
bit will be self cleared.
0
do not assert core0 reset
1
assert core0 reset
12
-
This field is reserved.
Reserved
11
eim_rst
EIM reset is needed in order to reconfigure the eim chip select.
The software reset bit must de-asserted.
The eim chip select configuration should be updated.
The software bit must be re-asserted since this is not self-refresh.
10–7
mask_wdog_rst
Mask wdog_rst_b source. If these 4 bits are coded from A to 5 then, the wdog_rst_b input to SRC will be
masked and the wdog_rst_b will not create a reset to the chip.
NOTE: During the time the WDOG event is masked using SRC logic, it is likely that the WDOG Reset
Status Register (WRSR) bit 1 (which indicates a WDOG timeout event) will get asserted.
software / OS developer must prepare for this case. Re-enabling the WDOG is possible, by un-
masking it in SRC, though it must be preceded by servicing the WDOG. However, for the case
that the event has been asserted, the status bit (WRSR bit-1) will remain asserted, regardless of
servicing the WDOG module.
(Hardware reset is the only way to cause the de-assertion of that bit).
any other code will be coded to 1010 i.e. wdog_rst_b is not masked
0101
wdog_rst_b is masked
1010
wdog_rst_b is not masked (default)
6–5
warm_rst_
bypass_count
Defines the XTALI cycles to count before bypassing the MMDC acknowledge for WARM reset. If the
MMDC acknowledge will not be asserted before this counter has elapsed, then a COLD reset will be
initiated.
00
Counter not to be used - system will wait until MMDC acknowledge until it is asserted.
01
Wait 16 XTALI cycles before changing WARM reset to a COLD reset.
10
Wait 32 XTALI cycles before changing WARM reset to a COLD reset.
11
Wait 64 XTALI cycles before changing WARM reset to a COLD reset
4–1
-
This field is reserved.
Reserved
0
warm_reset_
enable
WARM reset enable bit. WARM reset will be enabled only if warm_reset_enable bit is set. Otherwise all
WARM reset sources will generate COLD reset.
0
WARM reset disabled
1
WARM reset enabled
SRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3516
NXP Semiconductors

<!-- page 3517 -->

51.7.2
SRC Boot Mode Register 1 (SRC_SBMR1)
The Boot Mode register (SBMR) contains bits that reflect the status of Boot Mode Pins
of the chip. The reset value is configuration dependent (depending on boot/fuses/IO
pads).
If SRC_GPR10[28] bit is set, this bit instructs the ROM code to use the SRC_GPR9
registe as if it is SBMR1. This allows software to override the fuse bits and boot from an
alternate boot source.
Address: 20D_8000h base + 4h offset = 20D_8004h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
BOOT_CFG4[7:0]
BOOT_CFG3[7:0]
BOOT_CFG2[7:0]
BOOT_CFG1[7:0]
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_SBMR1 field descriptions
Field
Description
31–24
BOOT_
CFG4[7:0]
Refer to fusemap.
23–16
BOOT_
CFG3[7:0]
Refer to fusemap.
15–8
BOOT_
CFG2[7:0]
Refer to fusemap.
BOOT_
CFG1[7:0]
Refer to fusemap.
51.7.3
SRC Reset Status Register (SRC_SRSR)
The SRSR is a write to one clear register which records the source of the reset events for
the chip. The SRC reset status register will capture all the reset sources that have
occurred. This register is reset on ipp_reset_b. This is a read-write register.
For bit[6-0] - writing zero does not have any effect. Writing one will clear the
corresponding bit. The individual bits can be cleared by writing one to that bit. When the
system comes out of reset, this register will have bits set corresponding to all the reset
sources that occurred during system reset. Software has to take care to clear this register
by writing one after every reset that occurs so that the register will contain the
information of recently occurred reset.
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3517

<!-- page 3518 -->

Address: 20D_8000h base + 8h offset = 20D_8008h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
warm_boot
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
tempsense_rst_b
wdog3_rst_b
jtag_sw_rst
jtag_rst_b
wdog_rst_b
ipp_user_reset_b
csu_reset_b
0
ipp_reset_b
W
w1c
w1c
w1c
w1c
w1c
w1c
w1c
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
SRC_SRSR field descriptions
Field
Description
31–17
Reserved
This read-only field is reserved and always has the value 0.
16
warm_boot
WARM boot indication shows that WARM boot was initiated by software. This indicates to the software
that it saved the needed information in the memory before initiating the WARM reset. In this case,
software will set this bit to '1', before initiating the WARM reset. The warm_boot bit should be used as
indication only after a warm_reset sequence. Software should clear this bit after warm_reset to indicate
that the next warm_reset is not performed with warm_boot. Please refer to Reset Sequence and De-
Assertion for details on warm_reset.
0
WARM boot process not initiated by software.
1
WARM boot initiated by software.
15–9
Reserved
This read-only field is reserved and always has the value 0.
8
tempsense_rst_b
Temper Sensor software reset. Indicates whether the reset was the result of software reset from on-chip
Temperature Sensor.
Table continues on the next page...
SRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3518
NXP Semiconductors

<!-- page 3519 -->

SRC_SRSR field descriptions (continued)
Field
Description
0
Reset is not a result of software reset from Temperature Sensor.
1
Reset is a result of software reset from Temperature Sensor.
7
wdog3_rst_b
IC Watchdog3 Time-out reset. Indicates whether the reset was the result of the watchdog3 time-out event.
0
Reset is not a result of the watchdog3 time-out event.
1
Reset is a result of the watchdog3 time-out event.
6
jtag_sw_rst
JTAG software reset. Indicates whether the reset was the result of software reset from JTAG.
0
Reset is not a result of software reset from JTAG.
1
Reset is a result of software reset from JTAG.
5
jtag_rst_b
HIGH - Z JTAG reset. Indicates whether the reset was the result of HIGH-Z reset from JTAG.
0
Reset is not a result of HIGH-Z reset from JTAG.
1
Reset is a result of HIGH-Z reset from JTAG.
4
wdog_rst_b
IC Watchdog Time-out reset. Indicates whether the reset was the result of the watchdog time-out event.
0
Reset is not a result of the watchdog time-out event.
1
Reset is a result of the watchdog time-out event.
3
ipp_user_reset_b
Indicates whether the reset was the result of the ipp_user_reset_b qualified reset.
0
Reset is not a result of the ipp_user_reset_b qualified as COLD reset event.
1
Reset is a result of the ipp_user_reset_b qualified as COLD reset event.
2
csu_reset_b
Indicates whether the reset was the result of the csu_reset_b input.
NOTE: If case the csu_reset_b occurred during a WARM reset process, during the phase that ipg_clk is
not available yet, then the occurrence of CSU reset will not be reflected in this bit.
0
Reset is not a result of the csu_reset_b event.
1
Reset is a result of the csu_reset_b event.
1
Reserved
This read-only field is reserved and always has the value 0.
0
ipp_reset_b
Indicates whether reset was the result of ipp_reset_b pin (Power-up sequence)
0
Reset is not a result of ipp_reset_b pin.
1
Reset is a result of ipp_reset_b pin.
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3519

<!-- page 3520 -->

51.7.4
SRC Interrupt Status Register (SRC_SISR)
Address: 20D_8000h base + 14h offset = 20D_8014h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
core0_wdog_rst_req
Reserved
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3520
NXP Semiconductors

<!-- page 3521 -->

SRC_SISR field descriptions
Field
Description
31–6
Reserved
This read-only field is reserved and always has the value 0.
5
core0_wdog_rst_
req
WDOG reset request from core0. Read-only status bit.
-
This field is reserved.
Reserved
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3521

<!-- page 3522 -->

51.7.5
SRC Boot Mode Register 2 (SRC_SBMR2)
The Boot Mode register (SBMR), contains bits that reflect the status of Boot Mode Pins
of the chip. The default values for those bits depends on the values of pins/fuses during
reset sequence, hence the question mark on their default value.
Address: 20D_8000h base + 1Ch offset = 20D_801Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
BMOD[1:0]
0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
BT_FUSE_SEL
DIR_
BT_
DIS
0
SEC_
CONFIG[1:0]
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3522
NXP Semiconductors

<!-- page 3523 -->

SRC_SBMR2 field descriptions
Field
Description
31–26
Reserved
This read-only field is reserved and always has the value 0.
25–24
BMOD[1:0]
BMOD[1:0] shows the latched state of the BOOT_MODE1 and BOOT_MODE0 signals on the rising edge
of POR_B. See the Boot mode pin settings section of System Boot.
23–5
Reserved
This read-only field is reserved and always has the value 0.
4
BT_FUSE_SEL
BT_FUSE_SEL (connected to gpio bt_fuse_sel) shows the state of the BT_FUSE_SEL fuse. See
Fusemap for additional information on this fuse.
3
DIR_BT_DIS
DIR_BT_DIS shows the state of the DIR_BT_DIS fuse. See Chapter 5, Fusemap for additional information
on this fuse.
2
Reserved
This read-only field is reserved and always has the value 0.
SEC_
CONFIG[1:0]
SECONFIG[1] shows the state of the SECONFIG[1] fuse. See Fusemap for additional information on this
fuse. SECONFIG[0] shows the state of the SECONFIG[0] fuse. This fuse is shown as reserved in
Fusemap (address 0x440[1]) because it does not have a user-relevant function.
51.7.6
SRC General Purpose Register 1 (SRC_GPR1)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 20h offset = 20D_8020h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
PERSISTENT_ENTRY0
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR1 field descriptions
Field
Description
PERSISTENT_
ENTRY0
Holds entry function for core0 for waking-up from low power mode. The SRC ensures that the register
value will persist across system resets.
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3523

<!-- page 3524 -->

51.7.7
SRC General Purpose Register 2 (SRC_GPR2)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 24h offset = 20D_8024h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
PERSISTENT_ARG0
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR2 field descriptions
Field
Description
PERSISTENT_
ARG0
Holds argument of entry function for core0 for waking-up from low power mode. The SRC ensures that the
register value will persist across system resets.
51.7.8
SRC General Purpose Register 3 (SRC_GPR3)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 28h offset = 20D_8028h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR3 field descriptions
Field
Description
-
Read/write general purpose bits used to store an arbitrary value.
SRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3524
NXP Semiconductors

<!-- page 3525 -->

51.7.9
SRC General Purpose Register 4 (SRC_GPR4)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 2Ch offset = 20D_802Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR4 field descriptions
Field
Description
-
Read/write general purpose bits used to store an arbitrary value.
51.7.10
SRC General Purpose Register 5 (SRC_GPR5)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 30h offset = 20D_8030h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR5 field descriptions
Field
Description
-
Read/write general purpose bits used to store an arbitrary value.
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3525

<!-- page 3526 -->

51.7.11
SRC General Purpose Register 6 (SRC_GPR6)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 34h offset = 20D_8034h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR6 field descriptions
Field
Description
-
Read/write general purpose bits used to store an arbitrary value.
51.7.12
SRC General Purpose Register 7 (SRC_GPR7)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 38h offset = 20D_8038h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR7 field descriptions
Field
Description
-
Read/write general purpose bits used to store an arbitrary value.
SRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3526
NXP Semiconductors

<!-- page 3527 -->

51.7.13
SRC General Purpose Register 8 (SRC_GPR8)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 3Ch offset = 20D_803Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR8 field descriptions
Field
Description
-
Read/write general purpose bits used to store an arbitrary value.
51.7.14
SRC General Purpose Register 9 (SRC_GPR9)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 40h offset = 20D_8040h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR9 field descriptions
Field
Description
-
This field is reserved.
Reserved.
Chapter 51 System Reset Controller (SRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3527

<!-- page 3528 -->

51.7.15
SRC General Purpose Register 10 (SRC_GPR10)
NOTE
This register is used by the ROM code and should not be used
by application software.
Address: 20D_8000h base + 44h offset = 20D_8044h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
-
Reserved
-
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SRC_GPR10 field descriptions
Field
Description
31–26
-
Read/write bits, for general purpose
NOTE: Reset only by POR
25
-
This field is reserved.
Reserved.
-
Read/write bits, for general purpose
NOTE: Reset only by POR
SRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3528
NXP Semiconductors

