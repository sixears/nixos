set -eu -o pipefail

$coreutils/bin/mkdir $out
$coreutils/bin/mkdir $out/bin
$coreutils/bin/ln --symbolic $apacheHttpd/bin/htpasswd $out/bin/htpswd
