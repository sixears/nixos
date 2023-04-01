{ hostname, domainname, stateVersion, etherMac, wifiMac, systemPackages, system
, filesystems, imports, bash-header, boot
, logicalCores ? 1
}:

# CPU: 1.7-GHz AMD Athlon II Neo K125 (12W)
# GPU: ATI Radeon HD 4225
# Broadcom wifi

[ (import ./networking/broadcom.nix)
  (import ./sata/ahci.nix)
  (import ./sata/ehci-pci.nix)
  (import ./sata/ohci-pci.nix)
  (import ./card/ums-realtek.nix)
  (import ./fwupd.nix)

  (import ../virtualization/amd.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports boot;
    # see https://wiki.archlinux.org/title/CPU_frequency_scaling
    # intel_pstate driver works well with powersave.
    # run cpupower frequency-info to check that intel_pstate driver is in use,
    # and that the current policy is "powersave"
    cpuFreqGovernor = "powersave";
  })
]
