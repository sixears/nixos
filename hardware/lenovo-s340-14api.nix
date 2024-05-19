{ hostname, domainname, stateVersion, logicalCores ? 8, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header, hlib }:

[ (import ./networking/broadcom.nix)

  (import ./sata/xhci-pci.nix)
  (import ./card/rtsx-pci-sdmmc.nix)

  (import ../virtualization/amd.nix)
  (import ../storage/nvme0.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports hlib;
    cpuFreqGovernor = "powersave";
  })
]
