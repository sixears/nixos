{ hostname, domainname, stateVersion, logicalCores ? 4, etherMac, wifiMac ? ""
, systemPackages, system, filesystems, imports, bash-header, hlib }:

# CPU: 2.0-2.7 GHz Intel J4125 [4 cores/4 threads] 10W

[ (import ./sata/ahci.nix)
  (import ./sata/xhci-pci.nix)
  (import ./usb/hid.nix)
  (import ./card/rtsx-usb-sdmmc.nix)
  (import ./card/sdhci.nix)
  (import ./fwupd.nix)
  (import ../virtualization/intel.nix)
  (import ../storage/nvme0.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports hlib;
    # see https://wiki.archlinux.org/title/CPU_frequency_scaling
    # intel_pstate driver works well with powersave.
    # run cpupower frequency-info to check that intel_pstate driver is in use,
    # and that the current policy is "powersave"
    cpuFreqGovernor = "powersave";
  })
]++ (if (wifiMac == "") then [
  (import ../components/wifi.nix     { inherit wifiMac; })
] else [])
