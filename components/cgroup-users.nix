{...}:

# https://grok.com/c/85cc4fe6-2585-4944-b054-6387c312bd2a

# By default, /sys/fs/cgroup is owned by root with restricted permissions,
# preventing regular users from creating cgroups. You need to adjust permissions
# to allow a user (or a group) to manage cgroups. Since NixOS manages the
# filesystem declaratively, you can use a systemd-tmpfiles rule or a custom
# activation script to set permissions.  Add the following to configuration.nix
# to create a group (e.g., cgroup-users) and set permissions on the cgroup
# filesystem:

# Explanation:

# users.groups.cgroup-users         : Creates a group for users who can manage
#                                     cgroups.
# users.users.<username>.extraGroups: Adds the user (replace <username> with the
#                                     actual username, e.g., alice) to the
#                                     cgroup-users group.
# systemd.tmpfiles.rules            : Creates a directory
#                                     /sys/fs/cgroup/memory/user-cgroups owned
#                                     by root but writable by the cgroup-users
#                                     group. This directory will host
#                                     user-created cgroups.
#                                     Z ensures recursive permissions for
#                                     subdirectories/files.

{
  # Install cgroup-tools for manual cgroup management
  environment.systemPackages = [ pkgs.cgroup-tools ];

  # Create a group for users allowed to manage cgroups
  users.groups.cgroup-users = {};

  # Assign specific users to the cgroup-users group
  users.users.<username> = {
    extraGroups = [ "cgroup-users" ];
  };

  # Use systemd-tmpfiles to set permissions on the unified cgroup v2 hierarchy
  systemd.tmpfiles.rules = [
    # Create a user-owned directory under /sys/fs/cgroup for user cgroups
    "d /sys/fs/cgroup/user-cgroups 0755 root cgroup-users - -"
    # Ensure the directory and its subdirectories/files are writable by the group
    "Z /sys/fs/cgroup/user-cgroups 0755 root cgroup-users - -"
  ];
}
