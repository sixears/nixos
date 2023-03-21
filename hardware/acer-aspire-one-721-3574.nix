{ hostname, domainname, stateVersion, logicalCores ? 1, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header }:

# CPU: 1.7-GHz AMD Athlon II Neo K125 (12W)
# GPU: ATI Radeon HD 4225
# Broadcom wifi

[ (import ../virtualization/amd.nix)
  (import ../hardware/networking/broadcom.nix)
  (import ../hardware/sata/ahci.nix)
  (import ../hardware/sata/ehci-pci.nix)
  (import ../hardware/sata/ohci-pci.nix)
  (import ../hardware/card/ums-realtek.nix)
  (import ../hardware/fwupd.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports;
    # see https://wiki.archlinux.org/title/CPU_frequency_scaling
    # intel_pstate driver works well with powersave.
    # run cpupower frequency-info to check that intel_pstate driver is in use,
    # and that the current policy is "powersave"
    cpuFreqGovernor = "powersave";

    boot = import ../boot/grub.nix { grub-device = "/dev/sda"; };

  })
]
