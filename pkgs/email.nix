{ pkgs, bash-header }: pkgs.writers.writeBashBin "email" ''
set -u -o pipefail
shopt -s nullglob
PATH=/dev/null

source ${bash-header}

# Restrict incoming env to reduce surprises; the following is the list of
# env vars that we allow through the door.
# We don't relly want SHLVL, PWD or _; but we get them anyway if we re-exec: so
# don't re-exec if we see them, though we'll drop them below for cleanliness

keep_env=( DISPLAY SHLVL PWD _ )
keep_env_re="^($(IFS='|';echo "''${keep_env[*]}")=)"
if ''${Cmd[env]} | ''${Cmd[grep]} -qEv "$keep_env_re"; then
  # Polluting environment detected!  Re-exec with a limited set
  env_set=($(for i in "''${keep_env[@]}"; do
               declare -n x="$i"
               echo "$i=''${x:-}"
             done ))
  exec ''${Cmd[env]} -i "''${env_set[@]}" ''${Cmd[bash]} "$0" "$@"
fi

unset SHLVL PWD _

app="''${1:-rainloop}"

${pkgs.librewolf}/bin/librewolf 'https://mail.mxlogin.com/#!/sixears.org/apps/$app/'
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
