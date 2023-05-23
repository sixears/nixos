{ pkgs, hlib, ... }:

let
  inherit (pkgs) rclone;
  s6-rotate    = import ../../pkgs/s6-rotate.nix     { inherit pkgs; };
  queue        = import ../../pkgs/queue.nix         { inherit pkgs hlib; };
  trim-to-size = import ../../pkgs/trim-to-size.nix  { inherit pkgs; };
  cam-bashrc =
    pkgs.writeTextFile
      {
        name = "cam-bashrc" ;
        text = ''
                 export RCLONE_CONFIG=$HOME/rclone.conf
                 PATH="${PATH:+$PATH:}/etc/profiles/per-user/$USER/bin"
               '';
        executable = false;
        destination = "/share/bashrc";
      };
  rclone-conf =
    pkgs.writeText "rclone-conf"
                   ''
                     [dropbox]
                     type = dropbox
                     token = {"access_token":"bYvu7GOPwYkAAAAAAAAiyOCKjayVxedb9gkSLEdrz8tvgV3p3yXEs7c4RZIm-2J5","token_type":"bearer","expiry":"0001-01-01T00:00:00Z"}

                     [mega-nz]
                     type = mega
                     user = mega-nz@sixears.com
                     pass = U4-8VBPIBkqNjMVt79YoTnbgvZa3zHu9jG6f
                     debug = false
                   '';
  cam-watch =
    pkgs.writers.writeBashBin
      "cam-watch"
      ''
        cam_rclone=/tmp/cam-rclone
        inotifywait=${pkgs.inotify-tools}/bin/inotifywait
        queue=${queue}/bin/queue
        rclone=${rclone}/bin/rclone
        rclone_conf=${rclone-conf}
        stat=${pkgs.coreutils}/bin/stat
        touch=${pkgs.coreutils}/bin/touch

        $touch $cam_rclone
        # /cam is on tmpfs, so will be initially empty.  sync it back from
        # mega-nz to initialize.
        $queue1 --queue /tmp/cam/rclone.queue                              \
             -- $rclone --config $rclone_conf copy mega-nz:cam/ /cam/      \
                           --syslog -v --log-format date,time,longfile,utc ;

        # The backgrounding of rclone is important, so we can continue
        # processing & queueing events.  Without the background, each event
        # will be handled in sequence - the queue will be redundant, everything
        # will just happen in order, one after the other.
        $inotifywait --timefmt %s --format %T /cam/ --monitor --quiet          \
                                  --recursive --event close_write              \
          | while read t f; do                                                 \
              $queue1 --queue /tmp/cam/rclone.queue                            \
                   -- $rclone --config $rclone_conf sync /cam/                 \
                         mega-nz:cam/ --exclude \*.mp4 --delete-excluded       \
                         --syslog -v --log-format date,time,longfile,utc &     \
            done
      '';
  rsync  = "${pkgs.rsync}/bin/rsync";
  s6-log = "${pkgs.s6}/bin/s6-log";
  move-cam-mp4s = pkgs.writers.writeBash "move-cam-mp4s" ''
    set -eu -o pipefail

    exec > >(${s6-log} t T S104857600 "$1")

    dirname=${pkgs.coreutils}/bin/dirname
    mkdir=${pkgs.coreutils}/bin/mkdir
    mv=${pkgs.coreutils}/bin/mv

    ${pkgs.findutils}/bin/find /cam -name \*.mp4 -mmin +60 -printf %P\\n | \
      while read i; do                                                     \
        t=/Cam-Archive/"$i";                                               \
        echo "/cam/$i -> $t";                                              \
        $mkdir --parents "$($dirname "$t")";                               \
        $mv -v /cam/"$i" "$t";                                             \
      done
  '';
in
{
  environment.systemPackages = with pkgs; [ gqview rclone ];

  imports = [ ../../components/fcron.nix ];
  services.fcron.systab =
    ''
      cam_log_dir=/var/log/cam/move-cam-mp4s/

      # 12 minutes past every hour
      &runas(cam) 12 * * * * ${trim-to-size}/bin/trim-to-size /cam 1792 --exclude-pat 'camthttpd*' --log-file /tmp/trim-to-size.cam.log
      # every 6 hours at 10 past the hour; plus 3:10AM before the boot dance
      # 1:10 rather than 12:10 to avoid mirrorfs
      &runas(cam) 10 1,3,6,12,16,18 * * * ${pkgs.rsync}/bin/rsync -a /cam/* /Cam-Archive/ --exclude cam\*
      # 15 minutes past every hour
      &runas(cam) 15 * * * * ${move-cam-mp4s} $cam_log_dir && ${s6-rotate} $cam_log_dir

      # 6AM; After 5AM timer plug on / 5:30AM BIOS resume
      &runas(cam) 0  6          * * * ${trim-to-size}/bin/trim-to-size /Cam-Archive 1572864 --exclude-pat 'camthttpd*'
    '';

  users.groups.cam.gid = 2005;

  users.users.cam = {
    isSystemUser = true;
    name        = "cam";
    group       = "cam";
    extraGroups = [
      "disk" "systemd-journal"
    ];
    createHome  = true;
    uid         = 2005;
    home        = "/home/cam";
    shell       = "/run/current-system/sw/bin/bash";


    # this stuff appears in /etc/profiles/per-user/$USER
    packages = with pkgs; with pkgs.writers; [
      cam-watch
      (writeBashBin "home-init"
                           ''
                             #!{bash}/bin/bash

                             ${coreutils}/bin/ln --symbolic --no-dereference --force ${cam-bashrc}/share/bashrc $HOME/.bashrc
                             ${coreutils}/bin/ln --symbolic --no-dereference --force /cam $HOME/cam
                           '')
      ];
  };

  users.groups.cam.members = [ "martyn" ];

  systemd.services.cam-rclone = {
    wantedBy = [ "multi-user.target" ];
    description = "watch /cam, rclone to mega-nz whenever a file is written";
    serviceConfig = {
      Type = "simple";
      User = "cam";
      ExecStart = "${cam-watch}/bin/cam-watch";
    };
  };
}
