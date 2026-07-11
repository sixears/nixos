set -eu -o pipefail

$coreutils/bin/mkdir -p $out/{bin,share}/
$coreutils/bin/cp -v $src/*.conf $out/share
$coreutils/bin/touch $out/bin/foo
