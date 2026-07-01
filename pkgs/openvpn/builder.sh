set -eu -o pipefail

source "$stdenv/setup"

# implicitly creates $out
$coreutils/bin/mkdir -p $out/bin/
substituteAll $src/podcast.pl $out/bin/podcast
substituteAll $src/podcast-server.bash $out/bin/podcast-server
substituteAll $src/redirect.pl $out/bin/redirect
$coreutils/bin/chmod 0555 $out/bin/{podcast{,-server},redirect}
# out created above when we made $out/bin
$coreutils/bin/cp -av $src/perllib $out
$coreutils/bin/mkdir -p -m 0755 $out/htdocs
$coreutils/bin/cp -v $src/share/*.yaml $out/htdocs
# $coreutils/bin/cp -vr $src/share/scripts/ $out/share/podcasts/scripts/
