# Chapter 57: Universal Serial Bus 2.0 Integrated PHY (USB-PHY)

> Nguồn: `IMX6ULLRM.pdf` — trang 3901–3946

<!-- page 3901 -->

Chapter 57
Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
57.1
USB PHY Overview
The chip contains 2 integrated USB 2.0 PHY macrocells capable of connecting to USB
host/device systems at the USB low-speed (LS) rate of 1.5 Mbits/s, full-speed (FS) rate of
12 Mbits/s or at the USB 2.0 high-speed (HS) rate of 480 Mbits/s.
The integrated PHY provides a standard UTM interface. The USB_n_DN and
USB_n_DP pins connect directly to a USB connector.
The following subsections describe the external interfaces, internal interfaces, major
blocks, and programmable registers that comprise the integrated USB 2.0 PHY.
57.2
Operation
The UTM provides a 16-bit interface to the USB controller. This interface is clocked at
30 MHz.
• The digital portions of the USBPHY block include the UTMI, digital transmitter,
digital receiver, and the programmable registers.
• The analog transceiver section comprises an analog receiver and an analog
transmitter, as shown in Figure 57-1.
57.2.1
UTMI
The UTMI block handles the line_state bits, reset buffering, suspend distribution,
transceiver speed selection, and transceiver termination selection.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3901

<!-- page 3902 -->

The PLL supplies a 120 MHz signal to all of the digital logic. The UTMI block does a
final divide-by-four to develop the 30 MHz clock used in the interface.
57.2.2
Digital Transmitter
The digital transmitter receives the 16-bit transmit data from the USB controller and
handles the tx_valid, tx_validh and tx_ready handshake.
In addition, it contains the transmit serializer that converts the 16-bit parallel words at 30
MHz to a single bitstream at 480 Mbit for high-speed or 12 Mbit for full-speed or 1.5
Mbit for low-speed. It does this while implementing the bit-stuffing algorithm and the
NRZI encoder that are used to remove the DC component from the serial bitstream. The
output of this encoder is sent to the low-speed (LS), full-speed (FS) or high-speed (HS)
drivers in the analog transceiver section's transmitter block.
57.2.3
Digital Receiver
The digital receiver receives the raw serial bitstream from the low speed (LS) differential
transceiver, full speed (FS) differential transceiver, and a 9X, 480 MHz sampled data
from the high speed (HS) differential transceiver.
As the phase of the USB host transmitter shifts relative to the local PLL, the receiver
section's HS DLL tracks these changes to give a reliable sample of the incoming 480
Mbit/s bitstream. Since this sample point shifts relative to the PLL phase used by the
digital logic, a rate-matching elastic buffer is provided to cross this clock domain
boundary. Once the bitstream is in the local clock domain, an NRZI decoder and bit
unstuffer restore the original payload data bitstream and pass it to a deserializer and
holding register. The receive state machine handles the rx_valid, rx_validh, and
handshake with the USB controller. The handshake is not interlocked, in that there is no
rx_ready signal coming from the controller. The controller must take each 16-bit value as
presented by the PHY. The receive state machine provides an rx_active signal to the
controller that indicates when it is inside a valid packet (SYNC detected, and so on).
Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3902
NXP Semiconductors

<!-- page 3903 -->

57.2.4
Analog Receiver
The analog receiver comprises five differential receivers, two single-ended receivers, and
a 9X, 480 MHz HS data sampling module
, as shown in the figure below and described further in this section.
USB
Cable
HS Differential RCVR
Squelch
LS/FS Differential RCVR
HS_Disconnect_Detect
Single-Ended Detector SE_DP
Single-Ended Detector SE_DM
LS/FS DataDrive
Assert SE0
HS Current Source Enable
HS Data Drive
HS Drive Enable
FS Edge Mode Select
LS/FS Driver Output Enable
VDDIO
(3.3V)
1500Ω
RPU Enable
Transmitter
Receiver
Test and discrete
power-down controls
USB_Plugged_In_Detect
15000Ω
15000Ω
USB_n_DP
USB_n_DN
Figure 57-1. USB 2.0 PHY Analog Transceiver Block Diagram
57.2.4.1
HS Differential Receiver
The high-speed differential receiver is both a differential analog receiver and threshold
comparator. Its output is a one if the differential signal is greater than a 0-V threshold.
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3903

<!-- page 3904 -->

Otherwise, its output is 0. Its purpose is to discriminate the ± 400-mV differential voltage
resulting from the high-speed drivers current flow into the dual 45Ω terminations found
on each pin of the differential pair. The envelope or squelch detector, described below,
ensures that the differential signal has sufficient magnitude to be valid. The HS
differential receiver tolerates up to 500 mV of common mode offset.
57.2.4.2
Squelch Detector
The squelch detector is a differential analog receiver and threshold comparator.
Its output is 1, if the differential magnitude is less than a nominal 100 mV threshold.
Otherwise, its output is 0.
Its purpose is to invalidate the HS differential receiver when the incoming signal is
simply too low to receive reliably.
57.2.4.3
LS/FS Differential Receiver
The low-speed/full-speed differential receiver is both a differential analog receiver and
threshold comparator.
The crossover voltage falls between 1.3 V and 2.0 V. Its output is 1, when the
USB_n_DP line is above the crossover point and the USB_n_DN line is below the
crossover point. The digital receiver section decodes the receiver data into J or K state
according to the speed.
57.2.4.4
HS Disconnect Detector
It is a differential analog receiver and threshold comparator. It outputs high when
differential magnitude is greater than a nominal 575-mV threshold. Otherwise, it outputs
low.
57.2.4.5
USB Plugged-In Detector
The USB plugged-in detector looks for both USB_n_DP and USB_n_DN to be high.
There is a pair of large on-chip pullup resistors (200 KΩ) that hold both USB_n_DP and
USB_n_DN high when the USB cable is not attached. The USB plugged-in detector
signals a 0 in this case.
Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3904
NXP Semiconductors

<!-- page 3905 -->

When operating in device mode, the upstream port in host/hub interface contains a 15 KΩ
pulldown resistor which could easily override the 200 KΩ pullup resistor. When plugged
in, at least one signal in the pair will be low, which will force the plugged-in detector's
output high.
57.2.4.6
Single-Ended USB_DP Receiver
The single-ended USB_n_DP receiver output is high whenever the USB_n_DP input is
above its nominal 1.8 V threshold.
57.2.4.7
Single-Ended USB_DN Receiver
The single-ended USB_n_DN receiver output is high whenever the USB_n_DN input is
above its nominal 1.8 V threshold.
57.2.4.8
9X Oversample Module
The 9X oversample module uses nine identically spaced phases of the 480 MHz clock to
sample a high speed bit data. The squelch signal is sampled only 1X.
57.2.5
Analog Transmitter
The analog transmitter comprises two differential drivers: one for high-speed signaling
and one for full-speed signaling. It also contains the switchable 1.5 KΩ pullup resistor.
See Figure 57-1.
57.2.5.1
Switchable High-Speed 45Ω Termination Resistors
High-speed current mode differential signaling requires good 90 Ω differential
termination at each end of the USB cable. This results from switching in 45 Ω terminating
resistors from each signal line to ground at each end of the cable.
Because each signal is parallel terminated with 45 Ω at each end, each driver sees a 22.5
Ω load. This load impedance is much too low for full-speed signaling levels—hence the
need for switchable high-speed terminating resistors. Switchable trimming resistors are
provided to tune the actual termination resistance of each device, as shown in Figure
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3905

<!-- page 3906 -->

57-2. The HW_USBPHY_TX_TXCAL45DP bit field, for example, allows one of 16
trimming resistor values to be placed in parallel with the 45Ω terminator on the
USB_n_DP signal.
57.2.5.2
Low-Speed/Full-Speed Differential Driver
The low-speed/full-speed differential drivers are essentially low-impedance pulldown
devices that are switched in a differential mode for low-speed or full-speed signaling, that
is, either one or the other device is turned on to signal the "J" state or the "K" state.
57.2.5.3
High-Speed Differential Driver
The high-speed differential driver receives a 17.78 mA current from the constant current
source (Iref) and essentially steers it down either the USB_DP signal or the USB_DN
signal or alternatively to ground.
This current will produce approximately a 400 mV drop across the 22.5 Ω termination
seen by the driver when it is steered onto one of the signal lines. The approximately 17.78
mA current source is referenced back to the integrated voltage-band-gap (Vbg) circuit.
The Iref, Ibias, and V to I circuits are shared with the integrated battery charger.
57.2.5.4
Switchable 1.5KΩ USB_DP Pullup Resistor
This product contains a switchable 1.5 KΩ pullup resistor on the USB_n_DP signal.
This resistor is switched on to indicate to the host/hub controller that a full-speed-capable
device is on the USB cable, powered on, and ready. This resistor is switched off at
power-on reset so the host does not recognize a USB device until the processor software
enables the announcement of a full-speed device.
Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3906
NXP Semiconductors

<!-- page 3907 -->

57.2.5.5
Switchable 15KΩ USB_DP Pulldown Resistor
This product contains a switchable 15 KΩ pulldown resistor on both USB_n_DP and
USB_n_DN signals. This is used in host mode to indicate to the device controller that a
host is present.
current
switch
45Ω
LS/FS
DRVR
current
switch
45Ω
LS/FS
DRVR
Current Steering
17.78mA
USB
Cable
V to I
data_p,hs_xcvr
data_n,hs_xcvr
Vbg
To Battery
Charger
HW_USBPHY_TX_
TXCAL45DN
HW_USBPHY_TX_
TXCAL45DP
HW_USBPHY_PWD:
TXPWDV2I,
TXPWDIBIAS
data_p,data_n,
fs_hiz, hs_term,
tx_ls_en
Ibias
HW_USBPHY_TX:
TXENCAL45DP,DN
HW_USBPHY_TX:
D_CAL
Current trim
To External
Temperature
Sensor
USB_n_DP
USB_n_DN
Figure 57-2. USB 2.0 PHY Transmitter Block Diagram
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3907

<!-- page 3908 -->

57.2.6
Recommended Register Configuration for USB
Certification
The register settings in this section are recommended for passing USB certification.
The following settings lower the J/K levels to certifiable limits:
HW_USBPHY_TX_TXCAL45DP = 0x0
HW_USBPHY_TX_TXCAL45DN = 0x0
HW_USBPHY_TX_D_CAL = 0x7
57.2.7
Charger detection
The USB charger detector is a block that detects whether the upstream-facing device is
connected to a down-stream facing charger, either a dedicated USB charger or a host
charger.
The USB charger detector is comprised of two sub-blocks, namely the USB data-pin
contact detector and the charger detector.
This section details those two sub-blocks and gives the software flow of USB charger
detection. Finally, this chapter discusses the detection of a USB charger in case of a dead
battery.
57.2.7.1
Charger detect control table
Before we dive into the details of the detectors, we show the logic table of the control
signals to give the user an overall picture of the charger detector.
Table 57-1. Charger detection control table
EN_B
CHK_CHRG_B
CHK_CONTACT
Data pin contact
detector
Charger detector
0
1
1
Enabled
Disabled
0
0
x(don't care)
Disabled
Enabled
1
x
x(don't care)
Disabled
Disabled
Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3908
NXP Semiconductors

<!-- page 3909 -->

57.2.7.2
Data pin contact detector
According to Battery Charging Specification (rev 1.2), USB plugs and receptacles are
designed such that when the plug is inserted into the receptacle, the power pins make
contact before the data pins make contact. Therefore, there is inevitably a time interval
during which USB_n_VBUS has been observed by the device while the USB_n_DP and
USB_n_DN pins are not still pending for contact. The USB data pin contact detector is
designed to give the software an indication of the contact of the data pins.
To enable the USB data pin contact detector, the user should set the CHK_CONTACT bit
of the USB1_CHRG_DETECT register to 1 and monitor the PLUG_CONTACT bit
status of the USB1_CHRG_DETECT_STAT register. If PLUG_CONTACT is 1, then it
indicates that the data pins have make good contacts, otherwise the user should continue
to wait until this bit is set.
According to Table 1, it should be noted that the data pin contact detector only works
when EN_B=0 and CHK_CHRG_B=1, both bit being of the USB1_CHRG_DETECT
register.
57.2.7.3
Charger detector
Once the data pins make contact, the user should enable the charger detector by clearing
the CHK_CHRG_B bit that is low-active. Then the user should wait for 40ms and then
check the status bit of CHRG_DETECTED in register hw_anadig_usb1_chrg_det_stat.
CHRG_DETECTED=1 means that the device is connected to a charger, either a
dedicated charger or a charging downstream port (or equivalently called a host charger,
or charging host). To further differentiate between a host charger and a dedicated charger,
the user is suggested to pull up USB_n_DP signaling a connect event to the host. Then
the user should monitor the USB_n_DN line status. If USB_n_DN=1, then the charger is
a dedicated charger; if USB_n_DN=0, then it is a host charger.
57.2.7.4
Charger detection software flow
Upon seeing VBUS, the software should follow the software flow for the charger
detection process. The flow chart mentions the "enable the vdd3p0 current limiter".
Please refer to the power chapter for details.
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3909

<!-- page 3910 -->

Start 
USBn_VBUS_DETECT_STAT .
VBUSVALID=1'b1?
Turn off the charger detector
(set EN_B and CHK_CHRG_B to 1)
In register USBn_VBUS_DETECT
N
Y
Continue normal boot up
Set CHK_CHRG_B = 1'b1
And CHK_CONTACT = 1'b1
USB plug 
contacted ?
Set CHK_CONTACT=1'b0
And CHK_CHRG_B = 1'b0
Is it a 
charger?
(monitor the 
PLUG_CONTACT bit)
(monitor the 
CHRG_DETECTED bit)
Y
N
Y
Turn off the 
charger detector 
Is DM high ?
(monitor the 
DM_STATE bit)
Y
N
Dedicated Charger
Charging Downstream 
Port
Continue boot up
(can draw 1.8A)
Continue boot up
(can draw 900mA)
(set EN_B and 
CHK_CHRG_B to 1)
Turn off the 
charger detector 
Continue boot up
Timeout
N
Wait for > 40ms
Wait for > 40ms
Initiliaze system and USB 
(can draw high current- 1.5A)
Pull up DP
(Recommend to draw 
less than 900mA)
VBUS is coming from a 
dedicated power supply. 
No USB actions required.
pull DP high to 
enumerate
(set EN_B and 
CHK_CHRG_B to 1)
Initiliaze system and USB 
(can only draw 100mA current)
Continue boot up
Enable the vdd3p0 curret limiter
Set PMU_REG_3P0.ENABLE_ILIMIT = 1'b1
and PMU_REG_3P0.ENABLE_LINREG = 1'b1
Disable  the vdd3p0 curret limiter
Set PMU_REG_3P0.
ENABLE_ILIMIT = 1'b0
Figure 57-3. USBPHY Charger Detection Software Flow
Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3910
NXP Semiconductors

<!-- page 3911 -->

57.2.7.5
Dead Battery Protect
All the descriptions above are based on the assumption that all the power supplies have
been on when the device is plugged into a remote host (or charger). However, there are
cases when the local battery of the portable device has been so depleted that the system
could not be turned on. In such scenarios the user may prefer a method of signaling the
external power management unit (PMIC) the existence of the USB charger to draw a
current larger than 100mA from the remote host to speed up system boot up or battery
charging. The charger detector indeed supports this function.
When we have a fully depleted battery, all the power supplies might be off. Upon
insertion of the 5V, the supplies are brought up by the external PMIC and the internal
regulators. Due to the 100mA inrush current limit of the USB spec, we cannot draw
larger than 100mA current which might be a limit for system boot-up. Since by default,
EN_B=0, CHK_CHRG_B=0 and CHK_CONTACT=1, the usb charger detector is
automatically enabled without any software operation needed and it can signal the
external PMIC the existence of a USB charger through the open-drain output pin
USB_OTG_CHD_B. This pin should be pulled up to an external voltage that is
acceptable to the PMIC. If this signal is low, then the PMIC can get that the device is
connected to a charger. In this case, the PMIC can draw more than 100mA current from
the USB.
It should be noted that this function requires cooperation between the chip and the
external PMIC. It is suggested that the user consult NXP for such use cases.
57.3
USB PHY Memory Map/Register Definition
USBPHY Hardware Register Format Summary
USBPHY memory map
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
20C_9000
USB PHY Power-Down Register (USBPHY1_PWD)
32
R/W
001E_1C00h
57.3.1/3914
20C_9004
USB PHY Power-Down Register (USBPHY1_PWD_SET)
32
R/W
001E_1C00h
57.3.1/3914
20C_9008
USB PHY Power-Down Register (USBPHY1_PWD_CLR)
32
R/W
001E_1C00h
57.3.1/3914
20C_900C
USB PHY Power-Down Register (USBPHY1_PWD_TOG)
32
R/W
001E_1C00h
57.3.1/3914
20C_9010
USB PHY Transmitter Control Register (USBPHY1_TX)
32
R/W
1006_0607h
57.3.2/3916
Table continues on the next page...
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3911

<!-- page 3912 -->

USBPHY memory map (continued)
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
20C_9014
USB PHY Transmitter Control Register
(USBPHY1_TX_SET)
32
R/W
1006_0607h
57.3.2/3916
20C_9018
USB PHY Transmitter Control Register
(USBPHY1_TX_CLR)
32
R/W
1006_0607h
57.3.2/3916
20C_901C
USB PHY Transmitter Control Register
(USBPHY1_TX_TOG)
32
R/W
1006_0607h
57.3.2/3916
20C_9020
USB PHY Receiver Control Register (USBPHY1_RX)
32
R/W
0000_0000h
57.3.3/3917
20C_9024
USB PHY Receiver Control Register (USBPHY1_RX_SET)
32
R/W
0000_0000h
57.3.3/3917
20C_9028
USB PHY Receiver Control Register (USBPHY1_RX_CLR)
32
R/W
0000_0000h
57.3.3/3917
20C_902C
USB PHY Receiver Control Register (USBPHY1_RX_TOG)
32
R/W
0000_0000h
57.3.3/3917
20C_9030
USB PHY General Control Register (USBPHY1_CTRL)
32
R/W
C020_0000h
57.3.4/3919
20C_9034
USB PHY General Control Register
(USBPHY1_CTRL_SET)
32
R/W
C020_0000h
57.3.4/3919
20C_9038
USB PHY General Control Register
(USBPHY1_CTRL_CLR)
32
R/W
C020_0000h
57.3.4/3919
20C_903C
USB PHY General Control Register
(USBPHY1_CTRL_TOG)
32
R/W
C020_0000h
57.3.4/3919
20C_9040
USB PHY Status Register (USBPHY1_STATUS)
32
R/W
0000_0000h
57.3.5/3922
20C_9050
USB PHY Debug Register (USBPHY1_DEBUG)
32
R/W
7F18_0000h
57.3.6/3924
20C_9054
USB PHY Debug Register (USBPHY1_DEBUG_SET)
32
R/W
7F18_0000h
57.3.6/3924
20C_9058
USB PHY Debug Register (USBPHY1_DEBUG_CLR)
32
R/W
7F18_0000h
57.3.6/3924
20C_905C
USB PHY Debug Register (USBPHY1_DEBUG_TOG)
32
R/W
7F18_0000h
57.3.6/3924
20C_9060
UTMI Debug Status Register 0
(USBPHY1_DEBUG0_STATUS)
32
R
0000_0000h
57.3.7/3926
20C_9070
UTMI Debug Status Register 1 (USBPHY1_DEBUG1)
32
R/W
0000_1000h
57.3.8/3927
20C_9074
UTMI Debug Status Register 1 (USBPHY1_DEBUG1_SET)
32
R/W
0000_1000h
57.3.8/3927
20C_9078
UTMI Debug Status Register 1 (USBPHY1_DEBUG1_CLR)
32
R/W
0000_1000h
57.3.8/3927
20C_907C
UTMI Debug Status Register 1 (USBPHY1_DEBUG1_TOG)
32
R/W
0000_1000h
57.3.8/3927
20C_9080
UTMI RTL Version (USBPHY1_VERSION)
32
R
0402_0000h
57.3.9/3928
20C_A000
USB PHY Power-Down Register (USBPHY2_PWD)
32
R/W
001E_1C00h
57.3.1/3914
20C_A004
USB PHY Power-Down Register (USBPHY2_PWD_SET)
32
R/W
001E_1C00h
57.3.1/3914
20C_A008
USB PHY Power-Down Register (USBPHY2_PWD_CLR)
32
R/W
001E_1C00h
57.3.1/3914
20C_A00C
USB PHY Power-Down Register (USBPHY2_PWD_TOG)
32
R/W
001E_1C00h
57.3.1/3914
20C_A010
USB PHY Transmitter Control Register (USBPHY2_TX)
32
R/W
1006_0607h
57.3.2/3916
20C_A014
USB PHY Transmitter Control Register
(USBPHY2_TX_SET)
32
R/W
1006_0607h
57.3.2/3916
20C_A018
USB PHY Transmitter Control Register
(USBPHY2_TX_CLR)
32
R/W
1006_0607h
57.3.2/3916
20C_A01C
USB PHY Transmitter Control Register
(USBPHY2_TX_TOG)
32
R/W
1006_0607h
57.3.2/3916
20C_A020
USB PHY Receiver Control Register (USBPHY2_RX)
32
R/W
0000_0000h
57.3.3/3917
Table continues on the next page...
USB PHY Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3912
NXP Semiconductors

<!-- page 3913 -->

USBPHY memory map (continued)
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
20C_A024
USB PHY Receiver Control Register (USBPHY2_RX_SET)
32
R/W
0000_0000h
57.3.3/3917
20C_A028
USB PHY Receiver Control Register (USBPHY2_RX_CLR)
32
R/W
0000_0000h
57.3.3/3917
20C_A02C
USB PHY Receiver Control Register (USBPHY2_RX_TOG)
32
R/W
0000_0000h
57.3.3/3917
20C_A030
USB PHY General Control Register (USBPHY2_CTRL)
32
R/W
C020_0000h
57.3.4/3919
20C_A034
USB PHY General Control Register
(USBPHY2_CTRL_SET)
32
R/W
C020_0000h
57.3.4/3919
20C_A038
USB PHY General Control Register
(USBPHY2_CTRL_CLR)
32
R/W
C020_0000h
57.3.4/3919
20C_A03C
USB PHY General Control Register
(USBPHY2_CTRL_TOG)
32
R/W
C020_0000h
57.3.4/3919
20C_A040
USB PHY Status Register (USBPHY2_STATUS)
32
R/W
0000_0000h
57.3.5/3922
20C_A050
USB PHY Debug Register (USBPHY2_DEBUG)
32
R/W
7F18_0000h
57.3.6/3924
20C_A054
USB PHY Debug Register (USBPHY2_DEBUG_SET)
32
R/W
7F18_0000h
57.3.6/3924
20C_A058
USB PHY Debug Register (USBPHY2_DEBUG_CLR)
32
R/W
7F18_0000h
57.3.6/3924
20C_A05C
USB PHY Debug Register (USBPHY2_DEBUG_TOG)
32
R/W
7F18_0000h
57.3.6/3924
20C_A060
UTMI Debug Status Register 0
(USBPHY2_DEBUG0_STATUS)
32
R
0000_0000h
57.3.7/3926
20C_A070
UTMI Debug Status Register 1 (USBPHY2_DEBUG1)
32
R/W
0000_1000h
57.3.8/3927
20C_A074
UTMI Debug Status Register 1 (USBPHY2_DEBUG1_SET)
32
R/W
0000_1000h
57.3.8/3927
20C_A078
UTMI Debug Status Register 1 (USBPHY2_DEBUG1_CLR)
32
R/W
0000_1000h
57.3.8/3927
20C_A07C
UTMI Debug Status Register 1 (USBPHY2_DEBUG1_TOG)
32
R/W
0000_1000h
57.3.8/3927
20C_A080
UTMI RTL Version (USBPHY2_VERSION)
32
R
0402_0000h
57.3.9/3928
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3913

<!-- page 3914 -->

57.3.1
USB PHY Power-Down Register (USBPHYx_PWDn)
The USB PHY Power-Down Register provides overall control of the PHY power state.
Before programming this register, the PHY clocks must be enabled in registers
USBPHYx_CTRLn and CCM_ANALOG_USBPHYx_PLL_480_CTRLn.
Address: Base address + 0h offset + (4d × i), where i=0d to 3d
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
RSVD2
RXPWDRX
RXPWDDIFF
RXPWD1PT1
RXPWDENV
RSVD
1
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
RSVD1
TXPWDV2I
TXPWDIBIAS
TXPWDFS
RSVD0
W
Reset
0
0
0
1
1
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
USBPHYx_PWDn field descriptions
Field
Description
31–21
RSVD2
Reserved.
20
RXPWDRX
0 = Normal operation.
1 = Power-down the entire USB PHY receiver block except for the full-speed differential receiver.
Note that this bit will be auto cleared if there is USB wakeup event while ENAUTOCLR_PHY_PWD bit of
USBPHYx_CTRL is enabled.
19
RXPWDDIFF
0 = Normal operation.
1 = Power-down the USB high-speed differential receiver.
Table continues on the next page...
USB PHY Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3914
NXP Semiconductors

<!-- page 3915 -->

USBPHYx_PWDn field descriptions (continued)
Field
Description
Note that this bit will be auto cleared if there is USB wakeup event while ENAUTOCLR_PHY_PWD bit of
USBPHYx_CTRL is enabled.
18
RXPWD1PT1
0 = Normal operation.
1 = Power-down the USB full-speed differential receiver.
Note that this bit will be auto cleared if there is USB wakeup event while ENAUTOCLR_PHY_PWD bit of
USBPHYx_CTRL is enabled.
17
RXPWDENV
0 = Normal operation.
1 = Power-down the USB high-speed receiver envelope detector (squelch signal).
Note that this bit will be auto cleared if there is USB wakeup event while ENAUTOCLR_PHY_PWD bit of
USBPHYx_CTRL is enabled.
16–13
RSVD1
Reserved.
12
TXPWDV2I
0 = Normal operation.
1 = Power-down the USB PHY transmit V-to-I converter and the current mirror.
Note that this bit will be auto cleared if there is USB wakeup event while ENAUTOCLR_PHY_PWD bit of
USBPHYx_CTRL is enabled.
Note that these circuits are shared with the battery charge circuit. Setting this to 1 does not power-down
these circuits, unless the corresponding bit in the battery charger is also set for power-down.
11
TXPWDIBIAS
0 = Normal operation.
1 = Power-down the USB PHY current bias block for the transmitter. This bit should be set only when the
USB is in suspend mode. This effectively powers down the entire USB transmit path.
Note that this bit will be auto cleared if there is USB wakeup event while ENAUTOCLR_PHY_PWD bit of
USBPHYx_CTRL is enabled.
Note that these circuits are shared with the battery charge circuit. Setting this bit to 1 does not power-
down these circuits, unless the corresponding bit in the battery charger is also set for power-down.
10
TXPWDFS
0 = Normal operation.
1 = Power-down the USB full-speed drivers. This turns off the current starvation sources and puts the
drivers into high-impedance output.
Note that this bit will be auto cleared if there is USB wakeup event while ENAUTOCLR_PHY_PWD bit of
USBPHYx_CTRL is enabled.
RSVD0
Reserved.
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3915

<!-- page 3916 -->

57.3.2
USB PHY Transmitter Control Register (USBPHYx_TXn)
The USB PHY Transmitter Control Register handles the transmit controls.
Address: Base address + 10h offset + (4d × i), where i=0d to 3d
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
RSVD5
USBPHY_TX_
EDGECTRL
RSVD2
TXCAL45DP
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
0
0
0
0
1
1
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
RSVD1
TXCAL45DN
RSVD0
D_CAL
W
Reset
0
0
0
0
0
1
1
0
0
0
0
0
0
1
1
1
USBPHYx_TXn field descriptions
Field
Description
31–29
RSVD5
Reserved.
28–26
USBPHY_TX_
EDGECTRL
Controls the edge-rate of the current sensing transistors used in HS transmit. NOT FOR CUSTOMER
USE.
25–20
RSVD2
Reserved.
19–16
TXCAL45DP
Decode to select a 45-Ohm resistance to the USB_DP output pin. Maximum resistance = 0000.
Resistance is centered by design at 0110.
15–12
RSVD1
Reserved.
Note: This bit should remain clear.
11–8
TXCAL45DN
Decode to select a 45-Ohm resistance to the USB_DN output pin. Maximum resistance = 0000.
Resistance is centered by design at 0110.
7–4
RSVD0
Reserved.
Note: This bit should remain clear.
D_CAL
Resistor Trimming Code:
0000 = 0.16%
0111 = Nominal
1111 = +25%
USB PHY Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3916
NXP Semiconductors

<!-- page 3917 -->

57.3.3
USB PHY Receiver Control Register (USBPHYx_RXn)
The USB PHY Receiver Control Register handles receive path controls.
Address: Base address + 20h offset + (4d × i), where i=0d to 3d
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
RSVD2
RXDBYPASS
RSVD1
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
RSVD1
DISCONADJ
RSVD0
ENVADJ
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
USBPHYx_RXn field descriptions
Field
Description
31–23
RSVD2
Reserved.
22
RXDBYPASS
0 = Normal operation.
1 = Use the output of the USB_DP single-ended receiver in place of the full-speed differential receiver.
This test mode is intended for lab use only.
21–7
RSVD1
Reserved.
Table continues on the next page...
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3917

<!-- page 3918 -->

USBPHYx_RXn field descriptions (continued)
Field
Description
6–4
DISCONADJ
The DISCONADJ field adjusts the trip point for the disconnect detector:
000 = Trip-Level Voltage is 0.57500 V
001 = Trip-Level Voltage is 0.56875 V
010 = Trip-Level Voltage is 0.58125 V
011 = Trip-Level Voltage is 0.58750 V
1XX = Reserved
3
RSVD0
Reserved.
ENVADJ
The ENVADJ field adjusts the trip point for the envelope detector.
000 = Trip-Level Voltage is 0.12500 V
001 = Trip-Level Voltage is 0.10000 V
010 = Trip-Level Voltage is 0.13750 V
011 = Trip-Level Voltage is 0.15000 V
1XX = Reserved
USB PHY Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3918
NXP Semiconductors

<!-- page 3919 -->

57.3.4
USB PHY General Control Register (USBPHYx_CTRLn)
The USB PHY General Control Register handles OTG and Host controls. This register
also includes interrupt enables and connectivity detect enables and results.
Address: Base address + 30h offset + (4d × i), where i=0d to 3d
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
SFTRST
CLKGATE
UTMI_SUSPENDM
HOST_FORCE_LS_SE0
OTG_ID_VALUE
RSVD1
FSDLL_RST_EN
ENVBUSCHG_WKUP
ENIDCHG_WKUP
ENDPDMCHG_WKUP
ENAUTOCLR_PHY_PWD
ENAUTOCLR_CLKGATE
ENAUTO_PWRON_PLL
WAKEUP_IRQ
ENIRQWAKEUP
W
Reset
1
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
ENUTMILEVEL3
ENUTMILEVEL2
DATA_ON_LRADC
DEVPLUGIN_IRQ
ENIRQDEVPLUGIN
RESUME_IRQ
ENIRQRESUMEDETECT
RESUMEIRQSTICKY
ENOTGIDDETECT
OTG_ID_CHG_IRQ
DEVPLUGIN_POLARITY
ENDEVPLUGINDETECT
HOSTDISCONDETECT_IRQ
ENIRQHOSTDISCON
ENHOSTDISCONDETECT
ENOTG_ID_CHG_IRQ
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
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3919

<!-- page 3920 -->

USBPHYx_CTRLn field descriptions
Field
Description
31
SFTRST
Writing a 1 to this bit will soft-reset the USBPHYx_PWD, USBPHYx_TX, USBPHYx_RX, and
USBPHYx_CTRL registers. Set to 0 to release the PHY from reset.
30
CLKGATE
Gate UTMI Clocks. Clear to 0 to run clocks. Set to 1 to gate clocks. Set this to save power
while the USB is not actively being used. Configuration state is kept while the clock is gated.
Note this bit can be auto-cleared if there is any wakeup event when USB is suspended while
ENAUTOCLR_CLKGATE bit of USBPHYx_CTRL is enabled.
29
UTMI_SUSPENDM
Used by the PHY to indicate a powered-down state. If all the power-down bits in the
USBPHYx_PWD are enabled, UTMI_SUSPENDM will be 0, otherwise 1. UTMI_SUSPENDM
is negative logic, as required by the UTMI specification.
28
HOST_FORCE_LS_SE0
Forces the next FS packet that is transmitted to have a EOP with LS timing. This bit is used in
host mode for the resume sequence. After the packet is transferred, this bit is cleared. The
design can use this function to force the LS SE0 or use the
USBPHYx_CTRL_UTMI_SUSPENDM to trigger this event when leaving suspend. This bit is
used in conjunction with USBPHYx_DEBUG_HOST_RESUME_DEBUG.
27
OTG_ID_VALUE
Almost same as OTGID_STATUS in USBPHYx_STATUS Register. The only difference is that
OTG_ID_VALUE has debounce logic to filter the glitches on ID Pad.
26–25
RSVD1
Reserved.
24
FSDLL_RST_EN
Enables the feature to reset the FSDLL lock detection logic at the end of each TX packet.
23
ENVBUSCHG_WKUP
Enables the feature to wakeup USB if VBUS is toggled when USB is suspended.
22
ENIDCHG_WKUP
Enables the feature to wakeup USB if ID is toggled when USB is suspended.
21
ENDPDMCHG_WKUP
Enables the feature to wakeup USB if DP/DM is toggled when USB is suspended. This bit is
enabled by default.
20
ENAUTOCLR_PHY_PWD
Enables the feature to auto-clear the PWD register bits in USBPHYx_PWD if there is wakeup
event while USB is suspended. This should be enabled if needs to support auto wakeup
without S/W's interaction.
19
ENAUTOCLR_CLKGATE
Enables the feature to auto-clear the CLKGATE bit if there is wakeup event while USB is
suspended. This should be enabled if needs to support auto wakeup without S/W's interaction.
18
ENAUTO_PWRON_PLL
Enables the feature to auto-enable the POWER bit of HW_CLKCTRL_PLLxCTRL0 if there is
wakeup event if USB is suspended. This should be enabled if needs to support auto wakeup
without S/W's interaction.
17
WAKEUP_IRQ
Indicates that there is a wakeup event. Reset this bit by writing a 1 to the clear address space
and not by a general write.
16
ENIRQWAKEUP
Enables interrupt for the wakeup events.
15
ENUTMILEVEL3
Enables UTMI+ Level3. This should be enabled if needs to support external FS Hub with LS
device connected
14
ENUTMILEVEL2
Enables UTMI+ Level2. This should be enabled if needs to support LS device
13
DATA_ON_LRADC
Enables the LRADC to monitor USB_DP and USB_DM. This is for use in non-USB modes
only.
12
DEVPLUGIN_IRQ
Indicates that the device is connected. Reset this bit by writing a 1 to the clear address space
and not by a general write.
Table continues on the next page...
USB PHY Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3920
NXP Semiconductors

<!-- page 3921 -->

USBPHYx_CTRLn field descriptions (continued)
Field
Description
11
ENIRQDEVPLUGIN
Enables interrupt for the detection of connectivity to the USB line.
10
RESUME_IRQ
Indicates that the host is sending a wake-up after suspend. This bit is also set on a reset
during suspend. Use this bit to wake up from suspend for either the resume or the reset case.
Reset this bit by writing a 1 to the clear address space and not by a general write.
9
ENIRQRESUMEDETECT
Enables interrupt for detection of a non-J state on the USB line. This should only be enabled
after the device has entered suspend mode.
8
RESUMEIRQSTICKY
Set to 1 will make RESUME_IRQ bit a sticky bit until software clear it. Set to 0, RESUME_IRQ
only set during the wake-up period.
7
ENOTGIDDETECT
Enables circuit to detect resistance of MiniAB ID pin.
6
OTG_ID_CHG_IRQ
OTG ID change interrupt. Indicates the value of ID pin changed.
5
DEVPLUGIN_POLARITY
For device mode, if this bit is cleared to 0, then it trips the interrupt if the device is plugged in. If
set to 1, then it trips the interrupt if the device is unplugged.
4
ENDEVPLUGINDETECT
For device mode, enables 200-KOhm pullups for detecting connectivity to the host.
3
HOSTDISCONDETECT_
IRQ
Indicates that the device has disconnected in high-speed mode. Reset this bit by writing a 1 to
the clear address space and not by a general write.
2
ENIRQHOSTDISCON
Enables interrupt for detection of disconnection to Device when in high-speed host mode. This
should be enabled after ENDEVPLUGINDETECT is enabled.
1
ENHOSTDISCONDETECT
For host mode, enables high-speed disconnect detector. This signal allows the override of
enabling the detection that is normally done in the UTMI controller. The UTMI controller
enables this circuit whenever the host sends a start-of-frame packet.
SW shall set this bit when it found the high-speed device is connected, suggested during bus
reset, after found high-speed device in USB_PORTSC1.PSPD).
SW shall make sure this bit is not set at the end of resume, otherwise a wrong disconnect
status may be detected. Suggest clear it after set USB_PORTSC1.SUSP, set it again after
resume is ended(USB_PORTSC1.FPR==0).
0
ENOTG_ID_CHG_IRQ
Enable OTG_ID_CHG_IRQ.
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3921

<!-- page 3922 -->

57.3.5
USB PHY Status Register (USBPHYx_STATUS)
The USB PHY Status Register holds results of IRQ and other detects.
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
R
RSVD4
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
USB PHY Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3922
NXP Semiconductors

<!-- page 3923 -->

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
RSVD4
RESUME_STATUS
RSVD3
OTGID_STATUS
RSVD2
DEVPLUGIN_STATUS
RSVD1
HOSTDISCONDETECT_STATUS
RSVD0
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
USBPHYx_STATUS field descriptions
Field
Description
31–11
RSVD4
Reserved.
10
RESUME_STATUS
Indicates that the host is sending a wake-up after suspend and has triggered an interrupt.
9
RSVD3
Reserved.
8
OTGID_STATUS
Indicates the results of ID pin on MiniAB plug.
False (0) is when ID resistance is less than Ra_Plug_ID, indicating host (A) side.
True (1) is when ID resistance is greater than Rb_Plug_ID, indicating device (B) side.
7
RSVD2
Reserved.
6
DEVPLUGIN_STATUS
Indicates that the device has been connected on the USB_DP and USB_DM lines.
5–4
RSVD1
Reserved.
3
HOSTDISCONDETECT_
STATUS
Indicates that the device has disconnected while in high-speed host mode.
RSVD0
Reserved.
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3923

<!-- page 3924 -->

57.3.6
USB PHY Debug Register (USBPHYx_DEBUGn)
This register is used to debug the USB PHY.
Address: Base address + 50h offset + (4d × i), where i=0d to 3d
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
RSVD3
CLKGATE
HOST_RESUME_DEBUG
SQUELCHRESETLENGTH
ENSQUELCHRESET
RSVD2
SQUELCHRESETCOUNT
W
Reset
0
1
1
1
1
1
1
1
0
0
0
1
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
RSVD1
ENTX2RXCOUNT
TX2RXCOUNT
RSVD0
ENHSTPULLDOWN
HSTPULLDOWN
DEBUG_INTERFACE_HOLD
OTGIDPIOLOCK
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
USB PHY Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3924
NXP Semiconductors

<!-- page 3925 -->

USBPHYx_DEBUGn field descriptions
Field
Description
31
RSVD3
Reserved.
30
CLKGATE
Gate Test Clocks.
Clear to 0 for running clocks.
Set to 1 to gate clocks. Set this to save power while the USB is not actively being used.
Configuration state is kept while the clock is gated.
29
HOST_RESUME_DEBUG
Choose to trigger the host resume SE0 with HOST_FORCE_LS_SE0 = 0 or UTMI_SUSPEND
= 1.
28–25
SQUELCHRESETLENGTH
Duration of RESET in terms of the number of 480-MHz cycles.
24
ENSQUELCHRESET
Set bit to allow squelch to reset high-speed receive.
23–21
RSVD2
Reserved.
20–16
SQUELCHRESETCOUNT
Delay in between the detection of squelch to the reset of high-speed RX.
15–13
RSVD1
Reserved.
12
ENTX2RXCOUNT
Set this bit to allow a countdown to transition in between TX and RX.
11–8
TX2RXCOUNT
Delay in between the end of transmit to the beginning of receive. This is a Johnson count value
and thus will count to 8.
7–6
RSVD0
Reserved.
5–4
ENHSTPULLDOWN
Set bit 5 to 1 to override the control of the USB_DP 15-KOhm pulldown.
Set bit 4 to 1 to override the control of the USB_DM 15-KOhm pulldown.
Clear to 0 to disable.
3–2
HSTPULLDOWN
Set bit 3 to 1 to pull down 15-KOhm on USB_DP line.
Set bit 2 to 1 to pull down 15-KOhm on USB_DM line.
Clear to 0 to disable.
1
DEBUG_INTERFACE_
HOLD
Use holding registers to assist in timing for external UTMI interface.
0
OTGIDPIOLOCK
Once OTG ID from USBPHYx_STATUS_OTGID_STATUS, use this to hold the value. This is to
save power for the comparators that are used to determine the ID status.
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3925

<!-- page 3926 -->

57.3.7
UTMI Debug Status Register 0
(USBPHYx_DEBUG0_STATUS)
The UTMI Debug Status Register 0 holds multiple views for counters and status of state
machines. This is used in conjunction with the USBPHYx_DEBUG1_DBG_ADDRESS
field to choose which function to view. The default is described in the bit fields below
and is used to count errors.
Address: Base address + 60h offset
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
SQUELCH_COUNT
UTMI_RXERROR_FAIL_COUNT
LOOP_BACK_FAIL_COUNT
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
USBPHYx_DEBUG0_STATUS field descriptions
Field
Description
31–26
SQUELCH_
COUNT
Running count of the squelch reset instead of normal end for HS RX.
25–16
UTMI_
RXERROR_
FAIL_COUNT
Running count of the UTMI_RXERROR.
LOOP_BACK_
FAIL_COUNT
Running count of the failed pseudo-random generator loopback. Each time entering testmode, counter
goes to 900D and will count up for every detected packet failure in digital/analog loopback tests.
USB PHY Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3926
NXP Semiconductors

<!-- page 3927 -->

57.3.8
UTMI Debug Status Register 1 (USBPHYx_DEBUG1n)
Chooses the muxing of the debug register to be shown in
USBPHYx_DEBUG0_STATUS.
Address: Base address + 70h offset + (4d × i), where i=0d to 3d
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
RSVD1
ENTA
ILADJ
VD
RSVD0
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
0
0
USBPHYx_DEBUG1n field descriptions
Field
Description
31–15
RSVD1
Reserved.
14–13
ENTAILADJVD
Delay increment of the rise of squelch:
00 = Delay is nominal
01 = Delay is +20%
10 = Delay is -20%
11 = Delay is -40%
RSVD0
Reserved.
Note: This bit should remain clear.
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3927

<!-- page 3928 -->

57.3.9
UTMI RTL Version (USBPHYx_VERSION)
Fields for RTL Version.
Address: Base address + 80h offset
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
MAJOR
MINOR
STEP
W
Reset 0
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
0
0
0
0
0
0
0
USBPHYx_VERSION field descriptions
Field
Description
31–24
MAJOR
Fixed read-only value reflecting the MAJOR field of the RTL version.
23–16
MINOR
Fixed read-only value reflecting the MINOR field of the RTL version.
STEP
Fixed read-only value reflecting the stepping of the RTL version.
57.4
USB Analog Memory Map/Register Definition
USB_ANALOG memory map
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
20C_81A0
USB VBUS Detect Register
(USB_ANALOG_USB1_VBUS_DETECT)
32
R/W
0010_0004h
57.4.1/3930
20C_81A4
USB VBUS Detect Register
(USB_ANALOG_USB1_VBUS_DETECT_SET)
32
R/W
0010_0004h
57.4.1/3930
20C_81A8
USB VBUS Detect Register
(USB_ANALOG_USB1_VBUS_DETECT_CLR)
32
R/W
0010_0004h
57.4.1/3930
20C_81AC
USB VBUS Detect Register
(USB_ANALOG_USB1_VBUS_DETECT_TOG)
32
R/W
0010_0004h
57.4.1/3930
20C_81B0
USB Charger Detect Register
(USB_ANALOG_USB1_CHRG_DETECT)
32
R/W
0000_0000h
57.4.2/3931
20C_81B4
USB Charger Detect Register
(USB_ANALOG_USB1_CHRG_DETECT_SET)
32
R/W
0000_0000h
57.4.2/3931
20C_81B8
USB Charger Detect Register
(USB_ANALOG_USB1_CHRG_DETECT_CLR)
32
R/W
0000_0000h
57.4.2/3931
20C_81BC
USB Charger Detect Register
(USB_ANALOG_USB1_CHRG_DETECT_TOG)
32
R/W
0000_0000h
57.4.2/3931
Table continues on the next page...
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3928
NXP Semiconductors

<!-- page 3929 -->

USB_ANALOG memory map (continued)
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
20C_81C0
USB VBUS Detect Status Register
(USB_ANALOG_USB1_VBUS_DETECT_STAT)
32
R
0000_0000h
57.4.3/3933
20C_81D0
USB Charger Detect Status Register
(USB_ANALOG_USB1_CHRG_DETECT_STAT)
32
R
0000_0000h
57.4.4/3935
20C_81F0
USB Misc Register (USB_ANALOG_USB1_MISC)
32
R/W
0000_0002h
57.4.5/3936
20C_81F4
USB Misc Register (USB_ANALOG_USB1_MISC_SET)
32
R/W
0000_0002h
57.4.5/3936
20C_81F8
USB Misc Register (USB_ANALOG_USB1_MISC_CLR)
32
R/W
0000_0002h
57.4.5/3936
20C_81FC
USB Misc Register (USB_ANALOG_USB1_MISC_TOG)
32
R/W
0000_0002h
57.4.5/3936
20C_8200
USB VBUS Detect Register
(USB_ANALOG_USB2_VBUS_DETECT)
32
R/W
0010_0004h
57.4.6/3937
20C_8204
USB VBUS Detect Register
(USB_ANALOG_USB2_VBUS_DETECT_SET)
32
R/W
0010_0004h
57.4.6/3937
20C_8208
USB VBUS Detect Register
(USB_ANALOG_USB2_VBUS_DETECT_CLR)
32
R/W
0010_0004h
57.4.6/3937
20C_820C
USB VBUS Detect Register
(USB_ANALOG_USB2_VBUS_DETECT_TOG)
32
R/W
0010_0004h
57.4.6/3937
20C_8210
USB Charger Detect Register
(USB_ANALOG_USB2_CHRG_DETECT)
32
R/W
0000_0000h
57.4.7/3939
20C_8214
USB Charger Detect Register
(USB_ANALOG_USB2_CHRG_DETECT_SET)
32
R/W
0000_0000h
57.4.7/3939
20C_8218
USB Charger Detect Register
(USB_ANALOG_USB2_CHRG_DETECT_CLR)
32
R/W
0000_0000h
57.4.7/3939
20C_821C
USB Charger Detect Register
(USB_ANALOG_USB2_CHRG_DETECT_TOG)
32
R/W
0000_0000h
57.4.7/3939
20C_8220
USB VBUS Detect Status Register
(USB_ANALOG_USB2_VBUS_DETECT_STAT)
32
R
0000_0000h
57.4.8/3941
20C_8230
USB Charger Detect Status Register
(USB_ANALOG_USB2_CHRG_DETECT_STAT)
32
R
0000_0000h
57.4.9/3943
20C_8250
USB Misc Register (USB_ANALOG_USB2_MISC)
32
R/W
0000_0002h
57.4.10/
3944
20C_8254
USB Misc Register (USB_ANALOG_USB2_MISC_SET)
32
R/W
0000_0002h
57.4.10/
3944
20C_8258
USB Misc Register (USB_ANALOG_USB2_MISC_CLR)
32
R/W
0000_0002h
57.4.10/
3944
20C_825C
USB Misc Register (USB_ANALOG_USB2_MISC_TOG)
32
R/W
0000_0002h
57.4.10/
3944
20C_8260
Chip Silicon Version (USB_ANALOG_DIGPROG)
32
R
0065_0000h
57.4.11/
3945
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3929

<!-- page 3930 -->

57.4.1
USB VBUS Detect Register
(USB_ANALOG_USB1_VBUS_DETECTn)
This register defines controls for USB VBUS detect.
Address: 20C_8000h base + 1A0h offset + (4d × i), where i=0d to 3d
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
CHARGE_VBUS
DISCHARGE_
VBUS
Reserved
VBUSVALID_
PWRUP_CMPS
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
1
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
VBUSVALID_
THRESH
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
1
0
0
USB_ANALOG_USB1_VBUS_DETECTn field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved.
27
CHARGE_VBUS
USB OTG charge VBUS.
26
DISCHARGE_
VBUS
USB OTG discharge VBUS.
25–21
-
This field is reserved.
Reserved.
20
VBUSVALID_
PWRUP_CMPS
Powers up comparators for vbus_valid detector.
19–3
-
This field is reserved.
Reserved.
VBUSVALID_
THRESH
Set the threshold for the VBUSVALID comparator. This comparator is the most accurate method to
determine the presence of 5v, and includes hystersis to minimize the need for software debounce of the
detection. This comparator has ~50mV of hystersis to prevent chattering at the comparator trip point.
000
4V0 — 4.0V
Table continues on the next page...
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3930
NXP Semiconductors

<!-- page 3931 -->

USB_ANALOG_USB1_VBUS_DETECTn field descriptions (continued)
Field
Description
001
4V1 — 4.1V
010
4V2 — 4.2V
011
4V3 — 4.3V
100
4V4 — 4.4V (default)
101
4V5 — 4.5V
110
4V6 — 4.6V
111
4V7 — 4.7V
57.4.2
USB Charger Detect Register
(USB_ANALOG_USB1_CHRG_DETECTn)
This register defines controls for USB charger detect.
Address: 20C_8000h base + 1B0h offset + (4d × i), where i=0d to 3d
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
Reserved
Reserved
EN_B
CHK_CHRG_B
CHK_CONTACT
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
USB_ANALOG_USB1_CHRG_DETECTn field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved.
Table continues on the next page...
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3931

<!-- page 3932 -->

USB_ANALOG_USB1_CHRG_DETECTn field descriptions (continued)
Field
Description
23
-
This field is reserved.
Reserved.
22–21
-
This field is reserved.
Reserved.
20
EN_B
Control the charger detector.
0
ENABLE — Enable the charger detector.
1
DISABLE — Disable the charger detector.
19
CHK_CHRG_B
Check the charger connection
0
CHECK — Check whether a charger (either a dedicated charger or a host charger) is connected to
USB port.
1
NO_CHECK — Do not check whether a charger is connected to the USB port.
18
CHK_CONTACT
Check the contact of USB plug
0
NO_CHECK — Do not check the contact of USB plug.
1
CHECK — Check whether the USB plug has been in contact with each other
-
This field is reserved.
Reserved.
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3932
NXP Semiconductors

<!-- page 3933 -->

57.4.3
USB VBUS Detect Status Register
(USB_ANALOG_USB1_VBUS_DETECT_STAT)
This register defines fields for USB VBUS Detect status.
Address: 20C_8000h base + 1C0h offset = 20C_81C0h
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
VBUS_VALID
AVALID
BVALID
SESSEND
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
USB_ANALOG_USB1_VBUS_DETECT_STAT field descriptions
Field
Description
31–4
-
This field is reserved.
Reserved.
Table continues on the next page...
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3933

<!-- page 3934 -->

USB_ANALOG_USB1_VBUS_DETECT_STAT field descriptions (continued)
Field
Description
3
VBUS_VALID
VBus valid for USB OTG. This bit is a read only version of the state of the analog signal. It can not be
overwritten by software.
2
AVALID
Indicates VBus is valid for a A-peripheral. This bit is a read only version of the state of the analog signal. It
can not be overritten by software.
1
BVALID
Indicates VBus is valid for a B-peripheral. This bit is a read only version of the state of the analog signal. It
can not be overritten by software.
0
SESSEND
Session End for USB OTG. This bit is a read only version of the state of the analog signal. It can not be
overwritten by software like the SESSEND bit below.
NOTE: This bit's default value depends on whether VDD5V is present, 0 if VDD5V is present, 1 if VDD5V
is not present.
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3934
NXP Semiconductors

<!-- page 3935 -->

57.4.4
USB Charger Detect Status Register
(USB_ANALOG_USB1_CHRG_DETECT_STAT)
This register defines fields for USB charger detect status.
Address: 20C_8000h base + 1D0h offset = 20C_81D0h
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
DP_STATE
DM_STATE
CHRG_DETECTED
PLUG_CONTACT
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
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3935

<!-- page 3936 -->

USB_ANALOG_USB1_CHRG_DETECT_STAT field descriptions
Field
Description
31–4
-
This field is reserved.
Reserved.
3
DP_STATE
DP line state output of the charger detector.
2
DM_STATE
DM line state output of the charger detector.
1
CHRG_
DETECTED
State of charger detection. This bit is a read only version of the state of the analog signal.
0
CHARGER_NOT_PRESENT — The USB port is not connected to a charger.
1
CHARGER_PRESENT — A charger (either a dedicated charger or a host charger) is connected to the
USB port.
0
PLUG_
CONTACT
State of the USB plug contact detector.
0
NO_CONTACT — The USB plug has not made contact.
1
GOOD_CONTACT — The USB plug has made good contact.
57.4.5
USB Misc Register (USB_ANALOG_USB1_MISCn)
This register defines controls for USB.
Address: 20C_8000h base + 1F0h offset + (4d × i), where i=0d to 3d
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
EN_CLK_UTMI
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
EN_DEGLITCH
HS_USE_EXTERNAL_R
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
1
0
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3936
NXP Semiconductors

<!-- page 3937 -->

USB_ANALOG_USB1_MISCn field descriptions
Field
Description
31
-
This field is reserved.
Reserved.
30
EN_CLK_UTMI
Enables the clk to the UTMI block.
29–2
-
This field is reserved.
Reserved.
1
EN_DEGLITCH
Enable the deglitching circuit of the USB PLL output.
0
HS_USE_
EXTERNAL_R
Use external resistor to generate the current bias for the high speed transmitter. This bit should not be
changed unless recommended by NXP.
57.4.6
USB VBUS Detect Register
(USB_ANALOG_USB2_VBUS_DETECTn)
This register defines controls for USB VBUS detect.
Address: 20C_8000h base + 200h offset + (4d × i), where i=0d to 3d
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
CHARGE_VBUS
DISCHARGE_
VBUS
Reserved
VBUSVALID_
PWRUP_CMPS
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
1
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
VBUSVALID_
THRESH
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
1
0
0
USB_ANALOG_USB2_VBUS_DETECTn field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved.
Table continues on the next page...
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3937

<!-- page 3938 -->

USB_ANALOG_USB2_VBUS_DETECTn field descriptions (continued)
Field
Description
27
CHARGE_VBUS
USB OTG charge VBUS.
26
DISCHARGE_
VBUS
USB OTG discharge VBUS.
25–21
-
This field is reserved.
Reserved.
20
VBUSVALID_
PWRUP_CMPS
Powers up comparators for vbus_valid detector.
19–3
-
This field is reserved.
Reserved.
VBUSVALID_
THRESH
Set the threshold for the VBUSVALID comparator. This comparator is the most accurate method to
determine the presence of 5v, and includes hystersis to minimize the need for software debounce of the
detection. This comparator has ~50mV of hystersis to prevent chattering at the comparator trip point.
000
4V0 — 4.0V
001
4V1 — 4.1V
010
4V2 — 4.2V
011
4V3 — 4.3V
100
4V4 — 4.4V (default)
101
4V5 — 4.5V
110
4V6 — 4.6V
111
4V7 — 4.7V
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3938
NXP Semiconductors

<!-- page 3939 -->

57.4.7
USB Charger Detect Register
(USB_ANALOG_USB2_CHRG_DETECTn)
This register defines controls for USB charger detect.
Address: 20C_8000h base + 210h offset + (4d × i), where i=0d to 3d
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
Reserved
Reserved
EN_B
CHK_CHRG_B
CHK_CONTACT
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
USB_ANALOG_USB2_CHRG_DETECTn field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved.
23
-
This field is reserved.
Reserved.
22–21
-
This field is reserved.
Reserved.
20
EN_B
Control the charger detector.
0
ENABLE — Enable the charger detector.
1
DISABLE — Disable the charger detector.
19
CHK_CHRG_B
Check the charger connection
Table continues on the next page...
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3939

<!-- page 3940 -->

USB_ANALOG_USB2_CHRG_DETECTn field descriptions (continued)
Field
Description
0
CHECK — Check whether a charger (either a dedicated charger or a host charger) is connected to
USB port.
1
NO_CHECK — Do not check whether a charger is connected to the USB port.
18
CHK_CONTACT
Check the contact of USB plug
0
NO_CHECK — Do not check the contact of USB plug.
1
CHECK — Check whether the USB plug has been in contact with each other
-
This field is reserved.
Reserved.
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3940
NXP Semiconductors

<!-- page 3941 -->

57.4.8
USB VBUS Detect Status Register
(USB_ANALOG_USB2_VBUS_DETECT_STAT)
This register defines fields for USB VBUS Detect status.
Address: 20C_8000h base + 220h offset = 20C_8220h
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
VBUS_VALID
AVALID
BVALID
SESSEND
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
USB_ANALOG_USB2_VBUS_DETECT_STAT field descriptions
Field
Description
31–4
-
This field is reserved.
Reserved.
Table continues on the next page...
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3941

<!-- page 3942 -->

USB_ANALOG_USB2_VBUS_DETECT_STAT field descriptions (continued)
Field
Description
3
VBUS_VALID
VBus valid for USB OTG. This bit is a read only version of the state of the analog signal. It can not be
overwritten by software.
2
AVALID
Indicates VBus is valid for a A-peripheral. This bit is a read only version of the state of the analog signal. It
can not be overritten by software.
1
BVALID
Indicates VBus is valid for a B-peripheral. This bit is a read only version of the state of the analog signal. It
can not be overritten by software.
0
SESSEND
Session End for USB OTG. This bit is a read only version of the state of the analog signal. It can not be
overwritten by software like the SESSEND bit below.
NOTE: This bit's default value depends on whether VDD5V is present, 0 if VDD5V is present, 1 if VDD5V
is not present.
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3942
NXP Semiconductors

<!-- page 3943 -->

57.4.9
USB Charger Detect Status Register
(USB_ANALOG_USB2_CHRG_DETECT_STAT)
This register defines fields for USB charger detect status.
Address: 20C_8000h base + 230h offset = 20C_8230h
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
DP_STATE
DM_STATE
CHRG_DETECTED
PLUG_CONTACT
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
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3943

<!-- page 3944 -->

USB_ANALOG_USB2_CHRG_DETECT_STAT field descriptions
Field
Description
31–4
-
This field is reserved.
Reserved.
3
DP_STATE
DP line state output of the charger detector.
2
DM_STATE
DM line state output of the charger detector.
1
CHRG_
DETECTED
State of charger detection. This bit is a read only version of the state of the analog signal.
0
CHARGER_NOT_PRESENT — The USB port is not connected to a charger.
1
CHARGER_PRESENT — A charger (either a dedicated charger or a host charger) is connected to the
USB port.
0
PLUG_
CONTACT
State of the USB plug contact detector.
0
NO_CONTACT — The USB plug has not made contact.
1
GOOD_CONTACT — The USB plug has made good contact.
57.4.10
USB Misc Register (USB_ANALOG_USB2_MISCn)
This register defines controls for USB.
Address: 20C_8000h base + 250h offset + (4d × i), where i=0d to 3d
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
EN_CLK_UTMI
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
EN_DEGLITCH
HS_USE_EXTERNAL_R
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
1
0
USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3944
NXP Semiconductors

<!-- page 3945 -->

USB_ANALOG_USB2_MISCn field descriptions
Field
Description
31
-
This field is reserved.
Reserved.
30
EN_CLK_UTMI
Enables the clk to the UTMI block.
29–2
-
This field is reserved.
Reserved.
1
EN_DEGLITCH
Enable the deglitching circuit of the USB PLL output.
0
HS_USE_
EXTERNAL_R
Use external resistor to generate the current bias for the high speed transmitter. This bit should not be
changed unless recommended by NXP.
57.4.11
Chip Silicon Version (USB_ANALOG_DIGPROG)
The DIGPROG register returns the digital program ID for the silicon.
Address: 20C_8000h base + 260h offset = 20C_8260h
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
SILICON_REVISION
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
1
1
0
0
1
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
0
0
0
0
0
0
USB_ANALOG_DIGPROG field descriptions
Field
Description
SILICON_
REVISION
0x00650000
Silicon revision 1.0
0x00650001
Silicon revision 1.1
Chapter 57 Universal Serial Bus 2.0 Integrated PHY (USB-PHY)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3945

<!-- page 3946 -->

USB Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3946
NXP Semiconductors

