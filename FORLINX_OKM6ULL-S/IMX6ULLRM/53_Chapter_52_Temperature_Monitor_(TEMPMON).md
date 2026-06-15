# Chapter 52: Temperature Monitor (TEMPMON)

> Nguồn: `IMX6ULLRM.pdf` — trang 3529–3536

<!-- page 3529 -->

Chapter 52
Temperature Monitor (TEMPMON)
52.1
Overview
The temperature sensor module implements a temperature sensor/conversion function
based on a temperature-dependent voltage to time conversion.
The module features alarm functions that can raise independent interrupt signals if the
temperature is above two high-temperature thresholds and below a low temperature
threshold. These temperature thresholds are programmable and designated as low, high
and panic temperature. The panic threshold is a special programmable threshold in that if
the temperature increases above this value and the temperature-panic-reset interrupt is
enabled in the System Reset Controller, the hardware will assume that software no longer
has control over the thermal situation and will initiate a reset of the chip.
In order to avoid false panic temperature initiated resets, the panic alarm will not fire
until the temperature panic condition has been met for four consecutive conversion
cycles. A self-repeating mode can also be programmed which executes a temperature
sensing operation based on a programmed delay.
Since the high and low temperature thresholds are programmable, they form a sliding
temperature bracket that can be tailored to the application’s needs. For example, at start-
up software can set the low temperature threshold to the minimum temperature code and
the high temperature threshold to a maximum operating temperature for the system.
The system can then use this module to monitor the on-die temperature and take
appropriate actions such as throttling back the core frequency when a the high
temperature interrupt is set. Once the high temperature interrupt is set then the system can
program the low temperature threshold to a desired cool down temperature. The system
would then switch to monitoring the low temperature alarm and wait for its interrupt to
be set. With this scheme, once the low temperature interrupt is set then software could be
assured that the temperature has cooled down to a safe level and the process could be
repeated.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3529

<!-- page 3530 -->

The high-level implementation of the temperature sensor is shown in the figure below.
Comparators
Core Temp Sensor
Programmable
Divider
Low-Threshold
480MHz 
(USB1_PLL)
Measure_Freq
32KHz
Determines 
Measurement Frequency
tstart
Low-Alarm: Counter < Low-Threshold
TEMP_CNT
valid
VBG
High-Alarm: Counter > Low-Threshold
Panic-Alarm: Counter > Panic-Threshold
High-Threshold
Panic-Threshold
Figure 52-1. High Level Temp Sensor System Diagram
As shown in the figure above, the temperature sensor uses and assumes that the bandgap
reference, 480MHz PLL and 32KHz RTC modules are properly programmed and fully
settled for correct operation.
52.2
Software Usage Guidelines
During normal system operation software can use the temperature sensor counter output
(TEMP_CNT) in conjunction with the fused temperature calibration data to determine the
on-die operational temperature or to set an over-temperature interrupt alarm to within a
couple of °C.
Based on calibration, two sets of temperature and counter values will be available via
fuses on the device. These data points will correspond to the points (N1, T1) and (N2, T2)
in the curve below.
Software Usage Guidelines
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3530
NXP Semiconductors

<!-- page 3531 -->

Temperature
TEMP_CNT
T1
T2
Tmeas
N1
N2
Nmeas
Figure 52-2. Temperature Measurement Cycle
After a temperature measurement cycle, software should use the calibration points in
conjunction with the temperature code value in the
TEMPMON_TEMPSENSE0[TEMP_CNT] bitfield to calculate the temperature for the
device using the following equation:
Tmeas = T2 - (Nmeas - N2) * ((T2 – T1) / (N1 – N2))
Likewise, to determine the alarm counter value to be written in the
TEMPMON_TEMPSENSE0 register for a temperature based interrupt, the above
equation can be solved for the Nmeas value that should be used based on the desired
temperature trigger.
The temperature calibration point fuse values are available in the OCOTP_ANA1
register. The temperature calibration values are fused individually for each part in the
product testing process. The fields of this register are described in the following table.
Table 52-1. OCOTP_ANA1 Temperature Sensor Calibration Data
Bit Range
Bit Mask
Name
Description
[31:20]
FFF0_0000h
ROOM_COUNT
Value of TEMPMON_TEMPSENSE0[TEMP_VALUE] after a
measurement cycle at room temperature (25.0 °C).
[19:8]
000F_FF00h
HOT_COUNT
Value of TEMPMON_TEMPSENSE0[TEMP_VALUE] after a
measurement cycle at the hot temperature, i.e. HOT_TEMP.
[7:0]
0000_00FFh
HOT_TEMP
The hot temperature test point. Each LSB equals 1 °C.
The points on the calibration curve are as follows.
• (N1, T1) = (ROOM_COUNT, 25.0)
Chapter 52 Temperature Monitor (TEMPMON)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3531

<!-- page 3532 -->

• (N2, T2) = (HOT_COUNT, HOT_TEMP)
• (Nmeas, Tmeas) = (TEMP_CNT, Tmeas)
Substituting the fields from OCOTP_ANA1 into the earlier equation results in the
following:
Tmeas = HOT_TEMP - (Nmeas - HOT_COUNT) * ((HOT_TEMP - 25.0) /
(ROOM_COUNT – HOT_COUNT))
52.3
TEMPMON Memory Map/Register Definition
TEMPMON memory map
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
20C_8180
Tempsensor Control Register 0
(TEMPMON_TEMPSENSE0)
32
R/W
0000_0001h
52.3.1/3533
20C_8184
Tempsensor Control Register 0
(TEMPMON_TEMPSENSE0_SET)
32
R/W
0000_0001h
52.3.1/3533
20C_8188
Tempsensor Control Register 0
(TEMPMON_TEMPSENSE0_CLR)
32
R/W
0000_0001h
52.3.1/3533
20C_818C
Tempsensor Control Register 0
(TEMPMON_TEMPSENSE0_TOG)
32
R/W
0000_0001h
52.3.1/3533
20C_8190
Tempsensor Control Register 1
(TEMPMON_TEMPSENSE1)
32
R/W
0000_0001h
52.3.2/3535
20C_8194
Tempsensor Control Register 1
(TEMPMON_TEMPSENSE1_SET)
32
R/W
0000_0001h
52.3.2/3535
20C_8198
Tempsensor Control Register 1
(TEMPMON_TEMPSENSE1_CLR)
32
R/W
0000_0001h
52.3.2/3535
20C_819C
Tempsensor Control Register 1
(TEMPMON_TEMPSENSE1_TOG)
32
R/W
0000_0001h
52.3.2/3535
20C_8290
Tempsensor Control Register 2
(TEMPMON_TEMPSENSE2)
32
R/W
0000_0000h
52.3.3/3536
20C_8294
Tempsensor Control Register 2
(TEMPMON_TEMPSENSE2_SET)
32
R/W
0000_0000h
52.3.3/3536
20C_8298
Tempsensor Control Register 2
(TEMPMON_TEMPSENSE2_CLR)
32
R/W
0000_0000h
52.3.3/3536
20C_829C
Tempsensor Control Register 2
(TEMPMON_TEMPSENSE2_TOG)
32
R/W
0000_0000h
52.3.3/3536
TEMPMON Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3532
NXP Semiconductors

<!-- page 3533 -->

52.3.1
Tempsensor Control Register 0
(TEMPMON_TEMPSENSE0n)
This register defines the basic controls for the temperature sensor minus the frequency of
automatic sampling which is defined in the tempsensor.
Address: 20C_8000h base + 180h offset + (4d × i), where i=0d to 3d
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
ALARM_VALUE
TEMP_CNT
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
Chapter 52 Temperature Monitor (TEMPMON)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3533

<!-- page 3534 -->

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
TEMP_CNT
Reserved
Reserved
Reserved
FINISHED
MEASURE_TEMP
POWER_DOWN
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
1
TEMPMON_TEMPSENSE0n field descriptions
Field
Description
31–20
ALARM_VALUE
This bit field contains the temperature count (raw sensor output) that will generate an alarm interrupt.
19–8
TEMP_CNT
This bit field contains the last measured temperature count.
7
-
This field is reserved.
Reserved.
6
-
This field is reserved.
Reserved.
5–3
-
This field is reserved.
Reserved
2
FINISHED
Indicates that the latest temp is valid. This bit should be cleared by the sensor after the start of each
measurement.
0
INVALID — Last measurement is not ready yet.
1
VALID — Last measurement is valid.
1
MEASURE_
TEMP
Starts the measurement process. If the measurement frequency is zero in the TEMPSENSE1 register, this
results in a single conversion.
Table continues on the next page...
TEMPMON Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3534
NXP Semiconductors

<!-- page 3535 -->

TEMPMON_TEMPSENSE0n field descriptions (continued)
Field
Description
0
STOP — Do not start the measurement process.
1
START — Start the measurement process.
0
POWER_DOWN
This bit powers down the temperature sensor.
0
POWER_UP — Enable power to the temperature sensor.
1
POWER_DOWN — Power down the temperature sensor.
52.3.2
Tempsensor Control Register 1
(TEMPMON_TEMPSENSE1n)
This register defines the automatic repeat time of the temperature sensor.
Address: 20C_8000h base + 190h offset + (4d × i), where i=0d to 3d
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
MEASURE_FREQ
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
1
TEMPMON_TEMPSENSE1n field descriptions
Field
Description
31–16
-
This field is reserved.
Reserved.
MEASURE_
FREQ
This bits determines how many RTC clocks to wait before automatically repeating a temperature
measurement. The pause time before remeasuring is the field value multiplied by the RTC period.
0x0000
Defines a single measurement with no repeat.
0x0001
Updates the temperature value at a RTC clock rate.
0x0002
Updates the temperature value at a RTC/2 clock rate.
. . .
—
0xFFFF
Determines a two second sample period with a 32.768KHz RTC clock. Exact timings depend
on the accuracy of the RTC clock.
Chapter 52 Temperature Monitor (TEMPMON)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3535

<!-- page 3536 -->

52.3.3
Tempsensor Control Register 2
(TEMPMON_TEMPSENSE2n)
This register defines the automatic repeat time of the temperature sensor.
Address: 20C_8000h base + 290h offset + (4d × i), where i=0d to 3d
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
PANIC_ALARM_VALUE
Reserved
LOW_ALARM_VALUE
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
TEMPMON_TEMPSENSE2n field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved
27–16
PANIC_ALARM_
VALUE
This bit field contains the temperature that will generate a panic interrupt when exceeded by the
temperature measurement.
15–12
-
This field is reserved.
Reserved.
LOW_ALARM_
VALUE
This bit field contains the temperature that will generate a low alarm interrupt when the field is greater than
the temperature measurement.
TEMPMON Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3536
NXP Semiconductors

