{ hostname, domainname, stateVersion, logicalCores ? 8, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header }:

# CPU: 2.8-GHz Intel Core i7-1165G7 (9-29W)
#      [4 cores, 8 threads]
# GPU: Intel Corporation TigerLake-LP GT2 [Iris Xe Graphics]

[ (import ./sata/xhci-pci.nix)
  (import ./fwupd.nix)

  (import ../virtualization/intel.nix)
  (import ./networking/broadcom.nix)
  (import ../storage/nvme0.nix)
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
  })
]
