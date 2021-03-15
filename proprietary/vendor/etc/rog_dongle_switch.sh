#!/vendor/bin/sh

sleep 3
type=`getprop vendor.asus.dongletype`
event=`getprop vendor.asus.dongleevent`
accy_gen=`getprop vendor.asus.accy_gen`
inbox_fwmode_path="/sys/class/leds/aura_inbox/fw_mode"
echo "[EC_HID] ROG DongleSwitch, type $type, event $event, accy_gen $accy_gen" > /dev/kmsg
retry=0
retry_tp=0
pdretry=0

function reset_accy_fw_ver(){
	setprop vendor.inbox.aura_fwver 0
	setprop vendor.asus.accy.fw_status 000000
	setprop vendor.asus.accy.fw_status2 000000
	setprop vendor.oem.asus.inboxid 0
}

# Define rmmod function
function remove_mod(){

	if [ -n "$1" ]; then
		echo "[EC_HID] remove_mod $1" > /dev/kmsg
	else
		exit
	fi

	test=1
	while [ "$test" == 1 ]
	do
		rmmod $1
		ret=`lsmod | grep $1`
		if [ "$ret" == "" ]; then
			echo "[EC_HID] rmmod $1 success" > /dev/kmsg
			test=0
		else
			echo "[EC_HID] rmmod $1 fail" > /dev/kmsg
			test=1
			sleep 0.5
		fi
	done
}

function check_accy_fw_ver(){

	echo "[EC_HID] Get Dongle FW Ver, type $type" > /dev/kmsg

	if [ "$type" == "1" ]; then

		if [ "$accy_gen" == "1" ]; then			# for factory test, it will be deleted later.
			setprop vendor.asus.accy.fw_status 000000
		else
			fw_mode=`cat /sys/class/leds/aura_inbox/fw_mode`
			echo "[EC_HID] InBox fw_mode =$fw_mode " > /dev/kmsg
			if [ "$fw_mode" == "1" ]; then
				inbox_unique_id=`cat /sys/class/leds/aura_inbox/unique_id`
				setprop vendor.oem.asus.inboxid $inbox_unique_id
				inbox_aura=`cat /sys/class/leds/aura_inbox/fw_ver`
				if [ "$inbox_aura" == "0x0000" ]; then
					sleep 0.35
				fi
				inbox_aura=`cat /sys/class/leds/aura_inbox/fw_ver`
				setprop vendor.inbox.aura_fwver $inbox_aura

				# check FW need update or not
				aura_fw=`getprop vendor.asusfw.inbox.aura_fwver`
				echo "[EC_HID] InBox inbox_aura = $inbox_aura  aura_fw = $aura_fw"  > /dev/kmsg
				if [ "$inbox_aura" == "$aura_fw" ]; then
					setprop vendor.asus.accy.fw_status 000000
				elif [ "$inbox_aura" == "i2c_error" ]; then
					echo "[EC_HID] InBox AURA_SYNC FW Ver Error" > /dev/kmsg
					setprop vendor.asus.accy.fw_status 000000
				else
					setprop vendor.asus.accy.fw_status 100000
				fi
			elif [ "$fw_mode" == "2" ]; then
				setprop vendor.asus.accy.fw_status 100000
			else # the wrong mode
				#Todo:reset
				echo 0 > /sys/class/leds/aura_inbox/gpio8
				echo 1 > /sys/class/leds/aura_inbox/gpio8
				fw_mode=`cat /sys/class/leds/aura_inbox/fw_mode`
				if [ "$fw_mode" == "1" ]; then
					inbox_aura=`cat /sys/class/leds/aura_inbox/fw_ver`
					setprop vendor.inbox.aura_fwver $inbox_aura

					# check FW need update or not
					aura_fw=`getprop vendor.asusfw.inbox.aura_fwver`
					if [ "$inbox_aura" == "$aura_fw" ]; then
						setprop vendor.asus.accy.fw_status 000000
					elif [ "$inbox_aura" == "i2c_error" ]; then
						echo "[EC_HID] InBox AURA_SYNC FW Ver Error" > /dev/kmsg
						setprop vendor.asus.accy.fw_status 000000
					else
						setprop vendor.asus.accy.fw_status 100000
					fi
				elif [ "$fw_mode" == "2" ]; then
					setprop vendor.asus.accy.fw_status 100000
				else
					echo "[EC_HID] inbox fw_mode is wrong." > /dev/kmsg
				fi
			fi

                        # Inbox Audio port
#                        inbox_audio=`cat /sys/class/rt5683/rt5683_i2s_inbox/rt5683_firmware`
#                	setprop vendor.inbox.audio_fwver $inbox_audio
#                        echo "[ASUS][EC_HID][check_accy_fw_ver] Get Inbox audio codec fw version : $inbox_audio" > /dev/kmsg
#                        log -p d -t [ASUS][EC_HID][check_accy_fw_ver] Get Inbox audio codec fw version : $inbox_audio

#                        inbox_audio=`getprop vendor.inbox.audio_fwver`
#                        echo "[ASUS][EC_HID][check_accy_fw_ver] Get Inbox audio codec prop fw version : $inbox_audio" > /dev/kmsg
#                        log -p d -t [ASUS][EC_HID][check_accy_fw_ver] Get Inbox audio codec prop fw version : $inbox_audio


		fi
	fi

	fw_status=`getprop vendor.asus.accy.fw_status`
	fw_status2=`getprop vendor.asus.accy.fw_status2`

	echo "[EC_HID] ACCY fw_status $fw_status, fw_status2 $fw_status2" > /dev/kmsg
	#echo "[EC_HID] Get Dongle FW Ver done." > /dev/kmsg
}

bootmode=`getprop ro.bootmode`
if [ "$bootmode" == "charger" ]
then
	if [ "$type" != "2" ]
	then
		remove_mod station_key
	fi
fi

if [ "$type" == "0" ]; then
	exit

elif [ "$type" == "1" ]; then
	echo "[EC_HID][Switch] InBox" > /dev/kmsg

	if [ "$accy_gen" == "1" ]; then			# For JEDI dongle
		insmod /vendor/lib/modules/ene_8k41_inbox.ko
		insmod /vendor/lib/modules/nct7802.ko
		#sleep 0.5
	elif [ "$accy_gen" == "2" ]; then		# For YODA dongle
		insmod /vendor/lib/modules/ml51fb9ae_inbox.ko
		#sleep 0.5
	elif [ "$accy_gen" == "3" ]; then		# For OBIWAN dongle
		# Inbox Audio request IRQ for headset on I2S mode
		echo 1 > /sys/bus/i2c/devices/2-001a/rt5683_get_irq_setting
		sleep 1.5
		echo 1 > /sys/bus/i2c/devices/2-001a/rt5683_enable_irq_setting

		insmod /vendor/lib/modules/ms51_inbox.ko
		sleep 0.5
		echo 1 > /sys/class/leds/aura_inbox/dongle_switch_mode
	elif [ "$accy_gen" == "5" ]; then		# For ANAKIN dongle
		echo "this is rog5 inbox" > /dev/kmsg
	else
		echo "[EC_HID][Switch] ACCY Generation wrong, $accy_gen!!!!" > /dev/kmsg
		echo 14 > /sys/class/ec_hid/dongle/device/sync_state
		exit 0
	fi

	# Detect Inbox driver sysfs node
#	if [ ! -f "$inbox_fwmode_path" ]; then
#		echo "[EC_HID][Switch] Inbox driver occur error!!! Maybe it is not 5nd inbox." > /dev/kmsg
#		echo 14 > /sys/class/ec_hid/dongle/device/sync_state
#		exit 0
#	fi

	# Close Phone aura
	#echo 0 > /sys/class/leds/aura_sync/mode
	#echo 1 > /sys/class/leds/aura_sync/apply
	#echo 0 > /sys/class/leds/aura_sync/VDD

	# do not add any action behind here
	setprop vendor.asus.donglechmod 1
	##start DongleFWCheck
	check_accy_fw_ver;
	if [ "$accy_gen" == "3" ]; then
		echo 0 > /sys/class/leds/aura_inbox/dongle_switch_mode
	fi
	echo 1 > /sys/class/ec_hid/dongle/device/sync_state
elif [ "$type" == "7" ]; then
	insmod /vendor/lib/modules/ms51_backcover.ko
	sleep 1
	setprop vendor.asus.donglechmod 7
	IDs=`cat /sys/class/leds/aura_backcover/IDs`
	setprop vendor.asus.aura.bumper5_info $IDs
	echo 23 > /sys/class/ec_hid/dongle/device/sync_state
else
	echo "[EC_HID][Switch] Error Type $type" > /dev/kmsg
	echo 0 > /sys/class/ec_hid/dongle/device/pogo_mutex
fi
