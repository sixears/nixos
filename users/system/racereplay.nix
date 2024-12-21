{ config, pkgs, ... }:

{
  users.groups.racereplay.gid = 2002;

  users.users.racereplay = {
    name        = "racereplay";
    group       = "racereplay";
    extraGroups = [
      "disk" "audio" "video" "systemd-journal"
    ];
    createHome  = false;
    uid         = 2002;
    home        = "/home/racereplay";
    shell       = "/run/current-system/sw/bin/bash";
    isSystemUser = true;
  };

  users.groups.racereplay.members = [ "martyn" ];


  system.userActivationScripts =
    {
      firefox-set-volume = {
        text = ''
               f=/home/racereplay/bin/firefox-set-volume
               p=$( ${pkgs.coreutils}/bin/basename $0 )
               d=$( ${pkgs.coreutils}/bin/dirname $f )
               [[ -d $d ]] || ${pkgs.coreutils}/bin/mkdir $d
               ${pkgs.coreutils}/bin/chown racereplay $d
               t=$( ${pkgs.coreutils}/bin/mktemp -p $d $p.XXXXXX.tmp )
               trap '${pkgs.coreutils}/bin/rm -f $t' EXIT

               ${pkgs.coreutils}/bin/cat > $t <<-END
		#!${pkgs.bashInteractive}/bin/bash

		# !! INSTALLED BY NIXOS USER-ACTIVATION SCRIPTS !!

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

      xsession = {
        text = ''
               f=/home/racereplay/.xsession
               p=$( ${pkgs.coreutils}/bin/basename $0 )
               d=$( ${pkgs.coreutils}/bin/dirname $f )
               ${pkgs.coreutils}/bin/chown racereplay $d
               t=$( ${pkgs.coreutils}/bin/mktemp -p $d $p.XXXXXX.tmp )
               trap '${pkgs.coreutils}/bin/rm -f $t' EXIT

               ${pkgs.coreutils}/bin/cat > $t <<-END
		#!${pkgs.bashInteractive}/bin/bash

		# !! INSTALLED BY NIXOS USER-ACTIVATION SCRIPTS !!

		#!/usr/bin/env bash

		${pkgs.haskellPackages.xmonad}/bin/xmonad &
		${pkgs.xterm}/bin/xterm &
		/home/racereplay/bin/firefox-set-volume &
		${pkgs.firefox}/bin/firefox --geometry 3840x2160 http://overtakefans.com/#
END
               ${pkgs.coreutils}/bin/mv --force $t $f
               ${pkgs.coreutils}/bin/chmod 0555 $f
               ${pkgs.coreutils}/bin/chown racereplay $f
        '';
      };
    };
}
