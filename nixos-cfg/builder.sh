cp=$coreutils/bin/cp
dirname=$coreutils/bin/dirname
find=$findutils/bin/find
mkdir=$coreutils/bin/mkdir

for i in $($find $src/ -type f \( -name \*.nix -o -name \*.data \) -printf '%P\n'); do
  $mkdir -p "$out"/share/"$($dirname "$i")"
  $cp -a "$src/$i" "$out"/share/"$i"
done
