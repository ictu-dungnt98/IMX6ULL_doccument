# Chapter 3: Interrupts and DMA Events

> Nguồn: `IMX6ULLRM.pdf` — trang 183–190

<!-- page 183 -->

Chapter 3
Interrupts and DMA Events
3.1
Overview
This section describes the assignments of interrupts from the ARM domain in Cortex A7
interruptsand from the DMA events in SDMA event mapping.
3.2
Cortex A7 interrupts
The Global Interrupt Controller (GIC) collects up to 128 interrupt requests from all chip
sources and provides an interface to the Cortex A7 CPU. The first 32 interrupts are
private to the CPUs' interface. These interrupts are not included in the table below. All
interrupts besides those private to the CPU are hooked up to the GPC.
Each interrupt can be configured as a normal or a secure interrupt. Software force
registers and software priority masking are also supported. This table describes the ARM
Cortex A7 interrupt sources:
Table 3-1. ARM Cortex A7 domain interrupt summary
IRQ
Interrupt Source
LOGIC
Interrupt Description
0
boot
-
Used to notify cores on exception condition while boot
1
ca7_platform
-
DAP
2
sdma
-
AND of all 48 SDMA interrupts (events) from all the channels
3
tsc
-
TSC interrupt
4
snvs_lp_wrapper
OR
ON-OFF button press shorter than 5 secs (pulse event)
snvs_hp_wrapper
ON-OFF button press shorter than 5 secs (pulse event)
5
lcdif
-
LCDIF Sync Interrupt
6
rngb
-
RNGB Interrupt
7
csi
-
CSI interrupt
8
pxp
-
PXP interrupt
9
sctr
-
SCTR compare interrupt
Table continues on the next page...
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
183

<!-- page 184 -->

Table 3-1. ARM Cortex A7 domain interrupt summary (continued)
IRQ
Interrupt Source
LOGIC
Interrupt Description
10
sctr
-
SCTR compare interrupt
11
wdog3
-
Watchdog Timer reset
12
-
-
Reserved
13
apbhdma
OR
GPMI operation channel 0 description complete interrupt
GPMI operation channel 1 description complete interrupt
GPMI operation channel 2 description complete interrupt
GPMI operation channel 3 description complete interrupt
14
weim
-
WEIM interrupt
15
bch
-
BCH operation complete interrupt
16
gpmi
-
GPMI operation TIMEOUT ERROR interrupt
17
uart6
-
UART-6 ORed interrupt
18
pxp
-
PXP interrupt
19
snvs_hp_wrapper
-
SRTC Consolidated Interrupt. Non TZ.
20
snvs_hp_wrapper
-
SRTC Security Interrupt. TZ.
21
csu
-
CSU Interrupt Request 1. Indicates to the processor that one
or more alarm inputs were asserted
22
usdhc1
-
uSDHC1 Enhanced SDHC Interrupt Request
23
usdhc2
-
uSDHC2 Enhanced SDHC Interrupt Request
24
sai3
-
SAI interrupt
25
sai3
-
SAI interrupt
26
uart1
-
UART-1 ORed interrupt
27
uart2
-
UART-2 ORed interrupt
28
uart3
-
UART-3 ORed interrupt
29
uart4
-
UART-4 ORed interrupt
30
uart5
-
UART-5 ORed interrupt
31
ecspi1
-
eCSPI1 interrupt request line to the core.
32
ecspi2
-
eCSPI2 interrupt request line to the core.
33
ecspi3
-
eCSPI3 interrupt request line to the core.
34
ecspi4
-
eCSPI4 interrupt request line to the core.
35
i2c4
-
I2C-4 Interrupt
36
i2c1
-
I2C-1 Interrupt
37
i2c2
-
I2C-2 Interrupt
38
i2c3
-
I2C-3 Interrupt
39
uart7
-
UART-7 ORed interrupt
40
uart8
-
UART-8 ORed interrupt
41
-
-
Reserved
42
usb
-
USBO2 USB OTG2
43
usb
-
USBO2 USB OTG1
44
anatop
-
USBPHY (UTMI0), Interrupt
45
anatop
-
USBPHY (UTMI1), Interrupt
Table continues on the next page...
Cortex A7 interrupts
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
184
NXP Semiconductors

<!-- page 185 -->

Table 3-1. ARM Cortex A7 domain interrupt summary (continued)
IRQ
Interrupt Source
LOGIC
Interrupt Description
46
dcp
-
DCP Interrupt
47
dcp
-
DCP Interrupt
48
dcp
-
DCP Interrupt
49
tempsensor
OR
TempSensor low
TempSensor high
TempSensor panic
50
asrc
-
ASRC- Interrupt for core
51
esai
-
ESAI interrupt
52
spdif
OR
SPDIF Rx interrupt
spdif
SPDIF Tx interrupt
53
-
-
Reserved
54
pmu
-
Brown-out event on either the 1.1, 2.5 or 3.0 regulators.
55
gpt1
-
OR of GPT1 Rollover interrupt line, Input Capture 1 & 2 lines,
Output Compare 1,2 &3 Interrupt lines
56
epit1
-
EPIT1 output compare interrupt
57
epit2
-
EPIT2 output compare interrupt
58
gpio1
-
Active HIGH Interrupt from INT7 from GPIO
59
gpio1
-
Active HIGH Interrupt from INT6 from GPIO
60
gpio1
-
Active HIGH Interrupt from INT5 from GPIO
61
gpio1
-
Active HIGH Interrupt from INT4 from GPIO
62
gpio1
-
Active HIGH Interrupt from INT3 from GPIO
63
gpio1
-
Active HIGH Interrupt from INT2 from GPIO
64
gpio1
-
Active HIGH Interrupt from INT1 from GPIO
65
gpio1
-
Active HIGH Interrupt from INT0 from GPIO
66
gpio1
-
Combined interrupt indication for GPIO1 signal 0 throughout
15
67
gpio1
-
Combined interrupt indication for GPIO1 signal 16 throughout
31
68
gpio2
-
Combined interrupt indication for GPIO2 signal 0 throughout
15
69
gpio2
-
Combined interrupt indication for GPIO2 signal 16 throughout
31
70
gpio3
-
Combined interrupt indication for GPIO3 signal 0 throughout
15
71
gpio3
-
Combined interrupt indication for GPIO3 signal 16 throughout
31
72
gpio4
-
Combined interrupt indication for GPIO4 signal 0 throughout
15
73
gpio4
-
Combined interrupt indication for GPIO4 signal 16 throughout
31
74
gpio5
-
Combined interrupt indication for GPIO5 signal 0 throughout
15
Table continues on the next page...
Chapter 3 Interrupts and DMA Events
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
185

<!-- page 186 -->

Table 3-1. ARM Cortex A7 domain interrupt summary (continued)
IRQ
Interrupt Source
LOGIC
Interrupt Description
75
gpio5
-
Combined interrupt indication for GPIO5 signal 16 throughout
31
76
can1
-
IPI compare interrupt
77
can2
-
IPI compare interrupt
78
-
-
Reserved
79
-
-
Reserved
80
wdog1
-
Watchdog Timer reset
81
wdog2
-
Watchdog Timer reset
82
kpp
-
Keypad Interrupt
83
pwm1
-
Cumulative interrupt line. OR of Rollover Interrupt line,
Compare Interrupt line and FIFO Waterlevel crossing interrupt
line
84
pwm2
-
Cumulative interrupt line. OR of Rollover Interrupt line,
Compare Interrupt line and FIFO Waterlevel crossing interrupt
line
85
pwm3
-
Cumulative interrupt line. OR of Rollover Interrupt line,
Compare Interrupt line and FIFO Waterlevel crossing interrupt
line
86
pwm4
-
Cumulative interrupt line. OR of Rollover Interrupt line,
Compare Interrupt line and FIFO Waterlevel crossing interrupt
line
87
ccm
-
CCM, Interrupt Request 1
88
ccm
-
CCM, Interrupt Request 2
89
gpc
-
GPC, Interrupt Request 1
90
-
-
Reserved
91
src
-
SRC interrupt request
92
-
-
Reserved
93
-
-
Reserved
94
ca7_platform
-
Performance Unit Interrupts from ca7_mx6ul (interrnally:
nPMUIRQ[0])
95
ca7_platform
-
CTI trigger outputs (internal: nCTIIRQ[0])
96
src
-
Combined CPU wdog interrupts (4x) out of SRC.
97
sai1
OR
SAI interrupt
SAI interrupt
SAI interrupt
SAI interrupt
98
sai2
OR
SAI interrupt
SAI interrupt
SAI interrupt
SAI interrupt
99
-
-
Reserved
100
adc1
OR
ADC1 interrupt
Table continues on the next page...
Cortex A7 interrupts
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
186
NXP Semiconductors

<!-- page 187 -->

Table 3-1. ARM Cortex A7 domain interrupt summary (continued)
IRQ
Interrupt Source
LOGIC
Interrupt Description
ADC1 interrupt
101
adc2
OR
ADC2 interrupt
ADC2 interrupt
102
-
-
Reserved
103
-
-
Reserved
104
sjc
-
SJC Interrupt from General Purpose register.
105
caam_wrapper
-
CAAM interrupt queue for JQ0
106
caam_wrapper
-
CAAM interrupt queue for JQ1
107
qspi
-
QuadSPI interrput
108
tzasc
-
TZASC #1 (PL380) interrupt
109
gpt2
-
OR of GPT2 Rollover interrupt line, Input Capture 1 & 2 lines,
Output Compare 1,2 &3 Interrupt lines
110
can1
-
Combined interrupt of ini_int_busoff, ini_int_error,
ipi_int_mbor, ipi_int_rxwarning, ipi_int_txwarning and
ipi_int_wakein.
111
can2
-
Combined interrupt of ini_int_busoff, ini_int_error,
ipi_int_mbor, ipi_int_rxwarning, ipi_int_txwarning and
ipi_int_wakein.
112
epdc
-
epdc interrupt
113
-
-
Reserved
114
pwm5
-
Cumulative interrupt line. OR of Rollover Interrupt line,
Compare Interrupt line and FIFO Waterlevel crossing interrupt
line
115
pwm6
-
Cumulative interrupt line. OR of Rollover Interrupt line,
Compare Interrupt line and FIFO Waterlevel crossing interrupt
line
116
pwm7
-
Cumulative interrupt line. OR of Rollover Interrupt line,
Compare Interrupt line and FIFO Waterlevel crossing interrupt
line
117
pwm8
-
Cumulative interrupt line. OR of Rollover Interrupt line,
Compare Interrupt line and FIFO Waterlevel crossing interrupt
line
118
enet1
OR
MAC 0 Periodic Timer Overflow
MAC 0 Time Stamp Available
MAC 0 Payload Receive Error
MAC 0 Transmit FIFO Underrun
MAC 0 Collision Retry Limit
MAC 0 Late Collision
MAC 0 Ethernet Bus Error
MAC 0 MII Data Transfer Done
MAC 0 Receive Buffer Done
MAC 0 Receive Frame Done
MAC 0 Transmit Buffer Done
Table continues on the next page...
Chapter 3 Interrupts and DMA Events
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
187

<!-- page 188 -->

Table 3-1. ARM Cortex A7 domain interrupt summary (continued)
IRQ
Interrupt Source
LOGIC
Interrupt Description
MAC 0 Transmit Frame Done
MAC 0 Graceful Stop
MAC 0 Babbling Transmit Error
MAC 0 Babbling Receive Error
MAC 0 Wakeup Request (sync)
119
enet1
-
MAC 0 1588 Timer Interrupt – synchronous
120
enet2
OR
MAC 0 Periodic Timer Overflow
MAC 0 Time Stamp Available
MAC 0 Payload Receive Error
MAC 0 Transmit FIFO Underrun
MAC 0 Collision Retry Limit
MAC 0 Late Collision
MAC 0 Ethernet Bus Error
MAC 0 MII Data Transfer Done
MAC 0 Receive Buffer Done
MAC 0 Receive Frame Done
MAC 0 Transmit Buffer Done
MAC 0 Transmit Frame Done
MAC 0 Graceful Stop
MAC 0 Babbling Transmit Error
MAC 0 Babbling Receive Error
MAC 0 Wakeup Request (sync)
121
enet2
-
MAC 0 1588 Timer Interrupt – synchronous
122
-
-
Reserved
123
-
-
Reserved
124
-
-
Reserved
125
-
-
Reserved
126
-
-
Reserved
127
pmu
-
Brown out event on either the core, gpu or soc regulators
3.3
SDMA event mapping
This table shows the DMA request signals for the peripherals in the chip:
SDMA event mapping
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
188
NXP Semiconductors

<!-- page 189 -->

Table 3-2. SDMA event mapping
Event
Number
DMA Source
Description
0
UART6 / ESAI
UAR6 Rx FIFO; ESAI Rx FIFO DMA request
1
ADC1
ADC1 DMA request
2
EPIT2 / PXP
EPIT2 DMA request; PXP DMA Event
3
eCSPI1
eCSPI1 Rx request
4
eCSPI1
eCSPI1 Tx request
5
eCSPI2
eCSPI2 Rx request
6
eCSPI2
eCSPI2 Tx request
7
eCSPI3 / I2C1
eCSPI3 Rx request; I2C1 DMA event
8
eCSPI3 / I2C2
eCSPI3 Tx request; I2C2 DMA event
9
eCSPI4 / I2C3
eCSPI4 Rx request; I2C3 DMA event
10
eCSPI4 / I2C4
eCSPI4 Tx request; I2C4 DMA event
11
QSPI
QSPI DMA RX request
12
QSPI
QSPI DMA TX request
13
ADC2 / TSC
ADC2 DMA request; TSC interrupt
14
Mux_bottom
external DMA pad #1
15
Mux_bottom
external DMA pad #2
16
EPIT1 / CSI
EPIT1 DMA request: CSI DMA Event
17
ASRC
ASRC DMA1 request (Pair A input Request)
18
ASRC
ASRC DMA2 request (Pair B input Request)
19
ASRC
ASRC DMA3 request (Pair C input Request)
20
ASRC
ASRC DMA4 request (Pair A output Request)
21
ASRC
ASRC DMA5 request (Pair B output Request)
22
ASRC
ASRC DMA6 request (Pair C output Request)
23
GPT1
GPT1 counter event
24
GPT2 / LCDIF
GPT2 counter event; LCDIF DMA Event
25
UART1
UART1 Rx FIFO
26
UART1
UART1 Tx FIFO
27
UART2
UART2 Rx FIFO
28
UART2
UART2 Tx FIFO
29
UART3
UART3 Rx FIFO
30
UART3
UART3 Tx FIFO
31
UART4
UART4 Rx FIFO
32
UART4
UART4 Tx FIFO
33
UART5
UART5 Rx FIFO
34
UART5 / EPDC
UART5 Tx FIFO; EPDC DMA request
35
SAI1
SAI1 Rx FIFO
36
SAI1
SAI1 Tx FIFO
37
SAI2
SAI2 Rx FIFO
38
SAI2
SAI2 Tx FIFO
Table continues on the next page...
Chapter 3 Interrupts and DMA Events
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
189

<!-- page 190 -->

Table 3-2. SDMA event mapping (continued)
Event
Number
DMA Source
Description
39
SAI3
SAI3 Rx FIFO
40
SAI3
SAI3 Rx FIFO
41
SPDIF
SPDIF Rx DMA request
42
SPDIF
SPDIF Tx DMA request
43
UART7 / ENET1
UART7 Rx FIFO; ENET1 1588 Event0 out
44
UART7 / ENET1
UAR7 Tx FIFO; ENET1 1588 Event1 out
45
UART8 / ENET2
UART8 Rx FIFO; ENET2 1588 Event0 out
46
UART8 / ENET2
UART8 Tx FIFO; ENET2 1588 Event1 out
47
UART6 / ESAI
UART6 Tx FIFO; ESAI Tx FIFO DMA request
As shown in the table, some of the events are the output of a mux of two signals or
triggers. The selection of this mux is controlled by the general-purpose registers in
IOMUXC.
SDMA event mapping
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
190
NXP Semiconductors

