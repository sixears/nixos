{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./fcron.nix
    ];

  services.rsnapshot = {
    enable                = true;
    enableManualRsnapshot = true;
    extraConfig = ''
                    snapshot_root	/local/home-backup/
                    no_create_root	1
                    sync_first	1

                    exclude		*~
                    exclude		.gvfs
                    exclude		.shotwell/thumbs/
                    exclude		.cache/

                    backup	/home/	localhost/home/

                    retain	hourly	24
                    retain	daily		7
                    retain	weekly	4
                    retain	monthly	2
                  '';
  };

  services.fcron.systab =
    ''
      @ 1h  ${pkgs.rsnapshot}/bin/rsnapshot sync && ${pkgs.rsnapshot}/bin/rsnapshot hourly
      @ 1d  ${pkgs.rsnapshot}/bin/rsnapshot daily
      @ 1w  ${pkgs.rsnapshot}/bin/rsnapshot weekly
      @ 1m  ${pkgs.rsnapshot}/bin/rsnapshot monthly
    '';
}
