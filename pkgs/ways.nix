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

input_config=~/.config/sway/config
output_config=$XDG_RUNTIME_DIR/sway.rc

${pkgs.coreutils}/bin/rm -f $output_config
if [[ -x $input_config ]]; then
  echo "executing $input_config > $output_config" >&2
  $input_config > $output_config
else
  ${pkgs.coreutils}/bin/cp -v $input_config $output_config
fi

exec ${pkgs.sway}/bin/sway --config $output_config
''

# Local Variables:
# mode: sh
# End:
