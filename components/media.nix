{ config, lib, pkgs, ... }:

let mlen = import ../pkgs/mlen.nix { inherit pkgs; };
 in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    atomicparsley
    handbrake
    mlen
  ];
}
