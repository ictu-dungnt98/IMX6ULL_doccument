# Chapter 13: Analog-to-Digital Converter (ADC)

> Nguồn: `IMX6ULLRM.pdf` — trang 391–442

<!-- page 391 -->

Chapter 13
Analog-to-Digital Converter (ADC)
13.1
Overview
The analog-to-digital converter (ADC) is a successive approximation ADC designed for
operation within an integrated microcontroller system-on-chip.
13.1.1
Features
The features of the ADC are as follows:
• Configuration registers
• 32-bit, word aligned, byte enabled registers. (byte and halfword access is not
supported)
• Linear successive approximation algorithm with up to 12-bit resolution with 10/11
bit accuracy.
• Up to 10 ENOB (dedicated single ended channels)
• Up to 1MS/s sampling rate
• Up to 8 single-ended external analog inputs
• Single or continuous conversion (automatic return to idle after single conversion)
• Output Modes: (in right-justified unsigned format)
• 12-bit
• 10-bit
• 8-bit
• Configurable sample time and conversion speed/power
• Conversion complete and hardware average complete flag and interrupt
• Input clock selectable from up to three sources
• Asynchronous clock source for lower noise operation with option to output the clock
• Automatic compare with interrupt for less-than, greater-than or equal-to, within
range, or out-of-range, programmable value
• Operation in low power modes for lower noise operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
391

<!-- page 392 -->

• Hardware average function
• Self-calibration mode
13.1.2
ADC I/F block diagram
The following diagram represents the ADC I/F block.
DUT
Configuration Registers
Analog Hard Block
ADC
Conversion Complete
CLK
async_clk
Calibration
 
Selection
SAR DATA PROCESSING UNIT
External Pin 
Control
SAR Controller
Compare Logic
Sample &
Conversion
Controls
Formatting
Averaging
Converted Data
External Channel
Control
Bus Access I/F
and Interrupt bits
Output clocks
Figure 13-1. ADC I/F block diagram
13.1.3
ADC block diagram
The following figure shows a top-level block diagram of the ADC module.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
392
NXP Semiconductors

<!-- page 393 -->

ADC1_IN0
ADC2_IN3
COCOn
Control Sequencer
Clock 
Divide
ADCK
Async 
Clock Gen
IPG Clock
ALTCLK
ADICLK
ADIV
ADACK
ADLPC/ADHSC
complete
SAR Converter
CV2
ADC_HCn[AIEN]
trigger
MCU STOP 
ADHWT
ACFE
1
Compare true
A C FG T, A C R E N
ADC_VREFH
ADC_VREFL
A D V IN P
ADACKEN
ADC_CV
ADC_CAL 
Calibration
CAL
D
CALF
ADC_CFG
MODE
ADC_GC
ADCO
Conversion
Hardware Trigger Control Reg[0]
ADHWTS0
ADHWTSn
Trigger 
Control
ADTRG
transfer
ADC_Rn
ADC_R0
Hardware Trigger Control
Reg[n-1]
Analog 
SAR control 
comparator 
Digital 
SAR FSM
Analog
Block
Legend:
abort
Interrupt
Compare true
Control Registers (ADC_GC, ADC_CFG)
ADC_HCn[ADCH]
MODE
ADLSMP/ADSTS
initialize
sample
convert
transfer
AVGE, AVGS
CAL
CV1
Compare
Logic
1
2
Averager
Offset Processing
ADC_OFS
ADC_GC
Formatting
ADC1_IN1
Figure 13-2. ADC block diagram
NOTE
ADC_VREFL is shorted to ground internally, no dedicate ball
for this signal.
13.1.4
ADC module interface
The ADC is connected to many interfaces such as the clocks and reset, access bus,
voltage references, interrupt controller, ADC pin control, and analog I/F as shown in the
following figure.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
393

<!-- page 394 -->

ADC
Interrupt Controller
External Pin Control
DMA I/F
Bus Access I/F
Analog I/F
Clocks & Reset
Voltage References
COCO I/F
(conversion complete)
Figure 13-3. ADC module interface
13.1.5
Modes of Operation
By default, the ADC is in disabled mode. In this state, no conversion or other actions
occur. All of the ADC control registers are accessible in this state through an access bus
interface.To enable the ADC, required configurations should be done by programming
the ADC configuration registers.
13.2
External Signals
The following table describes the external signals of ADC:
Table 13-1. ADC External Signals
Signal
Description
Pad
Mode
Direction
ADC_VREFH
Voltage reference high
ADC_VREFH
-
I
ADC1_IN0
Analog channel 1 input 0
GPIO1_IO00
-
I
ADC1_IN1
Analog channel 1 input 1
GPIO1_IO01
-
I
ADC1_IN2
Analog channel 1 input 2
GPIO1_IO02
-
I
ADC1_IN3
Analog channel 1 input 3
GPIO1_IO03
-
I
ADC1_IN4
Analog channel 1 input 4
GPIO1_IO04
-
I
ADC1_IN5
Analog channel 1 input 5
GPIO1_IO05
-
I
ADC1_IN6
Analog channel 1 input 6
GPIO1_IO06
-
I
ADC1_IN7
Analog channel 1 input 7
GPIO1_IO07
-
I
ADC1_IN8
Analog channel 1 input 8
GPIO1_IO08
-
I
ADC1_IN9
Analog channel 1 input 9
GPIO1_IO09
-
I
ADC2_IN0
Analog channel 2 input 0
GPIO1_IO00
-
I
ADC2_IN1
Analog channel 2 input 1
GPIO1_IO01
-
I
ADC2_IN2
Analog channel 2 input 2
GPIO1_IO02
-
I
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
394
NXP Semiconductors

<!-- page 395 -->

Table 13-1. ADC External Signals (continued)
Signal
Description
Pad
Mode
Direction
ADC2_IN3
Analog channel 2 input 3
GPIO1_IO03
-
I
ADC2_IN4
Analog channel 2 input 4
GPIO1_IO04
-
I
ADC2_IN5
Analog channel 2 input 5
GPIO1_IO05
-
I
ADC2_IN6
Analog channel 2 input 6
GPIO1_IO06
-
I
ADC2_IN7
Analog channel 2 input 7
GPIO1_IO07
-
I
ADC2_IN8
Analog channel 2 input 8
GPIO1_IO08
-
I
ADC2_IN9
Analog channel 2 input 9
GPIO1_IO09
-
I
Signal
Description
Pad
Mode
Direction
ADC 1_IN0
Analog channel 1 input
0
GPIO_AD_B1_11
-
I
ADC1_IN1
Analog channel 1 input
1
GPIO_AD_B0_12
-
I
ADC1_IN2
Analog channel 1 input
2
GPIO_AD_B0_13
-
I
ADC1_IN3
Analog channel 1 input
3
GPIO_AD_B0_14
-
I
ADC1_IN4
Analog channel 1 input
4
GPIO_AD_B0_15
-
I
ADC1_IN5
Analog channel 1 input
5
GPIO_AD_B1_00
-
I
ADC1_IN6
Analog channel 1 input
6
GPIO_AD_B1_01
-
I
ADC1_IN7
Analog channel 1 input
7
GPIO_AD_B1_02
-
I
ADC1_IN8
Analog channel 1 input
8
GPIO_AD_B1_03
-
I
ADC1_IN9
Analog channel 1 input
9
GPIO_AD_B1_04
-
I
ADC1_IN10
Analog channel 1 input
10
GPIO_AD_B1_05
-
I
ADC1_IN11
Analog channel 1 input
11
GPIO_AD_B1_06
-
I
ADC1_IN12
Analog channel 1 input
12
GPIO_AD_B1_07
-
I
ADC1_IN13
Analog channel 1 input
13
GPIO_AD_B1_08
-
I
ADC1_IN14
Analog channel 1 input
14
GPIO_AD_B1_09
-
I
ADC1_IN15
Analog channel 1 input
15
GPIO_AD_B1_10
-
I
ADC 2_IN0
Analog channel 2 input
0
GPIO_AD_B1_11
-
I
Table continues on the next page...
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
395

<!-- page 396 -->

ADC2_IN1
Analog channel 2 input
1
GPIO_AD_B1_12
-
I
ADC2_IN2
Analog channel 2 input
2
GPIO_AD_B1_13
-
I
ADC2_IN3
Analog channel 2 input
3
GPIO_AD_B1_14
-
I
ADC2_IN4
Analog channel 2 input
4
GPIO_AD_B1_15
-
I
ADC2_IN5
Analog channel 2 input
5
GPIO_AD_B1_00
-
I
ADC2_IN6
Analog channel 2 input
6
GPIO_AD_B1_01
-
I
ADC2_IN7
Analog channel 2 input
7
GPIO_AD_B1_02
-
I
ADC2_IN8
Analog channel 2 input
8
GPIO_AD_B1_03
-
I
ADC2_IN9
Analog channel 2 input
9
GPIO_AD_B1_04
-
I
ADC2_IN10
Analog channel 2 input
10
GPIO_AD_B1_05
-
I
ADC2_IN11
Analog channel 2 input
11
GPIO_AD_B1_06
-
I
ADC2_IN12
Analog channel 2 input
12
GPIO_AD_B1_07
-
I
ADC2_IN13
Analog channel 2 input
13
GPIO_AD_B1_08
-
I
ADC2_IN14
Analog channel 2 input
14
GPIO_AD_B1_09
-
I
ADC2_IN15
Analog channel 2 input
15
GPIO_AD_B1_10
-
I
NOTE
The ADC input signals connect to GPIO[0:9]. The GPIO
default configuration is enabled for keeper. The keeper causes
an undesired jump behavior in ADC. To avoid the problem,
disable keeper before starting ADC. For detailed information
about keeper, refer to the GPIO block.
13.3
Functional Description
There are three possible states which ADC module can be in:
1. Disabled State
2. Idle state
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
396
NXP Semiconductors

<!-- page 397 -->

3. Performing conversions
Disabled State:
The ADC module is disabled during reset or stop mode (if internal clock is not
selected as source of clock).
Idle State:
The module is idle when a conversion has completed and another conversion has not
been initiated. When idle and the asynchronous clock output enable is disabled
(ADACKEN = 0), the module is in its lowest power state.
Conversion State:
The ADC can perform an analog-to-digital conversion on any of the software
selectable channels. All modes perform conversion by a successive approximation
algorithm.
To meet accuracy specifications the ADC module must be calibrated using the on chip
calibration function. Calibration is recommended to be done after any reset.
When the conversion is completed, the result is placed in the data result registers
(ADC_Rn). The conversion complete flag (COCOn) field in the Hardware Status register
is/are then set and an interrupt is generated, if the respective conversion complete
interrupt has been enabled (ADC_HCn[AIEN]=1).
The ADC module has the capability of automatically comparing the result of a
conversion with the contents of the compare value registers. The compare function is
enabled by setting ACFE (ADC Compare Function Enable) in the ADC general control
register.
The ADC module has the capability of automatically averaging the result of multiple
conversions. The hardware average function is enabled by setting AVGE in the ADC
general control register.
13.3.1
Clock Select and Divide Control
The ADC digital module has two clock sources:
• IPG clock
• Internal clock (ADACK) is a dedicated clock used only by the ADC.
ADC digital block generates IPG clock/2 by internally dividing the IPG clock. The final
clock is chosen from the following clocks.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
397

<!-- page 398 -->

• IPG clock
• IPG clock divided by 2
• ADACK
From the three clocks listed above, one is chosen depending on the configuration of
ADICLK[1:0] bits of ADC_CFG. This chosen clock is divided depending on the
configuration of ADIV[1:0] bits of ADC_CFG. The final generated clock is used as
conversion clock for ADC.
ADICLK
Selected Clock Source
00
IPG clock
01
IPG clock divided by 2
10
Reserved
11
Asynchronous clock (ADACK)
• The IPG clock. This is the default selection following reset.
• The IPG clock divided by two. For higher IPG clock rates, this allows a maximum
divide by 16 of the IPG clock using the ADIV bits.
• The asynchronous clock (ADACK). This clock is generated from a clock source
within the ADC module. Conversions are possible using ADACK as the input clock
source while the MCU is in stop mode.
Whichever clock is selected, its frequency must fall within the specified frequency range
for ADCK. If the available clocks are too slow, the ADC may not perform according to
specifications. If the available clocks are too fast, the clock must be divided to the
appropriate frequency. This divider is specified by the ADIV bits and can be divide-by 1,
2, 4, or 8.
13.3.2
Voltage Reference Selection
The ADC can be configured to use reference pairs as the reference voltages used for
conversions (VREFSH and VREFSL). Each pair contains a positive reference which must be
between the minimum Ref Voltage High and VDDAD, and a ground reference which must
be at the same potential as VSSAD. The pairs can be as follows:
• External (VREFH and VREFL)
These voltage references are selected by configuring ADC_CFG[REFSEL].
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
398
NXP Semiconductors

<!-- page 399 -->

13.3.3
Conversion Control
Conversions are performed as determined by ADC_CFG[MODE] field.
Conversions are initiated by a software trigger. In addition, the ADC can be configured
for low power operation, long sample time, continuous conversion, hardware average,
and automatic comparison of conversion results with predetermined values.
13.3.3.1
Initiating Conversions
A conversion is initiated:
• Following a write to ADC_HC0 when a software triggered operation is selected
(ADTRG=0).
• Following the transfer of the result to the data registers when continuous conversion
is enabled (ADCO=1 in ADC_GC register).
If continuous conversion is enabled, a new conversion is automatically initiated after the
completion of the current conversion. In software triggered operation (ADTRG=0),
continuous conversions begin after ADC_HC0 is written and continue until aborted.
If hardware averaging is enabled, a new conversion is automatically initiated after the
completion of the current conversion until the correct number of conversions is
completed. In software triggered operation, conversions begin after ADC_HC0 is written.
If continuous conversions is also enabled, a new set of conversions to be averaged are
initiated following the last of the selected number of conversions.
13.3.3.2
Completing Conversions
A conversion is completed when the result of the conversion is transferred into the data
result registers. (provided the compare function & hardware averaging is disabled), this is
indicated by the setting of COCOn. If hardware averaging is enabled, COCOn sets only,
if the last of the selected number of conversions is complete. If the compare function is
enabled, COCOn sets and conversion result data is transferred only if the compare
condition is true. If both hardware averaging and compare functions are enabled, then
COCOn sets only if the last of the selected number of conversions is complete and the
compare condition is true. An interrupt is generated, if ADC_HCn[AIEN] is high at the
time that COCOn is set and if DMAEN is set, DMA request is asserted, if COCOn is set.
Both the requests get deasserted when COCOn is low, cleared, which happens when data
is read.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
399

<!-- page 400 -->

In all modes a blocking mechanism prevents a new result from overwriting previous data
in ADC_Rn, if the previous data is in the process of being read. When blocking is active
(OVWREN=0 in ADC_CFG), the conversion result data transfer is blocked, COCOn is
not set, and the new result is lost. In all other cases of operation, when a conversion result
data transfer is blocked, another conversion is initiated regardless of the state of ADCO
(single or continuous conversions enabled).
Note
If continuous conversions are enabled, the blocking mechanism
could result in the loss of data occurring at specific timepoints.
To avoid this issue, the data must be read in fewer cycles than
an ADC conversion time, accounting for interrupt or software
polling loop latency.
If single conversions are enabled, the blocking mechanism
could result in several discarded conversions and excess power
consumption. To avoid this issue, the data registers must not be
read after initiating a single conversion until the conversion
completes.
13.3.3.3
Aborting Conversions
Any conversion in progress is aborted when:
• The MCU enters stop mode with ADACK not enabled.
• In software trigger mode, write to ADC_HC0 register, while ADC_HC0 is actively
(already) controlling a conversion, aborts the current conversion.
• A write to any ADC register other than the ADC_HC0 register occurs. This indicates
a mode of operation change has occurred and the current conversion is therefore
invalid.
Note
When a conversion is aborted, the contents of the data result
registers, ADCRn are not altered. The data result registers
continue to hold the values, transferred after the completion of
the last successful conversion. If the conversion is aborted by a
reset or stop (not operated with internal ADACK), ADCRn
(data result register) return to their reset states.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
400
NXP Semiconductors

<!-- page 401 -->

13.3.3.4
Power Control
The ADC module remains in its idle state until a conversion is initiated. If ADACK is
selected as the conversion clock source but the asynchronous clock output is disabled
(ADACKEN=0), the ADACK clock generator will also remain in its idle state (disabled)
until a conversion is initiated. If the asynchronous clock output is enabled
(ADACKEN=1), it will remain active regardless of the state of the ADC or the MCU
power mode.
Power consumption when the ADC is active can be reduced by setting ADLPC.
13.3.3.5
Sample Time and Total Conversion Time
The total conversion time depends upon the following:
• the sample phase time (as determined by ADLSMP and ADSTS bits in ADC_CFG
register),
• the compare phase time (determined by MODE bits)
• the frequency of the conversion clock (fADCK).
• the MCU bus frequency (for Handshaking and selection of clock)
Sample Phase time
(in adc clock cycle)
(in adc clock cycle)
Base conversion time 
controlled by 
ADLSMP & ADSTS 
controlled by MODE (8/10/12 bit)
Trigger arrives to ADC
Coco bit set at external signal
[Single or First Continuous Time Adder 
(SFCAdder)]
Domain Handshaking time
between MCU & ADC
Total Conversion time (in adc clock cycle)
Compare Phase time
Figure 13-4. ADC conversion time details
After the module becomes active, sampling of the input begins. ADLSMP and ADSTS
decide the sample time duration. When sampling is complete, the converter is isolated
from the input channel and a successive approximation algorithm is performed to
determine the digital value of the analog signal. The result of the conversion is
transferred to ADC_Rn upon completion of the conversion algorithm.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
401

<!-- page 402 -->

If the bus frequency is less than the fADCK frequency, precise sample time for continuous
conversions cannot be guaranteed .
The maximum total conversion time is determined by the clock source chosen and the
divide ratio selected. The clock source is selectable by the ADICLK bits in ADC_CFG
register, and the divide ratio is specified by the ADIV bits.
The maximum total conversion time for all configurations is summarized in Equation 1
on page 402. Refer to Table 13-2 through Table 13-5 for the variables referenced in the
equation.
Equation 1. Equation of Conversion Time
Table 13-2. Single or First Continuous Time Adder (SFCAdder)
ADACKEN
ADICLK
Single or First Continuous Time Adder (SFCAdder)
x
0x, 10
3 ADCK cycles (before starting of conversion) +
1ADCK (after end of conversion) +
2 bus clock cycles
1
11
3 ADCK cycles (before starting of conversion) +
1 ADCK (after end of conversion) +
2 bus clock cycles
                            
0
11
1.5µs +
3 ADCK cycles (before starting of conversion) +
1 ADCK (after end of conversion) +
2 bus clock cycles
Table 13-3. Average Number Factor (AverageNum)
AVGE
AVGS[1:0]
Average Number Factor (AverageNum)
0
xx
1
1
00
4
1
01
8
1
10
16
1
11
32
Table 13-4. Base Conversion Time (BCT) (compare phase duration)
Mode
Base Conversion Time (BCT) (compare phase duration)
8 bit
17 ADCK cycles
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
402
NXP Semiconductors

<!-- page 403 -->

Table 13-4. Base Conversion Time (BCT) (compare phase duration) (continued)
Mode
Base Conversion Time (BCT) (compare phase duration)
10 bit
21 ADCK cycles
12 bit
25 ADCK cycles
Table 13-5. Long Sample Time
ADLSMP
ADSTS
Long Sample Time Adder (LSTAdder)
0
00
3 ADCK cycles
0
01
5 ADCK cycles
0
10
7 ADCK cycles (default)
0
11
9 ADCK cycles
1
00
13 ADCK cycles
1
01
17 ADCK cycles
1
10
21 ADCK cycles
1
11
25 ADCK cycles
Note
The ADCK frequency must be between fADCK minimum and
fADCK maximum to meet ADC specifications.
13.3.3.6
Conversion Time Examples
The following examples uses Equation 1 on page 402 and the information provided in
tables Table 13-2 through Table 13-5.
13.3.3.6.1
Typical conversion time configuration
A typical configuration for ADC conversion is: 10-bit mode, with the bus clock selected
as the input clock source, the input clock divide-by-1 ratio selected, and a bus frequency
of 40 MHz, ADLSMP=0,ADLSTS=10 and high speed conversion disabled. The
conversion time for a single conversion is calculated by using Equation 1 on page 402
and the information provided in Table 13-6 through Table 13-8. The table below list the
variables of Equation 1 on page 402.
Table 13-6. Typical Conversion Time
Variable
Time
SFCAdder
5 ADCK cycles + 5 bus clock cycles
AverageNum
1
Table continues on the next page...
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
403

<!-- page 404 -->

Table 13-6. Typical Conversion Time (continued)
Variable
Time
BCT
21 ADCK cycles
LSTAdder
7
The resulting conversion time is generated using the parameters listed in Table 13-6. So
for Bus clock equal to 40 Mhz and ADCK equal to 40 Mhz the resulting conversion time
is 0.95 us.
13.3.3.6.2
Long conversion time configuration
A configuration for long ADC conversion is: 12-bit mode, with the bus clock selected as
the input clock source, the input clock divide-by-8 ratio selected, and a bus frequency of
40 MHz, long sample time enabled (ADLSMP=1, ADSTS=11) and configured for
longest adder and high speed conversion disabled. Average enabled for 32 conversions
(AVGE=1, AVGS=11). The conversion time for this conversion is calculated by using
equation on Sample Time and Total Conversion Time and the information provided in
Table 13-2 through Table 13-5. The table below lists the variables of equation.
Table 13-7. Typical Conversion Time
Variable
Time
SFCAdder
3 ADCK cycles + 5 bus clock cycles
AverageNum
32
BCT
25 ADCK cycles
LSTAdder
25 ADCK cycles
The resulting conversion time is generated using the parameters listed in Table 13-7. So
for Bus clock equal to 40 Mhz and ADCK equal to 5 Mhz the resulting conversion time
is 10.0226 us (AverageNum). This results in a total conversion time of 320.725 us.
13.3.3.6.3
Short conversion time configuration
A configuration for short ADC conversion is: 8-bit mode, with the bus clock selected as
the input clock source, the input clock divide-by-1 ratio selected, and a bus frequency of
40 MHz, long sample time disabled(ADLSMP=0, ADSTS=00) and high speed
conversion enabled. The conversion time for this conversion is calculated by using the
equation and the information provided in Table 13-2 to Table 13-5. The table below list
the variables of equation.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
404
NXP Semiconductors

<!-- page 405 -->

Table 13-8. Typical Conversion Time
Variable
Time
SFCAdder
3 ADCK cycles + 5 bus clock cycles
AverageNum
1
BCT
17 ADCK cycles
LSTAdder
3 ADCK cycles
The resulting conversion time is generated using the parameters listed in Table 13-8. So
for Bus clock equal to 40Mhz and ADCK equal to 40Mhz the resulting conversion time
is 700 ns.
13.3.3.7
Hardware Average Function
The hardware average function can be enabled (AVGE=1) to perform a hardware average
of multiple conversions. The number of conversions is determined by the AVGS[1:0]
bits, which select 4, 8, 16 or 32 conversions to be averaged. While the hardware average
function is in progress the ADACT bit will be set.
After the selected input is sampled and converted, the result is placed in an accumulator
from which an average is calculated once the selected number of conversions has been
completed. When hardware averaging is selected the completion of a single conversion
will not set the COCOn bit.
If the compare function is either disabled or evaluates true, after the selected number of
conversions are completed, the average conversion result is transferred into the data
result registers, ADC_Rn , and the COCOn bit is set. An ADC interrupt is generated upon
the setting of COCOn if the respective ADC interrupt is enabled (AIENn=1).
13.3.4
Automatic Compare Function
The compare function can be configured to check if the result is less than or greater-than-
or-equal-to a single compare value, or if the result falls within or outside a range
determined by two compare values. The compare mode is determined by ACFGT,
ACREN and the values in the compare value register (ADC_CV). After the input is
sampled and converted, the compare values (CV1 and CV2) are used as described in the
table below. There are six compare modes as shown in the table below.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
405

<!-- page 406 -->

Table 13-9. Compare Modes
ACFGT
ACREN
CV1 relative to
CV2
Function
Compare Mode Description
0
0
-
Less than threshold
Compare true if the result is less than the CV1 registers.
1
0
-
Greater than or equal to
threshold
Compare true if the result is greater than or equal to CV1
registers.
0
1
Less than or
equal
Outside range, not inclusive
Compare true if the result is less than CV1 Or the result is
Greater than CV2
0
1
Greater than
Inside range, not inclusive
Compare true if the result is less than CV1 And the result is
greater than CV2
1
1
Less Than or
equal
Inside range, inclusive
Compare true if the result is greater than or equal to CV1 And
the result is less than or equal to CV2
1
1
Greater than
Outside range, inclusive
Compare true if the result is greater than or equal to CV1 Or
the result is less than or equal to CV2
With the ADC range enable bit set, ADCREN =1, if compare value 1(CV1 value) is less
than or equal to the compare value 2 (CV2 value), setting ACFGT will select a trigger-if-
inside-compare-range, inclusive-of-endpoints function. Clearing ACFGT will select a
trigger-if-outside-compare-range, not-inclusive-of-endpoints function.
If CV1 is greater than the CV2, setting ACFGT will select a trigger-if-outside-compare-
range, inclusive-of-endpoints function. Clearing ACFGT will select a trigger-if-inside-
compare-range, not-inclusive-of-endpoints function.
If the condition selected evaluates true, COCOn is set.
Upon completion of a conversion while the compare function is enabled, if the compare
condition is not true, COCOn is not set and the conversion result data will not be
transferred to the result register. If the hardware averaging function is enabled, the
compare function compares the averaged result to the compare values. The same compare
function definitions apply. An ADC interrupt is generated upon the setting of COCOn if
the respective ADC interrupt is enabled (ADC_HCn[AIEN]=1).
Note
The compare function can monitor the voltage on a channel
while the MCU is in wait or stop3 mode. The ADC interrupt
wakes the MCU when the compare condition is met.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
406
NXP Semiconductors

<!-- page 407 -->

13.3.5
Calibration Function
The ADC contains a self-calibration function that is required to achieve the specified
accuracy. Calibration should be run or valid calibration values should be written after
power up and system reset (as the calibration register will be reset on reset assertion) with
specified settings before any conversion is initiated. The calibration function sets the
calibration value at the end of running the full calibration sequence in ADC_CAL
register. The user must configure the ADC correctly prior to starting the calibration
process, and must allow the process to run the full calibration sequence by checking the
status of ADC_GC[CAL] and ADC_GS[CALF] so that the generated calibration value
can be loaded.
Prior to calibration, the user must configure the ADC's clock source and frequency, low
power configuration, voltage reference selection, sample time, averaging, and the high
speed configuration according to the application's clock source availability and needs. If
the application uses the ADC in a wide variety of configurations, the configuration for
which the highest accuracy is required should be selected, or multiple calibrations can be
done for the different configurations. The input channel, conversion mode, continuous
function and compare function are all ignored during the calibration process.
To initiate calibration, the user sets the CAL bit and the calibration will automatically
begin if the ADTRG bit = 0. If ADTRG = 1, the CAL bit will not get set and the
calibration fail flag (CALF) will be set. While calibration is active, no ADC register can
be written and no stop mode may be entered or the calibration routine will be aborted
causing the CAL bit to clear and the CALF bit to set.
At the end of a calibration sequence the COCO[0] bit of the ADC_HS register will be set.
The ADC_HCn[AIEN] bit can be used to allow an interrupt to occur at the end of a
calibration sequence. If, at the end of calibration routine, the CALF bit is not set, the
automatic calibration routine completed successfully.
To complete calibration, the user must follow the below procedure :
• Configure ADC_CFG with actual operating values for maximum accuracy.
• Configure the ADC_GC values along with CAL bit
• Check the status of CALF bit in ADC_GS and the CAL bit in ADC_GC
• When CAL bit becomes '0' then check the CALF status and COCO[0] bit status
When complete the user may reconfigure and use the ADC as desired.
A second calibration may also be performed if desired by clearing and again setting the
CAL bit
Overall the calibration routine may take as many as 14000 ADCK cycles and 100 bus
cycles, depending on the results and the clock source chosen.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
407

<!-- page 408 -->

13.3.6
User Defined Offset Function
The ADC Offset Correction Register (ADC_OFS) contains the user configured offset
value. This register is 13 bit wide. The value in MSB (13th bit ) is the operation bit, if this
bit is ‘0’ then the value in rest 12 bit is added with the converted result value to generate
final result to be loaded into ADC_Rn and if this bit is ‘1’ then this field is subtracted
from converted value to generate final Result (ADC_Rn). If the Final result is above the
maximum or below the minimum result value, it is forced to the appropriate limit for the
current mode of operation. Forced to 0x0FFF if over and 0x0000 if lower for 12 bit
mode.
The offset value has no effect during calibration on the final result.
The formatting of the ADC Offset Register is different from the Data Result Registers
(ADC_Rn) to preserve the resolution of the value regardless of the conversion mode
selected. Lower order bits are ignored in lower resolution modes. For example, in 8b
single-ended mode, the bits OFS[11:4] are subtracted from D[7:0] when bit OFS[12]
(sign bit) is ‘1’ ; indicates subtraction and bits OFS[4:0] are ignored. For 12b single-
ended mode, bits OFS[11:0] are directly subtracted from the conversion result data
CDATA[11:0] when OFS[12] (sign bit) is ‘1’. The similar is the addition operation when
OFS[12](sign bit) is 0.
ADC_OFS is manually set according to user requirements once the self calibration
sequence is done (CAL is cleared). The user have to write ADC_OFS with desired value.
NOTE
There is an effective limit to the values of Offset that can be set
by the user. If the magnitude of the offset is too great the results
of the conversions will cap off at the limits.
The offset function may be employed by the user to remove application offsets or DC
bias values. An offset correction that results in an out-of-range value will be forced to the
minimum or maximum value.
For applications which may change the offset repeatedly during operation, it is
recommended to store the initial offset value in flash so that it can be recovered and
added to any user offset adjustment value and the sum stored in the ADC_OFS registers.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
408
NXP Semiconductors

<!-- page 409 -->

13.3.7
MCU Wait Mode Operation
Wait mode is a lower power-consumption standby mode from which recovery is fast
because the clock sources remain active. If a conversion is in progress when the MCU
enters wait mode, it continues until completion. Conversions can be initiated while the
MCU is in wait mode if continuous conversions are enabled.
The bus clock, bus clock divided by two, and ADACK are available as conversion clock
sources while in wait mode.
A conversion complete event sets the COCOn and generates an ADC interrupt to wake
the MCU from wait mode.
If the compare and hardware averaging functions are disabled, a conversion complete
event sets the COCOn and generates an ADC interrupt to wake the MCU from wait mode
if the respective ADC interrupt is enabled (ADC_HCn[AIEN]=1).
If the hardware averaging function is enabled the COCOn will set (and generate an
interrupt if enabled) when the selected number of conversions are complete.
If the compare function is enabled the COCOn will set (and generate an interrupt if
enabled) only if the compare conditions are met.
If a single conversion is selected and the compare trigger is not met, the ADC will return
to its idle state and cannot wake the MCU from wait mode.
13.3.8
MCU Stop Mode Operation
Stop mode is a low power-consumption standby mode during which most or all clock
sources on the MCU are disabled. Stop mode is entered when stop indication comes from
the MCU.
13.3.8.1
Stop Mode With ADACK Disabled
If the asynchronous clock, ADACK, is not selected as the conversion clock, executing a
stop instruction aborts the current conversion and places the ADC in its idle state. The
contents of the ADC registers, including ADC_Rn are unaffected by stop mode. After
exiting from stop mode, a software trigger is required to resume conversions.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
409

<!-- page 410 -->

13.3.8.2
Stop Mode With ADACK Enabled
If ADACK is selected as the conversion clock, the ADC continues operation during stop
mode. For guaranteed ADC operation, the MCU's voltage regulator must remain active
during stop mode.
If a conversion is in progress when the MCU enters stop mode, it continues until
completion. Conversions can be initiated while the MCU is in stop mode if continuous
conversions are enabled.
A conversion complete event sets the COCOn and generates an ADC interrupt to wake
the MCU from stop mode :
Note
The ADC module can wake the system from low-power stop
and cause the MCU to begin consuming run-level currents
without generating a system level interrupt. To prevent this
scenario, software should ensure the conversion result data
transfer blocking mechanism (discussed in Completing
Conversions) is cleared when entering stop and continuing
ADC conversions.
13.4
Initialization Information
This section gives an example that provides some basic direction on how to initialize and
configure the ADC module. User can configure the module for 8, 10, 12 bit resolution,
single or continuous conversion, and a polled or interrupt approach, among many other
options.
13.4.1
ADC Module Initialization Example
This section describes the initialization sequence along with pseudo-code.
13.4.1.1
Initialization Sequence
Before the ADC module can be used to complete conversions, an initialization procedure
must be performed. A typical sequence is as follows:
• Calibrate the ADC by following the calibration instructions in Calibration Function
Initialization Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
410
NXP Semiconductors

<!-- page 411 -->

• Update the configuration register (ADC_CFG) to select the input clock source and
the divide ratio used to generate the internal clock, ADCK. This register is also used
for selecting sample time and low-power configuration.
• Update General control register (ADC_GC) to select whether conversions will be
continuous or completed only once (ADCO) and to select whether to perform
hardware averaging, etc.
• Update Trigger control register (ADC_HCn) to select the conversion trigger and
compare function options, if enabled.
13.4.1.2
Pseudo-Code Example
In this example, the ADC module is set up with interrupts enabled to perform a single 10-
bit conversion at low power with a long sample time on input channel 1, where the
internal ADCK clock is derived from the bus clock divided by 1.
ADC_CFG
    Bit 7    ADLPC   1      Configures for low power (lowers maximum clock speed.
    Bit 6:5  ADIV    00     Sets the ADCK to the input clock  ÷  1.
    Bit 4    ADLSMP  1      Configures for long sample time.
    Bit 3:2  MODE    10     Sets mode at 10-bit conversions.
    Bit 1:0  ADICLK  00     Selects bus clock as input clock source.
ADC_GC
    Bit 7    CAL     0      Flag indicates if a conversion is in progress.
    Bit 6    ADCO    0      Software trigger selected.
    Bit 5    AVGE    0      Compare function disabled.
    Bit 4    ACFE    0      Compare function disabled.
    Bit 3    ACFGT   0      Not used in this example.
    Bit 2    ACREN   0      Not used in this example.
    Bit 1    DMAEN   0      Not used in this example.
    Bit 0    ADACKEN 0      Not used in this example.
ADC_HC0
       Bit 7    AIEN   1      Conversion complete interrupt enabled.
    Bit 4:0  ADCH   00001  Input channel 1 selected as ADC input channel.
ADC_R0
    Holds results of conversion. Read high byte (ADCRHA) before low byte (ADCRLA) so that 
conversion data cannot be overwritten with data from the next conversion.
ADC_CV
    Holds compare values when compare function enabled.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
411

<!-- page 412 -->

Reset
Initialize ADC 
ADC_CFG 
ADC_HCn 
ADC_GC 
Check 
COCOn=1?
Read ADC_Rn 
To 
Clear COCOn Bit
Continue
Yes
No
Figure 13-5. Initialization Flowchart for Example
13.5
Application Information
This section contains information for using the ADC module in applications. The ADC
has been designed to be integrated into a microcontroller for use in embedded control
applications requiring an A/D converter.
13.5.1
Sources of Error
Several sources of error exist for A/D conversions. These are discussed in the following
sections.
13.5.1.1
Sampling Error
For proper conversions, the input must be sampled long enough to achieve the proper
accuracy. Given the maximum input resistance of approximately 7kΩ and input
capacitance of approximately 1.3 pF, sampling to within 1/4LSB (at 12-bit resolution)
can be achieved within the nominal sample window (6 cycles @ 40 MHz maximum
ADCK frequency) provided the resistance of the external analog source (RAS) is kept
below 4 kΩ.
Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
412
NXP Semiconductors

<!-- page 413 -->

Higher source resistances or higher-accuracy sampling is possible by setting ADLSMP
and changing the ADSTS bits (to increase the sample window) or decreasing ADCK
frequency to increase sample time.
13.5.1.2
Pin Leakage Error
Leakage on the I/O pins can cause conversion error if the external analog source
resistance (RAS) is high. If this error cannot be tolerated by the application, keep RAS
lower than VDDAD/ (2N*ILEAK) for less than 1/4LSB leakage error (N = 8 in 8-bit, 10 in
10-bit or 12 in 12-bit mode).
13.5.1.3
Noise-Induced Errors
System noise that occurs during the sample or conversion process can affect the accuracy
of the conversion. The ADC accuracy numbers are guaranteed as specified only if the
following conditions are met:
• There is a 0.1 µF low-ESR capacitor from VREFH to VREFL.
• There is a 0.1 µF low-ESR capacitor from VDDAD to VSSAD.
• If inductive isolation is used from the primary supply, an additional 1 µF capacitor is
placed from VDDAD to VSSAD.
• VSSAD (and VREFL, if connected) is connected to VSS at a quiet point in the ground
plane.
• Operate the MCU in wait or stop mode immediately after initiating (software
triggered conversions) the ADC conversion.
• For software triggered conversions, immediately follow the write to ADCSC1
with a wait instruction or stop instruction.
• For stop mode operation, select ADACK as the clock source. Operation in stop
reduces VDD noise but increases effective conversion time due to stop recovery.
• There is no I/O switching, input or output, on the MCU during the conversion.
There are some situations where external system activity causes radiated or conducted
noise emissions or excessive VDD noise is coupled into the ADC. In these situations, or
when the MCU cannot be placed in wait or stop or I/O activity cannot be halted, these
recommended actions may reduce the effect of noise on the accuracy:
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
413

<!-- page 414 -->

• Place a 0.01 µF capacitor (CAS) on the selected input channel to VREFL or VSS (this
improves noise issues, but affects the sample rate based on the external analog source
resistance).
• Average the result by converting the analog input many times in succession and
dividing the sum of the results. Four samples are required to eliminate the effect of a
1LSB, one-time error.
• Reduce the effect of synchronous noise by operating off the asynchronous clock
(ADACK) and averaging. Noise that is synchronous to ADCK cannot be averaged
out.
13.5.1.4
Code Width and Quantization Error
Note
This will remain the same as long as the result is rounded for 8
and 10-bit modes. If the result is truncated in 8/10b modes then
they will match 12b mode where the quantization error is -1 to
0.
The ADC quantizes the ideal straight-line transfer function into 4096 steps (in 12-bit
mode). Each step ideally has the same height (1 code) and width. The width is defined as
the delta between the transition points to one code and the next. The ideal code width for
an N bit converter (in this case N can be 8, 10 or 12), defined as 1LSB, is:
There is an inherent quantization error due to the digitization of the result. For 8-bit or
10-bit conversions the code transitions when the voltage is at the midpoint between the
points where the straight line transfer function is exactly represented by the actual
transfer function. Therefore, the quantization error will be ± 1/2 lsb in 8- or 10-bit mode.
As a consequence, however, the code width of the first (0x000) conversion is only 1/2 lsb
and the code width of the last (0xFF or 0x3FF) is 1.5 lsb.
For 12-bit conversions the code transitions only after the full code width is present, so the
quantization error is -1 lsb to 0 lsb and the code width of each step is 1 lsb.
Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
414
NXP Semiconductors

<!-- page 415 -->

13.5.1.5
Linearity Errors
The ADC may also exhibit non-linearity of several forms. Every effort has been made to
reduce these errors but the system should be aware of them because they affect overall
accuracy. These errors are:
• Zero-scale error (EZS) (sometimes called offset) — This error is defined as the
difference between the actual code width of the first conversion and the ideal code
width (1/2 lsb in 8-bit or 10-bit modes and 1 lsb in 12-bit mode). If the first
conversion is 0x001, the difference between the actual 0x001 code width and its ideal
(1 lsb) is used.
• Full-scale error (EFS) — This error is defined as the difference between the actual
code width of the last conversion and the ideal code width (1.5 lsb in 8-bit or 10-bit
modes and 1LSB in 12-bit mode). If the last conversion is 0x3FE, the difference
between the actual 0x3FE code width and its ideal (1LSB) is used.
• Differential non-linearity (DNL) — This error is defined as the worst-case difference
between the actual code width and the ideal code width for all conversions.
• Integral non-linearity (INL) — This error is defined as the highest-value the
(absolute value of the) running sum of DNL achieves. More simply, this is the worst-
case difference of the actual transition voltage to a given code and its corresponding
ideal transition voltage, for all codes.
• Total unadjusted error (TUE) — This error is defined as the difference between the
actual transfer function and the ideal straight-line transfer function and includes all
forms of error.
13.5.1.6
Code Jitter, Non-Monotonicity, and Missing Codes
Analog-to-digital converters are susceptible to three special forms of error. These are
code jitter, non-monotonicity, and missing codes.
Code jitter is when, at certain points, a given input voltage converts to one of two values
when sampled repeatedly. Ideally, when the input voltage is infinitesimally smaller than
the transition voltage, the converter yields the lower code (and vice-versa). However,
even small amounts of system noise can cause the converter to be indeterminate (between
two codes) for a range of input voltages around the transition voltage. This range is
normally around ±1/2 lsb in 8-bit or 10-bit mode, or around 2 lsb in 12-bit mode, and
increases with noise.
This error may be reduced by repeatedly sampling the input and averaging the result.
Additionally the techniques discussed in Noise-Induced Errors reduces this error.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
415

<!-- page 416 -->

Non-monotonicity is defined as when, except for code jitter, the converter converts to a
lower code for a higher input voltage. Missing codes are those values never converted for
any input value.
In 8-bit or 10-bit mode, the ADC is guaranteed to be monotonic and have no missing
codes.
13.6
Memory map and register definition
The ADC-Digital contains 32-bit, word aligned, byte enables registers; byte or half word
access are not supported. All configuration registers are accessible via 32-bit access bus
Interface. Write access to reserved locations have no impact while read access to reserved
locations always return 0.
NOTE
No protection or indication mechanism is available (for
example, 32-bit access starting with address offset value 0x01
or 0x02 or 0x03). The ADC does not check for correctness of
the programmed values in the registers and the programmer
must ensure that correct values are being written.
ADC memory map
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
219_8000
Control register (ADC1_HC0)
32
R/W
0000_001Fh
13.6.1/417
219_8008
Status register (ADC1_HS)
32
R (reads
0)
0000_0000h
13.6.2/418
219_800C
Data result register (ADC1_R0)
32
R
0000_0000h
13.6.3/419
219_8014
Configuration register (ADC1_CFG)
32
R/W
0000_0200h
13.6.4/420
219_8018
General control register (ADC1_GC)
32
R/W
0000_0000h
13.6.5/422
219_801C
General status register (ADC1_GS)
32
R/W
0000_0000h
13.6.6/424
219_8020
Compare value register (ADC1_CV)
32
R/W
0000_0000h
13.6.7/425
219_8024
Offset correction value register (ADC1_OFS)
32
R/W
0000_0000h
13.6.8/426
219_8028
Calibration value register (ADC1_CAL)
32
R/W
0000_0000h
13.6.9/427
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
416
NXP Semiconductors

<!-- page 417 -->

13.6.1
Control register (ADCx_HC0)
ADC_HC0 is used to control software triggers. Writing ADC_HC0 while ADC_HC0 is
actively controlling a conversion aborts the current conversion. In software trigger mode
(ADTRG=0), writes to ADC_HC0 subsequently initiate a new conversion (if the ADCH
bits are equal to a value other than all 1s).
Address: Base address + 0h offset
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
AIEN
0
ADCH
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
1
1
1
1
1
ADCx_HC0 field descriptions
Field
Description
31–8
Reserved
This read-only field is reserved and always has the value 0.
7
AIEN
Conversion Complete Interrupt Enable/Disable Control
An interrupt is generated whenever ADC_HS[COCO0]=1 (conversion ADC_HC0 completed), provided the
corresponding interrupt is enabled.
1
Conversion complete interrupt enabled
0
Conversion complete interrupt disabled
6–5
Reserved
This read-only field is reserved and always has the value 0.
ADCH
Input Channel Select
This 5-bit field selects one of the input channels. The successive approximation converter subsystem is
turned off when the channel select bits are all set (ADCH = 11111b). This feature allows for explicit
disabling of the ADC and isolation of the input channel from all sources. Terminating continuous
conversions this way prevents an additional single conversion from being performed.
00000-01111
External channels 0 to 15.
10000-10111
Reserved
11000
Reserved.
11001
VREFSH = internal channel, for ADC self-test, hard connected to VRH internally
11010
Reserved.
11011
Reserved.
11100-11110
Reserved.
11111
Conversion Disabled.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
417

<!-- page 418 -->

13.6.2
Status register (ADCx_HS)
Bit 0 is used for software trigger modes of operation.
Address: Base address + 8h offset
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
COCO0
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
ADCx_HS field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
COCO0
Conversion Complete Flag
The COCOn flag is a read-only bit that is set each time a conversion is completed when the compare
function is disabled (ADC_GC[ACFE]=0) and the hardware average function is disabled
(ADC_GC[AVGE]=0). When the compare function is enabled (ADC_GC[ACFE]=1), the COCOn flag is set
upon completion of a conversion only if the compare result is true. When the hardware average function is
enabled (ADC_GC[AVGE]=1), the COCOn flag is set upon completion of the selected number of
conversions (determined by the ADC_CFG[AVGS] field). The COCO0 flag will also set at the completion
of a Calibration and Test sequence. A COCOn bit is cleared when the respective ADC_HCn is written or
when the respective ADC_Rn is read.
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
418
NXP Semiconductors

<!-- page 419 -->

13.6.3
Data result register (ADCx_R0)
Contains the result of an ADC conversion of the channel selected by the respective
channel control register (ADC_HC0). Unused bits in the ADC_Rn register are cleared in
unsigned right justified modes. For example when configured for 10-bit single-ended
mode, D[31:10] are cleared. The table below describes the behavior of the data result
registers in the different modes of operation.
Table 13-10. Data Result Register Description
Conversion
Mode
Data Result Register bits
Format
D31
D30
…..
D12
D11
D10
D9
D8
D7
D6
D5
D4
D3
D2
D1
D0
12b single-ended
0
0
0
0
D
D
D
D
D
D
D
D
D
D
D
D
unsigned right justified
10b single-ended
0
0
0
0
0
0
D
D
D
D
D
D
D
D
D
D
unsigned right justified
8b single-ended
0
0
0
0
0
0
0
0
D
D
D
D
D
D
D
D
unsigned right justified
Address: Base address + Ch offset
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
0
CDATA
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
ADCx_R0 field descriptions
Field
Description
31–12
Reserved
This read-only field is reserved and always has the value 0.
CDATA
Data (result of an ADC conversion)
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
419

<!-- page 420 -->

13.6.4
Configuration register (ADCx_CFG)
Selects the mode of operation, clock source, clock divide, configure for low power, long
sample time, high speed configuration and selects the sample time duration.
Address: Base address + 14h offset
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
OVWREN
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
AVGS
ADTRG
REFSEL
ADHSC
ADSTS
ADLPC
ADIV
ADLSMP
MODE
ADICLK
W
Reset
0
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
ADCx_CFG field descriptions
Field
Description
31–17
Reserved
This read-only field is reserved and always has the value 0.
16
OVWREN
Data Overwrite Enable
Controls the overwriting of the next converted Data onto the existing (previous) unread data into the Data
result register.
1
Enable the overwriting.
0
Disable the overwriting. Existing Data in Data result register will not be overwritten by subsequent
converted data.
15–14
AVGS
Hardware Average select
Determines how many ADC conversions will be averaged to create the ADC average result. This
functionality is activated when ADC_GC[AVGE] = 1.
00
4 samples averaged
01
8 samples averaged
10
16 samples averaged
11
32 samples averaged
13
ADTRG
Conversion Trigger Select
Only software trigger is supported. When software trigger is selected, a conversion is initiated following a
write to ADC_HC0.
0
Software trigger selected
1
Reserved
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
420
NXP Semiconductors

<!-- page 421 -->

ADCx_CFG field descriptions (continued)
Field
Description
12–11
REFSEL
Voltage Reference Selection
Selects the voltage reference source used for conversions.
00
Selects VREFH/VREFL as reference voltage.
01
Reserved
10
Reserved
11
Reserved
10
ADHSC
High Speed Configuration
This bit configures the ADC for high speed operation. The internal ADC clock is higher than normal.
0
Normal conversion selected.
1
High speed conversion selected.
9–8
ADSTS
Defines the sample time duration. This has two modes, short and long. When long sample time is selected
(ADLSMP=1) this works for long sample time otherwise this works for short sample. This allows higher
impedance inputs to be accurately sampled or to maximize conversion speed for lower impedance inputs.
Longer sample times can also be used to lower overall power consumption when continuous conversions
are enabled if high conversion rates are not required.
00
Sample period (ADC clocks) = 2 if ADLSMP=0b
Sample period (ADC clocks) = 12 if ADLSMP=1b
01
Sample period (ADC clocks) = 4 if ADLSMP=0b
Sample period (ADC clocks) = 16 if ADLSMP=1b
10
Sample period (ADC clocks) = 6 if ADLSMP=0b
Sample period (ADC clocks) = 20 if ADLSMP=1b
11
Sample period (ADC clocks) = 8 if ADLSMP=0b
Sample period (ADC clocks) = 24 if ADLSMP=1b
7
ADLPC
Low-Power Configuration
Puts the ADC hard block into low power mode and reduces the comparator enable period by controlling its
timing in the SAR controller block towards the analog hard block.
The signal indicating low power mode to the Analog block is asserted when this bit is set.
0
ADC hard block not in low power mode.
1
ADC hard block in low power mode.
6–5
ADIV
Clock Divide Select
Selects the divide ratio used by the ADC to generate the internal clock ADCK.
00
Input clock
01
Input clock / 2
10
Input clock / 4
11
Input clock / 8
4
ADLSMP
Long Sample Time Configuration
Selects between different sample times based on the ADC_CFG[ADSTS] field. This bit adjusts the sample
period to allow higher impedance inputs to be accurately sampled or to maximize conversion speed for
lower impedance inputs. If high conversion rates are not required, longer sample times can also be used
Table continues on the next page...
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
421

<!-- page 422 -->

ADCx_CFG field descriptions (continued)
Field
Description
to lower overall power consumption when continuous conversions are enabled. When ADLSMP=1, the
Long Sample Time mode is selected and the time is defined by ADSTS[1:0] of the ADC_CFG register.
0
Short sample mode.
1
Long sample mode.
3–2
MODE
Conversion Mode Selection
Used to set the ADC resolution mode.
00
8-bit conversion
01
10-bit conversion
10
12-bit conversion
11
Reserved
ADICLK
Input Clock Select
Selects the input clock source to generate the internal clock ADCK.
00
IPG clock
01
IPG clock divided by 2
10
Reserved
11
Asynchronous clock (ADACK)
13.6.5
General control register (ADCx_GC)
Controls the calibration, continuous convert, hardware averaging functions, conversion
active, compare function and voltage reference select of the ADC module.
Address: Base address + 18h offset
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
CAL
ADCO
AVGE
ACFE
ACFGT
ACREN
DMAEN
ADACKEN
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
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
422
NXP Semiconductors

<!-- page 423 -->

ADCx_GC field descriptions
Field
Description
31–8
Reserved
This read-only field is reserved and always has the value 0.
7
CAL
Calibration
CAL begins the calibration sequence when set. This bit stays set while the calibration is in progress and is
cleared when the calibration sequence is complete. The ADC_GS[CALF] bit must be checked to
determine the result of the calibration sequence. Once started, the calibration routine cannot be
interrupted by writes to the ADC registers or the results will be invalid and the ADC_GS[CALF] bit will set.
Setting the CAL bit will abort any current conversion.
6
ADCO
Continuous Conversion Enable
Enables continuous conversions.
0
One conversion or one set of conversions if the hardware average function is enabled (AVGE=1) after
initiating a conversion.
1
Continuous conversions or sets of conversions if the hardware average function is enabled (AVGE=1)
after initiating a conversion.
5
AVGE
Hardware average enable
Enables the hardware average function of the ADC.
0
Hardware average function disabled
1
Hardware average function enabled
4
ACFE
Compare Function Enable
Enables the compare function.
0
Compare function disabled
1
Compare function enabled
3
ACFGT
Compare Function Greater Than Enable
Configures the compare function to check the conversion result relative to the compare value register
(ADC_CV) based upon the value of ACREN (bit 2 in ADC_GC register). The ACFE bit must be set for
ACFGT to have any effect.
0
Configures "Less Than Threshold, Outside Range Not Inclusive and Inside Range Not Inclusive"
functionality based on the values placed in the ADC_CV register.
1
Configures "Greater Than Or Equal To Threshold, Outside Range Inclusive and Inside Range
Inclusive" functionality based on the values placed in the ADC_CV registers.
2
ACREN
Compare Function Range Enable
Configures the compare function to check the conversion result of the input being monitored is either
between or outside the range formed by the compare values in register (ADC_CV) determined by the
value of ACFGT. The ACFE bit must be set for ACFGT to have any effect.
0
Range function disabled. Only the compare value 1 of ADC_CV register (CV1) is compared.
1
Range function enabled. Both compare values of ADC_CV registers (CV1 and CV2) are compared.
1
DMAEN
DMA Enable
Enables the DMA logic.
Table continues on the next page...
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
423

<!-- page 424 -->

ADCx_GC field descriptions (continued)
Field
Description
0
DMA disabled (default)
1
DMA enabled
0
ADACKEN
Asynchronous clock output enable
Enables the ADC's asynchronous clock source and the clock source output regardless of the conversion
and input clock select (ADC_CFG[ADICLK]) settings of the ADC. Based on MCU configuration, the
asynchronous clock may be used by other modules (see module introduction section). Setting this bit
allows the clock to be used even while the ADC is idle or operating from a different clock source. Also,
latency of initiating a single or first-continuous conversion with the asynchronous clock selected is reduced
since the ADACK clock is already operational.
0
Asynchronous clock output disabled; Asynchronous clock only enabled if selected by ADICLK and a
conversion is active.
1
Asynchronous clock and clock output enabled regardless of the state of the ADC
13.6.6
General status register (ADCx_GS)
Indicates the status of the asynchronous wakeup interrupt, calibration failure and
conversion active functions.
Address: Base address + 1Ch offset
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
AWKST
CALF
ADACT
W
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
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
424
NXP Semiconductors

<!-- page 425 -->

ADCx_GS field descriptions
Field
Description
31–3
Reserved
This read-only field is reserved and always has the value 0.
2
AWKST
Asynchronous wakeup interrupt status
Holds the status of asynchronous interrupt status that occurred during stop mode. This bit is set when
ipg_stop is deasserted and ipg_clk has started. It is cleared by writing ‘1’ to it. Clearing this bit also
deasserts the Asynchronous interrupt to CPU.
1
Asynchronous wake up interrupt occurred in stop mode.
0
No asynchronous interrupt.
1
CALF
Calibration Failed Flag
Displays the result of the calibration sequence. The calibration sequence will fail if any ADC register is
written, or any stop mode is entered before the calibration sequence completes. The CALF bit is cleared
by writing a 1 to it.
0
Calibration completed normally.
1
Calibration failed. ADC accuracy specifications are not guaranteed.
0
ADACT
Conversion Active
Indicates that a conversion or hardware averaging is in progress. ADACT is set when a conversion is
initiated and cleared when a conversion is completed or aborted.
0
Conversion not in progress.
1
Conversion in progress.
13.6.7
Compare value register (ADCx_CV)
Contains compare values used to compare with the conversion result when the compare
function is enabled (ADC_GC[ACFE]=1). The compare values are right justified.
Therefore, the compare function only uses the compare value register bits that are related
to the ADC mode of operation. (e.g. in 8 bit mode, CV1 = ADC_CV[7:0] and CV2 =
ADC_CV[23:16], similarly in 10 bit mode, CV1 = ADC_CV[9:0] and CV2 =
ADC_CV[25:16] etc.) The compare value 2 in this register is utilized only when the
compare range function is enabled (ADC_GC[ACREN]=1).
Address: Base address + 20h offset
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
0
CV2
0
CV1
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
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
425

<!-- page 426 -->

ADCx_CV field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
CV2
Compare Value 2
Contains a compare value used to compare with the conversion result when the compare function and
compare range function are enabled (ADC_GC[ACFE]=1, ADC_GC[ACREN]=1).
15–12
Reserved
This read-only field is reserved and always has the value 0.
CV1
Compare Value 1
Contains a compare value used to compare with the conversion result when the compare function is
enabled (ADC_GC[ACFE]=1).
13.6.8
Offset correction value register (ADCx_OFS)
Contains the user-defined offset error correction value. This register is 13 bits wide. The
value in the most significant bit (13th bit ) is the operation bit. If this bit is ‘0’ then the
value in the other 12 bits is added with the converted result value to generate final result
to be loaded into ADC_Rn; if this bit is ‘1’ then this field is subtracted from converted
value to generate final result (ADC_Rn).
Address: Base address + 24h offset
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
SIGN
OFS
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
ADCx_OFS field descriptions
Field
Description
31–13
Reserved
This read-only field is reserved and always has the value 0.
12
SIGN
Sign bit
0
The offset value is added with the raw result
1
The offset value is subtracted from the raw converted value
OFS
Offset value
User configurable offset value.
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
426
NXP Semiconductors

<!-- page 427 -->

13.6.9
Calibration value register (ADCx_CAL)
Contains calibration information that is generated by the calibration function. This
register contains a calibration value of four bits(CAL[3:0]); this is automatically set once
the self calibration sequence is done (ADC_SC[CAL] bit is cleared). If this register is
written to by the user after calibration, the linearity error specifications may not be met.
Address: Base address + 28h offset
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
0
CAL_CODE
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
ADCx_CAL field descriptions
Field
Description
31–4
Reserved
This read-only field is reserved and always has the value 0.
CAL_CODE
Calibration Result Value
This value is automatically loaded and updated at the end of calibration.
13.7
Memory map and register definition
The ADC-Digital contains 32-bit, word aligned, byte enables registers; byte or half word
access are not supported. All configuration registers are accessible via 32-bit access bus
Interface. Write access to reserved locations have no impact while read access to reserved
locations always return 0.
NOTE
No protection or indication mechanism is available (for
example, 32-bit access starting with address offset value 0x01
or 0x02 or 0x03). The ADC does not check for correctness of
the programmed values in the registers and the programmer
must ensure that correct values are being written.
ADC memory map
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
219_C000
Control register for hardware triggers (ADC2_HC0)
32
R/W
0000_001Fh
13.7.1/429
Table continues on the next page...
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
427

<!-- page 428 -->

ADC memory map (continued)
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
219_C004
Control register for hardware triggers (ADC2_HC1)
32
R/W
0000_001Fh
13.7.2/430
219_C008
Control register for hardware triggers (ADC2_HC2)
32
R/W
0000_001Fh
13.7.2/430
219_C00C
Control register for hardware triggers (ADC2_HC3)
32
R/W
0000_001Fh
13.7.2/430
219_C010
Control register for hardware triggers (ADC2_HC4)
32
R/W
0000_001Fh
13.7.2/430
219_C014
Status register for HW triggers (ADC2_HS)
32
R (reads
0)
0000_0000h
13.7.3/432
219_C018
Data result register for HW triggers (ADC2_R0)
32
R/W
0000_0000h
13.7.4/433
219_C01C
Data result register for HW triggers (ADC2_R1)
32
R/W
0000_0000h
13.7.5/434
219_C020
Data result register for HW triggers (ADC2_R2)
32
R/W
0000_0000h
13.7.5/434
219_C024
Data result register for HW triggers (ADC2_R3)
32
R/W
0000_0000h
13.7.5/434
219_C028
Data result register for HW triggers (ADC2_R4)
32
R/W
0000_0000h
13.7.5/434
219_C02C
Configuration register (ADC2_CFG)
32
R/W
0000_0200h
13.7.6/435
219_C030
General control register (ADC2_GC)
32
R/W
0000_0000h
13.7.7/437
219_C034
General status register (ADC2_GS)
32
R/W
0000_0000h
13.7.8/439
219_C038
Compare value register (ADC2_CV)
32
R/W
0000_0000h
13.7.9/440
219_C03C
Offset correction value register (ADC2_OFS)
32
R/W
0000_0000h
13.7.10/441
219_C040
Calibration value register (ADC2_CAL)
32
R/W
0000_0000h
13.7.11/442
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
428
NXP Semiconductors

<!-- page 429 -->

13.7.1
Control register for hardware triggers (ADCx_HC0)
ADC_HC0 can be used for both software and hardware trigger mode. Other ADC_HCn
(n = 1...) are for use only in hardware trigger mode. The ADC_HC0 to ADC_HCn (n =
0,1) registers have identical fields, and are used to control ADC operation. At any one
point in time, only one of the ADC_HC0 to ADC_HCn (n = 0,1) registers is actively
controlling ADC conversions. Updating ADC_HC0 while ADC_HCn (n = 0,1) is
actively controlling a conversion is allowed (and vice-versa for any of the ADC_HCn (n
= 0,1) registers). Writing ADC_HC0 while ADC_HC0 is actively controlling a
conversion aborts the current conversion. In software trigger mode (ADTRG=0), writes
to ADC_HC0 subsequently initiates a new conversion (if the ADCH bits are equal to a
value other than all 1s). Similarly, writing any of the ADC_HCn (n = 0,1) registers while
that specific ADC_HC register is actively controlling a conversion aborts the current
conversion. ADC_HC1 register is not used for software trigger operation and therefore
writes to any of them do not initiate a new conversion.
Address: Base address + 0h offset
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
AIEN
0
ADCH
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
1
1
1
1
1
ADCx_HC0 field descriptions
Field
Description
31–8
Reserved
This read-only field is reserved and always has the value 0.
7
AIEN
Conversion Complete Interrupt Enable/Disable Control
An interrupt is generated whenever ADC_HS[COCO0]=1 (conversion ADC_HC0 completed), provided the
corresponding interrupt is enabled.
1
Conversion complete interrupt enabled
0
Conversion complete interrupt disabled
6–5
Reserved
This read-only field is reserved and always has the value 0.
ADCH
Input Channel Select
This 5-bit field selects one of the input channels. The successive approximation converter subsystem is
turned off when the channel select bits are all set (ADCH = 11111b). This feature allows for explicit
Table continues on the next page...
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
429

<!-- page 430 -->

ADCx_HC0 field descriptions (continued)
Field
Description
disabling of the ADC and isolation of the input channel from all sources. Terminating continuous
conversions this way prevents an additional single conversion from being performed.
00000-01111
External channels 0 to 15.
10000-10111
Reserved
11000
Reserved.
11001
VREFSH = internal channel, for ADC self-test, hard connected to VRH internally
11010
Reserved.
11011
Reserved.
11100-11110
Reserved.
11111
Conversion Disabled. Hardware Triggers will not initiate any conversion.
13.7.2
Control register for hardware triggers (ADCx_HCn)
ADC_HCn are for use only in hardware trigger mode. The ADC_HC0 to ADC_HCn
registers have identical fields, and are used to control ADC operation. At any one point in
time, only one of the ADC_HC0 to ADC_HCn registers is actively controlling ADC
conversions. Updating ADC_HC0 while ADC_HCn is actively controlling a conversion
is allowed (and vice-versa for any of the ADC_HCn registers). Writing any of the
ADC_HCn registers while that specific ADC_HCn register is actively controlling a
conversion aborts the current conversion. Any of the ADC_HC1 - ADC_HCn registers
are not used for software trigger operation and therefore writes to any of them do not
initiate a new conversion.
Address: Base address + 4h offset + (4d × i), where i=0d to 3d
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
AIEN
0
ADCH
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
1
1
1
1
1
ADCx_HCn field descriptions
Field
Description
31–8
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
430
NXP Semiconductors

<!-- page 431 -->

ADCx_HCn field descriptions (continued)
Field
Description
7
AIEN
Conversion Complete Interrupt Enable/Disable Control
An interrupt is generated whenever ADC_HS[COCO0]=1(conversion ADC_HC0 completed), provided the
corresponding interrupt is enabled.
1
Conversion complete interrupt enabled
0
Conversion complete interrupt disabled
6–5
Reserved
This read-only field is reserved and always has the value 0.
ADCH
Input Channel Select
This 5-bit field selects one of the input channels. The successive approximation converter subsystem is
turned off when the channel select bits are all set (ADCH =11111b). This feature allows for explicit
disabling of the ADC and isolation of the input channel from all sources. Terminating continuous
conversions this way prevents an additional single conversion from being performed.
00000-01111
External channels 0 to 15.
10000-10111
Reserved
11000
Reserved
11001
VREFSH = internal channel, for ADC self-test, hard connected to VRH internally
11010
Reserved
11011
Reserved
11100-11110
Reserved
11111
Conversion Disabled. Hardware Triggers will not initiate any conversion.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
431

<!-- page 432 -->

13.7.3
Status register for HW triggers (ADCx_HS)
Bit 0 is used for both software and hardware trigger modes of operation. Bit 1 to bit (n-1)
indicate the rest of the HW triggers' statuses similar to bit 0, potentially corresponding to
multiple ADC_HC registers (for use only in hardware trigger mode).
Address: Base address + 14h offset
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
COCO4
COCO3
COCO2
COCO1
COCO0
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
ADCx_HS field descriptions
Field
Description
31–5
Reserved
This read-only field is reserved and always has the value 0.
4
COCO4
See description for COCO0.
3
COCO3
See description for COCO0.
2
COCO2
See description for COCO0.
1
COCO1
See description for COCO0.
0
COCO0
Conversion Complete Flag
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
432
NXP Semiconductors

<!-- page 433 -->

ADCx_HS field descriptions (continued)
Field
Description
The COCOn flag is a read-only bit that is set each time a conversion is completed when the compare
function is disabled (ADC_GC[ACFE]=0) and the hardware average function is disabled
(ADC_GC[AVGE]=0). When the compare function is enabled (ADC_GC[ACFE]=1), the COCOn flag is set
upon completion of a conversion only if the compare result is true. When the hardware average function is
enabled (ADC_GC[AVGE]=1), the COCOn flag is set upon completion of the selected number of
conversions (determined by the ADC_CFG[AVGS] field). The COCO0 flag will also set at the completion
of a Calibration and Test sequence. A COCOn bit is cleared when the respective ADC_HCn is written or
when the respective ADC_Rn is read.
13.7.4
Data result register for HW triggers (ADCx_R0)
Contains the result of an ADC conversion of the channel selected by the
respectivehardware trigger and channel control register (ADC_HC0:ADC_HCn). For
every ADC_HC0:ADC_HCn status and channel control register, there is a respective
ADC_R0:ADC_Rn data result register. Unused bits in the ADC_Rn register are cleared
in unsigned right justified modes. For example when configured for 10-bit single-ended
mode, D[31:10] are cleared. The table below describes the behavior of the data result
registers in the different modes of operation.
Table 13-11. Data Result Register Description
Conversion
Mode
Data Result Register bits
Format
D31
D30
…..
D12
D11
D10
D9
D8
D7
D6
D5
D4
D3
D2
D1
D0
12b single-ended
0
0
0
0
D
D
D
D
D
D
D
D
D
D
D
D
unsigned right justified
10b single-ended
0
0
0
0
0
0
D
D
D
D
D
D
D
D
D
D
unsigned right justified
8b single-ended
0
0
0
0
0
0
0
0
D
D
D
D
D
D
D
D
unsigned right justified
Address: Base address + 18h offset
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
0
CDATA
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
ADCx_R0 field descriptions
Field
Description
31–12
Reserved
This read-only field is reserved and always has the value 0.
CDATA
Data (result of an ADC conversion)
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
433

<!-- page 434 -->

13.7.5
Data result register for HW triggers (ADCx_Rn)
Contains the result of an ADC conversion of the channel selected by the respective
Hardware Trigger and channel control register (ADC_HC0:ADC_HCn). For every
ADC_HC0:ADC_HCn status and channel control register, there is a respective ADC_R0
to ADC_Rn data result register. Unused bits in the ADC_Rn register are cleared in
unsigned right justified modes. For example when configured for 10-bit single-ended
mode, D[31:10] are cleared. The table below describes the behavior of the data result
registers in the different modes of operation.
Table 13-12. Data Result Register Description
Conversion
Mode
Data Result Register bits
Format
D31
D30
…..
D12
D11
D10
D9
D8
D7
D6
D5
D4
D3
D2
D1
D0
12b single-ended
0
0
0
0
D
D
D
D
D
D
D
D
D
D
D
D
unsigned right justified
10b single-ended
0
0
0
0
0
0
D
D
D
D
D
D
D
D
D
D
unsigned right justified
8b single-ended
0
0
0
0
0
0
0
0
D
D
D
D
D
D
D
D
unsigned right justified
Address: Base address + 1Ch offset + (4d × i), where i=0d to 3d
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
0
CDATA
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
ADCx_Rn field descriptions
Field
Description
31–12
Reserved
This read-only field is reserved and always has the value 0.
CDATA
Data (result of an ADC conversion)
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
434
NXP Semiconductors

<!-- page 435 -->

13.7.6
Configuration register (ADCx_CFG)
Selects the mode of operation, clock source, clock divide, configure for low power, long
sample time, high speed configuration and selects the sample time duration.
Address: Base address + 2Ch offset
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
OVWREN
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
AVGS
ADTRG
REFSEL
ADHSC
ADSTS
ADLPC
ADIV
ADLSMP
MODE
ADICLK
W
Reset
0
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
ADCx_CFG field descriptions
Field
Description
31–17
Reserved
This read-only field is reserved and always has the value 0.
16
OVWREN
Data Overwrite Enable
Controls the overwriting of the next converted Data onto the existing (previous) unread data into the Data
result register.
1
Enable the overwriting.
0
Disable the overwriting. Existing Data in Data result register will not be overwritten by subsequent
converted data.
15–14
AVGS
Hardware Average select
Determines how many ADC conversions will be averaged to create the ADC average result. This
functionality is activated when ADC_GC[AVGE] = 1.
00
4 samples averaged
01
8 samples averaged
10
16 samples averaged
11
32 samples averaged
13
ADTRG
Conversion Trigger Select
Selects the type of trigger used for initiating a conversion. Two types of trigger are selectable: software
trigger and hardware trigger. When software trigger is selected, a conversion is initiated following a write
to ADC_HC0. When hardware trigger is selected, a conversion is initiated following the assertion of a
pulse on Alternate Hardware trigger input along with the assertion of the enable of respective the
hardware Triggers input.
Table continues on the next page...
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
435

<!-- page 436 -->

ADCx_CFG field descriptions (continued)
Field
Description
0
Software trigger selected
1
Hardware trigger selected
12–11
REFSEL
Voltage Reference Selection
Selects the voltage reference source used for conversions.
00
Selects VREFH/VREFL as reference voltage.
01
Reserved
10
Reserved
11
Reserved
10
ADHSC
High Speed Configuration
This bit configures the ADC for high speed operation. The internal ADC clock is higher than normal.
0
Normal conversion selected.
1
High speed conversion selected.
9–8
ADSTS
Defines the sample time duration. This has two modes, short and long. When long sample time is selected
(ADLSMP=1) this works for long sample time otherwise this works for short sample. This allows higher
impedance inputs to be accurately sampled or to maximize conversion speed for lower impedance inputs.
Longer sample times can also be used to lower overall power consumption when continuous conversions
are enabled if high conversion rates are not required.
00
Sample period (ADC clocks) = 2 if ADLSMP=0b
Sample period (ADC clocks) = 12 if ADLSMP=1b
01
Sample period (ADC clocks) = 4 if ADLSMP=0b
Sample period (ADC clocks) = 16 if ADLSMP=1b
10
Sample period (ADC clocks) = 6 if ADLSMP=0b
Sample period (ADC clocks) = 20 if ADLSMP=1b
11
Sample period (ADC clocks) = 8 if ADLSMP=0b
Sample period (ADC clocks) = 24 if ADLSMP=1b
7
ADLPC
Low-Power Configuration
Puts the ADC hard block into low power mode and reduces the comparator enable period by controlling its
timing in the SAR controller block towards the anlong hard block.
The signal indicating low power mode to the Analog block is asserted when this bit is set.
0
ADC hard block not in low power mode.
1
ADC hard block in low power mode.
6–5
ADIV
Clock Divide Select
Selects the divide ratio used by the ADC to generate the internal clock ADCK.
00
Input clock
01
Input clock / 2
10
Input clock / 4
11
Input clock / 8
4
ADLSMP
Long Sample Time Configuration
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
436
NXP Semiconductors

<!-- page 437 -->

ADCx_CFG field descriptions (continued)
Field
Description
Selects between different sample times based on the ADC_CFG[ADSTS] field. This bit adjusts the sample
period to allow higher impedance inputs to be accurately sampled or to maximize conversion speed for
lower impedance inputs. If high conversion rates are not required, longer sample times can also be used
to lower overall power consumption when continuous conversions are enabled. When ADLSMP=1, the
Long Sample Time mode is selected and the time is defined by ADSTS[1:0] of the ADC_CFG register.
0
Short sample mode.
1
Long sample mode.
3–2
MODE
Conversion Mode Selection
Used to set the ADC resolution mode.
00
8-bit conversion
01
10-bit conversion
10
12-bit conversion
11
Reserved
ADICLK
Input Clock Select
Selects the input clock source to generate the internal clock ADCK.
00
IPG clock
01
IPG clock divided by 2
10
Reserved
11
Asynchronous clock (ADACK)
13.7.7
General control register (ADCx_GC)
Controls the calibration, continuous convert, hardware averaging functions, conversion
active, hardware/software trigger select, compare function and voltage reference select of
the ADC module.
Address: Base address + 30h offset
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
CAL
ADCO
AVGE
ACFE
ACFGT
ACREN
DMAEN
ADACKEN
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
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
437

<!-- page 438 -->

ADCx_GC field descriptions
Field
Description
31–8
Reserved
This read-only field is reserved and always has the value 0.
7
CAL
Calibration
CAL begins the calibration sequence when set. This bit stays set while the calibration is in progress and is
cleared when the calibration sequence is complete. The ADC_GS[CALF] bit must be checked to
determine the result of the calibration sequence. Once started, the calibration routine cannot be
interrupted by writes to the ADC registers or the results will be invalid and the ADC_GS[CALF] bit will set.
Setting the CAL bit will abort any current conversion.
6
ADCO
Continuous Conversion Enable
Enables continuous conversions.
0
One conversion or one set of conversions if the hardware average function is enabled (AVGE=1) after
initiating a conversion.
1
Continuous conversions or sets of conversions if the hardware average function is enabled (AVGE=1)
after initiating a conversion.
5
AVGE
Hardware average enable
Enables the hardware average function of the ADC.
0
Hardware average function disabled
1
Hardware average function enabled
4
ACFE
Compare Function Enable
Enables the compare function.
0
Compare function disabled
1
Compare function enabled
3
ACFGT
Compare Function Greater Than Enable
Configures the compare function to check the conversion result relative to the compare value register
(ADC_CV) based upon the value of ACREN (bit 2 in ADC_GC register). The ACFE bit must be set for
ACFGT to have any effect.
0
Configures "Less Than Threshold, Outside Range Not Inclusive and Inside Range Not Inclusive"
functionality based on the values placed in the ADC_CV register.
1
Configures "Greater Than Or Equal To Threshold, Outside Range Inclusive and Inside Range
Inclusive" functionality based on the values placed in the ADC_CV registers.
2
ACREN
Compare Function Range Enable
Configures the compare function to check the conversion result of the input being monitored is either
between or outside the range formed by the compare values in register (ADC_CV) determined by the
value of ACFGT. The ACFE bit must be set for ACFGT to have any effect.
0
Range function disabled. Only the compare value 1 of ADC_CV register (CV1) is compared.
1
Range function enabled. Both compare values of ADC_CV registers (CV1 and CV2) are compared.
1
DMAEN
DMA Enable
Enables the DMA logic.
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
438
NXP Semiconductors

<!-- page 439 -->

ADCx_GC field descriptions (continued)
Field
Description
0
DMA disabled (default)
1
DMA enabled
0
ADACKEN
Asynchronous clock output enable
Enables the ADC’s asynchronous clock source and the clock source output regardless of the conversion
and input clock select (ADC_CFG[ADICLK]) settings of the ADC. Based on MCU configuration, the
asynchronous clock may be used by other modules (see module introduction section). Setting this bit
allows the clock to be used even while the ADC is idle or operating from a different clock source. Also,
latency of initiating a single or first-continuous conversion with the asynchronous clock selected is reduced
since the ADACK clock is already operational.
0
Asynchronous clock output disabled; Asynchronous clock only enabled if selected by ADICLK and a
conversion is active.
1
Asynchronous clock and clock output enabled regardless of the state of the ADC
13.7.8
General status register (ADCx_GS)
Controls the calibration, continuous convert, hardware averaging functions, conversion
active, hardware/software trigger select, compare function and voltage reference select of
the ADC module.
Address: Base address + 34h offset
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
AWKST
CALF
ADACT
W
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
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
439

<!-- page 440 -->

ADCx_GS field descriptions
Field
Description
31–3
Reserved
This read-only field is reserved and always has the value 0.
2
AWKST
Asynchronous wakeup interrupt status
Holds the status of asynchronous interrupt status that occured during stop mode. This bit is set when
ipg_stop is deasserted and ipg_clk has started. It is cleared by writing ‘1’ to it. Clearing this bit also
deasserts the Asynchronous interrupt to CPU.
1
Asynnchronous wake up interrupt occured in stop mode.
0
No asynchronous interrupt.
1
CALF
Calibration Failed Flag
Displays the result of the calibration sequence. The calibration sequence will fail ifHardware Trigger is
selected (i.e. ADC_CFG[ADTRG] = 1), or any ADC register is written, or any stop mode is entered before
the calibration sequence completes. The CALF bit is cleared by writing a 1 to it.
0
Calibration completed normally.
1
Calibration failed. ADC accuracy specifications are not guaranteed.
0
ADACT
Conversion Active
Indicates that a conversion or hardware averaging is in progress. ADACT is set when a conversion is
initiated and cleared when a conversion is completed or aborted.
0
Conversion not in progress.
1
Conversion in progress.
13.7.9
Compare value register (ADCx_CV)
Contains compare values used to compare with the conversion result when the compare
function is enabled (ADC_GC[ACFE]=1). The compare values are right justified.
Therfore, the compare function only uses the compare value register bits that are related
to the ADC mode of operation. (e.g. in 8 bit mode, CV1 = ADC_CV[7:0] and CV2 =
ADC_CV[23:16], similarly in 10 bit mode, CV1 = ADC_CV[9:0] and CV2 =
ADC_CV[25:16] etc.) The compare value 2 in this register is utilized only when the
compare range function is enabled (ADC_GC[ACREN]=1).
Address: Base address + 38h offset
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
0
CV2
0
CV1
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
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
440
NXP Semiconductors

<!-- page 441 -->

ADCx_CV field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
CV2
Compare Value 2
Contains a compare value used to compare with the conversion result when the compare function and
compare range function are enabled (ADC_GC[ACFE]=1, ADC_GC[ACREN]=1).
15–12
Reserved
This read-only field is reserved and always has the value 0.
CV1
Compare Value 1
Contains a compare value used to compare with the conversion result when the compare function ais
enabled (ADC_GC[ACFE]=1).
13.7.10
Offset correction value register (ADCx_OFS)
Contains the user-defined offset error correction value. This register is 13 bits wide. The
value in the most significant bit (13th bit ) is the operation bit. If this bit is ‘0’ then the
value in the other 12 bits is added with the converted result value to generate final result
to be loaded into ADC_Rn; if this bit is ‘1’ then this field is subtracted from converted
value to generate final result (ADC_Rn).
Address: Base address + 3Ch offset
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
SIGN
OFS
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
ADCx_OFS field descriptions
Field
Description
31–13
Reserved
This read-only field is reserved and always has the value 0.
12
SIGN
Sign bit
0
The offset value is added with the raw result
1
The offset value is subtracted from the raw converted value
OFS
Offset value
User configurable offset value.
Chapter 13 Analog-to-Digital Converter (ADC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
441

<!-- page 442 -->

13.7.11
Calibration value register (ADCx_CAL)
Contains calibration information that is generated by the calibration function. This
register contains a calibration value of four bits(CAL[3:0]); this is automatically set once
the self calibration sequence is done (ADC_SC[CAL] bit is cleared). If this register is
written to by the user after calibration, the linearity error specifications may not be met.
Address: Base address + 40h offset
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
0
CAL_CODE
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
ADCx_CAL field descriptions
Field
Description
31–4
Reserved
This read-only field is reserved and always has the value 0.
CAL_CODE
Calibration Result Value
This value is automatically loaded and updated at the end of calibration.
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
442
NXP Semiconductors

