{ pkgs }: pkgs.writers.writeBashBin "mythtv-convert" ''
set -eu -o pipefail

basename=${pkgs.coreutils}/bin/basename
ffmpeg=${pkgs.ffmpeg}/bin/ffmpeg

for i in *.mpg; do
  j="$($basename "$i" .mpg)".mkv
  [ -e "$j" ] || \
      "$ffmpeg" -i "$i" -map 0:0 -map 0:1 -c:v libx264 -c:a copy -map 0:3 \
                -c:s dvdsub "$j" \
              || break
done
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
