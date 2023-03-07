{ pkgs ? import <nixpkgs> {} }: pkgs.writers.writeBash "s6-rotate" ''
set -eu -o pipefail

# sadly, we need this to ensure that the prior job has released the lock
sleep 2

# force s6-log to rotate the files by starting one up, and then
# sending a sigALARM
if [[ -s "''${1%/}/current" ]]; then
  ${pkgs.s6}/bin/s6-log "$1" < <(${pkgs.coreutils}/bin/tail -f /dev/null) &
  # sadly, we need this to ensure that the above has started properly
  ${pkgs.coreutils}/bin/sleep 2
  ${pkgs.util-linux}/bin/kill -ALRM $!
  # sadly, we need this to ensure that the rotation has happened
  ${pkgs.coreutils}/bin/sleep 2
  ${pkgs.util-linux}/bin/kill -TERM $!
fi
''
