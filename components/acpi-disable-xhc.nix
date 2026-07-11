{...}:

# disable XHC (USB) service from acpi wakeup to prevent
# USB devices waking up a suspended kernel.

# to, e.g., prevent cargo (Lenovo X1 Carbon) waking immediately
# after lid close

{
  systemd.tmpfiles.settings =
    {
      "disable-spurious-wakeup" =
        {
          "/proc/acpi/wakeup" =
            { "w+" = { argument = "XHCI"; }; };
        };
    };
}

