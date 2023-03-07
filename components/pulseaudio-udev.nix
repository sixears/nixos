# Fix up pulse refusing to detect analog output in onboard card; see
# https://unix.stackexchange.com/questions/348823/how-to-force-pulseaudio-ports-to-be-available
# https://www.kernel.org/doc/html/latest/sound/hd-audio/notes.html#hd-audio-reconfiguration

# chip name found in /sys/class/sound/hwC1D0/chip_name
# see also `pacmd list-cards`

{ ... }:

{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="sound", ATTRS{chip_name}=="ALC1220", ATTR{hints}="jack_detect=false"
    ACTION=="add", SUBSYSTEM=="sound", ATTRS{chip_name}=="ALC1220", ATTR{reconfig}="1"
  '';
}
