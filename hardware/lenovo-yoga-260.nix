{ hostname, domainname, stateVersion, logicalCores ? 4, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header, hlib }:

# CPU: 2.5-3.1GHz Intel Core i7-6500U 15W
# https://www.cpubenchmark.net/cpu.php?cpu=Intel+Core+i7-6500U+%40+2.50GHz&id=2607
#      [2 cores, 4 threads]
# from lspci
# GPU: Intel Corporation SkyLake GT2 [HD Graphics 520] (rev 07)

[ (import ../virtualization/intel.nix)

  (import ./sata/xhci-pci.nix)
  (import ./sata/ahci.nix)
  (import ./card/rtsx-pci-sdmmc.nix)

  (import ../storage/sda.nix)
  (import ../components/ethernet.nix { inherit etherMac; })
  (import ../components/wifi.nix     { inherit wifiMac; })
  (import ../std.nix {
    inherit hostname domainname stateVersion logicalCores systemPackages system
            bash-header hlib filesystems imports;
    cpuFreqGovernor = "powersave";
  })
]
