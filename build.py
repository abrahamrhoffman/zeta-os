import subprocess
import datetime
import time
import os

class OSBuild(object):


    def __init__(self):
        self._datetime = datetime.datetime.now()
        self._dt = self._datetime.strftime('%m%d%Y-%H%M%S')
        self._build_path = os.getcwd()
        self._iso_path = ("../releases/testing/zeta-{}.iso".format(self._dt))
        self._iso_details = ("zeta")
        self._initramfs_name = ("zeta.gz")

    def _build_initramfs(self):
        os.chdir(self._build_path + "/src/root")
        # Create Minimal Folder structure
        dirs = ["dev", "proc", "sys"]
        for ele in dirs:
            if not os.path.exists(ele):
                os.mkdir(ele)
        # Compress initramfs from root filesystem
        cmd = ("find | cpio -o -H newc | gzip -2 > {}"\
            .format(self._build_path + "/src/iso/boot/" + self._initramfs_name))
        subprocess.call(cmd, shell=True)
        # Further compress initramfs (insane)
        cmd = ("advdef -z4 {} 2> /dev/null"\
            .format(self._build_path + "/src/iso/boot/" + self._initramfs_name))
        subprocess.call(cmd, shell=True)
        os.chdir(self._build_path)

    def _build_iso(self):
        os.chdir(self._build_path + "/src")
        cmd = ("mkisofs -l -J -R -V {} -no-emul-boot -boot-load-size 4 \
                -input-charset utf-8 \
                -boot-info-table -b {} -c {} -o {} {}"\
                .format(self._iso_details,
                ("boot/isolinux/isolinux.bin"),
                ("boot/isolinux/boot.cat"),
                (self._iso_path), ("./iso")))
        subprocess.call(cmd, shell=True)
        os.chmod(self._iso_path, 775)
        # Delete softlink if present
        if os.path.isfile("../releases/testing/current-test.iso"):
            os.remove("../releases/testing/current-test.iso")
        # Create softlink
        cmd = ("ln -s {} {} ".format(self._iso_path,
                            "../releases/testing/current-test.iso")
        subprocess.call(cmd, shell=True)
        os.chdir(self._build_path)

    def _cleanup(self):
        os.remove(self._build_path + "/src/iso/boot/" + self._initramfs_name)

    def run(self):
        self._build_initramfs()
        self._build_iso()
        self._cleanup()

def main():
    osb = OSBuild()
    osb.run()

if __name__ == "__main__":
    main()
