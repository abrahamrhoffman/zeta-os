from __future__ import print_function
import collections
import subprocess
import time
import sys


class StaticIP(object):

    def __init__(self):
        pass

    def startInterfaces(self, interfaces):
        for interface in interfaces:
            cmd = ("sudo ifconfig %s up" % interface)
            subprocess.check_output(cmd, shell=True)

    def readInject(self):
        # Read metadata injection data
        cmd = ("cat /proc/cmdline")
        data = subprocess.check_output(cmd, shell=True).split("\n")[0]
        # Create dictionary
        ipstack = ("")
        vlan = ("")
        aList = data.split("=")
        for ix, ele in enumerate(aList):
            if ("ipstack") in ele:
                temp = aList[(ix+1)].split('"')
                ipstack = temp[1].split(" ")
            if ("vlan") in ele:
                temp = aList[(ix+1)]
                vlan = temp.split('"')
        try:
            vlan
            return ipstack, vlan
        except UnboundLocalError:
            vlan = ("")
            return ipstack, vlan

    def interfaceList(self):
        cmd = ("ifconfig -a | grep eth | awk '{print $1}'")
        interfaces = subprocess.check_output(cmd, shell=True).split("\n")
        del interfaces[-1]
        return interfaces

    def linkValidate(self):
        links = []
        for interface in self.interfaces:
            cmd = ("/x/bins/ethtool %s | awk '/Link/ {print $3}'" % interface)
            link = subprocess.check_output(cmd, shell=True).split("\n")[0]
            if link == ("yes"):
                links.extend([interface])
            else:
                cmd = ("sudo ifconfig %s down" % interface)
                subprocess.check_output(cmd, shell=True)
        return links

    def injectIP(self):
        address = self.ipstack[0]
        netmask = self.ipstack[1]
        gateway = self.ipstack[2]
        for ele in self.links:
            cmd = ("sudo ifconfig %s %s netmask %s up" %
                   (ele, address, netmask))
            subprocess.call(cmd, shell=True)
            cmd = ("sudo route add default gw %s" % gateway)
            subprocess.call(cmd, shell=True)
            # Five second delay: allow switch to ARP
            time.sleep(5)
            cmd = ("ping -c3 %s | awk '/\packet loss/ {print $7}' |\
                    sed 's/.$//g'" % gateway)
            ping = subprocess.check_output(cmd, shell=True).split("\n")
            del ping[-1]
            # Check if all packets were not returned.
            # If not, that means the interface is down.
            # If some of the packets returned, that means the interface
            #  is working. In that case, leave the interface set
            #  and exit the script.
            if ping[0] != ("100"):
                self.clearScreen()
                raise SystemExit
            else:
                # Down current interface before continuing
                cmd = "sudo ifconfig {} down".format(ele)
                subprocess.call(cmd, shell=True)
                continue

    def clearScreen(self):
        cmd = ("clear;cat /etc/motd;echo")
        subprocess.call(cmd, shell=True)

    def run(self):
        self.ipstack, self.vlan = self.readInject()
        self.interfaces = self.interfaceList()
        self.startInterfaces(self.interfaces)
        self.links = self.linkValidate()
        self.injectIP()


def main():
    sip = StaticIP()
    sip.run()

if __name__ == "__main__":
    main()
