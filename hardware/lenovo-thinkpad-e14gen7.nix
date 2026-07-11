{ hostname, domainname, stateVersion, logicalCores ? 14, etherMac, wifiMac
, ip4addr, systemPackages, system, filesystems, imports, bash-header, hlib }:

[ (import ./sata/xhci-pci.nix)
  (import ./thunderbolt.nix)
  # cannae make this work :-(
  # (import ./networking/intel-ax210.nix)

  (import ../virtualization/intel.nix)
  (import ../storage/nvme0.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit ip4addr wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports hlib;
    cpuFreqGovernor = "powersave";
  })
]
