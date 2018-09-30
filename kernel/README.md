# Zeta Kernel Compilation
Zeta-OS is based on the open source MIT licensed project called: `TinyCore`. TinyCore is a micro operating system designed for embedded systems or prolific OS enthusiasts interested in minimalism. This is a small set of tools and instructions to custom compile the tinycore kernel and produce the Zeta-OS Kernel and Modules (including drivers).

## Rationale
Tinycore is super small (~10MB). However, this sparsity leaves certain kernel parameters, modules and drivers out. PayPal's Enterprise hardware needs just a few of these to operate correctly. For example:
- SuperMicro's X10 and X11 BIOS config requires the CONFIG_X86_X2APIC parameter be compiled into the kernel. X2APIC is required to boot TinyCore on motherboards with high IRQ count.
- SuperMicro's X10 and X11 hardware uses 72 CPUs. Tinycore's kernel only enables 64 naturally.
- A full list of hardware requirements and current support is available here: <a href="https://github.paypal.com/IAAS-R/Zeta-os/blob/master/kernel/VENDOR_SUPPORT.md">Vendor Support</a>

## VM Setup
- Download the TinyCore ISO: https://distro.ibiblio.org/tinycorelinux/9.x/x86_64/release/CorePure64-9.0.iso
- Start the ISO in a Tinycore VM (VirtualBox or other)
- Ensure the ISO you select uses the same kernel version that you are attempting to compile
  - For example, the 9.0 release of Corepure64 uses the 4.14.10-tinycore64 kernel.
  - ** Cross-compilation toolchains are available, but they often break and generally require too much maintenance and are therefore not included.

## TinyCore Setup
1. `vi /usr/share/udhcpc/default.script`, add `dns="8.8.8.8"` to the top.
2. `sudo echo "nameserver 8.8.8.8" > /etc/resolv.conf`
3. `tce-load -wi openssh`
4. `sudo cp /usr/local/etc/ssh/sshd_config.orig /usr/local/etc/ssh/sshd_config`
5. `sudo /usr/local/etc/init.d/openssh start`
6. Change the `tc` user password: `passwd`
7. SSH to the ip address: `ifconfig -a | grep inet`
8. Now, inside the SSH session: `tce-load -wi git glibc_apps ncurses-dev compiletc coreutils bc bash perl5 advcomp mkisofs-tools cdrtools`
9. Change to root: `sudo su`
10. Ensure a compatible Terminal variable is set: `TERM=xterm`

## Manual Build
1. Download the tinycore patched kernel and kernel config:
```
wget https://distro.ibiblio.org/tinycorelinux/9.x/x86_64/release/src/kernel/config-4.14.10-tinycore64
wget https://distro.ibiblio.org/tinycorelinux/9.x/x86_64/release/src/kernel/linux-4.14.10-patched.txz
```
2. Unpack the Kernel `tar -Jxf linux-4.14.10-patched.txz -C /tmp/my-folder`
3. Move the kernel config `mv config-4.14.10-tinycore64 /tmp/my-folder/linux-4.14.10/.config`
4. `make oldconfig`
5. `make menuconfig` and make desired changes
6. `make bzImage` to build the kernel itself
7. `make modules` to build the loadable modules
8. `mkdir /tmp/my-folder/modules`
9. `make INSTALL_MOD_PATH=/tmp/my-folder/modules modules_install`
10. Copy the desired drivers and modules from `/tmp/my-folder/modules/` to the location of your choice: e.x. for ISO remaster

* Hint: `make -j{N}` significantly speeds up the build process. Ex: `make -j12 bzImage` will use 12 threads to compile the kernel.
