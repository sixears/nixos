# https://manpages.ubuntu.com/manpages/focal/en/man4/sdhci.4freebsd.html
{ ... }: { boot.initrd.availableKernelModules = [ "sdhci_pci" ]; }
