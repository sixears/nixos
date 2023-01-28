{ pkgs }: pkgs.writers.writeBashBin "xkb" ''

basename=${pkgs.coreutils}/bin/basename
dconf=${pkgs.dconf}/bin/dconf
ibus=${pkgs.ibus}/bin/ibus
id=${pkgs.coreutils}/bin/id
setxkbmap=${pkgs.xorg.setxkbmap}/bin/setxkbmap
tty=${pkgs.coreutils}/bin/tty
xmodmap=${pkgs.xorg.xmodmap}/bin/xmodmap

script="$($basename "$0")"
$tty -s && echo "running $script..." 1>&2
# proposed solution to random keyboard resets taken from
# https://bugs.launchpad.net/ubuntu/+source/gnome-shell/+bug/1276467
# $dconf write /desktop.ibus.general.use-system-keyboard-layout true

# solution to keyboard remapping nonsense, I think
# https://bugs.launchpad.net/ubuntu/+source/ibus/+bug/1278569
$ibus list-engine 2>/dev/null && $ibus exit
# $ibus exit

if [ "x$($id --user --name)" == "xmartyn" ]; then
  $setxkbmap -rules evdev -model pc105 -layout us -variant dvorak-alt-intl
fi
$xmodmap $HOME/rc/xmodmap/xmodmap
''

# Local Variables:
# mode: sh
# End:
