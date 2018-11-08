import subprocess
import argparse
import datetime
import time
import os

class OSBuild(object):


    def __init__(self, build_version):
        self._build_version = build_version
        self._datetime = datetime.datetime.now()
        self._pubdate = datetime.datetime.now().strftime("%m-%d-%Y")
        self._dt = self._datetime.strftime('%m%d%Y-%H%M%S')
        self._build_path = os.getcwd()
        self._iso_path = ("../releases/testing/zeta-{}.iso".format(self._dt))
        self._sl0_path = ("zeta-{}.iso".format(self._dt))
        self._sl1_path = ("current-test.iso")
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
        os.chdir(self._build_path)

    def _softlink(self):
        os.chdir(self._build_path + "/releases/testing")
        # Delete softlink if present
        try: os.remove(self._sl1_path)
        except: pass
        # Create softlink
        cmd = ("ln -s {} {} ".format(self._sl0_path,self._sl1_path))
        subprocess.call(cmd, shell=True)
        os.chdir(self._build_path)

    def _cleanup(self):
        os.remove(self._build_path + "/src/iso/boot/" + self._initramfs_name)

    def _stamp(self):
        someFiles = ["README.md", "./src/iso/boot/isolinux/boot.msg",
                     "./src/root/etc/motd"]
        # Update README.md, MOTD, and boot.msg
        for F in someFiles:
            f = open(F, "r+")
            aFile = f.read()
            f.close();os.remove(F)
            aFile = aFile.split("\n")
            for ix, ele in enumerate(aFile):
                if ("Current Build") in ele:
                    ele = ("    ....  .    Current Build: v{} [{}]"\
                            .format(self._build_version, self._pubdate))
                    aFile[ix] = ele
            f = open(F, "w")
            f.write("\n".join(aFile));f.close()

    def run(self):
        self._build_initramfs()
        self._build_iso()
        self._cleanup()
        self._softlink()
        self._stamp()

def main():
    parser = argparse.ArgumentParser()
    required = parser.add_argument_group('Required arguments')
    required.add_argument('-b', '--build', action='store', help='Build version. Ex: 1.20', required=True)
    args = parser.parse_args()
    osb = OSBuild(args.build)
    osb.run()

if __name__ == "__main__":
    main()
