{ hostname, domainname, stateVersion, logicalCores ? 8, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header }:

[ (import ../virtualization/amd.nix)
  (import ../storage/nvme0.nix)
  (import ../hardware/sata/xhci-pci.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports;
    cpuFreqGovernor = "powersave";
  })
]
