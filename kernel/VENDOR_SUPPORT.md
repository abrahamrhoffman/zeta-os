# Dragonfly OS : Vendor Hardware Support

## Legend:
* KPC : Kernel Parameter Coverage
  * Tunable kernel parameters required by the hardware to boot Dragonfly
* NDC : Network Driver Coverage
  * Network drivers compiled into the kernel, required for network functionality
* BKF : Boot-time Kernel Flags
  * Optional Kernel flags appended to the boot-time kernel

## Supermicro
- [X] X10DRT-P : Full Hardware Coverage - KPC, NDC, BKF
- [X] X10DRT-P : (KPC) Kernel Parameter Coverage : `X2APIC`, `128 CPUs`
- [X] X10DRT-P : (NDC) Network Driver Coverage
  - `Intel Ethernet Controller I350-AM2` : `igb.ko`
  - `Mellanox Technologies MT27710 Family [ConnectX-4 Lx]` : `mlx5_core.ko`
- [X] X10DRT-P : (BKF) Boot-time Kernel Flags : `N/A`
<br><br>
- [X] X11DPT-B : Full Hardware Coverage - KPC, NDC, BKF
- [X] X11DPT-B : (KPC) Kernel Parameter Coverage : `X2APIC`, `128 CPUs`
- [X] X11DPT-B : (NDC) Network Driver Coverage
  - `Intel Ethernet Controller I350-AM2` : `igb.ko`
  - `Mellanox Technologies MT27710 Family [ConnectX-4 Lx]` : `mlx5_core.ko`
- [X] X11DPT-B : (BKF) Boot-time Kernel Flags : `N/A`

## HP

## Dell
