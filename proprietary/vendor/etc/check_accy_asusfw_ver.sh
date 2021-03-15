#!/vendor/bin/sh

#prop_type=`getprop vendor.asus.dongletype`

FW_VER=`cat /vendor/asusfw/FW_version.txt | grep Inbox_FW | cut -d ':' -f 2`
setprop vendor.asusfw.inbox.aura_fwver $FW_VER

FW_VER=`cat /vendor/asusfw/FW_version.txt | grep gamepad_left | cut -d ':' -f 2`
setprop vendor.asusfw.gamepad.left_fwver $FW_VER

FW_VER=`cat /vendor/asusfw/FW_version.txt | grep gamepad_holder | cut -d ':' -f 2`
setprop vendor.asusfw.gamepad.holder_fwver $FW_VER

FW_VER=`cat /vendor/asusfw/FW_version.txt | grep gamepad_dongle | cut -d ':' -f 2`
setprop vendor.asusfw.gamepad.wireless_fwver $FW_VER

FW_VER=`cat /vendor/asusfw/FW_version.txt | grep gamepad3_left | cut -d ':' -f 2`
setprop vendor.asusfw.gamepad3.left_fwver $FW_VER

FW_VER=`cat /vendor/asusfw/FW_version.txt | grep gamepad3_middle | cut -d ':' -f 2`
setprop vendor.asusfw.gamepad3.middle_fwver $FW_VER

FW_VER=`cat /vendor/asusfw/FW_version.txt | grep gamepad3_right | cut -d ':' -f 2`
setprop vendor.asusfw.gamepad3.right_fwver $FW_VER

FW_VER=`cat /vendor/asusfw/FW_version.txt | grep gamepad3_bt | cut -d ':' -f 2`
setprop vendor.asusfw.gamepad3.bt_fwver $FW_VER

echo "[ACCY] Check Accy AsusFW Ver Done" > /dev/kmsg
