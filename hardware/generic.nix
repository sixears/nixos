{ hostname, domainname, stateVersion, logicalCores, etherMac, wifiMac ? ""
, systemPackages, system, filesystems, imports, bash-header
, virtualization
, nvme0 ? false
, cpuFreqGovernor ? "ondemand"
}:

[ (import virtualization)
  (if nvme0 then (import ../storage/nvme0.nix) else ../null.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (if wifiMac != "" then
    (import ../components/wifi.nix     { inherit wifiMac; }) else ../null.nix)
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports;
    inherit cpuFreqGovernor;
  })
]
