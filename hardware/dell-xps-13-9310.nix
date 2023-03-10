{ hostname, domainname, stateVersion, logicalCores, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header }:

[ (import ../video/i915.nix)
  (import ../virtualization/intel.nix)
  (import ../storage/nvme0.nix)
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
