{ hostname, domainname }:
{ ... }:
{
  networking = {
    hostName = hostname;
    extraHosts =
      "127.0.0.1 " + hostname + "." + domainname + " " + hostname;

    enableIPv6 = false;
    nameservers = [
      "103.247.36.36" # dns1.dnsfilter.com
      "103.247.37.37" # dns2.dnsfilter.com
    ];
    search = [ domainname ];
    domain = domainname;
  };

}
