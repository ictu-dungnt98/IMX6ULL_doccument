# Chapter 11: System Security

> Nguồn: `IMX6ULLRM.pdf` — trang 381–386

<!-- page 381 -->

Chapter 11
System Security
11.1
Overview
Security is a common requirement for platforms built using the chip, although the
specific needs vary greatly depending on the platform and market. The type and cost of
assets to be protected on a portable consumer device are very different from those to be
protected on automotive or industrial platforms, and the same applies to the kind of
attacks and level of resources threatening those assets. The platform designer must select
an appropriate set of counter measures to meet the relevant platform security needs.
For the platform designer to meet the requirements for each market, the chip incorporates
a range of security features which can be used individually or in concert to underpin the
platform security architecture. Most of the chip security features provide protection
against particular kinds of attack and can be configured at various levels according to the
required degree of protection. These features are designed to work together and can be
integrated with appropriate software to create defensive layers. In addition to protection
features, the chip includes a general purpose accelerator to enhance the performance of
selected industry standard cryptographic algorithms.
The following is an introduction to the chip security components.
• High Assurance Boot (HAB) feature in the System Boot up to RSA-4096 signature
verification
• Secure Non Volatile Storage (SNVS)
• TrustZone (TZ) Architecture in the ARM Cortex A7 Platform, TrustZone aware
Interrupt Controller (GIC) and TrustZone Watchdog Timer (WDOG-2)
• TrustZone Address Space Controller (TZC-380) - providing security address region
control functions on DDR memory space.
• On-chip RAM (OCRAM) with TrustZone protection using OCRAM controller.
• On chip OTP (OCOTP) with on-chip electrical fuses
• Central Security Unit (CSU)
• Secure JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
381

<!-- page 382 -->

• Locked mode in the Smart Direct Memory Access (SDMA) controller
• 2 tamper pins supported
• Hardware Cryptographic Accelerators
• Symmetric: AES-128
• Hash Message Digest: SHA-1 and SHA-256
• True and Pseudo Random Number Generator
11.2
Central Security Unit (CSU)
11.2.1
CSU Overview
The CSU manages the system security policy for peripheral access on the SoC. The CSU
allows trusted code to set individual security access privilges on each of the peripherals,
using one of eight security access privilege levels. Also, according to programmed
policy, the CSU may assign bus master security privileges during bus transactions.
11.2.2
CSU Features
The Central Security Unit (CSU) sets access control policies between bus masters and
bus slaves, allowing peripherals to be separated into distinct security domains. This
protects against unauthorized access to data e.g. when software programs a DMA bus
master to access addresses that the software itself is prohibited from accessing directly.
Configuring DMA bus master privileges in the CSU consistent with software privileges
defends against such attempted accesses.
CSU has the following security related features:
• Peripheral access policy - Appropriate bus master privileges and identity are required
to access each peripheral.
• Masters privilege policy - CSU overrides bus master privilege signals, i.e. user/
supervisor secure/non-secure, according to access control policy.
11.2.3
CSU Functional Description
The CSU enables secure software to set bus privilege security policy within the platform.
Central Security Unit (CSU)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
382
NXP Semiconductors

<!-- page 383 -->

Security policies may be set, and optionally locked in the CSU registers. These privilege
values may originate in the command sequence file (CSF) which is processed by the High
Assurance Boot (HAB) itself or by an HAB authenticated image which executes after the
initial boot ROM phase.
11.2.3.1
CSU Peripheral Access Policy
According to its programmed policy, the CSU determines the bus master privileges and
the masters that are allowed to access each of the slave peripherals.
There are four security modes of operation (i.e. bus privileges) in the system
distinguished by security (TrustZone/non-TrustZone) and privilege (Supervisor/User)
setting of the module. Below is the list of these security modes from the highest security
level to the lowest:
• TrustZone (Secure) Privilege (Supervisor) Mode - Highest Security Level
• TrustZone (Secure) non-Privilege (User) Mode - Medium Security Level
• non-TrustZone (Regular) Privilege (Supervisor) Mode - Medium Security Level
• non-TrustZone (Regular) non-Privilege (User) Mode - Lowest Security Level
This functionality is implemented as follows:
The Configure Slave Level (CSL) Register value for a specified peripheral resource
defines the output signal -- csu_sec_level for that peripheral. The value of this signal
determines by what master privileges a peripheral is accessible. The relationship between
the value of the csu_sec_level signal and security operation mode is shown in the table
below. The CSL registers reside in the CSU module. Details, describing CSL register
fields and how they are programmed to control access privileges for specific peripherals,
can be found in the Security Reference Manual.
Table 11-1. Permission Access Table
CSU_SEC_LEVEL[2:
0]
Non-Secure
User Mode
Non-Secure
Spvr Mode
Secure (TZ) User
Mode
Secure (TZ) Spvr
Mode
CSL register
value
(0) 000
RD+WR
RD+WR
RD+WR
RD+WR
8'b1111_1111
(1) 001
None
RD+WR
RD+WR
RD+WR
8'b1011_1011
(2) 010
RD
RD
RD+WR
RD+WR
8'b0011_1111
(3) 011
None
RD
RD+WR
RD+WR
8'b0011_1011
(4) 100
None
None
RD+WR
RD+WR
8'b0011_0011
(5) 101
None
None
None
RD+WR
8'b0010_0010
(6) 110
None
None
RD
RD
8'b0000_0011
(7) 111
None
None
None
None
Any other value
Chapter 11 System Security
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
383

<!-- page 384 -->

11.3
Secure Non-Volatile Storage (SNVS)
11.3.1
SNVS Overview
SNVS is a hardware device that includes a security state machine and security violation
detection circuits that, together with High Assurance Boot software, determine whether
the chip is currently in a secure state.
When the security state machine indicates a secure state, the SNVS allows use of special
cryptographic keys to decrypt long-term secrets such as public/private keypairs, Digital
Rights Management keys and proprietary software. When the SNVS detects a potential
security violation, such as a tamper alert, the SNVS sends an interrupt to alert the
Operating System of the event. The SNVS also includes a general purpose real-time
counter.
The SNVS includes the following features:
• Security State Machine driven by High Assurance Boot software and tamper
detection circuits
• Master Key Control that protects the integrity and secrecy of the Master Key
(OTPMK) stored in fuses
• Tamper detection circuits that detect JTAG events, power glitches, Master Key ECC
check failure, and software-reported and hardware-reported security violations
• 256-bit Zeroizable Master Key that can be automatically erased in the event of a
security breach
• Tamper-protected Secure Realtime Counter that continues running when the chip is
powered off
• Non-volatile Monotonic Counter used to protect against “roll-back” attacks
• Non-volatile General Purpose Register can be used to store a 32-bit value across
power cycles
• Non-Secure Real Time Counter with programmable alarm and periodic interrupt
• Controls the access to the OTP master secret key used by DCP to protect confidential
data in off-chip storage
• Smart button input in the SNVS_LP logic of the SoC.
• Pulse mode output signal to request power state changes to a ‘Smart’ external PMIC.
Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
384
NXP Semiconductors

<!-- page 385 -->

11.3.2
Tamper Detection
External Tamper Detection is a special mechanism provided through a chip pin to signal
when the device encounters unauthorized opening or tampering. Inside the chip, the
received signal is compared with the desired signal level, once unequal, tamper event is
found. When the desired signal is fixed, it is a passive tamper; when the desired signal
level is also toggling with time, it is an active tamper. The chip supports at most 10
passive tamper detection pins, or 5 active tamper pairs alternatively. The use of each
active tamper pair will reduce the available number of passive tamper pins at most by 2.
An always-ON power supply (coincell battery) should be present in the system. If the
tamper detection feature is enabled by software then opening of the tamper contact:
• Switches system power ON with a Tamper Detection alarm interrupt asserted (for
software reaction)
• Activate security related hardware (e.g. automatic and immediate erasure of the
Zeroizable Master Key and deny access and erase secure memory contents)
11.4
Data Co-Processor (DCP)
For security purposes, the Data Co-Processor (DCP) provides hardware acceleration for
the cryptographic algorithms. The features of DCP are:
• Encryption Algorithms: AES-128 (ECB and CBC modes)
• Hashing Algorithms: SHA-1 and SHA-256
• Key selection from the SNVS, DCP internal key storage, or general memory
• Internal Memory for storing up to four AES-128 keys—when a key is written to a
key slot it can be read only by the DCP AES-128 engine
• IP slave interface
• DMA
11.5
High-Assurance Boot (HAB)
The HAB, which is the high-assurance boot feature in the system boot ROM, detects and
prevents the execution of unauthorized software (malware) during the boot sequence.
When the unauthorized software is permitted to gain control of the boot sequence, it can
be used for a variety of goals, such as exposing stored secrets; circumventing access
controls to sensitive data, services, or networks, or for repurposing the platform. The
unauthorized software can enter the platform during upgrades or reprovisioning, or when
booting from the USB connections or removable devices.
Chapter 11 System Security
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
385

<!-- page 386 -->

The HAB protects against unauthorized software by:
• Using digital signatures to recognize the authentic software. This enables you to boot
the device to a known initial state and run the software signed by the device
manufacturer.
11.6
System JTAG Controller (SJC)
The JTAG port provides debug access to hardware blocks, including the Arm processor
and the system bus. This enables program control and manipulation as well as visibility
to the chip peripherals and memory.
The JTAG port must be accessible during initial platform development, manufacturing
tests, and general troubleshooting. Given its capabilities, JTAG manipulation is a known
attack vector for accessing sensitive data and gaining control over software execution.
The System JTAG Controller (SJC) protects against the whole range of attacks based on
unauthorized JTAG manipulation. It also provides a JTAG port that conforms to the
IEEE 1149.1 and IEEE 1149.6 (AC) standards for BSR (boundary-scan) testing.
The SJC provides these security levels:
• The JTAG Disabled-JTAG use is permanently blocked.
• The No-Debug-All security sensitive JTAG features are permanently blocked.
• The Secure JTAG-JTAG use is restricted (as in the No-Debug level) unless a secret-
key challenge/response protocol is successfully executed.
• The JTAG Enabled-JTAG use is unrestricted.
The security levels are selected via the e-fuse configuration.
System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
386
NXP Semiconductors

