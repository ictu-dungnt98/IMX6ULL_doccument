GIAI ĐOẠN 1: U-Boot chạy boot.scr
bashecho "Running A/B OTA boot.scr"
In ra UART console, biết script đang chạy.

bashif test -z "${boot_slot}"; then
    setenv boot_slot A
fi
Đọc boot_slot từ flash. Lần đầu flash trống → rỗng → set A. Các lần sau đọc được giá trị đã lưu.

bashif test -z "${rollback_slot}"; then
    setenv rollback_slot A
fi
Tương tự, rollback_slot chưa có → default A.

bashif test ${boot_slot} = B; then
    setenv image zImage_B
    setenv fdt_file okmx6ull-s-emmc_B.dtb
    setenv mmcroot /dev/mmcblk1p3 rootwait rw
else
    setenv image zImage_A
    setenv fdt_file okmx6ull-s-emmc_A.dtb
    setenv mmcroot /dev/mmcblk1p2 rootwait rw
fi
Giả sử boot_slot=A → set:
image    = zImage_A
fdt_file = okmx6ull-s-emmc_A.dtb
mmcroot  = /dev/mmcblk1p2 rootwait rw

bashsetenv bootargs console=${console},${baudrate} calibrate=${calibrate} cma=64M root=${mmcroot} ota.slot=${boot_slot}
Tạo chuỗi truyền cho kernel:
console=ttymxc0,115200 cma=64M root=/dev/mmcblk1p2 rootwait rw ota.slot=A

bashfatload mmc ${mmcdev}:${mmcpart} ${loadaddr} ${image}
Load zImage_A từ partition FAT (p1) vào RAM địa chỉ ${loadaddr}.

bashfatload mmc ${mmcdev}:${mmcpart} ${fdt_addr} ${fdt_file}
Load okmx6ull-s-emmc_A.dtb vào RAM địa chỉ ${fdt_addr}.

bashbootz ${loadaddr} - ${fdt_addr}
Boot kernel. Nếu thành công → nhảy sang Giai đoạn 2. Các lệnh phía dưới không bao giờ chạy.

⚠️ CHỈ CHẠY KHI bootz THẤT BẠI:
bashecho "BOOT FAILED, rollback..."
In ra console báo hiệu boot thất bại.

bashsetenv boot_slot ${rollback_slot}
setenv upgrade_available 0
setenv bootcount 0
saveenv

boot_slot → quay về slot cũ (rollback_slot=A)
upgrade_available=0 → không có OTA đang chờ
bootcount=0 → reset bộ đếm
saveenv → ghi xuống flash ngay


bashif test ${boot_slot} = B; then
    ...
else
    setenv image zImage_A
    setenv fdt_file okmx6ull-s-emmc_A.dtb
    setenv mmcroot /dev/mmcblk1p3 rootwait rw
fi
Chọn lại kernel/dtb/partition theo slot cũ.

bashfatload mmc ${mmcdev}:${mmcpart} ${loadaddr} ${image}
fatload mmc ${mmcdev}:${mmcpart} ${fdt_addr} ${fdt_file}
bootz ${loadaddr} - ${fdt_addr}
Load lại và boot bằng slot cũ. Nếu thất bại tiếp → board treo ở đây.

GIAI ĐOẠN 2: Linux boot lên
kernel mount /dev/mmcblk1p2 làm rootfs
    │
    └── init chạy
            │
            └── rc.local chạy

GIAI ĐOẠN 3: rc.local chạy
bash/usr/bin/ota-confirm-boot.sh &
Chạy nền ngay lập tức, không chờ.

bash( while true; do
    if ! ip a show wlan0 | grep -q "inet "; then
        killall wpa_supplicant 2>/dev/null
        ifconfig wlan0 up
        wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
        sleep 5
        udhcpc -i wlan0 -n -q
    fi
    sleep 10
done ) &
Vòng lặp WiFi chạy nền song song — cứ 10 giây check WiFi, mất kết nối thì reconnect.

bash( while true; do
    if ip a show wlan0 | grep -q "inet "; then
        /usr/bin/mqtt_led_app >> /var/log/mqtt_led_app.log 2>&1
    else
        echo "Waiting WiFi..."
    fi
    sleep 5
done ) &
Vòng lặp app chạy nền song song — có WiFi thì chạy app, app crash thì tự restart.

bashexit 0
rc.local thoát, 3 process nền vẫn tiếp tục chạy.

GIAI ĐOẠN 4: ota-confirm-boot.sh chạy (song song với rc.local)
bashSLOT=$(sed -n 's/.*ota.slot=\([^ ]*\).*/\1/p' /proc/cmdline)
Đọc /proc/cmdline → lấy ra A.

bashif [ -z "$SLOT" ]; then
    exit 0
fi
SLOT=A → không rỗng → tiếp tục.

bashfw_setenv boot_slot A
fw_setenv rollback_slot A
fw_setenv upgrade_available 0
fw_setenv bootcount 0
Ghi vào flash lần lượt qua fw_env.config → tìm /dev/mmcblk1 offset 0x400000 → ghi từng biến.
Sau bước này flash có:
boot_slot=A
rollback_slot=A
upgrade_available=0
bootcount=0          ← U-Boot lần sau thấy 0 → không rollback

Tóm tắt toàn bộ luồng:
U-Boot
  └── đọc flash (boot_slot=A, bootcount=0)
  └── chọn zImage_A, p2
  └── set bootargs (ota.slot=A)
  └── load kernel + dtb vào RAM
  └── bootz → boot kernel
                  │
                  └── kernel mount p2
                  └── init → rc.local
                              │
                              ├── [nền] ota-confirm-boot.sh
                              │           └── fw_setenv bootcount 0 → flash
                              │
                              ├── [nền] vòng lặp WiFi
                              │
                              └── [nền] vòng lặp app




gedit  ~/imx-yocto-new/build-fb/tmp/work/okmx6ull_s_emmc-poky-linux-gnueabi/u-boot-imx/2022.04-r0/git/include/config_distro_bootcmd.h


"run boot_a_script; "