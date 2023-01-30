{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    9090 # prometheus
    9100 # node
  ];

  # currently only local - we haven't exposed the port for this
  # https://prometheus.io/docs/guides/node-exporter
  # see here for example config, including alertmanager and grafana
  # https://gist.github.com/globin/02496fd10a96a36f092a8e7ea0e6c7dd
  services.prometheus = {
    enable = true;
    exporters.node = {
      enable = true;
      enabledCollectors = [ "conntrack" "diskstats" "entropy" "filefd"
                            "filesystem" "interrupts" "ksmd" "loadavg" "logind"
                            "mdadm" "meminfo" "netdev" "netstat" "stat"
                            "systemd" "time" "vmstat"
                          ];
    };

    scrapeConfigs =
      [ { job_name        = "node";
          scrape_interval = "10s";
          static_configs  = [ { targets = [ "localhost:9100" ]; } ];
#          labels          = { alias = "localhost"; }; 
        }
        
        { job_name        = "prometheus";
          scrape_interval = "5s";
          static_configs  = [ { targets = [ "localhost:9090" ]; } ];
        }
      ];
  };
}
