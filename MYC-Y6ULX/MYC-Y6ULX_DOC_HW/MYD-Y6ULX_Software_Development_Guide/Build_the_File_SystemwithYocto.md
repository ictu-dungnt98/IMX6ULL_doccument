# Chapter 3: Building the Yocto System Image

---

## 3.1 Introduction

The Yocto Project is an open-source "umbrella" project, meaning it has many sub-projects under it. Yocto puts all the projects together and provides a reference build project **Poky** to guide developers on how to apply these projects to build an embedded Linux system. Yocto also contains:

- **BitBake** build tool
- **OpenEmbedded-Core**
- Board Level Support Packages (BSP)
- Configuration files of various software

This allows developers to build systems with different requirements. For more information about the Yocto project, please refer to: [www.yoctoproject.org](https://www.yoctoproject.org)

MYIR's CD image `04_Sources` directory contains Yocto meta file data for the MYD-Y6ULX development board, which helps developers build different types of Linux system images, such as:

- **myir-image-full** — system image with Qt 5.15 graphics library
- **myir-image-core** — system image without GUI interface
- **Weston** — official ST demonstration system image

The following sections use **myir-image-full** as an example to introduce the specific development process.

> **Note:** The SDK toolchain environment variables configured in Section 2.2.3 do **not** need to be loaded to build the Yocto system. Please create a new shell or open a new terminal window before proceeding.

---

## 3.2 Get the Source Code

There are two ways to obtain the source code:

1. Obtain the compressed package directly from the `04_Sources` directory of the MYIR CD image
2. Use `repo` to obtain the source code updated in real time on GitHub

Users can choose either method.

> **Note:** Before building the Yocto system, all software packages need to be downloaded locally. To speed up the build, MYD-Y6ULX has packaged the relevant software — users can directly unzip and copy it to the build directory to reduce repeated download time.

---

### 3.2.1 Get Compressed Source Code from CD Image

Find the Yocto compressed source package in the development kit at `04_Sources/MYiR-i.MX6UL-Yocto.tar.gz`:

```bash
myir$ cd $DEV_ROOT/04_Sources
myir$ tar -xzf MYiR-i.MX6UL-Yocto.tar.gz
myir$ ls
myir-setup-release.sh  README  README-IMXBSP  setup-environment  sources
```

---

### 3.2.2 Get Source Code from GitHub

The BSP source code and Yocto source code of the MYD-Y6ULX development board are managed on GitHub and will be updated long-term. Please refer to Section 2.2 of *MYD-Y6ULX SDK Release Notes* for details.

**Step 1:** Place the `03_tools/Repo/repo` file in `/usr/bin` and add executable permissions.

**Step 2:** Use `repo` to pull the Yocto source code:

```bash
myir$ export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/'

myir$ repo init \
  -u https://github.com/MYiR-Dev/myir-imx-manifest.git \
  --no-clone-bundle \
  --depth=1 \
  -m myir-i.mx6ul-5.10.9-1.0.0.xml \
  -b i.MX6UL-5.10-gatesgarth

myir$ repo sync
```

> Executing `repo sync` will download the code. It takes a certain amount of time — please be patient.

---

## 3.3 Build Development Board Image

This section provides detailed information along with the process for building an image.

Before using Yocto to build the system, the corresponding environment variables need to be set. MYIR provides a script `envsetup.sh` that simplifies setup for MYIR machines. The script sets up a build directory and configuration files for the specified machine and backend.

The Yocto Project build uses the `bitbake` command. Each component build has multiple tasks such as: fetching, configuration, compilation, packaging, and deploying to the target rootfs. The bitbake image build gathers all required components and builds them in dependency order per task.

---

### Step 1: Prepare Download Files

To reduce Yocto build time, extract the downloads archive into the working directory:

```bash
myir$ cd $DEV_ROOT/Yocto
myir$ tar -xzf downloads.tar.gz -C ./
```

---

### Step 2: Execute Script to Set Environment Variables

Use the script provided by NXP to create a build directory. There are two options for the `MACHINE` variable: `myd-y6ull14x14` and `myd-y6ul14x14`.

```bash
myir$ DISTRO=fsl-imx-fb MACHINE=myd-y6ull14x14 source myir-setup-release.sh -b build_imx6ull
```

After running the script, the directory structure looks like:

```
myir@myir-server1:~/imx6ul/yocto$ tree -L 1 .
├── build_imx6ull
├── downloads
├── myir-setup-release.sh -> sources/meta-myir/tools/myir-setup-release.sh
├── README -> sources/base/README
├── README-IMXBSP -> sources/meta-imx/README
├── setup-environment -> sources/base/setup-environment
└── sources

3 directories, 4 files
```

After the script runs, the working directory automatically switches to the newly created build directory (e.g. `build_imx6ull`).

---

### Step 3: Build the System Image

**Build myir-image-full:**

```bash
myir$ bitbake myir-image-full
```

**Build myir-image-core:**

```bash
myir$ bitbake myir-image-core
```

**Table 3-1. System Image Options**

| System Name      | Command                   |
|------------------|---------------------------|
| myir-image-core  | `bitbake myir-image-core` |
| myir-image-full  | `bitbake myir-image-full` |

**Table 3-2. Common BitBake Parameters**

| Parameter      | Description                                              |
|----------------|----------------------------------------------------------|
| `-k`           | Continue building when there are errors                  |
| `-c cleanall`  | Clear the entire build directory                         |
| `-c fetch`     | Pull the software source code to local from recipe URL   |
| `-c deploy`    | Deploy the image or software package to target rootfs    |
| `-c compile`   | Recompile image or package                               |

> **Tip:** It is recommended to extract `yocto qt-downloads.tar.xz` into the `build_imx6ull` directory to save significant download time.

---

## 3.4 Build SDK (Optional)

MYIR has provided a relatively complete SDK installation package which can be used directly. However, when users need to introduce new libraries into the SDK, they will need to rebuild the SDK tools using Yocto.

Run the following command to build the SDK package:

```bash
myir$ bitbake -c populate_sdk meta-toolchain
```

After building, the SDK installation package will be generated at:

```
build_imx6ull/tmp/deploy/sdk/
```

**Table 3-3. Build SDK Commands**

| System Name      | Command                                        |
|------------------|------------------------------------------------|
| myir-image-core  | `bitbake -c populate_sdk myir-image-core`      |
| myir-image-full  | `bitbake -c populate_sdk myir-image-full`      |
| meta-toolchain   | `bitbake -c populate_sdk meta-toolchain`       |



