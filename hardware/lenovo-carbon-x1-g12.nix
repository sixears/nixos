{ hostname, domainname, stateVersion, logicalCores ? 14, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header, hlib }:

# CPU: 1.7-GHz Intel Core i7-1250 (9-29W)
#      [8 efficient+2 performance cores/8 efficient+4 performance threads]
# GPU: Intel Corporation Alder Lake-UP4 GT2 [Iris Xe Graphics]

[ (import ./video/i915.nix)
  (import ./sata/xhci-pci.nix)
  (import ./fwupd.nix)
  (import ./thunderbolt.nix)

  (import ../virtualization/intel.nix)
  (import ../storage/nvme0.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header hlib filesystems imports;
    # see https://wiki.archlinux.org/title/CPU_frequency_scaling
    # intel_pstate driver works well with powersave.
    # run cpupower frequency-info to check that intel_pstate driver is in use,
    # and that the current policy is "powersave"
    cpuFreqGovernor = "powersave";
  })
]
