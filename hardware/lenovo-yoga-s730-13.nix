{ hostname, domainname, stateVersion, logicalCores ? 8, etherMac, wifiMac
, systemPackages, system, filesystems, imports, bash-header }:

# CPU: 1.8-4.6GHz Intel Core i7-8565U (10-25W)
#      [4 cores, 8 threads]
# https://ark.intel.com/content/www/us/en/ark/products/149091/intel-core-i7-8565u-processor-8m-cache-up-to-4-60-ghz.html
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
