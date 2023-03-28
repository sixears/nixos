{ hostname, domainname, stateVersion, logicalCores ? 12, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header }:

# CPU: 1.7-GHz Intel Core i7-1250 (9-29W)
#      [8 efficient+2 performance cores/8 efficient+4 performance threads]
# GPU: Intel Corporation Alder Lake-UP4 GT2 [Iris Xe Graphics]

[ (import ../hardware/video/i915.nix)
  (import ../virtualization/intel.nix)
  (import ../storage/nvme0.nix)
  (import ../hardware/sata/xhci-pci.nix)
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
  })
]
