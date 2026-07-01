{ pkgs, ... }:

let
  vpnZipUrl = "https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip";

  # Fetch and unpack the zip file
  vpnConfigs = pkgs.runCommand "vpn-configs" {
    # Fetch the zip file
    fetchzip = pkgs.fetchzip {
      url = vpnZipUrl;
      # Optional: add sha256 for cache correctness
      sha256 = "0v1h7s4k9v..."; # Replace with actual sha256
    };

    # Directory for unpacked configs
    unpackDir = "${name}/unpacked";

  } ''
    mkdir -p $out/${unpackDir}
    cp -r ${fetchzip}/* $out/${unpackDir}
  '';

in {
  # Example: copy configs to /etc/vpn (or any directory)
  environment.etc."vpn" = {
    source = vpnConfigs;
  };
}
