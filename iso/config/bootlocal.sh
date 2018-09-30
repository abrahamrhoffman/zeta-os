#!/bin/sh
##############################
# Dragonfly Post-Boot Script #
##########################################################
# !! IMPORTANT: This script is executed in ash shell.    #
# Critical bash features will not work!                  #
##########################################################

# Ash compliant script to load local packages
su tc -c 'for AFILE in `ls /x/packages`;do tce-load -i /x/packages/"$AFILE" &> /dev/null;done'
su tc -c 'sh /x/scripts/shellout.sh'
