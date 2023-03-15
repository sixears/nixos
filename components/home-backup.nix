{ config, lib, pkgs, ... }:

let home-backup-check = import ../pkgs/home-backup-check.nix { nixpkgs = pkgs; };
in
  {
    imports =
      [
        ./rsync-server.nix
        ./fcron.nix

        ../users/people/martyn.nix
        ../users/people/heather.nix
        ../users/people/abigail.nix
        ../users/people/xander.nix
        ../users/people/jj.nix
      ];

    services.rsyncd.settings = {
      heather       = { path         = "/home-backup/heather" ;
                        "auth users" = "heather:rw"; };
      pictures      = { path         = "/home-backup/pictures";
                        "auth users" = "heather:rw"; };
      abigail       = { path         = "/home-backup/abigail" ;
                        "auth users" = "abigail:rw"; };
      xander        = { path         = "/home-backup/xander" ;
                        "auth users" = "xander:rw"; };
      jj            = { path         = "/home-backup/jj" ;
                        "auth users" = "jj:rw"; };
    };

    services.rsnapshot = {
      enable                = true;
      enableManualRsnapshot = true;
      extraConfig = ''
                    snapshot_root	/home-backup/
                    no_create_root	1
                    sync_first	1

                    exclude		*~
                    exclude		.gvfs
                    exclude		.shotwell/thumbs/
                    exclude		.cache/

                    backup	/home-backup/jj/	localhost/jj/
                    backup	/home-backup/xander/	localhost/xander/
                    backup	/home-backup/abigail/	localhost/abigail/
                    backup	/home-backup/martyn/	localhost/martyn/
                    backup	/home-backup/heather/	localhost/heather/

                    backup	/home-backup/pictures/	localhost/pictures/
                    backup	/home-backup/pictures-abi/	localhost/pictures-abi/
                    backup	/home-backup/pictures-martyn/	localhost/pictures-martyn/

                    backup	/home/	localhost/local-home/

                    # hourlies kept on the "home" host
                    # retain	hourly	6
                    retain	daily	7
                    retain	weekly	4
                    retain	monthly	12
                  '';
    };

    services.fcron.systab =
      ''
      # hourlies kept on the "home" host
      # 45  * *         * *         ${pkgs.rsnapshot}/bin/rsnapshot hourly
      35 23 *         * *         ${pkgs.rsnapshot}/bin/rsnapshot sync && ${pkgs.rsnapshot}/bin/rsnapshot daily
      20 23 1,8,15,22 * *         ${pkgs.rsnapshot}/bin/rsnapshot weekly
      05 23 1         * *         ${pkgs.rsnapshot}/bin/rsnapshot monthly
      @daily ${home-backup-check}/bin/home-backup-check
    '';
  }
