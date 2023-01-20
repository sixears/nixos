{ wifiMac }:
{ ... }:
{
  networking.networkmanager = { enable = true;
                                # note that this won't effect until wifi is
                                # actually connected
                                wifi.macAddress = wifiMac; };
}
