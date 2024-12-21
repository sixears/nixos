{ config, pkgs, ... }:

let
  user     = "martyn";
  home     = "/home/${user}";
  hostname = "${pkgs.inetutils}/bin/hostname";
  touch    = "${pkgs.coreutils}/bin/touch";
  uid      = 1000;
in
  {
    users.groups.martyn.gid = uid;

    users.users.${user} = {
      isNormalUser = true;
      name         = user;
      group        = user;
      uid          = uid;
      extraGroups  = [
        "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal"
        "users" "scanner" "ftp" "adbusers" "cdrom" "dialout" "input"
      ];
      createHome   = true;
      home         = home;
      shell        = "/run/current-system/sw/bin/bash";
      openssh.authorizedKeys.keyFiles = [ ./authorized_keys.${user} ];

      # needed for podman; see https://beb.ninja/post/installing-podman/
      # see https://stackoverflow.com/questions/58443334/why-does-podman-report-not-enough-ids-available-in-namespace-with-different-ui
      # if you see 'there might not be enough IDs available in the namespace',
      # try running `podman system migrate`
      subUidRanges = [ { startUid = 100001; count = 65534; } ];
      subGidRanges = [ { startGid = 100001; count = 65534; } ];
      # this stuff appears in /etc/profiles/per-user/$USER
      packages = [
        (let
           rsync       = "${pkgs.rsync}/bin/rsync";
           passwd-file = "/home/martyn/.rsync.secret";
         in
           pkgs.writers.writeBashBin "rsync-deluge" ''
             builtin exec ${rsync} --archive                       \
                                   --password-file ${passwd-file}  \
                                   --port 7798                     \
                                   deluge::deluge/complete/        \
                                   /Deluge/complete/ "$@"
           '')
      ];
    };

    services.fcron.systab =
      "@runas(${user}) 60s ${touch} ${home}/.touch-$(${hostname} -s)";

    system.userActivationScripts =
      {
        fluffyTest = {
          text = ''
               f=/tmp/fluffy-test
               p=$( ${pkgs.coreutils}/bin/basename $0 )
               d=$( ${pkgs.coreutils}/bin/dirname $f )
               t=$( ${pkgs.coreutils}/bin/mktemp -p $d $p.XXXXXX.tmp )
               trap '${pkgs.coreutils}/bin/rm -f $t' EXIT

               ${pkgs.coreutils}/bin/cat > $t <<-END
		#!${pkgs.bashInteractive}/bin/bash

		set -eu -o pipefail

		pactl=${pkgs.pulseaudio}/bin/pactl
		jq=${pkgs.jq}/bin/jq
		sleep=${pkgs.coreutils}/bin/sleep

		selector='.[] | select(.properties."application.name"=="Firefox")|.index'
		while true; do
		  for i in \$( \$pactl --format=json list sink-inputs | \$jq "\$selector"  ); do
		    \$pactl set-sink-input-volume "\$i" 100% || true
		    \$sleep 2s
		  done
		done
END
               ${pkgs.coreutils}/bin/mv --force $t $f
               ${pkgs.coreutils}/bin/chmod 0555 $f
               ${pkgs.coreutils}/bin/chown racereplay $f
          '';
        };
      };
  }
