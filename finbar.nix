{ pkgs, ... }:

{
  environment.systemPackages = [
    (import pkgs/Finance { inherit pkgs; })
  ];
}
