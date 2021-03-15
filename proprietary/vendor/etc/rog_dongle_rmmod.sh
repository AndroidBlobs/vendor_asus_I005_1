#!/vendor/bin/sh

echo "[EC_HID]rog_dongle_rmmod ms51_backcover" > /dev/kmsg
rmmod ms51_backcover
