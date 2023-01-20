{ etherMac }:
{ ... }:
{
  networking.networkmanager = { enable = true;
                                # note that this won't effect until ethernet is
                                # actually connected
                                ethernet.macAddress = etherMac; };
}
