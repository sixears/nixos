{ pkgs, xkb, xmonad-with-pkgs }: pkgs.writers.writeBashBin "xsession" ''

cat=${pkgs.coreutils}/bin/cat
hostname=${pkgs.nettools}/bin/hostname
mv=${pkgs.coreutils}/bin/mv
xrandr=${pkgs.xorg.xrandr}/bin/xrandr
xset=${pkgs.xorg.xset}/bin/xset
xkb=${xkb}/bin/xkb
xrdb=${pkgs.xorg.xrdb}/bin/xrdb
xmonad=${xmonad-with-pkgs}/bin/xmonad
xscreensaver=${pkgs.xscreensaver}/bin/xscreensaver
xmodmap=${pkgs.xorg.xmodmap}/bin/xmodmap

# ------------------------------------------------------------------------------

xse=$HOME/.xsession-errors
xseo=$xse.old

echo "executing $0..."

[[ -e $xse ]] && $mv -f $xse ~/.xseo
exec &> $HOME/.xsession-errors

if [ "x$USER" == "xheather" ]; then
  export TZ=Europe/London
else
  export TZ=GMT+0
fi

# trayer --edge top --align right --SetDocType true --SetPartialStrut true --expand true --width 10 \
#        --transparent true --tint 0x191970 --height 12

if [ "$($hostname)" == "dog" ]; then
  # make HDMI-0 the primary, and DVI-D-0 the secondary (shown to the right of the primary)
  $xrandr --output HDMI-0 --primary --output DVI-D-0 --right-of HDMI-0 # --mode 1920x1200 --verbose
fi

$xset s blank # turn on the screensaver, choose blank (if supported) rather than pattern
$xset s 300   # blank after 5 mins
$xset dpms 360 420 600 # Energy Star params: standby (6mins), suspend (7mins), off (10mins)

for i in /etc/Xresources/* $HOME/.Xresources $HOME/rc/*/xresources; do
  if [ -f "$i" ]; then
    echo "xrdb merge: $i"
    $xrdb -merge "$i"
  fi
done

$xkb
xmm=$HOME/rc/xmodmap/xmodmap.$($hostname -s)
if [[ -e $xmm ]]; then
  echo "running $xmodmap $xmm..." 1>&2
  $xmodmap $xmm
  echo "have run $xmodmap $xmm..." 1>&2
else
  echo "no $xmm found" 1>&2
fi
$xscreensaver &
# i3status in nixos-18.09 barfs on non-C locales
export LANG=en_GB.UTF-8 # LANG=C
exec $xmonad
''

# Local Variables:
# mode: sh
# End:
