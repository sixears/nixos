{ pkgs, system }:

let
  confs = import ./openvpn { inherit pkgs system; };
in
  {
    services.openvpn.servers = {
      albania = {
        autoStart = false;
        config    = "config ${confs}/share/albania.conf";
      };
      algeria = {
        autoStart = false;
        config    = "config ${confs}/share/algeria.conf";
      };
      andorra = {
        autoStart = false;
        config    = "config ${confs}/share/andorra.conf";
      };
      argentina = {
        autoStart = false;
        config    = "config ${confs}/share/argentina.conf";
      };
      armenia = {
        autoStart = false;
        config    = "config ${confs}/share/armenia.conf";
      };
      au_melbourne = {
        autoStart = false;
        config    = "config ${confs}/share/au_melbourne.conf";
      };
      au_perth = {
        autoStart = false;
        config    = "config ${confs}/share/au_perth.conf";
      };
      austria = {
        autoStart = false;
        config    = "config ${confs}/share/austria.conf";
      };
      au_sydney = {
        autoStart = false;
        config    = "config ${confs}/share/au_sydney.conf";
      };
      bahamas = {
        autoStart = false;
        config    = "config ${confs}/share/bahamas.conf";
      };
      bangladesh = {
        autoStart = false;
        config    = "config ${confs}/share/bangladesh.conf";
      };
      belgium = {
        autoStart = false;
        config    = "config ${confs}/share/belgium.conf";
      };
      brazil = {
        autoStart = false;
        config    = "config ${confs}/share/brazil.conf";
      };
      bulgaria = {
        autoStart = false;
        config    = "config ${confs}/share/bulgaria.conf";
      };
      cambodia = {
        autoStart = false;
        config    = "config ${confs}/share/cambodia.conf";
      };
      ca_montreal = {
        autoStart = false;
        config    = "config ${confs}/share/ca_montreal.conf";
      };
      ca_ontario = {
        autoStart = false;
        config    = "config ${confs}/share/ca_ontario.conf";
      };
      ca_toronto = {
        autoStart = false;
        config    = "config ${confs}/share/ca_toronto.conf";
      };
      ca_vancouver = {
        autoStart = false;
        config    = "config ${confs}/share/ca_vancouver.conf";
      };
      china = {
        autoStart = false;
        config    = "config ${confs}/share/china.conf";
      };
      cyprus = {
        autoStart = false;
        config    = "config ${confs}/share/cyprus.conf";
      };
      czech_republic = {
        autoStart = false;
        config    = "config ${confs}/share/czech_republic.conf";
      };
      de_berlin = {
        autoStart = false;
        config    = "config ${confs}/share/de_berlin.conf";
      };
      de_frankfurt = {
        autoStart = false;
        config    = "config ${confs}/share/de_frankfurt.conf";
      };
      denmark = {
        autoStart = false;
        config    = "config ${confs}/share/denmark.conf";
      };
      egypt = {
        autoStart = false;
        config    = "config ${confs}/share/egypt.conf";
      };
      estonia = {
        autoStart = false;
        config    = "config ${confs}/share/estonia.conf";
      };
      finland = {
        autoStart = false;
        config    = "config ${confs}/share/finland.conf";
      };
      france = {
        autoStart = false;
        config    = "config ${confs}/share/france.conf";
      };
      georgia = {
        autoStart = false;
        config    = "config ${confs}/share/georgia.conf";
      };
      greece = {
        autoStart = false;
        config    = "config ${confs}/share/greece.conf";
      };
      greenland = {
        autoStart = false;
        config    = "config ${confs}/share/greenland.conf";
      };
      hong_kong = {
        autoStart = false;
        config    = "config ${confs}/share/hong_kong.conf";
      };
      hungary = {
        autoStart = false;
        config    = "config ${confs}/share/hungary.conf";
      };
      iceland = {
        autoStart = false;
        config    = "config ${confs}/share/iceland.conf";
      };
      india = {
        autoStart = false;
        config    = "config ${confs}/share/india.conf";
      };
      ireland = {
        autoStart = false;
        config    = "config ${confs}/share/ireland.conf";
      };
      isle_of_man = {
        autoStart = false;
        config    = "config ${confs}/share/isle_of_man.conf";
      };
      israel = {
        autoStart = false;
        config    = "config ${confs}/share/israel.conf";
      };
      italy = {
        autoStart = false;
        config    = "config ${confs}/share/italy.conf";
      };
      japan = {
        autoStart = false;
        config    = "config ${confs}/share/japan.conf";
      };
      kazakhstan = {
        autoStart = false;
        config    = "config ${confs}/share/kazakhstan.conf";
      };
      latvia = {
        autoStart = false;
        config    = "config ${confs}/share/latvia.conf";
      };
      liechtenstein = {
        autoStart = false;
        config    = "config ${confs}/share/liechtenstein.conf";
      };
      lithuania = {
        autoStart = false;
        config    = "config ${confs}/share/lithuania.conf";
      };
      luxembourg = {
        autoStart = false;
        config    = "config ${confs}/share/luxembourg.conf";
      };
      macao = {
        autoStart = false;
        config    = "config ${confs}/share/macao.conf";
      };
      macedonia = {
        autoStart = false;
        config    = "config ${confs}/share/macedonia.conf";
      };
      malta = {
        autoStart = false;
        config    = "config ${confs}/share/malta.conf";
      };
      mexico = {
        autoStart = false;
        config    = "config ${confs}/share/mexico.conf";
      };
      moldova = {
        autoStart = false;
        config    = "config ${confs}/share/moldova.conf";
      };
      monaco = {
        autoStart = false;
        config    = "config ${confs}/share/monaco.conf";
      };
      mongolia = {
        autoStart = false;
        config    = "config ${confs}/share/mongolia.conf";
      };
      montenegro = {
        autoStart = false;
        config    = "config ${confs}/share/montenegro.conf";
      };
      morocco = {
        autoStart = false;
        config    = "config ${confs}/share/morocco.conf";
      };
      netherlands = {
        autoStart = false;
        config    = "config ${confs}/share/netherlands.conf";
      };
      new_zealand = {
        autoStart = false;
        config    = "config ${confs}/share/new_zealand.conf";
      };
      nigeria = {
        autoStart = false;
        config    = "config ${confs}/share/nigeria.conf";
      };
      norway = {
        autoStart = false;
        config    = "config ${confs}/share/norway.conf";
      };
      panama = {
        autoStart = false;
        config    = "config ${confs}/share/panama.conf";
      };
      philippines = {
        autoStart = false;
        config    = "config ${confs}/share/philippines.conf";
      };
      poland = {
        autoStart = false;
        config    = "config ${confs}/share/poland.conf";
      };
      portugal = {
        autoStart = false;
        config    = "config ${confs}/share/portugal.conf";
      };
      qatar = {
        autoStart = false;
        config    = "config ${confs}/share/qatar.conf";
      };
      romania = {
        autoStart = false;
        config    = "config ${confs}/share/romania.conf";
      };
      saudi_arabia = {
        autoStart = false;
        config    = "config ${confs}/share/saudi_arabia.conf";
      };
      serbia = {
        autoStart = false;
        config    = "config ${confs}/share/serbia.conf";
      };
      singapore = {
        autoStart = false;
        config    = "config ${confs}/share/singapore.conf";
      };
      slovakia = {
        autoStart = false;
        config    = "config ${confs}/share/slovakia.conf";
      };
      south_africa = {
        autoStart = false;
        config    = "config ${confs}/share/south_africa.conf";
      };
      spain = {
        autoStart = false;
        config    = "config ${confs}/share/spain.conf";
      };
      sri_lanka = {
        autoStart = false;
        config    = "config ${confs}/share/sri_lanka.conf";
      };
      sweden = {
        autoStart = false;
        config    = "config ${confs}/share/sweden.conf";
      };
      switzerland = {
        autoStart = false;
        config    = "config ${confs}/share/switzerland.conf";
      };
      taiwan = {
        autoStart = false;
        config    = "config ${confs}/share/taiwan.conf";
      };
      turkey = {
        autoStart = false;
        config    = "config ${confs}/share/turkey.conf";
      };
      uk_london = {
        autoStart = false;
        config    = "config ${confs}/share/uk_london.conf";
      };
      uk_manchester = {
        autoStart = false;
        config    = "config ${confs}/share/uk_manchester.conf";
      };
      ukraine = {
        autoStart = false;
        config    = "config ${confs}/share/ukraine.conf";
      };
      uk_southampton = {
        autoStart = false;
        config    = "config ${confs}/share/uk_southampton.conf";
      };
      united_arab_emirates = {
        autoStart = false;
        config    = "config ${confs}/share/united_arab_emirates.conf";
      };
      us_atlanta = {
        autoStart = false;
        config    = "config ${confs}/share/us_atlanta.conf";
      };
      us_california = {
        autoStart = false;
        config    = "config ${confs}/share/us_california.conf";
      };
      us_chicago = {
        autoStart = false;
        config    = "config ${confs}/share/us_chicago.conf";
      };
      us_denver = {
        autoStart = false;
        config    = "config ${confs}/share/us_denver.conf";
      };
      us_east = {
        autoStart = false;
        config    = "config ${confs}/share/us_east.conf";
      };
      us_florida = {
        autoStart = false;
        config    = "config ${confs}/share/us_florida.conf";
      };
      us_houston = {
        autoStart = false;
        config    = "config ${confs}/share/us_houston.conf";
      };
      us_las_vegas = {
        autoStart = false;
        config    = "config ${confs}/share/us_las_vegas.conf";
      };
      us_new_york = {
        autoStart = false;
        config    = "config ${confs}/share/us_new_york.conf";
      };
      us_seattle = {
        autoStart = false;
        config    = "config ${confs}/share/us_seattle.conf";
      };
      us_silicon_valley = {
        autoStart = false;
        config    = "config ${confs}/share/us_silicon_valley.conf";
      };
      us_texas = {
        autoStart = false;
        config    = "config ${confs}/share/us_texas.conf";
      };
      us_washington_dc = {
        autoStart = false;
        config    = "config ${confs}/share/us_washington_dc.conf";
      };
      us_west = {
        autoStart = false;
        config    = "config ${confs}/share/us_west.conf";
      };
      venezuela = {
        autoStart = false;
        config    = "config ${confs}/share/venezuela.conf";
      };
      vietnam = {
        autoStart = false;
        config    = "config ${confs}/share/vietnam.conf";
      };
    };
  }
