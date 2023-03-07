set -eu -o pipefail

cp=$coreutils/bin/cp
dirname=$coreutils/bin/dirname
find=$findutils/bin/find
mkdir=$coreutils/bin/mkdir
mktinydnsdata=$htinydns/bin/mktinydnsdata

$mkdir -p "$out"/share
data="$out"/share/tinydns.data

export LANG=en_GB.UTF-8
export LOCALE_ARCHIVE=$glibcLocales/lib/locale/locale-archive
echo "MKTINYDNS: $mktinydnsdata $src/sixears-hosts.dhall"
$mktinydnsdata "$src/sixears-hosts.dhall" >> $data
