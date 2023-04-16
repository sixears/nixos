{ config, lib, pkgs, ... }:

{
  networking.extraHosts = ''
                            # networking
                            192.168.0.1    barry.sixears.co.uk        barry
                            192.168.0.50   disbeliever.sixears.co.uk  disbeliever
                            192.168.0.151  ground.sixears.co.uk       ground
                            192.168.0.112  dub.sixears.co.uk          dub

                            # servers
                            192.168.0.7    dog.sixears.co.uk          dog
                            192.168.0.24   night.sixears.co.uk        night
                            192.168.0.17   defector.sixears.co.uk     defector
                            192.168.0.23   apparatus.sixears.co.uk    apparatus

                            # laptops
                            192.168.0.5    red.sixears.co.uk          red
                            192.168.0.8    trance.sixears.co.uk       trance
                            192.168.0.28   dissolve.sixears.co.uk     dissolve
                            192.168.0.11   poison.sixears.co.uk       poison
                            192.168.0.14   curse.sixears.co.uk        curse
                            192.168.0.3    drifting.sixears.co.uk     drifting
                            192.168.0.28   dissolve.sixears.co.uk     dissolve
                            192.168.0.90   blues.sixears.co.uk        blues
                            192.168.0.4    grain.sixears.co.uk        grain

                            # phones
                            192.168.0.2    theory.sixears.co.uk       theory
                            192.168.0.72   backslider.sixears.co.uk   backslider
                            192.168.0.74   stalker.sixears.co.uk      stalker
                            192.168.0.55   conspiracy.sixears.co.uk   conspiracy
                            192.168.0.71   supreme.sixears.co.uk      supreme
                          '';
}
