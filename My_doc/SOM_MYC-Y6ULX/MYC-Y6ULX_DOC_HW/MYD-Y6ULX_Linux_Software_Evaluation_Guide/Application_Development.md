# Chapter 9 — Development Support

The SDK provides two reference images for secondary development:
- **`myir-image-core`** — for non-GUI applications
- **`myir-image-full`** — adds Qt runtime libraries, graphics libraries, and demo apps

See **"MYD-Y6ULX SDK Release Notes"** for details on both images.

---

## 9.1. Development Language

### 9.1.1. SHELL

Shell is a C-language program that acts as a bridge between the user and Linux — both a command language and a programming language. Common Linux shells:

| Shell | Path |
|---|---|
| Bourne Shell | `/usr/bin/sh` or `/bin/sh` |
| Bourne Again Shell (Bash) | `/bin/bash` |
| C Shell | `/usr/bin/csh` |
| K Shell | `/usr/bin/ksh` |
| Shell for Root | `/sbin/sh` |

The current SDK defaults to **Bash**.

#### Example: MEasy HMI 2.0 Startup Script (`start.sh`)

```sh
#!/bin/sh -e
echo "Start MYiR HMI V2.0..."

export TSLIB_TSDEVICE=/dev/input/event1
export TSLIB_CONFFILE=/etc/ts.conf
export TSLIB_CALIBFILE=/etc/pointercal
export TSLIB_PLUGINDIR=/usr/lib/ts
export TSLIB_CONSOLEDEVICE=none
export QT_QPA_FB_TSLIB=1
export QT_QPA_GENERIC_PLUGINS=tslib:/dev/input/event1

/home/root/mxapp2 -platform linuxfb &
exit 0
```

This script sets environment variables for MEasy HMI V2.0, then launches `mxapp2` in the background (`&`).

---

### 9.1.2. C/C++

C/C++ is the most commonly used language for low-level Linux application development. Development uses a **cross-compilation** workflow: code is written and compiled on the host PC, then deployed to the target device.

#### Setup SDK Environment

```bash
PC $ source /opt/test5.10/environment-setup-cortexa7t2hf-neon-poky-linux-gnueabi
```

> Always use `$CC` to compile — it includes the correct system library paths and configuration. Using `arm-poky-linux-gnueabi-gcc` directly may result in missing header file errors.

#### Hello World Example

Write `main.c` on the host:

```c
#include <stdio.h>
int main(int argc, char *argv[])
{
    printf("hello world!\n");
    return 0;
}
```

Compile with `$CC`:

```bash
myir@myir-server1:~/test$ $CC main.c -o main
myir@myir-server1:~/test$ file main
```

Copy to target and run:

```bash
# Copy via SCP
scp main root@<board-ip>:~/

# Run on target
root@myir:~# ./main
hello world!
```

For more complex examples, refer to **"MYD-Y6ULX Yocto Software Development Guide"**.

---

### 9.1.3. Python

Python 3.8 is included in the factory image. The system also includes Python 2.7 for compatibility.

#### Check Installed Python Versions

```bash
root@myd-y6ull14x14:~# ls /usr/bin/python*
/usr/bin/python       /usr/bin/python2      /usr/bin/python2.7
/usr/bin/python3      /usr/bin/python3.8    /usr/bin/python-config
```

#### Interactive Mode

```bash
root@myd-y6ull14x14:~# python3
Python 3.8.5 (default, Jul 20 2020, 13:26:22)
[GCC 10.2.0] on linux
>>> print("myir test")
myir test
>>> exit()
root@myir:~#
```

Press `Ctrl+D` or run `exit()` to quit.

#### Write and Run a Python Script

```bash
vi test.py
```

```python
#!/usr/bin/python3
print("Hello, Python!")
```

```bash
chmod +x test.py
./test.py
# Hello, Python!
```

> **Note:** The current system does not support `pip`. Port the `pip` tool manually if package installation is needed.

---

## 9.2. Database

### SQLite

SQLite is a lightweight, embedded SQL database engine. Unlike MySQL or PostgreSQL, it has no separate server process — it reads and writes directly to a single disk file containing the entire database (tables, indexes, triggers, views).

It is ACID-compliant, designed for embedded use, and requires only a few hundred KB of memory.

#### Create a Database

```bash
root@myir:~# sqlite3 testDB.db
SQLite version 3.31.1 2020-01-27 19:55:54
Enter ".help" for usage hints.
sqlite>
```

This creates `testDB.db` in the current directory.

#### Verify Database

```bash
sqlite> .databases
main: /home/root/testDB.db
```

#### Exit SQLite

```bash
sqlite> .quit
root@myir:~#
```

> Full SQLite documentation: https://www.sqlite.org/docs.html

---

## 9.3. Application Localization for Qt

Localization adapts a program to a specific language/region for input and output. This section uses **MEasy HMI 2.0** as the reference example.

---

### 9.3.1. Multiple Language Support

#### Step 1 — Open the mxapp2 Project

Extract `Mxapp2.tar.gz` into the build environment and open the project with **Qt Creator**.

#### Step 2 — Generate `.ts` Translation Files

```bash
PC$ lupdate mxapp2.pro
# Updating 'languages/language_zh.ts'... Found 202 source text(s)
# Updating 'languages/language_en.ts'... Found 202 source text(s)
```

The project ships with pre-built `language_zh.ts` (Chinese) and `language_en.ts` (English) files.

#### Step 3 — Edit Translations

Open a `.ts` file and edit the `<translation>` nodes:

```xml
<message>
    <location filename="../Album.qml" line="50"/>
    <source>返回</source>
    <translation type="unfinished">Return</translation>
</message>
```

#### Step 4 — Generate `.qm` Binary Files

```bash
PC$ lrelease language_en.ts -qm language_en.qm
# Generated 183 translation(s) (2 finished and 181 unfinished)

PC$ lrelease language_zh.ts -qm language_zh.qm
# Generated 183 translation(s)
```

#### Step 5 — Apply in Application Code

Translation files are loaded via the `loadLanguage` member function in `translator.cpp`.

---

### 9.3.2. Fonts

#### Install Fonts on the Development Board

Place font files directly into `/usr/lib/fonts/` on the board:

```bash
ls /usr/lib/fonts/msyh.ttc
# /usr/lib/fonts/msyh.ttc
```

Or embed fonts directly into the Qt project resource file:

```
└── fontawesome-webfont.ttf
```

#### Load Fonts in Qt Application Code

MXAPP2 uses `msyh.ttc` for text and `fontawesome-webfont.ttf` for icons. Refer to the `iconFontInit()` function in `main.cpp`:

```cpp
void iconFontInit()
{
    int fontId_digital = QFontDatabase::addApplicationFont(":/fonts/DIGITAL/DS-DIGIB.TTF");
    int fontId_fws = QFontDatabase::addApplicationFont(":/fonts/fontawesome-webfont.ttf");

    QString fontName_fws = QFontDatabase::applicationFontFamilies(fontId_fws).at(0);
    QFont iconFont_fws;
    iconFont_fws.setFamily(fontName_fws);
    QApplication::setFont(iconFont_fws);
    iconFont_fws.setPixelSize(20);
}
```

---

### 9.3.3. Virtual Keyboard (Qt)

Qt 5.15 includes the **Qt Virtual Keyboard** component, used in MEasy HMI 2.0.

> Before proceeding, set up the build environment as described in **Chapter 3.1 of "MEasy HMI 2.0 Development Manual"**.

#### Embed the Virtual Keyboard in QML

The soft keyboard can only be used in QML. Define its position and size before use:

```qml
InputPanel {
    id: inputPanel
    x: adaptive_width / 8
    y: adaptive_height / 1.06
    z: 99
    anchors.left: parent.left
    anchors.right: parent.right

    states: State {
        name: "visible"
        when: inputPanel.active
        PropertyChanges {
            target: inputPanel
            y: adaptive_height / 1.06 - inputPanel.height
        }
    }
}
```

#### Trigger the Virtual Keyboard

Add a `TextField` or `TextEdit` component to the UI — tapping on it automatically summons the keyboard:

```qml
TextField {
    id: netmask_input
    inputMethodHints: Qt.ImhFormattedNumbersOnly
    onAccepted: digitsField.focus = true
    font.family: "Microsoft YaHei"
    color: "white"
}
```

#### Usage Reference

For full virtual keyboard usage, refer to **Chapter 2.6 of "MEasy HMI 2.0 Development Manual"** — System Settings UI section.