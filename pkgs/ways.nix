{ pkgs }: pkgs.writers.writeBash "ways" ''
set -eu -o pipefail

id="$(${pkgs.coreutils}/bin/id --user)"
: ''${XDG_RUNTIME_DIR:=/run/user/$id}
export XDG_RUNTIME_DIR

# NOT SO HAPPY WITH THIS.  DO WE REALLY NEED IT?  MAYBE FOR I3STATUS, BUT THAT
# SHOULD DO ITSELF
# ways_paths="$HOME/bin/ways-paths"
# [[ -x $ways_paths ]] && . <($ways_paths)

exec >& "$XDG_RUNTIME_DIR/sway.log"
TZ=UTC ${pkgs.coreutils}/bin/date +%Y-%m-%dZ%H:%M:%S
echo "PID: $$"
exec ${pkgs.sway}/bin/sway "$@"
''

# Local Variables:
# mode: sh
# End:
