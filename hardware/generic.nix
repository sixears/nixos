{ hostname, domainname, stateVersion, logicalCores, etherMac
, system, filesystems, imports, bash-header, virtualization, hlib
, wifiMac         ? ""
, systemPackages  ? (_ : [])
, nvme0           ? false
, cpuFreqGovernor ? "ondemand"
, boot            ? ../boot/efi.nix
}:

[ (import virtualization)
  (if nvme0 then (import ../storage/nvme0.nix) else ../null.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (if wifiMac != "" then
    (import ../components/wifi.nix     { inherit wifiMac; }) else ../null.nix)
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header filesystems imports boot hlib;
    inherit cpuFreqGovernor;
  })
]
