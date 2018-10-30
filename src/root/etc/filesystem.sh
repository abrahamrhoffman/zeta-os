#!/bin/sh

mount -t tmpfs none /mnt

mkdir /mnt/dev
mkdir /mnt/sys
mkdir /mnt/proc
mkdir /mnt/tmp

mount --move /dev /mnt/dev
mount --move /sys /mnt/sys
mount --move /proc /mnt/proc
#mount --move /tmp /mnt/tmp

exec switch_root /mnt /etc/main_init.sh
