#!/vendor/bin/sh
#
#ifdef VENDOR_EDIT
#jie.cheng@swdp.shanghai, 2015/11/09, add init.oppo.hypnus.sh
#persist_enable_logging=`getprop persist.sys.oppo.junklog`
persist_enable_logging=true
enable_logging=1
#wait data partition
if [ "$0" != "/data/hypnus/init.oppo.hypnus.sh" ]; then
        n=0
        while [ n -lt 10 ]; do
                if [ "`stat -f -c '%t' /data/`" == "ef53"  -o "`stat -f -c '%t' /data/`" == "f2f52010" ];then
                        log "hypnus wait for data, data is ready"
                        break
                else
                        n=$((n+1));
                        log "hypnus wait for data, retry: n="$n
                        sleep 2
                fi
        done
        if [ -f /data/hypnus/init.oppo.hypnus.sh ]; then
                sh /data/hypnus/init.oppo.hypnus.sh
                exit
        fi
else
        log "hypnus load sh from data"
fi

complete=`getprop sys.boot_completed`
enable=`getprop persist.sys.enable.hypnus`


case "$persist_enable_logging" in
    "true")
        enable_logging=1
	;;
    "false")
        enable_logging=0
	;;
esac

if [ ! -n "$complete" ] ; then
        complete="0"
fi

elsaenable=`getprop persist.sys.elsa.kernel_enable`
if [ "$elsaenable" == "1" ]; then
	elsaenable=1
else
	elsaenable=0
fi

case "$enable" in
    "1")
		echo "Hypnus module insmod beging!" > /dev/kmsg
        #disable core_ctl
        echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/disable
        echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/disable

        n=0
        while [ n -lt 3 ]; do
                #load data folder module if it is exist
                if [ -f /data/hypnus/hypnus.ko ]; then
                        insmod /data/hypnus/hypnus.ko -f boot_completed=$complete kneuron_enable=1 elsa_enable=$elsaenable
                else
                        insmod /vendor/lib/modules/hypnus.ko -f boot_completed=$complete kneuron_enable=1 elsa_enable=$elsaenable
                fi

		if [ $? != 0 ];then
                        if [ -f /data/hypnus/hypnus.ko ]; then
                                insmod /data/hypnus/hypnus.ko -f kneuron_enable=1 elsa_enable=$elsaenable
                        else
                                insmod /vendor/lib/modules/hypnus.ko -f kneuron_enable=1 elsa_enable=$elsaenable
                        fi

	                if [ $? != 0 ];then
	                        n=$((n+1));
	                        echo "Error: insmod hypnus.ko failed, retry: n="$n > /dev/kmsg
	                else
	                        echo "Hypnus module insmod!" > /dev/kmsg
	                        break
	                fi
                else
                        echo "Hypnus module insmod!" > /dev/kmsg
                        break
                fi
        done
	chown system:system /dev/kneuron
        chown system:system /sys/kernel/hypnus/scene_info
        chown system:system /sys/kernel/hypnus/action_info
        chown system:system /sys/kernel/hypnus/view_info
        chown system:system /sys/kernel/hypnus/log_state
        chown system:system /sys/kernel/hypnus/notification_info
	chown root:system /sys/module/hypnus/parameters/cpuload_thresh
	chown root:system /sys/module/hypnus/parameters/io_thresh
	chown root:system /sys/module/hypnus/parameters/mem_thresh
	chown root:system /sys/module/hypnus/parameters/temperature_thresh
	chown root:system /sys/module/hypnus/parameters/trigger_time
	chown root:system /sys/module/hypnus/parameters/kneuron_work_enable
	chown root:system /sys/module/hypnus/parameters/elsa_enable_netlink
	chown root:system /sys/module/hypnus/parameters/elsa_socket_align_ms
	chown root:system /sys/module/hypnus/parameters/elsa_align_ms
        chmod 0666 /sys/kernel/hypnus/notification_info
        chown system:system /sys/kernel/hypnus/version
        chown system:system /sys/class/devfreq/mmc0/min_freq
        chcon u:object_r:sysfs_hypnus:s0 /sys/kernel/hypnus/view_info
        echo $enable_logging > /sys/module/hypnus/parameters/enable_logging
        chown system:system /data/hypnus
        setprop persist.report.tid 2
		echo "Hypnus module insmod end!" > /dev/kmsg
        ;;
esac

case "$enable" in
    "0")
        rmmod hypnus.ko
        # Bring up all cores online
        echo 1 > /sys/devices/system/cpu/cpu0/online
        echo 1 > /sys/devices/system/cpu/cpu1/online
        echo 1 > /sys/devices/system/cpu/cpu2/online
        echo 1 > /sys/devices/system/cpu/cpu3/online
        echo 1 > /sys/devices/system/cpu/cpu4/online
        echo 1 > /sys/devices/system/cpu/cpu5/online
        echo 1 > /sys/devices/system/cpu/cpu6/online
        echo 1 > /sys/devices/system/cpu/cpu7/online

        # Enable low power modes
        echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

        #governor settings
        echo 633600 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        echo 1843200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        echo 1113600 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
        echo 2208000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

        #enable core_ctl
        echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/disable
        echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/disable
        ;;
esac
#endif /* VENDOR_EDIT */
