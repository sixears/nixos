{ hostname, domainname, stateVersion, logicalCores, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header }:

[ (import ../virtualization/amd.nix)
  (import ../storage/nvme0.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports;
    cpuFreqGovernor = "powersave";
  })
]
