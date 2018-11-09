# zeta-os
The zeta serverless operating system

```
  ........
  .  ....         Zeta-OS : An in-RAM FaaS OS
    ....  .    Current Build: v0.07 [11-09-2018]
   ........
```

### Features
- Core : ~10MB
- Core + Extensions : ~25MB
- Core + Extensions + Hardware Drivers : ~50MB
- Kernel 4.14.10, 64-bit
- BASH, OpenSSH, Python2.7
- Easy to add features

### Remastering ISO
1. Clone repo and `cd zeta/iso`
2. Make desired changes to deltas.sh, bootlocal.sh, shellout.sh and associated files
3. Run `sudo bash build.sh`. You should see something like:
```
####################
# Zeta ISO Builder #
####################
Initializing : Done
Preparing    : Done
Creating     : Done
Shrinking    : Done
Compressing  : Done
Start Size   : 53M
End size     : 53M
ISO output   : /tmp/zeta-08172018-2044.iso
```
4. A new ISO is generated at: `/tmp/zeta-<timestamp>.iso`
