# Chapter 39: Power Management Unit (PMU)

> Nguồn: `IMX6ULLRM.pdf` — trang 2441–2472

<!-- page 2441 -->

Chapter 39
Power Management Unit (PMU)
39.1
Overview
The power management unit (PMU) is designed to simplify the external power interface.
The power system can be split into the input power sources and their characteristics, the
integrated power transforming and controlling elements, and the final load
interconnection and requirements.
A typical power system uses the PMU is depicted in the following diagram.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2441

<!-- page 2442 -->

External Supplies
VDD_SOC_IN
VDD_HIGH_IN
VDD_SNVS_IN
VDD_ARM_CAP
GND
GND
VDD_SOC_CAP
VDD_HIGH_CAP
GND
NVCC_PLL
GND
GND
VDD_SNVS_CAP
GND
VDD_USB_CAP
i.MX 6UL
NVCC_DRAM
NVCC_DRAM_2P5
NVCC_xxx
USB_OTG1_VBUS
LDO_ARM
LDO_SOC
LDO_2P5
PLLs
LDO_1P1
LDO_SNVS
USB
eFuse
24M
OSC
SNVS
32K
OSC
SOC (Always ON)
DRAM IO
…
NVCC_xxx
DCDC High
3.3V
Coin
Cell
DCDC DDR
1.2-1.5V
1.5V/1.8V/2.5V/3.3V
DCDC
ARM/SOC
1.375V nom
0.9V stby
1.5V/1.8V/2.5V/3.3V
SOC (Power Down)
Cortex A7 Core
L1 Cache
L2 Cache
VDDA_ADC_3P3
12-bit ADC
LDO_USB
USB_OTG1_VBUS
USB_OTG2_VBUS
USB_OTG2_VBUS
GPIO PADs
Figure 39-1. Power system overview
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2442
NXP Semiconductors

<!-- page 2443 -->

Using seven LDO regulators, the number of external supplies is greatly reduced. Not
counting the backup coin and USB inputs, the number of external supplies is reduced to
two. Missing from this external supply total is the number of necessary external supplies
to power the desired memory interface; that number varies depending on the type of
external memory selected. Other supplies may also be necessary to supply the voltage to
the different I/O power segments if their I/O voltages have to be different from what is
provided above.
39.2
Digital LDO Regulators
The PMU has three digital LDO regulators. They are referred to as "digital" because of
the logic loads they drive, not because of their construction. These regulators have three
basic modes that are unique to the digital regulators.
• Power Gate—The regulation FET is switched off fully, limiting the current draw
from the supply. The analog part of the regulator is powered down, limiting the
power consumption. The output voltage falls to a level at which the residual leakage
of the power FET balances with the leakage of the load. (TARG = 0x00)
• Analog regulation mode—The regulation FET is controlled such that the output
voltage of the regulator equals the programmed target voltage. The target voltage is
fully programmable in 25mV steps.
These modes allow the regulators to implement voltage scaling and power gating and
allow bypass. With the bypass feature, all of the accuracy and control requirements can
be shifted to the external supply source if capable and desired.
These digital regulators also feature brownout detection which is helpful when supplies
are starting to collapse. The voltage value where brownout is signaled is programmable
as an offset from the programmed target voltage. The controls are located in the
PMU_MISC2 register. The core is interrupted on a brownout.
The two digital regulators are known as LDO_ARM, , and LDO_SOC. As shown in the
power system overview figure, the ARM regulator powers the ARM cores. All regulators
support generous programming ranges in 25mV steps. It is possible to program voltages
above the process limit for the chip, thus causing permanent damage. Likewise, it is
possible to program the voltage so low that the chip cannot continue to operate or even
retain state without clocks. Care should be taken with these settings.
Care must be taken when raising the output voltage of the regulator rapidly. This can
cause large currents to flow into the output cap of the regulator up to the limits of the
input supply. When the input supply capability is exceeded, this can cause an input
supply dip that may affect other regulators on the same supply. Therefore, the rate of
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2443

<!-- page 2444 -->

voltage change on the output of the regulator should be limited. When powering up the
regulator, the integrated current limiter controls the ramp rate. This limiter is only
effective when transitioning from the off state of the regulator (bypassed or power gated).
However, in a DVFS situation, the same high rate of change can occur if the target
voltage is raised rapidly by software. To limit the rate of change, the hardware controlling
the regulator effects a piecewise linear ramp by stepping the output voltage in 25mV
steps until the desired output voltage is reached. The slope of the ramp is controlled by
the time spent at each 25mV step and is controlled by the step time field in the
PMU_MISC2 register. The same situation is not a problem when the output voltage is
dropped as the load pulls down the output cap. As a result, any reduction in the
programmed regulator target voltage is immediately effective with the actual supply
voltage falling at a rate controlled by the load on the regulator.
39.3
Analog LDO Regulators
There are two analog regulators described here.
39.3.1
LDO 1P1
The LDO_1P1 module on the chip implements a programmable linear-regulator function
from a higher analog supply voltage (2.8 V–3.3 V) to produce a nominal 1.1 V output
voltage.
The output of the regulator can be programmed in 25 mV steps from 0.8 V to 1.4 V. The
regulator has been designed to be stable with a minimum external low-ESR decoupling
capacitance, though the actual capacitance required should be determined by the
application. A programmable brownout detector is included in the regulator which can be
used by the system to determine when the load capability of the regulator is being
exceeded, so the necessary steps can be taken.
Current limiting can be enabled by setting the PMU_REG_1P1[ENABLE_ILIMIT] bit to
allow for in-rush current requirements during startup if needed. Active pulldown can also
be enabled by setting the PMU_REG_1P1[ENABLE_PULLDOWN] bit for systems
requiring this feature.
Analog LDO Regulators
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2444
NXP Semiconductors

<!-- page 2445 -->

39.3.2
LDO 2P5
The LDO_2P5 module on the chip implements a programmable linear-regulator function
from a higher analog supply voltage (2.8V-3.3V) to produce a nominal 2.5V output
voltage.
The output of the regulator can be programmed in 25mV steps from 2.0V to 2.75V. The
regulator has been designed to be stable with a minimum external low-ESR decoupling
capacitance, though the actual capacitance required should be determined by the
application. A programmable brown-out detector is included in the regulator which can
be used by the system to determine when the load capability of the regulator is being
exceeded to take the necessary steps.
Current-limiting can be enabled by setting the REG_PMU_2P5[ENABLE_ILIMIT] bit to
allow for in-rush current requirements during start-up if needed. Active-pulldown can
also be enabled by setting the REG_PMU_2P5[ENABLE_PULLDOWN] bit for systems
requiring this feature.
39.3.3
Low Power Operation
The 1.1 V and 2.5 V LDO includes an alternate, self-biased, low-precision, weak
regulator which can be enabled for applications needing to keep the 1.1 V and 2.5 V
output voltage alive during low-power modes where the main regulator and its associated
global bandgap reference module are disabled.
The output of this weak regulator is not programmable and is a function of its input
power supply as well as load current. The low-power mode is enabled by setting high the
PMU_REG_1P1[ENABLE_WEAK_LINREG] and
PMU_REG_2P5[ENABLE_WEAK_LINREG] bit of the regulator. It is recommended
that the following sequence be followed to enable this mode:
1. Throttle down the 1.1 V / 2.5 V attached load to its low-power maintain state.
2. Disable the main 1.1 V / 2.5 V regulator driver by clearing the
PMU_REG_1P1[ENABLE_LINREG] / PMU_REG_2P5[ENABLE_LINREG] bit.
3. Enable the weak 1.1 V / 2.5 V regulator by setting the
PMU_REG_1P1[ENABLE_WEAK_LINREG] /
PMU_REG_2P5[ENABLE_WEAK_LINREG] bit.
To go back to full-power operation, reverse the steps outlined above. Note that the
external decoupling cap is supporting the power supply between steps 2 and 3. Therefore
step 3 should happen appropriately in time relative to the discharge of the supporting
capacitor.
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2445

<!-- page 2446 -->

39.4
USB LDO Regulator
The USB_LDO module on the chip implements a programmable linear-regulator function
from the USB VBUS voltages (typically 5 V) to produce a nominal 3.0 V output voltage.
The output of the regulator can be programmed in 25 mV steps, from 2.625V to 3.4 V .
The regulator has been designed to be stable with a minimum external low-ESR
decoupling capacitor of 4.7 µF, though the actual capacitance required should be
determined by the application. A programmable brownout detector is included in the
regulator which can be used by the system to determine when the load capability of the
regulator is being exceeded, so the necessary steps can be taken. This regulator has a
built-in power mux which allows the user to choose to run the regulator from either
VBUS supply when both are present. If only one of the VBUS voltages is present, then
the regulator automatically selects this supply. Current limit is also included to help the
system meet in-rush current targets.
Upon attachment of VBUS, this regulator starts up in a low-power, self-preservation
mode to prevent over-voltage conditions on the chip. It is expected that the user transition
to full regulation by enabling the regulator and disabling the in-rush current limits via its
control registers. Upon VBUS removal, it is further expected that the regulator controls
are returned to their reset state.
39.5
SNVS Regulator
The SNVS regulator takes the SNVS_IN supply and generates the SNVS_CAP supply,
which powers the real time clock and SNVS blocks.
If VDDHIGH_IN is present, then the SNVS_IN supply is internally shorted to the
VDDHIGH_IN supply to allow coin cell recharging if necessary. The output voltage is
roughly one third of SNVS_IN.
USB LDO Regulator
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2446
NXP Semiconductors

<!-- page 2447 -->

39.6
PMU Memory Map/Register Definition
The register definitions that affect the behavior of the digital LDO regulators follow.
NOTE
Some of the registers are collections of bits that affect multiple
components on the chip. Those that are not pertinent to this
chapter have comments in the related register bitfields.
If a full description is desired, please consult the full register programming reference in
the related block.
PMU memory map
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
20C_8110
Regulator 1P1 Register (PMU_REG_1P1)
32
R/W
0000_1073h
39.6.1/2449
20C_8114
Regulator 1P1 Register (PMU_REG_1P1_SET)
32
R/W
0000_1073h
39.6.1/2449
20C_8118
Regulator 1P1 Register (PMU_REG_1P1_CLR)
32
R/W
0000_1073h
39.6.1/2449
20C_811C
Regulator 1P1 Register (PMU_REG_1P1_TOG)
32
R/W
0000_1073h
39.6.1/2449
20C_8120
Regulator 3P0 Register (PMU_REG_3P0)
32
R/W
0000_0F74h
39.6.2/2452
20C_8124
Regulator 3P0 Register (PMU_REG_3P0_SET)
32
R/W
0000_0F74h
39.6.2/2452
20C_8128
Regulator 3P0 Register (PMU_REG_3P0_CLR)
32
R/W
0000_0F74h
39.6.2/2452
20C_812C
Regulator 3P0 Register (PMU_REG_3P0_TOG)
32
R/W
0000_0F74h
39.6.2/2452
20C_8130
Regulator 2P5 Register (PMU_REG_2P5)
32
R/W
0000_1073h
39.6.3/2454
20C_8134
Regulator 2P5 Register (PMU_REG_2P5_SET)
32
R/W
0000_1073h
39.6.3/2454
20C_8138
Regulator 2P5 Register (PMU_REG_2P5_CLR)
32
R/W
0000_1073h
39.6.3/2454
20C_813C
Regulator 2P5 Register (PMU_REG_2P5_TOG)
32
R/W
0000_1073h
39.6.3/2454
20C_8140
Digital Regulator Core Register (PMU_REG_CORE)
32
R/W
0048_2012h
39.6.4/2456
20C_8144
Digital Regulator Core Register (PMU_REG_CORE_SET)
32
R/W
0048_2012h
39.6.4/2456
20C_8148
Digital Regulator Core Register (PMU_REG_CORE_CLR)
32
R/W
0048_2012h
39.6.4/2456
20C_814C
Digital Regulator Core Register (PMU_REG_CORE_TOG)
32
R/W
0048_2012h
39.6.4/2456
20C_8150
Miscellaneous Register 0 (PMU_MISC0)
32
R/W
0400_0000h
39.6.5/2458
20C_8154
Miscellaneous Register 0 (PMU_MISC0_SET)
32
R/W
0400_0000h
39.6.5/2458
20C_8158
Miscellaneous Register 0 (PMU_MISC0_CLR)
32
R/W
0400_0000h
39.6.5/2458
20C_815C
Miscellaneous Register 0 (PMU_MISC0_TOG)
32
R/W
0400_0000h
39.6.5/2458
20C_8160
Miscellaneous Register 1 (PMU_MISC1)
32
R/W
0000_0000h
39.6.6/2462
20C_8164
Miscellaneous Register 1 (PMU_MISC1_SET)
32
R/W
0000_0000h
39.6.6/2462
20C_8168
Miscellaneous Register 1 (PMU_MISC1_CLR)
32
R/W
0000_0000h
39.6.6/2462
20C_816C
Miscellaneous Register 1 (PMU_MISC1_TOG)
32
R/W
0000_0000h
39.6.6/2462
20C_8170
Miscellaneous Control Register (PMU_MISC2)
32
R/W
0027_2727h
39.6.7/2464
20C_8174
Miscellaneous Control Register (PMU_MISC2_SET)
32
R/W
0027_2727h
39.6.7/2464
Table continues on the next page...
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2447

<!-- page 2448 -->

PMU memory map (continued)
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
20C_8178
Miscellaneous Control Register (PMU_MISC2_CLR)
32
R/W
0027_2727h
39.6.7/2464
20C_817C
Miscellaneous Control Register (PMU_MISC2_TOG)
32
R/W
0027_2727h
39.6.7/2464
20C_8270
Low Power Control Register (PMU_LOWPWR_CTRL)
32
R/W
0000_4009h
39.6.8/2469
20C_8274
Low Power Control Register (PMU_LOWPWR_CTRL_SET)
32
R/W
0000_4009h
39.6.8/2469
20C_8278
Low Power Control Register (PMU_LOWPWR_CTRL_CLR)
32
R/W
0000_4009h
39.6.8/2469
20C_827C
Low Power Control Register (PMU_LOWPWR_CTRL_TOG)
32
R/W
0000_4009h
39.6.8/2469
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2448
NXP Semiconductors

<!-- page 2449 -->

39.6.1
Regulator 1P1 Register (PMU_REG_1P1n)
This register defines the control and status bits for the 1.1V regulator. This regulator is
designed to power the digital portions of the analog cells.
Address: 20C_8000h base + 110h offset + (4d × i), where i=0d to 3d
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
Reserved
SELREF_WEAK_LINREG
ENABLE_WEAK_LINREG
OK_VDD1P1
BO_VDD1P1
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
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2449

<!-- page 2450 -->

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
Reserved
OUTPUT_TRG
Reserved
BO_OFFSET
ENABLE_PULLDOWN
ENABLE_ILIMIT
ENABLE_BO
ENABLE_LINREG
W
Reset
0
0
0
1
0
0
0
0
0
1
1
1
0
0
1
1
PMU_REG_1P1n field descriptions
Field
Description
31–20
-
This field is reserved.
19
SELREF_
WEAK_LINREG
Selects the source for the reference voltage of the weak 1p1 regulator.
0
Weak-linreg output tracks low-power-bandgap voltage
1
Weak-linreg output tracks VDD_SOC_CAP voltage
18
ENABLE_
WEAK_LINREG
Enables the weak 1p1 regulator. This regulator can be used when the main 1p1 regulator is disabled,
under low-power conditions.
17
OK_VDD1P1
Status bit that signals when the regulator output is ok. 1 = regulator output > brownout target
16
BO_VDD1P1
Status bit that signals when a brownout is detected on the regulator output.
15–13
-
This field is reserved.
12–8
OUTPUT_TRG
Control bits to adjust the regulator output voltage. Each LSB is worth 25mV. Programming examples are
detailed below. Other output target voltages may be interpolated from these examples. Choices must be in
this range: 0x1b >= output_trg >= 0x04
NOTE: There may be reduced chip functionality or reliability at the extremes of the programming range.
0x04
0.8V
0x10
1.1V
0x1b
1.375V
7
-
This field is reserved.
Table continues on the next page...
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2450
NXP Semiconductors

<!-- page 2451 -->

PMU_REG_1P1n field descriptions (continued)
Field
Description
6–4
BO_OFFSET
Control bits to adjust the regulator brownout offset voltage in 25mV steps. The reset brown-offset is
175mV below the programmed target code. Brownout target = OUTPUT_TRG - BO_OFFSET. Some
steps may be irrelevant because of input supply limitations or load operation.
3
ENABLE_
PULLDOWN
Control bit to enable the pull-down circuitry in the regulator
2
ENABLE_ILIMIT
Control bit to enable the current-limit circuitry in the regulator.
1
ENABLE_BO
Control bit to enable the brownout circuitry in the regulator.
0
ENABLE_
LINREG
Control bit to enable the regulator output.
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2451

<!-- page 2452 -->

39.6.2
Regulator 3P0 Register (PMU_REG_3P0n)
This register defines the control and status bits for the 3.0V regulator powered by the host
USB VBUS pin.
Address: 20C_8000h base + 120h offset + (4d × i), where i=0d to 3d
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
Reserved
OK_VDD3P0
BO_VDD3P0
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
Reserved
OUTPUT_TRG
VBUS_SEL
BO_OFFSET
-
ENABLE_ILIMIT
ENABLE_BO
ENABLE_LINREG
W
Reset
0
0
0
0
1
1
1
1
0
1
1
1
0
1
0
0
PMU_REG_3P0n field descriptions
Field
Description
31–18
-
This field is reserved.
Table continues on the next page...
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2452
NXP Semiconductors

<!-- page 2453 -->

PMU_REG_3P0n field descriptions (continued)
Field
Description
17
OK_VDD3P0
Status bit that signals when the regulator output is ok. 1 = regulator output > brownout target
16
BO_VDD3P0
Status bit that signals when a brownout is detected on the regulator output.
15–13
-
This field is reserved.
12–8
OUTPUT_TRG
Control bits to adjust the regulator output voltage. Each LSB is worth 25mV. Programming examples are
detailed below. Other output target voltages may be interpolated from these examples.
NOTE: There may be reduced chip functionality or reliability at the extremes of the programming range.
0x00
2.625V
0x0f
3.000V
0x1f
3.400V
7
VBUS_SEL
Select input voltage source for LDO_3P0 from either USB_OTG1_VBUS or USB_OTG2_VBUS. If only
one of the two VBUS voltages is present, it is automatically selected.
1
USB_OTG1_VBUS — Utilize VBUS OTG1 power
0
USB_OTG2_VBUS — Utilize VBUS OTG2 power
6–4
BO_OFFSET
Control bits to adjust the regulator brownout offset voltage in 25mV steps. The reset brown-offset is
175mV below the programmed target code. Brownout target = OUTPUT_TRG - BO_OFFSET. Some
steps may not be relevant because of input supply limitations or load operation.
3
-
Reserved
2
ENABLE_ILIMIT
Control bit to enable the current-limit circuitry in the regulator.
1
ENABLE_BO
Control bit to enable the brownout circuitry in the regulator.
0
ENABLE_
LINREG
Control bit to enable the regulator output to be set by the programmed target voltage setting and internal
bandgap reference.
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2453

<!-- page 2454 -->

39.6.3
Regulator 2P5 Register (PMU_REG_2P5n)
This register defines the control and status bits for the 2.5V regulator.
Address: 20C_8000h base + 130h offset + (4d × i), where i=0d to 3d
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
Reserved
ENABLE_WEAK_LINREG
OK_VDD2P5
BO_VDD2P5
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
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2454
NXP Semiconductors

<!-- page 2455 -->

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
Reserved
OUTPUT_TRG
Reserved
BO_OFFSET
ENABLE_PULLDOWN
ENABLE_ILIMIT
ENABLE_BO
ENABLE_LINREG
W
Reset
0
0
0
1
0
0
0
0
0
1
1
1
0
0
1
1
PMU_REG_2P5n field descriptions
Field
Description
31–19
-
This field is reserved.
18
ENABLE_
WEAK_LINREG
Enables the weak 2p5 regulator. This low power regulator is used when the main 2p5 regulator is disabled
to keep the 2.5V output roughly at 2.5V. Scales directly with the value of VDDHIGH_IN.
17
OK_VDD2P5
Status bit that signals when the regulator output is ok. 1 = regulator output > brownout target
16
BO_VDD2P5
Status bit that signals when a brownout is detected on the regulator output.
15–13
-
This field is reserved.
12–8
OUTPUT_TRG
Control bits to adjust the regulator output voltage. Each LSB is worth 25mV. Programming examples are
detailed below. Other output target voltages may be interpolated from these examples.
NOTE: There may be reduced chip functionality or reliability at the extremes of the programming range.
0x00
2.10V
0x10
2.50V
0x1f
2.875V
7
-
This field is reserved.
6–4
BO_OFFSET
Control bits to adjust the regulator brownout offset voltage in 25mV steps. The reset brown-offset is
175mV below the programmed target code. Brownout target = OUTPUT_TRG - BO_OFFSET. Some
steps may be irrelevant because of input supply limitations or load operation.
3
ENABLE_
PULLDOWN
Control bit to enable the pull-down circuitry in the regulator
Table continues on the next page...
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2455

<!-- page 2456 -->

PMU_REG_2P5n field descriptions (continued)
Field
Description
2
ENABLE_ILIMIT
Control bit to enable the current-limit circuitry in the regulator.
1
ENABLE_BO
Control bit to enable the brownout circuitry in the regulator.
0
ENABLE_
LINREG
Control bit to enable the regulator output.
39.6.4
Digital Regulator Core Register (PMU_REG_COREn)
This register defines the function of the digital regulators
Address: 20C_8000h base + 140h offset + (4d × i), where i=0d to 3d
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
Reserved
FET_ODRIVE
RAMP_RATE
Reserved
REG2_TARG
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
1
0
0
1
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
Reserved
REG0_TARG
W
Reset
0
0
1
0
0
0
0
0
0
0
0
1
0
0
1
0
PMU_REG_COREn field descriptions
Field
Description
31–30
-
This field is reserved.
29
FET_ODRIVE
If set, increases the gate drive on power gating FETs to reduce leakage in the off state. Care must be
taken to apply this bit only when the input supply voltage to the power FET is less than 1.1V.
NOTE: This bit should only be used in low-power modes where the external input supply voltage is
nominally 0.9V.
28–27
RAMP_RATE
Regulator voltage ramp rate.
00
Fast
01
Medium Fast
Table continues on the next page...
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2456
NXP Semiconductors

<!-- page 2457 -->

PMU_REG_COREn field descriptions (continued)
Field
Description
10
Medium Slow
11
Slow
26–23
-
This field is reserved.
22–18
REG2_TARG
This field defines the target voltage for the SOC power domain. Single-bit increments reflect 25mV core
voltage steps. Some steps may not be relevant because of input supply limitations or load operation.
NOTE: This register is capable of programming an over-voltage condition on the device. Consult the
datasheet Operating Ranges table for the allowed voltages.
00000
Power gated off
00001
Target core voltage = 0.725V
00010
Target core voltage = 0.750V
00011
Target core voltage = 0.775V
...
10000
Target core voltage = 1.100V
...
11110
Target core voltage = 1.450V
11111
Power FET switched full on. No regulation.
17–5
-
This field is reserved.
REG0_TARG
This field defines the target voltage for the ARM core power domain. Single-bit increments reflect 25mV
core voltage steps. Some steps may not be relevant because of input supply limitations or load operation.
NOTE: This register is capable of programming an over-voltage condition on the device. Consult the
datasheet Operating Ranges table for the allowed voltages.
00000
Power gated off
00001
Target core voltage = 0.725V
00010
Target core voltage = 0.750V
00011
Target core voltage = 0.775V
...
10000
Target core voltage = 1.100V
...
11110
Target core voltage = 1.450V
11111
Power FET switched full on. No regulation.
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2457

<!-- page 2458 -->

39.6.5
Miscellaneous Register 0 (PMU_MISC0n)
This register defines the control and status bits for miscellaneous analog blocks.
Address: 20C_8000h base + 150h offset + (4d × i), where i=0d to 3d
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
VID_PLL_PREDIV
XTAL_24M_PWD
RTC_XTAL_SOURCE
CLKGATE_DELAY
CLKGATE_CTRL
Reserved
OSC_XTALOK_EN
W
Reset
0
0
0
0
0
1
0
0
0
0
0
0
0
0
0
0
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2458
NXP Semiconductors

<!-- page 2459 -->

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
OSC_XTALOK
OSC_I
DISCON_HIGH_SNVS
STOP_
MODE_
CONFIG
Reserved
REFTOP_VBGUP
REFTOP_VBGADJ
REFTOP_SELFBIASOFF
Reserved
REFTOP_PWD
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
PMU_MISC0n field descriptions
Field
Description
31
VID_PLL_
PREDIV
Predivider for the source clock of the PLL's.
0
Divide by 1
1
Divide by 2
30
XTAL_24M_PWD
This field powers down the 24M crystal oscillator if set true.
29
RTC_XTAL_
SOURCE
This field indicates which chip source is being used for the rtc clock.
0
Internal ring oscillator
1
RTC_XTAL
28–26
CLKGATE_
DELAY
This field specifies the delay between powering up the XTAL 24MHz clock and releasing the clock to the
digital logic inside the analog block.
NOTE: Do not change the field during a low power event. This is not a field that the user would normally
need to modify.
NOTE: Not related to PMU.
000
0.5ms
001
1.0ms
010
2.0ms
011
3.0ms
100
4.0ms
Table continues on the next page...
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2459

<!-- page 2460 -->

PMU_MISC0n field descriptions (continued)
Field
Description
101
5.0ms
110
6.0ms
111
7.0ms
25
CLKGATE_CTRL This bit allows disabling the clock gate (always ungated) for the xtal 24MHz clock that clocks the digital
logic in the analog block.
NOTE: Do not change the field during a low power event. This is not a field that the user would normally
need to modify.
NOTE: Not related to PMU.
0
ALLOW_AUTO_GATE — Allow the logic to automatically gate the clock when the XTAL is powered
down.
1
NO_AUTO_GATE — Prevent the logic from ever gating off the clock.
24–17
-
This field is reserved.
Always set to zero.
16
OSC_XTALOK_
EN
This bit enables the detector that signals when the 24MHz crystal oscillator is stable.
NOTE: Not related to PMU, Clocking content
15
OSC_XTALOK
Status bit that signals that the output of the 24-MHz crystal oscillator is stable. Generated from a timer and
active detection of the actual frequency.
NOTE: Not related to PMU, clocking content.
14–13
OSC_I
This field determines the bias current in the 24MHz oscillator. The aim is to start up with the highest bias
current, which can be decreased after startup if it is determined to be acceptable.
NOTE: Not related to PMU.
00
NOMINAL — Nominal
01
MINUS_12_5_PERCENT — Decrease current by 12.5%
10
MINUS_25_PERCENT — Decrease current by 25.0%
11
MINUS_37_5_PERCENT — Decrease current by 37.5%
12
DISCON_HIGH_
SNVS
This bit controls a switch from VDD_HIGH_IN to VDD_SNVS_IN.
0
Turn on the switch
1
Turn off the switch
11–10
STOP_MODE_
CONFIG
Configure the analog behavior in stop mode.
00
SUSPEND (DSM) — All analog except rtc powered down on stop mode assertion.
01
STANDBY — Analog regulators are ON.
10
STOP (lower power) — Analog regulators are ON.
11
STOP (very lower power) — Analog regulators are OFF.
9–8
-
This field is reserved.
Reserved
7
REFTOP_
VBGUP
Status bit that signals the analog bandgap voltage is up and stable. 1 - Stable.
Table continues on the next page...
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2460
NXP Semiconductors

<!-- page 2461 -->

PMU_MISC0n field descriptions (continued)
Field
Description
6–4
REFTOP_
VBGADJ
000
Nominal VBG
001
VBG+0.78%
010
VBG+1.56%
011
VBG+2.34%
100
VBG-0.78%
101
VBG-1.56%
110
VBG-2.34%
111
VBG-3.12%
3
REFTOP_
SELFBIASOFF
Control bit to disable the self-bias circuit in the analog bandgap. The self-bias circuit is used by the
bandgap during startup. This bit should be set after the bandgap has stabilized and is necessary for best
noise performance of analog blocks using the outputs of the bandgap.
NOTE: Value should be returned to zero before removing vddhigh_in or asserting bit 0 of this register
(REFTOP_PWD) to assure proper restart of the circuit.
0
Uses coarse bias currents for startup
1
Uses bandgap-based bias currents for best performance.
2–1
-
This field is reserved.
0
REFTOP_PWD
Control bit to power-down the analog bandgap reference circuitry.
NOTE: A note of caution, the bandgap is necessary for correct operation of most of the LDO, pll, and
other analog functions on the die.
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2461

<!-- page 2462 -->

39.6.6
Miscellaneous Register 1 (PMU_MISC1n)
This register defines the control and status bits for miscellaneous analog blocks.
Address: 20C_8000h base + 160h offset + (4d × i), where i=0d to 3d
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
IRQ_DIG_BO
IRQ_ANA_BO
IRQ_TEMPHIGH
IRQ_TEMPLOW
IRQ_TEMPPANIC
Reserved
PFD_528_AUTOGATE_EN
PFD_480_AUTOGATE_EN
W
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
Reserved
Reserved
LVDSCLK1_IBEN
Reserved
LVDSCLK1_OBEN
Reserved
LVDS1_CLK_SEL
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
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2462
NXP Semiconductors

<!-- page 2463 -->

PMU_MISC1n field descriptions
Field
Description
31
IRQ_DIG_BO
This status bit is set to one when when any of the digital regulator brownout interrupts assert. Check the
regulator status bits to discover which regulator interrupt asserted.
30
IRQ_ANA_BO
This status bit is set to one when when any of the analog regulator brownout interrupts assert. Check the
regulator status bits to discover which regulator interrupt asserted.
29
IRQ_TEMPHIGH This status bit is set to one when the temperature sensor high interrupt asserts for high temperature.
NOTE: Not related to PMU, Temperature Monitor content.
28
IRQ_TEMPLOW This status bit is set to one when the temperature sensor low interrupt asserts for low temperature.
NOTE: Not related to PMU, Temperature Monitor content.
27
IRQ_
TEMPPANIC
This status bit is set to one when the temperature sensor panic interrupt asserts for a panic high
temperature.
NOTE: Not related to PMU, Temperature Monitor content.
26–18
-
This field is reserved.
Reserved
17
PFD_528_
AUTOGATE_EN
This enables a feature that will clkgate (reset) all PFD_528 clocks anytime the PLL_528 is unlocked or
powered off.
16
PFD_480_
AUTOGATE_EN
This enables a feature that will clkgate (reset) all PFD_480 clocks anytime the USB1_PLL_480 is
unlocked or powered off.
15–14
-
This field is reserved.
Reserved
13
-
This field is reserved.
Reserved
12
LVDSCLK1_
IBEN
This enables the LVDS input buffer for anaclk1/1b. Do not enable input and output buffers simultaneously.
NOTE: Not related to PMU, Clocking content.
11
-
This field is reserved.
Reserved
10
LVDSCLK1_
OBEN
This enables the LVDS output buffer for anaclk1/1b. Do not enable input and output buffers
simultaneously.
NOTE: Not related to PMU, clocking content.
9–5
-
This field is reserved.
Reserved
LVDS1_CLK_
SEL
This field selects the clk to be routed to anaclk1/1b.
NOTE: Not related to PMU.
00000
ARM_PLL — Arm PLL
00001
SYS_PLL — System PLL
00010
PFD4 — ref_pfd4_clk == pll2_pfd0_clk
00011
PFD5 — ref_pfd5_clk == pll2_pfd1_clk
Table continues on the next page...
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2463

<!-- page 2464 -->

PMU_MISC1n field descriptions (continued)
Field
Description
00100
PFD6 — ref_pfd6_clk == pll2_pfd2_clk
00101
PFD7 — ref_pfd7_clk == pll2_pfd3_clk
00110
AUDIO_PLL — Audio PLL
00111
VIDEO_PLL — Video PLL
01001
ETHERNET_REF — ethernet ref clock (ENET_PLL)
01100
USB1_PLL — USB1 PLL clock
01101
USB2_PLL — USB2 PLL clock
01110
PFD0 — ref_pfd0_clk == pll3_pfd0_clk
01111
PFD1 — ref_pfd1_clk == pll3_pfd1_clk
10000
PFD2 — ref_pfd2_clk == pll3_pfd2_clk
10001
PFD3 — ref_pfd3_clk == pll3_pfd3_clk
10010
XTAL — xtal (24M)
10101 to 11111
- — ref_pfd7_clk == pll2_pfd3_clk
39.6.7
Miscellaneous Control Register (PMU_MISC2n)
This register defines the control for miscellaneous PMU Analog blocks.
NOTE
This register is shared with CCM.
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2464
NXP Semiconductors

<!-- page 2465 -->

Address: 20C_8000h base + 170h offset + (4d × i), where i=0d to 3d
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
VIDEO_DIV
REG2_STEP_TIME
Reserved
REG0_STEP_TIME
AUDIO_DIV_MSB
REG2_OK
REG2_ENABLE_BO
Reserved
REG2_BO_STATUS
REG2_BO_OFFSET
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
1
0
0
1
1
1
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2465

<!-- page 2466 -->

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
AUDIO_DIV_LSB
Reserved
PLL3_disable
Reserved
REG0_ENABLE_BO
Reserved
REG0_BO_STATUS
REG0_BO_OFFSET
W
Reset
0
0
1
0
0
1
1
1
0
0
1
0
0
1
1
1
PMU_MISC2n field descriptions
Field
Description
31–30
VIDEO_DIV
Post-divider for video. The output clock of the video PLL should be gated prior to changing this divider to
prevent glitches. This divider is feed by PLL_VIDEOn[POST_DIV_SELECT] to achieve division ratios
of /1, /2, /4, /8, and /16.
NOTE: Not related to PMU. See Clock Controller Module (CCM) for more information.
00
divide by 1 (Default)
01
divide by 2
10
divide by 1
11
divide by 4
29–28
REG2_STEP_
TIME
Number of clock periods (24MHz clock).
00
64_CLOCKS — 64
01
128_CLOCKS — 128
10
256_CLOCKS — 256
11
512_CLOCKS — 512
27–26
-
This field is reserved.
Reserved
Table continues on the next page...
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2466
NXP Semiconductors

<!-- page 2467 -->

PMU_MISC2n field descriptions (continued)
Field
Description
25–24
REG0_STEP_
TIME
Number of clock periods (24MHz clock).
00
64_CLOCKS — 64
01
128_CLOCKS — 128
10
256_CLOCKS — 256
11
512_CLOCKS — 512
23
AUDIO_DIV_
MSB
MSB of Post-divider for Audio PLL. The output clock of the video PLL should be gated prior to changing
this divider to prevent glitches. This divider is feed by PLL_AUDIOn[POST_DIV_SELECT] to achieve
division ratios of /1, /2, /4, /8, and /16.
NOTE: MSB bit value pertains to the first bit, please program the LSB bit (bit 15) as well to change
divider value
NOTE: Not related to PMU. See Clock Controller Module (CCM) for more information.
00
divide by 1 (Default)
01
divide by 2
10
divide by 1
11
divide by 4
22
REG2_OK
Signals that the voltage is above the brownout level for the SOC supply. 1 = regulator output >
brownout_target
21
REG2_ENABLE_
BO
Enables the brownout detection.
20
-
This field is reserved.
19
REG2_BO_
STATUS
Reg2 brownout status bit.
18–16
REG2_BO_
OFFSET
This field defines the brown out voltage offset for the xPU power domain. IRQ_DIG_BO is also asserted.
Single-bit increments reflect 25mV brownout voltage steps. The reset brown-offset is 175mV below the
programmed target code. Brownout target = OUTPUT_TRG - BO_OFFSET. Some steps may be
irrelevant because of input supply limitations or load operation.
100
Brownout offset = 0.100V
111
Brownout offset = 0.175V
15
AUDIO_DIV_LSB
LSB of Post-divider for Audio PLL. The output clock of the video PLL should be gated prior to changing
this divider to prevent glitches. This divider is feed by PLL_AUDIOn[POST_DIV_SELECT] to achieve
division ratios of /1, /2, /4, /8, and /16.
NOTE: LSB bit value pertains to the last bit, please program the MSB bit (bit 23) as well, to change
divider value
NOTE: Not related to PMU. See Clock Controller Module (CCM) for more information.
00
divide by 1 (Default)
01
divide by 2
10
divide by 1
11
divide by 4
14–8
-
This field is reserved.
Table continues on the next page...
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2467

<!-- page 2468 -->

PMU_MISC2n field descriptions (continued)
Field
Description
7
PLL3_disable
Default value of "0". Should be set to "1" to turn off the USB-PLL(PLL3) in run mode.
NOTE: Not related to PMU. See Clock Controller Module (CCM) for more information.
6
-
This field is reserved.
5
REG0_ENABLE_
BO
Enables the brownout detection.
4
-
This field is reserved.
3
REG0_BO_
STATUS
Reg0 brownout status bit.
1
Brownout, supply is below target minus brownout offset.
REG0_BO_
OFFSET
This field defines the brown out voltage offset for the CORE power domain. IRQ_DIG_BO is also
asserted. Single-bit increments reflect 25mV brownout voltage steps. Some steps may be irrelevant
because of input supply limitations or load operation.
100
Brownout offset = 0.100V
111
Brownout offset = 0.175V
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2468
NXP Semiconductors

<!-- page 2469 -->

39.6.8
Low Power Control Register (PMU_LOWPWR_CTRLn)
This register defines the low power configuration bits.
Address: 20C_8000h base + 270h offset + (4d × i), where i=0d to 3d
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
Reserved
0
MIX_PWRGATE
XTALOSC_PWRUP_STAT
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
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2469

<!-- page 2470 -->

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
XTALOSC_
PWRUP_
DELAY
RCOSC_CG_OVERRIDE
-
DISPLAY_PWRGATE
CPU_PWRGATE
L2_PWRGATE
L1_PWRGATE
REFTOP_IBIAS_OFF
LPBG_TEST
LPBG_SEL
OSC_SEL
RC_OSC_PROG
RC_OSC_EN
W
Reset
0
1
0
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
0
0
1
PMU_LOWPWR_CTRLn field descriptions
Field
Description
31–19
-
This field is reserved.
18
Reserved
This read-only field is reserved and always has the value 0.
17
MIX_PWRGATE
Display power gate control. Used as software mask. Set to zero to force ungated.
16
XTALOSC_
PWRUP_STAT
Status of the 24MHz xtal oscillator.
NOTE: Not related to PMU.
0
Not stable
1
Stable and ready to use
15–14
XTALOSC_
PWRUP_DELAY
Specifies the time delay between when the 24MHz xtal is powered up until it is stable and ready to use.
NOTE: Not related to PMU.
00
0.25ms
01
0.5ms
10
1ms
11
2ms
13
RCOSC_CG_
OVERRIDE
For debug purposes only. This bit effects clock gating of certain digital logic clocked by the 24MHz clk.
NOTE: Not related to PMU.
12
-
Reserved
Table continues on the next page...
PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2470
NXP Semiconductors

<!-- page 2471 -->

PMU_LOWPWR_CTRLn field descriptions (continued)
Field
Description
11
DISPLAY_
PWRGATE
Display logic power gate control. Used as software override.
10
CPU_PWRGATE CPU power gate control. Used as software override.
Attention: Test purpose only
9
L2_PWRGATE
L2 power gate control. Used as software override.
8
L1_PWRGATE
L1 power gate control. Used as software override.
7
REFTOP_IBIAS_
OFF
Low power reftop ibias disable.
6
LPBG_TEST
Low power bandgap test bit.
5
LPBG_SEL
Bandgap select.
0
Normal power bandgap
1
Low power bandgap
4
OSC_SEL
Select the source for the 24MHz clock.
NOTE: Not related to PMU.
0
XTAL OSC
1
RC OSC
3–1
RC_OSC_PROG RC osc. tuning values.
NOTE: Not related to PMU.
0
RC_OSC_EN
RC Osc. enable control.
NOTE: Not related to PMU.
0
Use XTAL OSC to source the 24MHz clock
1
Use RC OSC
Chapter 39 Power Management Unit (PMU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2471

<!-- page 2472 -->

PMU Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2472
NXP Semiconductors

