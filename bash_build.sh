#!/bin/bash

# Download the lastest busybox for x86_64
wget https://busybox.net/downloads/binaries/\
                         1.28.1-defconfig-multiarch/busybox-x86_64 -O\
                         ./busybox

# Download the latest stable mainline kernel files from cannonical
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.18.14/linux-headers-4.18.14-041814_4.18.14-041814.201810130431_all.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.18.14/linux-headers-4.18.14-041814-generic_4.18.14-041814.201810130431_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.18.14/linux-headers-4.18.14-041814-lowlatency_4.18.14-041814.201810130431_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.18.14/linux-image-unsigned-4.18.14-041814-generic_4.18.14-041814.201810130431_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.18.14/linux-image-unsigned-4.18.14-041814-lowlatency_4.18.14-041814.201810130431_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.18.14/linux-modules-4.18.14-041814-generic_4.18.14-041814.201810130431_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.18.14/linux-modules-4.18.14-041814-lowlatency_4.18.14-041814.201810130431_amd64.deb

# Create softlinks for BusyBox (enable commands)

# Compress the filesystem into a CPIO archive and GZIP
cd src/root
find | cpio -o -H newc | gzip -2 > ../iso/boot/zeta.gz

advdef -z4 zeta.gz

mkisofs -l -J -R -V zeta \
                    -no-emul-boot \
                    -boot-load-size 4 \
                    -boot-info-table \
                    -b boot/isolinux/isolinux.bin \
                    -c boot/isolinux/boot.cat \
                    -o zeta.iso iso

mkisofs -l -J -R -V zeta \
                    -no-emul-boot \
                    -boot-load-size 4 \
                    -boot-info-table \
                    -b iso/boot/isolinux/isolinux.bin \
                    -c iso/boot/isolinux/boot.cat \
                    -o zeta.iso ./iso
