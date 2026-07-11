# 2025-11-22 - we don't need this, we use sudo systemctl start openvpn-*
{ pkgs, ... }:

let
  vpnZipUrl = "https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip";
  name      = "private-internet-access";
  unpackDir = "share/${name}";

  # Fetch the zip archive
  vpnZip = pkgs.fetchzip {
    url = vpnZipUrl;
    # sha found with
    # nix-prefetch-url https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip
    # generated 2025-11-10
    sha256 = "1amdkrwiz5xklhgmax7iiakycac6d9z16xqm0zmfpnvknjz9jdpz";
    stripRoot = false; # all files are at the top level of the zip
  };

  # Fetch and unpack the zip file
  vpnConfigs = pkgs.runCommand "vpn-configs" {
    # Input: the downloaded zip
    buildInputs = [ pkgs.unzip ];

    src = vpnZip;
  } ''
    mkdir -p $out
    cp $src/*.ovpn -d $out/
  '';

in {
  # Example: copy configs to /etc/vpn (or any directory)
  environment.etc.${name} = {
    source = vpnConfigs;
  };
}
