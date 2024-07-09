{ pkgs }: ''
set -eu -o pipefail

dmidecode=${pkgs.dmidecode}/bin/dmidecode
sudo=/run/wrappers/bin/sudo
realpath=${pkgs.coreutils}/bin/realpath

[[ $UID -eq 0 ]] || exec $sudo "$($realpath "$0")" "$@"

strings=( $( $dmidecode --list-strings ) )
declare -A strings_a
for s in "''${strings[@]}"; do
  strings_a[$s]=1
done

args=()
fail=false
if [[ $# -eq 0 ]]; then
  args=( "''${strings[@]}" )
else
  for i in "$@"; do
    if [[ -z ''${strings_a[$i]:-} ]]; then
      echo "not a valid dmidecode string: '$i'" 1>&2
      fail=true
    else
      args+=( "$i" )
    fi
  done
fi

$fail && exit 10

for i in "''${args[@]}"; do
  [[ ''${#args[@]} -eq 1 ]] || printf '%-24s : ' "$i"
  $dmidecode -s "$i"
done

# that's all, folks! -----------------------------------------------------------

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# fill-column: 80
# End:
''
