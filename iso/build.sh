#!/bin/bash
########################
# Zeta-OS ISO Remaster #
##########################
# Author : Abe Hoffman   #
# Date   : 09302018      #
##########################

# Optional Debug mode
if [ "$1" = "-d" ]; then
  set -x
fi

## Global Variables ##
export BASEISO="zeta-current.iso"
export BASEISOPATH="base/$BASEISO"
export KERNEL="4.14.10-tinycore64"
export AUSER=`logname`
export ISODETAILS="zeta"
export WORKDIRNAME="zeta"
export MOUNT="/mnt/tmp"
export GZNAME="zeta.gz"
export BASEDIR="/tmp/tinycore"
export WORKDIR="/tmp/tinycore/$WORKDIRNAME"
export EXTRACT="$WORKDIR/extract"
export XLOC="$EXTRACT/x"
export TIMESTAMP=`date +"%m%d20%y-%H%M"`
export OUTPUT="/tmp/zeta-$TIMESTAMP.iso"
export APWD=`pwd`

###################### START ######################

# Begin User Feedback
echo "* Build env preparing, please wait..."
# Ensure proper packages are loaded for build
su tc -c 'tce-load -wi advcomp mkisofs-tools' > /dev/null

# Begin user feedback
echo "#######################"
echo "# Zeta-OS ISO Builder #"
echo "#######################"

###################### Prepare ######################

# User Feedback
echo -n "Preparing    : "

# Base Working Folders
mkdir ${MOUNT}
mkdir -p ${WORKDIR}
mkdir ${EXTRACT}

# Mount the ISO
mount ${BASEISOPATH} ${MOUNT} -o loop,ro
# Copy Data out of the ISO
cp -a ${MOUNT}/boot ${WORKDIR}
# Move the Initramfs to a workable location
mv ${WORKDIR}/boot/${GZNAME} ${WORKDIR}/${GZNAME}
# Unmount the ISO
umount ${MOUNT}

# Extract the Initramfs
cd ${EXTRACT}
zcat ${WORKDIR}/${GZNAME} | cpio -i -H newc -d &> /dev/null
rm ${WORKDIR}/${GZNAME}

# User Feedback
echo "Done"

###################### Inject Files ######################

# User Feedback
echo -n "Creating     : "

## Create the folders in the filesystem
cd ${APWD}

# Create 'tc' and 'dragonfly' user directories and permissions
mkdir ${EXTRACT}/home/tc
mkdir ${EXTRACT}/home/zeta

chown tc:staff ${EXTRACT}/home/tc
chown zeta:staff ${EXTRACT}/home/zeta

# Clean any old files (if present)
rm -rf ${XLOC}

# Create primary data directories (if not present)
mkdir ${XLOC}
mkdir ${XLOC}/src
mkdir ${XLOC}/bins
mkdir ${XLOC}/logs
mkdir ${XLOC}/files
mkdir ${XLOC}/scripts
mkdir ${XLOC}/packages
mkdir ${XLOC}/pythonlibs

# Create temporary working area folder and permissions
mkdir ${XLOC}/tmp
chown zeta:staff ${XLOC}/tmp
chmod 0777 ${XLOC}/tmp

# Inject Boot Related Files
cd ${APWD}
rm ${WORKDIR}/boot/isolinux/isolinux.cfg
cp config/isolinux.cfg ${WORKDIR}/boot/isolinux/isolinux.cfg
rm ${WORKDIR}/boot/isolinux/boot.msg
cp config/boot.msg ${WORKDIR}/boot/isolinux/boot.msg

# Inject the Message of the Day
cd ${APWD}
rm ${EXTRACT}/etc/motd
cp config/motd ${EXTRACT}/etc/motd

# Inject custom start-up script (hands off to shellout.sh)
cd ${APWD}
cp config/bootlocal.sh ${EXTRACT}/opt/bootlocal.sh
chmod 0775 ${EXTRACT}/opt/bootlocal.sh

# Inject user scripts
cd ${APWD}
cp config/shellout.sh ${XLOC}/scripts/shellout.sh
#cp config/staticip.py ${XLOC}/scripts/staticip.py
cp config/links.sh ${XLOC}/scripts/links.sh

chmod 0775 ${XLOC}/scripts/shellout.sh
#chmod 0775 ${XLOC}/scripts/staticip.py
chmod 0775 ${XLOC}/scripts/links.sh

# Inject TCZ Packages to load at boot time
cd ${APWD}
cp -a packages/* ${XLOC}/packages

# Inject python files
cd ${APWD}
cp -a pythonlibs/* ${XLOC}/pythonlibs

# Inject 'files' files
cd ${APWD}
cp -a files/* ${XLOC}/files

# Inject source files
cd ${APWD}
cp -a src/* ${XLOC}/src

# Inject Binary files (these need to be compiled for this kernel version)
cd ${APWD}
cp -a bins/* ${XLOC}/bins

# Inject user, password and connection related files
cd ${APWD}
cp config/passwd ${XLOC}/files/passwd
cp config/shadow ${XLOC}/files/shadow
cp config/sudoers ${XLOC}/files/sudoers
cp config/sshd_config ${XLOC}/files/sshd_config
cp config/default.script ${XLOC}/files/default.script

# User Feedback
echo "Done"

###################### Kernel Module Linking ######################

# Ensure Kernel Modules are linked correctly
chroot ${EXTRACT} depmod -a ${KERNEL} 2> /dev/null
# Ensure proper softlinks are created
ldconfig -r ${EXTRACT} 2> /dev/null

###################### Compress Data ######################

# Compress the filesystem into a CPIO archive and GZIP
echo -n "Shrinking    : "
cd ${EXTRACT}
find | cpio -o -H newc | gzip -2 > ${BASEDIR}/${GZNAME} 2> /dev/null
echo "Done"

# Further compress the archive
cd ${BASEDIR}
echo -n "Compressing  : "
advdef -z4 ${GZNAME} &> /dev/null
echo "Done"

###################### Create ISO ######################

# Move the new initramfs
mv ${BASEDIR}/${GZNAME} ${WORKDIR}/boot
# Remove the extracted files
rm -r ${EXTRACT}
# Create the ISO
cd ${BASEDIR}
mkisofs -l -J -R -V ${ISODETAILS} \
                    -no-emul-boot \
                    -boot-load-size 4 \
                    -boot-info-table \
                    -b boot/isolinux/isolinux.bin \
                    -c boot/isolinux/boot.cat \
                    -o ${OUTPUT} ${WORKDIRNAME} 2> /dev/null

# Change ISO Permissions
chown ${AUSER} ${OUTPUT}
# Provide user feedback
cd ${APWD}
echo -n "Start Size   : "; echo `ls -lhatr "${BASEISOPATH}" | awk '{print $5}'`
echo -n "End size     : "; echo `ls -lhatr "${OUTPUT}" | awk '{print $5}'`
echo "ISO output   : ${OUTPUT}"

###################### END ######################

# Clean the base directory
rm -r ${BASEDIR}
