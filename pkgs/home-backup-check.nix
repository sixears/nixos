{ nixpkgs ? import <nixpkgs> {} }: nixpkgs.writers.writeBashBin "home-backup-check" ''
set -eu -o pipefail

cat <<EOF | while read who what when; do find /home-backup/$who/.touch-$what -mtime +$when -ls; done
abigail drifting 3
jj poison 3
heather blues 3
martyn blues 3
martyn defector 2
martyn dissolve 7
martyn dog 1
martyn drifting 3
martyn grain 7
martyn night 1
martyn poison 3
martyn trance 2
xander grain 7
EOF
# exit non-zero to cause an email
exit 1
''
