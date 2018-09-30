#!/bin/sh
##########################################################
# !! IMPORTANT: This script is executed in ash shell.    #
# Critical bash features will not work!                  #
##########################################################

# Ensure proper file permissions are set before the files are moved
su tc -c 'sudo chmod 0644 /x/files/passwd'
su tc -c 'sudo chmod 0644 /x/files/shadow'
su tc -c 'sudo chmod 0440 /x/files/sudoers'
su tc -c 'sudo chmod 0644 /x/files/sshd_config'
su tc -c 'sudo chmod 0755 /x/files/default.script'

# Copy Files to the proper position
su tc -c 'sudo cp /x/files/passwd /etc/passwd'
su tc -c 'sudo cp /x/files/shadow /etc/shadow'
su tc -c 'sudo cp /x/files/sudoers /etc/sudoers'
su tc -c 'sudo cp /x/files/sshd_config /usr/local/etc/ssh/sshd_config'
su tc -c 'sudo cp /x/files/default.script /usr/share/udhcpc/default.script'

## Move Python Libraries to System Usable location
su tc -c 'sudo cp /x/pythonlibs/xmltodict.py /usr/local/lib/python2.7/'
su tc -c 'sudo cp /x/pythonlibs/mimeparse.py /usr/local/lib/python2.7/'
su tc -c 'sudo cp /x/pythonlibs/six.py /usr/local/lib/python2.7/'
su tc -c 'sudo cp -a /x/pythonlibs/falcon /usr/local/lib/python2.7/'
su tc -c 'sudo cp -a /x/pythonlibs/certifi /usr/local/lib/python2.7/'
su tc -c 'sudo cp -a /x/pythonlibs/chardet /usr/local/lib/python2.7/'
su tc -c 'sudo cp -a /x/pythonlibs/idna /usr/local/lib/python2.7/'
su tc -c 'sudo cp -a /x/pythonlibs/urllib3 /usr/local/lib/python2.7/'
su tc -c 'sudo cp -a /x/pythonlibs/requests /usr/local/lib/python2.7/'

## Start System Services ##

# Static IP Injection
#su tc -c 'sudo python /x/scripts/staticip.py'
# OpenSSH
su tc -c 'sudo /usr/local/etc/init.d/openssh start &> /dev/null'
# Softlinks
su tc -c 'sudo sh /x/scripts/links.sh'
# Zeta REST API
su tc -c 'sudo python /x/pythonlibs/zeta/zeta.py &'
