{ pkgs, ... }:

let scan =
  # Enabling direct scanner support means running hp-setup, which doesn't work
  # atm, due to python nonsense not finding dbus (even though it's correctly
  # installed)


  # Traceback (most recent call last):
  #   File "/nix/store/j6sfxs1ab46a915rgbj2ps9wr46cfzj6-hplip-3.19.1/share/hplip/setup.py", line 314, in <module>
  #     ui = import_module(ui_package + ".setupdialog")
  #   File "/nix/store/29xfvq39h5z7af90id0zaa4a09vgpsm7-python-2.7.16/lib/python2.7/importlib/__init__.py", line 37, in import_module
  #     __import__(name)
  #   File "/nix/store/j6sfxs1ab46a915rgbj2ps9wr46cfzj6-hplip-3.19.1/share/hplip/ui5/setupdialog.py", line 31, in <module>
  #     from base import device, utils, models, pkit
  #   File "/nix/store/j6sfxs1ab46a915rgbj2ps9wr46cfzj6-hplip-3.19.1/share/hplip/base/pkit.py", line 34, in <module>
  #     import dbus


  # This is a known issue
  # https://github.com/NixOS/nixpkgs/issues/37857

  # Thankfully, simple-scan can take a URI, and hp-makeuri still works fine, and
  # gives something like
  # hpaio:/net/HP_ColorLaserJet_MFP_M278-M281?ip=192.168.0.87
  pkgs.writers.writeBashBin
    "scan"
    ''
      if [ -v SCANNER_IP ]; then
        uri="$(${pkgs.hplip}/bin/hp-makeuri --sane "$SCANNER_IP")"
        builtin exec ${pkgs.simple-scan}/bin/simple-scan "$uri"
      else
        echo "Please set SCANNER_IP in the environment" 1>&2
      fi
    '';
in
  {
    # we need printing to configure the HP officejet
    imports = [ ./printing.nix ];

    environment.systemPackages = with pkgs; [
      scan
    ];

    # vertigen HP Color Laserjet Pro MFP M281fdw
    environment.variables = { SCANNER_IP="192.168.0.87"; };

    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
  }
