# Speed Bin Tables

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 70–74

<!-- page 70 -->

Speed Bin Tables
Table 51: DDR3L-1066 Speed Bins
DDR3L-1066 Speed Bin
-187E
-187
Unit
Notes
CL-tRCD-tRP
7-7-7
8-8-8
Parameter
Symbol
Min
Max
Min
Max
Internal READ command to first data
tAA
13.125
–
15
–
ns
 
ACTIVATE to internal READ or WRITE delay
time
tRCD
13.125
–
15
–
ns
 
PRECHARGE command period
tRP
13.125
–
15
–
ns
 
ACTIVATE-to-ACTIVATE or REFRESH command
period
tRC
50.625
–
52.5
–
ns
 
ACTIVATE-to-PRECHARGE command period
tRAS
37.5
9 x tREFI
37.5
9 x tREFI
ns
1
CL = 5
CWL = 5
tCK (AVG)
3.0
3.3
3.0
3.3
ns
2
CWL = 6
tCK (AVG)
Reserved
Reserved
ns
3
CL = 6
CWL = 5
tCK (AVG)
2.5
3.3
2.5
3.3
ns
2
CWL = 6
tCK (AVG)
Reserved
Reserved
ns
3
CL = 7
CWL = 5
tCK (AVG)
Reserved
Reserved
ns
3
CWL = 6
tCK (AVG)
1.875
<2.5
Reserved
ns
2, 3
CL = 8
CWL = 5
tCK (AVG)
Reserved
Reserved
ns
3
CWL = 6
tCK (AVG)
1.875
<2.5
1.875
<2.5
ns
2
Supported CL settings
5, 6, 7, 8
5, 6, 8
CK
 
Supported CWL settings
5, 6
5, 6
CK
 
Notes:
1.
tREFI depends on TOPER.
2. The CL and CWL settings result in tCK requirements. When making a selection of tCK,
both CL and CWL requirement settings need to be fulfilled.
3. Reserved settings are not allowed.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Speed Bin Tables
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
70
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 71 -->

Table 52: DDR3L-1333 Speed Bins
DDR3L-1333 Speed Bin
-15E1
-152
Unit
Notes
CL-tRCD-tRP
9-9-9
10-10-10
Parameter
Symbol
Min
Max
Min
Max
Internal READ command to first data
tAA
13.5
–
15
–
ns
 
ACTIVATE to internal READ or WRITE delay
time
tRCD
13.5
–
15
–
ns
 
PRECHARGE command period
tRP
13.5
–
15
–
ns
 
ACTIVATE-to-ACTIVATE or REFRESH command
period
tRC
49.5
–
51
–
ns
 
ACTIVATE-to-PRECHARGE command period
tRAS
36
9 x tREFI
36
9 x tREFI
ns
3
CL = 5
CWL = 5
tCK (AVG)
3.0
3.3
3.0
3.3
ns
4
CWL = 6, 7
tCK (AVG)
Reserved
Reserved
ns
5
CL = 6
CWL = 5
tCK (AVG)
2.5
3.3
2.5
3.3
ns
4
CWL = 6
tCK (AVG)
Reserved
Reserved
ns
5
CWL = 7
tCK (AVG)
Reserved
Reserved
ns
5
CL = 7
CWL = 5
tCK (AVG)
Reserved
Reserved
ns
5
CWL = 6
tCK (AVG)
1.875
<2.5
Reserved
ns
4, 5
CWL = 7
tCK (AVG)
Reserved
Reserved
ns
5
CL = 8
CWL = 5
tCK (AVG)
Reserved
Reserved
ns
5
CWL = 6
tCK (AVG)
1.875
<2.5
1.875
<2.5
ns
4
CWL = 7
tCK (AVG)
Reserved
Reserved
ns
5
CL = 9
CWL = 5, 6
tCK (AVG)
Reserved
Reserved
ns
5
CWL = 7
tCK (AVG)
1.5
<1.875
Reserved
ns
4, 5
CL = 10
CWL = 5, 6
tCK (AVG)
Reserved
Reserved
ns
5
CWL = 7
tCK (AVG)
1.5
<1.875
1.5
<1.875
ns
4
Supported CL settings
5, 6, 7, 8, 9, 10
5, 6, 8, 10
CK
 
Supported CWL settings
5, 6, 7
5, 6, 7
CK
 
Notes:
1. The -15E speed grade is backward compatible with 1066, CL = 7 (-187E).
2. The -15 speed grade is backward compatible with 1066, CL = 8 (-187).
3.
tREFI depends on TOPER.
4. The CL and CWL settings result in tCK requirements. When making a selection of tCK,
both CL and CWL requirement settings need to be fulfilled.
5. Reserved settings are not allowed.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Speed Bin Tables
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
71
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 72 -->

Table 53: DDR3L-1600 Speed Bins
DDR3L-1600 Speed Bin
-1251
Unit
Notes
CL-tRCD-tRP
11-11-11
Parameter
Symbol
Min
Max
Internal READ command to first data
tAA
13.75
–
ns
 
ACTIVATE to internal READ or WRITE delay time
tRCD
13.75
–
ns
 
PRECHARGE command period
tRP
13.75
–
ns
 
ACTIVATE-to-ACTIVATE or REFRESH command period
tRC
48.75
–
ns
 
ACTIVATE-to-PRECHARGE command period
tRAS
35
9 x tREFI
ns
2
CL = 5
CWL = 5
tCK (AVG)
3.0
3.3
ns
3
CWL = 6, 7, 8
tCK (AVG)
Reserved
ns
4
CL = 6
CWL = 5
tCK (AVG)
2.5
3.3
ns
3
CWL = 6
tCK (AVG)
Reserved
ns
4
CWL = 7, 8
tCK (AVG)
Reserved
ns
4
CL = 7
CWL = 5
tCK (AVG)
Reserved
ns
4
CWL = 6
tCK (AVG)
1.875
<2.5
ns
3
CWL = 7
tCK (AVG)
Reserved
ns
4
CWL = 8
tCK (AVG)
Reserved
ns
4
CL = 8
CWL = 5
tCK (AVG)
Reserved
ns
4
CWL = 6
tCK (AVG)
1.875
<2.5
ns
3
CWL = 7
tCK (AVG)
Reserved
ns
4
CWL = 8
tCK (AVG)
Reserved
ns
4
CL = 9
CWL = 5, 6
tCK (AVG)
Reserved
ns
4
CWL = 7
tCK (AVG)
1.5
<1.875
ns
3
CWL = 8
tCK (AVG)
Reserved
ns
4
CL = 10
CWL = 5, 6
tCK (AVG)
Reserved
ns
4
CWL = 7
tCK (AVG)
1.5
<1.875
ns
3
CWL = 8
tCK (AVG)
Reserved
ns
4
CL = 11
CWL = 5, 6, 7
tCK (AVG)
Reserved
ns
4
CWL = 8
tCK (AVG)
1.25
<1.5
ns
3
Supported CL settings
5, 6, 7, 8, 9, 10, 11
CK
 
Supported CWL settings
5, 6, 7, 8
CK
 
Notes:
1. The -125 speed grade is backward compatible with 1333, CL = 9 (-15E) and 1066, CL = 7
(-187E).
2.
tREFI depends on TOPER.
3. The CL and CWL settings result in tCK requirements. When making a selection of tCK,
both CL and CWL requirement settings need to be fulfilled.
4. Reserved settings are not allowed.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Speed Bin Tables
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
72
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 73 -->

Table 54: DDR3L-1866 Speed Bins
DDR3L-1866 Speed Bin
-1071
Unit
Notes
CL-tRCD-tRP
13-13-13
Parameter
Symbol
Min
Max
Internal READ command to first data
tAA
13.91
20
 
 
ACTIVATE to internal READ or WRITE delay time
tRCD
13.91
–
ns
 
PRECHARGE command period
tRP
13.91
–
ns
 
ACTIVATE-to-ACTIVATE or REFRESH command period
tRC
47.91
–
ns
 
ACTIVATE-to-PRECHARGE command period
tRAS
34
9 x tREFI
ns
2
CL = 5
CWL = 5
tCK (AVG)
3.0
3.3
ns
3
CWL = 6, 7, 8, 9
tCK (AVG)
Reserved
ns
4
CL = 6
CWL = 5
tCK (AVG)
2.5
3.3
ns
3
CWL = 6, 7, 8, 9
tCK (AVG)
Reserved
ns
4
CL = 7
CWL = 5, 7, 8, 9
tCK (AVG)
Reserved
ns
4
CWL = 6
tCK (AVG)
1.875
<2.5
ns
3
CL = 8
CWL = 5, 8, 9
tCK (AVG)
Reserved
ns
4
CWL = 6
tCK (AVG)
1.875
<2.5
ns
3
CWL = 7
tCK (AVG)
Reserved
ns
4
CL = 9
CWL = 5, 6, 8, 9
tCK (AVG)
Reserved
ns
4
CWL = 7
tCK (AVG)
1.5
<1.875
ns
3
CL = 10
CWL = 5, 6, 9
tCK (AVG)
Reserved
ns
4
CWL = 7
tCK (AVG)
1.5
<1.875
ns
3
CWL = 8
tCK (AVG)
Reserved
ns
4
CL = 11
CWL = 5, 6, 7
tCK (AVG)
Reserved
ns
4
CWL = 8
tCK (AVG)
1.25
<1.5
ns
3
CWL = 9
tCK (AVG)
Reserved
ns
4
CL = 12
CWL = 5, 6, 7, 8
tCK (AVG)
Reserved
ns
4
CWL = 9
tCK (AVG)
Reserved
ns
4
CL = 13
CWL = 5, 6, 7, 8
tCK (AVG)
Reserved
ns
4
CWL = 9
tCK (AVG)
1.07
<1.25
ns
3
Supported CL settings
5, 6, 7, 8, 9, 10, 11, 13
CK
 
Supported CWL settings
5, 6, 7, 8, 9
CK
 
Notes:
1. The -107 speed grade is backward compatible with 1600, CL = 11 (-125) , 1333, CL = 9
(-15E) and 1066, CL = 7 (-187E).
2.
tREFI depends on TOPER.
3. The CL and CWL settings result in tCK requirements. When making a selection of tCK,
both CL and CWL requirement settings need to be fulfilled.
4. Reserved settings are not allowed.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Speed Bin Tables
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
73
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 74 -->

Table 55: DDR3L-2133 Speed Bins
DDR3L-2133 Speed Bin
-0931
Unit
Notes
CL-tRCD-tRP
14-14-14
Parameter
Symbol
Min
Max
Internal READ command to first data
tAA
13.09
20
 
 
ACTIVATE to internal READ or WRITE delay time
tRCD
13.09
–
ns
 
PRECHARGE command period
tRP
13.09
–
ns
 
ACTIVATE-to-ACTIVATE or REFRESH command period
tRC
46.09
–
ns
 
ACTIVATE-to-PRECHARGE command period
tRAS
33
9 x tREFI
ns
2
CL = 5
CWL = 5
tCK (AVG)
3.0
3.3
ns
3
CWL = 6, 7, 8, 9
tCK (AVG)
Reserved
ns
4
CL = 6
CWL = 5
tCK (AVG)
2.5
3.3
ns
3
CWL = 6, 7, 8, 9
tCK (AVG)
Reserved
ns
4
CL = 7
CWL = 5, 7, 8, 9
tCK (AVG)
Reserved
ns
4
CWL = 6
tCK (AVG)
1.875
<2.5
ns
3
CL = 8
CWL = 5, 8, 9
tCK (AVG)
Reserved
ns
4
CWL = 6
tCK (AVG)
1.875
<2.5
ns
3
CWL = 7
tCK (AVG)
Reserved
ns
4
CL = 9
CWL = 5, 6, 8, 9
tCK (AVG)
Reserved
ns
4
CWL = 7
tCK (AVG)
1.5
<1.875
ns
3
CL = 10
CWL = 5, 6, 9
tCK (AVG)
Reserved
ns
4
CWL = 7
tCK (AVG)
1.5
<1.875
ns
3
CWL = 8
tCK (AVG)
Reserved
ns
4
CL = 11
CWL = 5, 6, 7
tCK (AVG)
Reserved
ns
4
CWL = 8
tCK (AVG)
1.25
<1.5
ns
3
CWL = 9
tCK (AVG)
Reserved
ns
4
CL = 12
CWL = 5, 6, 7, 8
tCK (AVG)
Reserved
ns
4
CWL = 9
tCK (AVG)
Reserved
ns
4
CL = 13
CWL = 5, 6, 7, 8
tCK (AVG)
Reserved
ns
4
CWL = 9
tCK (AVG)
1.07
<1.25
ns
3
CL = 14
CWL = 5, 6, 7, 8, 9
tCK (AVG)
Reserved
Reserved
ns
4
CWL = 10
tCK (AVG)
0.938
<1.07
ns
3
Supported CL settings
5, 6, 7, 8, 9, 10, 11, 13, 14
CK
 
Supported CWL settings
5, 6, 7, 8, 9
CK
 
Notes:
1. The -093 speed grade is backward compatible with 1866, CL = 13 (-107) , 1600, CL = 11
(-125) , 1333, CL = 9 (-15E) and 1066, CL = 7 (-187E).
2.
tREFI depends on TOPER.
3. The CL and CWL settings result in tCK requirements. When making a selection of tCK,
both CL and CWL requirement settings need to be fulfilled.
4. Reserved settings are not allowed.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Speed Bin Tables
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
74
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

