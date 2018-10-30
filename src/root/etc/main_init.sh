#!/bin/sh
# Busybox init. Based on configuration in /etc/inittab
setsid cttyhack /bin/sh
exec /sbin/init
