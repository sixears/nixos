{ config, lib, pkgs, ... }:

{
  programs.ssh.knownHosts = {
    barry = {
      hostNames     = [ "barry" "barry.sixears.co.uk" "192.168.0.1" ];
      publicKeyFile = ../sshkeys/barry.pub;
    };
    blues = {
      hostNames     = [ "blues" "blues.sixears.co.uk" "192.168.0.90" ];
      publicKeyFile = ../sshkeys/blues.pub;
    };
    drifting = {
      hostNames     = [ "drifting" "drifting.sixears.co.uk" "192.168.0.3" ];
      publicKeyFile = ../sshkeys/drifting.pub;
    };
    red = {
      hostNames     = [ "red" "red.sixears.co.uk" "192.168.0.5" ];
      publicKeyFile = ../sshkeys/red.pub;
    };
    dog = {
      hostNames     = [ "dog"  "dog.sixears.co.uk" "192.168.0.7"
                        "[sixears.co.uk]:9876" "[82.69.54.62]:9876" ];
      publicKeyFile = ../sshkeys/dog.pub;
    };
    trance = {
      hostNames     = [ "trance" "trance.sixears.co.uk" "192.168.0.8" ];
      publicKeyFile = ../sshkeys/trance.pub;
    };
   poison = {
      hostNames     = [ "poison" "poison.sixears.co.uk" "192.168.0.11" ];
      publicKeyFile = ../sshkeys/poison.pub;
    };
    slider = {
      hostNames     = [ "slider" "slider.sixears.co.uk" "192.168.0.13" ];
      publicKeyFile = ../sshkeys/slider.pub;
    };
    curse = {
      hostNames     = [ "curse" "curse.sixears.co.uk" "192.168.0.14" ];
      publicKeyFile = ../sshkeys/curse.pub;
    };
    defector = {
      hostNames     = [ "defector" "defector.sixears.co.uk" "192.168.0.17"
                        "deluge" "deluge.sixears.co.uk" ];
      publicKeyFile = ../sshkeys/defector.pub;
    };
    stone = {
      hostNames     = [ "stone" "stone.sixears.co.uk" "192.168.0.19" ];
      publicKeyFile = ../sshkeys/stone.pub;
    };
    bullet = {
      hostNames     = [ "bullet" "bullet.sixears.co.uk" "192.168.0.21" ];
      publicKeyFile = ../sshkeys/bullet.pub;
    };
    york = {
      hostNames     = [ "york" "york.sixears.co.uk" "192.168.0.22" ];
      publicKeyFile = ../sshkeys/york.pub;
    };
    slick = {
      hostNames     = [ "slick" "slick.sixears.co.uk" "192.168.0.2" ];
      publicKeyFile = ../sshkeys/slick.pub;
    };
    apparatus = {
      hostNames     = [ "apparatus" "apparatus.sixears.co.uk" "192.168.0.23" ];
      publicKeyFile = ../sshkeys/apparatus.pub;
    };
    night = {
      hostNames     = [ "night" "night.sixears.co.uk" "192.168.0.24"
                        "[sixears.co.uk]:9875" "[82.69.54.62]:9875"
                        "dvr" "dvr.sixears.co.uk"
                      ];
      publicKeyFile = ../sshkeys/night.pub;
    };
    adamson = {
      hostNames     = [ "adamson" "adamson.sixears.co.uk" "192.168.0.25" ];
      publicKeyFile = ../sshkeys/adamson.pub;
    };
    bukka = {
      hostNames     = [ "bukka" "bukka.sixears.co.uk" "192.168.0.26" ];
      publicKeyFile = ../sshkeys/bukka.pub;
    };
    barracuda = {
      hostNames     = [ "barracuda" "barracuda.sixears.co.uk" "192.168.0.27" ];
      publicKeyFile = ../sshkeys/barracuda.pub;
    };
    dissolve = {
      hostNames     = [ "dissolve" "dissolve.sixears.co.uk" "192.168.0.28" ];
      publicKeyFile = ../sshkeys/dissolve.pub;
    };
   panasonic = {
      hostNames     = [ "panasonic" "panasonic.sixears.co.uk" "192.168.0.30"
                        "[panasonic]:2222" "[192.168.0.30]:2222" ];
      publicKeyFile = ../sshkeys/panasonic.pub;
    };
    supreme = {
      hostNames     = [ "supreme" "supreme.sixears.co.uk" "192.168.0.71" ];
      publicKeyFile = ../sshkeys/supreme.pub;
    };
    shunt = {
      hostNames     = [ "shunt" "shunt.sixears.co.uk" "192.168.0.81" ];
      publicKeyFile = ../sshkeys/shunt.pub;
    };
    killing = {
      hostNames     = [ "killing" "killing.sixears.co.uk" "192.168.0.98" ];
      publicKeyFile = ../sshkeys/killing.pub;
    };
    ground = {
      hostNames     = [ "ground" "ground.sixears.co.uk" "192.168.0.109" ];
      publicKeyFile = ../sshkeys/ground.pub;
    };
    grain = {
      hostNames     = [ "grain" "grain.sixears.co.uk" "192.168.0.4" ];
      publicKeyFile = ../sshkeys/grain.pub;
    };
    freeze = {
      hostNames     = [ "freeze" "freeze.sixears.co.uk" "192.168.0.201" ];
      publicKeyFile = ../sshkeys/freeze.pub;
    };

    bitbucket = {
      hostNames     = [ "bitbucket.org"
                        "18.205.93.0" "18.205.93.1" "18.205.93.2" ];
      publicKeyFile = ../sshkeys/bitbucket.org.pub;
    };
    github = {
      hostNames     = [ "github.com" "*.github.com" ];
      publicKeyFile = ../sshkeys/github.com.pub;
    };

    titus = {
      hostNames     = [ "titus" "24.0.234.200" "mbligh.org" ];
      publicKeyFile = ../sshkeys/mbligh.org.pub;
    };
  };

}
