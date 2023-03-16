set -eu -o pipefail

$coreutils/bin/mkdir --parents $out/etc
$gnugrep/bin/grep -E '^(root|nobody):' /etc/passwd > $out/etc/passwd
$gzip/bin/gzip -cd $image | $gnutar/bin/tar xf - --to-stdout $layer | \
  $gnutar/bin/tar xf - -C $out --delay-directory-restore
