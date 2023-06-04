{ hostname, domainname, stateVersion, logicalCores ? 8, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header }:

# CPU: 1.8-GHz Intel Core i7-8565U (9-29W)
#      [8 efficient+2 performance cores/8 efficient+4 performance threads]
# GPU: Intel Corporation WhiskeyLake-U GT2 [UHD Graphics 620]

[ (import ./sata/xhci-pci.nix)

  (import ../virtualization/intel.nix)
  (import ../storage/nvme0.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports;
    cpuFreqGovernor = "powersave";
  })
]
