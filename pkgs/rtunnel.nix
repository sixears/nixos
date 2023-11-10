{ pkgs }: pkgs.writers.writeBashBin "rtunnel" ''
# establish an ssh reverse tunnel

set -eu -o pipefail

target_host="''${1:-sixears}"
target_port="''${2:-9876}"
tunnel_port="''${3:-61234}"

ssh "$target_host" -p "$target_port" -NR "$tunnel_port":localhost:22 -v
''

# Local Variables:
# mode: sh
# End:
