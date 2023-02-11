{ pkgs, bash-header }: pkgs.writers.writeBashBin "tinydns-oom-killer" ''
set -u -o pipefail
shopt -s nullglob
PATH=/dev/null

source ${bash-header}

# Restrict incoming env to reduce surprises; the following is the list of
# env vars that we allow through the door.
# We don't relly want SHLVL, PWD or _; but we get them anyway if we re-exec: so
# don't re-exec if we see them, though we'll drop them below for cleanliness

keep_env=( SHLVL PWD _ )
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

Cmd[strace]=${pkgs.strace}/bin/strace
Cmd[systemctl]=${pkgs.systemd}/bin/systemctl

while true; do
  # give tinydns a chance to start up
  gocmd 10 sleep 5s
  capture ss gocmd 16 systemctl show --property=MainPID tinydns
  capture pid gocmd 17 cut -d = -f 2 <<<"$ss"
  if [[ 0 -eq $pid ]]; then
    # no tinydns running; wait 1min
    gocmd 11 sleep 1m
  else
    gocmdnoexit strace -p $pid |& gocmd 13 grep --max-count=1 ENOMEM
    capture date gocmd 14 date --utc +'%FZ%T'
    echo -e "[$date] restart tinydns..."
    gocmd 15 systemctl restart tinydns
  fi
done

''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
