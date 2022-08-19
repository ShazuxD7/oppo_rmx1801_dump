#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:34489624:e5b02569673e2d7c4aee36af9ce8462cd551bbe6; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/bootdevice/by-name/boot:17179924:8d43addcdd9d804a1f95550e133af35773b67a1b EMMC:/dev/block/bootdevice/by-name/recovery e5b02569673e2d7c4aee36af9ce8462cd551bbe6 34489624 8d43addcdd9d804a1f95550e133af35773b67a1b:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
