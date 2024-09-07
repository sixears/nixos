{ domains = { sub_domain = "sixears.co.uk."
            , in_addr = "0.168.192.in-addr.arpa." }
, aliases = [ { from = "blackbox"      , to = "barry" }
            , { from = "dvr"           , to = "night" }
            , { from = "home-backup"   , to = "night" }
            , { from = "cam"           , to = "night" }
            , { from = "cam-front-x"   , to = "night" }
            , { from = "deluge"        , to = "defector" }
            , { from = "gitit"         , to = "night" }
            , { from = "podcasts"      , to = "night" }
            , { from = "podcast"       , to = "night" }
            , { from = "canine"        , to = "dog" }
            , { from = "nixos-bincache", to = "dog" }
            , { from = "nixpkgs"       , to = "dog" }
            , { from = "svn"           , to = "dog" }
            ]
, dns_servers = [ "night", "dog" ]
, mail_servers = [ ] : List Text

, hosts = [ -- Servers ---------------------------------------------------------

          , { fqdn = "dog.sixears.co.uk."
            , ipv4 = "192.168.0.7"
            , desc = "study desktop server 2019"
            , mac  = Some "04:92:26:da:00:ca"
            , comments = [] : List Text
            }

          , { fqdn = "night.sixears.co.uk."
            , ipv4 = "192.168.0.24"
            , desc = "2017 All-New PVR"
            , mac  = Some "60:45:cb:6f:68:86"
            , comments = [] : List Text
            }

          , { fqdn = "defector.sixears.co.uk."
            , ipv4 = "192.168.0.17"
            , desc = "VPN Box"
            , mac  = Some "fc:aa:14:87:cc:a2"
            , comments = [] : List Text
            }

          , { fqdn = "apparatus.sixears.co.uk."
            , ipv4 = "192.168.0.23"
            , desc = "VPN Box AWOW AK41"
            , mac  = Some "00:e0:4c:5d:fc:17"
            , comments = [] : List Text
            }

            -- Laptops ---------------------------------------------------------

          , { fqdn = "curse.sixears.co.uk."
            , ipv4 = "192.168.0.14"
            , desc = "HP Pavilion 15-ab105na JJ"
            , mac= Some "70:5a:0f:18:46:2a"
            , comments = [] : List Text
            }
          , { fqdn = "curse-wl.sixears.co.uk."
            , ipv4 = "192.168.0.14"
            , desc = "HP Pavilion 15-ab105na JJ"
            , mac= Some "48:e2:44:d5:2e:cf"
            , comments = [] : List Text
            }

          , { fqdn = "slider.sixears.co.uk."
            , ipv4 = "192.168.0.13"
            , desc = "Acer Aspire One 721-3574 11.6\""
            , mac= Some "20:6a:8a:24:87:26"
            , comments = [] : List Text
            }

          , { fqdn = "slider-wl.sixears.co.uk."
            , ipv4 = "192.168.0.13"
            , desc = "Acer Aspire One 721-3574 (wlan)"
            , mac= Some "18:f4:6a:a4:00:83"
            , comments = [] : List Text
            }

          , { fqdn = "edge.sixears.co.uk."
            , ipv4 = "192.168.0.16"
            , desc = "Lenovo X61s ThinkPad"
            , mac = Some "00:16:d3:c8:ae:33"
            , comments = [] : List Text
            }

          , { fqdn = "look.sixears.co.uk."
            , ipv4 = "192.168.0.95"
            , desc = "Lenovo X61s"
            , mac= Some "00:16:d3:c8:ae:33"
            , comments = [] : List Text
            }

          , { fqdn = "drifting.sixears.co.uk."
            , ipv4 = "192.168.0.3"
            , desc = "Dell Inspiron 7306 2n1 Ax"
            , mac= Some "9e:3f:86:01:96:a9"
            , comments = [] : List Text
            }

          , { fqdn = "dissolve.sixears.co.uk."
            , ipv4 = "192.168.0.28"
            , desc = "Lenovo Thinkpad Yoga 260"
            , mac= Some "fc:45:96:a9:a7:a6"
            , comments = [] : List Text
            }

          , { fqdn = "dissolve-wl.sixears.co.uk."
            , ipv4 = "192.168.0.28"
            , desc = "Lenovo Thinkpad Yoga 260"
            , mac= Some "14:ab:c5:08:1a:0b"
            , comments = [] : List Text
            }

          , { fqdn = "blues.sixears.co.uk."
            , ipv4 = "192.168.0.90"
            , desc = "Lenovo IdeaPad S540-13"
            , mac= Some "9c:eb:e8:5e:18:2e"
            , comments = [ "Hx, Ice Blue" ] : List Text
            }

          , { fqdn = "blues-wl.sixears.co.uk."
            , ipv4 = "192.168.0.90"
            , desc = "Lenovo IdeaPad S540-13 (WLAN)"
            , mac= Some "e4:aa:ea:cc:91:31"
            , comments = [ "Hx, Ice Blue" ] : List Text
            }

          , { fqdn = "trance.sixears.co.uk."
            , ipv4 = "192.168.0.8"
            , desc = "Lenovo Yoga S730 Laptop Ethernet"
            , mac= Some "00:e0:4c:68:04:ab"
            , comments = [] : List Text
            }
          , { fqdn = "trance-wl.sixears.co.uk."
            , ipv4 = "192.168.0.8"
            , desc = "Lenovo Yoga S730 Laptop Wireless"
            , mac= Some "b4:69:21:59:80:a3"
            , comments = [] : List Text
            }

          , { fqdn = "poison.sixears.co.uk."
            , ipv4 = "192.168.0.11"
            , desc = "Asus X555Y Ax"
            , mac= Some "9c:5c:8e:3c:52:37"
            , comments = [] : List Text
            }
          , { fqdn = "poison-wl.sixears.co.uk."
            , ipv4 = "192.168.0.11"
            , desc = "Asus X555Y WLAN Ax"
            , mac= Some "50:6f:69:73:6f:6e"
            , comments = [] : List Text
            }

          , { fqdn = "grain.sixears.co.uk."
            , ipv4 = "192.168.0.4"
            , desc = "Lenovo S340-14"
            , mac= Some "9c:eb:e8:5e:18:ed"
            , comments = [ "Xax, Platinum Grey" ] : List Text
            }

          , { fqdn = "grain-wl.sixears.co.uk."
            , ipv4 = "192.168.0.4"
            , desc = "Lenovo S340-14 (WLAN)"
            , mac= Some "e4:aa:ca:ca:c9:dd"
            , comments = [ "Xax, Platinum Grey" ] : List Text
            }

          , { fqdn = "hp-usb-dongle.sixears.co.uk."
            , ipv4 = "192.168.0.254"
            , desc = "Host using HP USB Dongle"
            , mac= Some "9c:eb:e8:5e:18:e2"
            , comments = [ ] : List Text
            }

          , { fqdn = "strange.sixears.co.uk."
            , ipv4 = "192.168.0.12"
            , desc = "Xax Asus Chromebook C223NA-JG0014"
            , mac= Some "14:F6:D8:53:99:0E"
            , comments = [ "Serial: L7NXCV23314731F" ] : List Text
            }

          , { fqdn = "red.sixears.co.uk."
            , ipv4 = "192.168.0.5"
            , desc = "Dell XPS 9315 Laptop Ethernet"
            , mac= Some "72:65:64:2e:73:69"
            , comments = [ "Service Tag: 155CKR3", "EX: 2488098063" ] : List Text
            }
          , { fqdn = "red-wl.sixears.co.uk."
            , ipv4 = "192.168.0.5"
            , desc = "Dell XPS 9315 Laptop Wireless"
            , mac= Some "30:89:4a:b5:4a:91"
            , comments = [] : List Text
            }

          , { fqdn = "cargo.sixears.co.uk."
            , ipv4 = "192.168.0.10"
            , desc = "Lenovo X1 Carbon Gen12 Ethernet"
            , mac= Some "c4:c6:e6:1c:cf:f7"
            , comments = [ "Serial Number: PF-51382V", "Type Number: 21KC-CTO1WW" ] : List Text
            }
          , { fqdn = "cargo-wl.sixears.co.uk."
            , ipv4 = "192.168.0.10"
            , desc = "Lenovo X1 Carbon Gen12 Wireless"
            , mac= Some "b0:47:e9:dc:95:42"
            , comments = [ "Serial Number: PF-51382V", "Type Number: 21KC-CTO1WW" ] : List Text
            }

            -- Phones ----------------------------------------------------------

          , { fqdn = "backslider.sixears.co.uk."
            , ipv4 = "192.168.0.72"
            , desc = "Motorola G7 Power (Xax)"
            , mac= Some "24:46:c8:94:d7:90"
            , comments = [] : List Text
            }

          , { fqdn = "stalker.sixears.co.uk."
            , ipv4 = "192.168.0.74"
            , desc = "Motorola G8 Plus (Hx)"
            , mac= Some "08:cc:27:48:93:33"
            , comments = [] : List Text
            }

          , { fqdn = "theory.sixears.co.uk."
            , ipv4 = "192.168.0.2"
            , desc = "OnePlus Nord CE 5G / 12GB / 256GB / Blue Void (Mx) / S/N 5011101713 / IMEI 866673053028251 / IMEI 866673053028244"
            , mac= Some "ac:5f:ea:e8:54:ab"
            , comments = [] : List Text
            }

          , { fqdn = "conspiracy.sixears.co.uk."
            , ipv4 = "192.168.0.55"
            , desc = "Motorola G7 Power (Ax)"
            , mac= Some "08:cc:27:bb:b0:18"
            , comments = [] : List Text
            }

          , { fqdn = "supreme.sixears.co.uk."
            , ipv4 = "192.168.0.71"
            , desc = "Wileyfox Swift (Mx Bike)"
            , mac= Some "fc:3d:93:3f:c2:f1"
            , comments = [] : List Text
            }

          , { fqdn = "church.sixears.co.uk."
            , ipv4 = "192.168.0.51"
            , desc = "OnePlus Nord 2T 5G / 12GB / 256GB / Grey Shadow (Ax) / S/N 8P6LMJHQIBPBR4BI / IMEI 860439060378378 / IMEI 860439060378360"
            , mac= Some "48:74:12:91:75:a1"
            , comments = [] : List Text
            }

          , { fqdn = "healed.sixears.co.uk."
            , ipv4 = "192.168.0.52"
            , desc = "OnePlus Nord 2 5G / 12GB / 256GB / Grey Sierra (Hx) / S/N YLMBE6DUYD8DWOC6 / IMEI 867192050336350 / IMEI 867192050336343"
            , mac= Some "d0:49:7c:38:9e:47"
            , comments = [] : List Text
            }

          , { fqdn = "noisy.sixears.co.uk."
            , ipv4 = "192.168.0.53"
            , desc = "OnePlus Nord CE 5G / 8GB / 128GB / Blue Void (JJ) / S/N fa111498 / IMEI 866673054132417 / IMEI 866673054132409"
            , mac= Some "ac:d6:18:d3:71:0d"
            , comments = [] : List Text
            }

            -- Pads ------------------------------------------------------------

{-
          , { fqdn = "killing.sixears.co.uk."
            , ipv4 = "192.168.0.98"
            , desc = "Nivia Shield Tablet Xax"
            , mac= Some "00:04:4b:61:e1:cc"
            , comments = [] : List Text
            }

          , { fqdn = "adamson.sixears.co.uk."
            , ipv4 = "192.168.0.25"
            , desc = "Samsung Galaxy Tab A T350 JJ"
            , mac= Some "e0:aa:96:ff:f6:6e"
            , comments = [] : List Text
            }
-}

          , { fqdn = "barracuda.sixears.co.uk."
            , ipv4 = "192.168.0.27"
            , desc = "Samsung Galaxy Tab A T350 Ax"
            , mac= Some "3c:f7:a4:47:f1:27"
            , comments = [] : List Text
            }


          , { fqdn = "shunt.sixears.co.uk."
            , ipv4 = "192.168.0.81"
            , desc = "Samsung Galaxy Note Tab Pro Mx"
            , mac= Some "20:d3:90:bb:d5:c8"
            , comments = [] : List Text
            }

          , { fqdn = "river.sixears.co.uk."
            , ipv4 = "192.168.0.9"
            , desc = "Samsung Galaxy Tab S8 JJ"
            , mac= Some "9c:2e:7a:5c:83:7a"
            , comments = [] : List Text
            }

            -- Kindles ---------------------------------------------------------

          , { fqdn = "gordon.sixears.co.uk."
            , ipv4 = "192.168.0.70"
            , desc = "Kindle (Ax)"
            , mac= Some "e0:cb:1d:68:5f:15"
            , comments = [] : List Text
            }

          , { fqdn = "james.sixears.co.uk."
            , ipv4 = "192.168.0.66"
            , desc = "Kindle Paperwhite (Mx)"
            , mac= Some "f0:4f:7c:64:64:70"
            , comments = [] : List Text
            }

          , { fqdn = "henry.sixears.co.uk."
            , ipv4 = "192.168.0.73"
            , desc = "Kindle Paperwhite (Hx)"
            , mac= Some "f0:4f:7c:a6:a4:79"
            , comments = [] : List Text
            }

            -- Gaming ----------------------------------------------------------

          , { fqdn = "freeze.sixears.co.uk."
            , ipv4 = "192.168.0.201"
            , desc = "Raspberry Pi 3B, Xax, RetroPie"
            , mac= Some "b8:27:eb:5c:d7:55"
            , comments = [ "Ethernet" ] : List Text
            }
          , { fqdn = "freeze-wl.sixears.co.uk."
            , ipv4 = "192.168.0.201"
            , desc = "Raspberry Pi 3B, Xax, RetroPie"
            , mac= Some "b8:27:eb:09:82:00"
            , comments = [ "WiFi" ] : List Text
            }

          , { fqdn = "deformity.sixears.co.uk."
            , ipv4 = "192.168.0.86"
            , desc = "Nintendo Switch"
            , mac= Some "60:6b:ff:24:7d:fc"
            , comments = [ "WiFi" ] : List Text
            }

          , { fqdn = "filthy.sixears.co.uk."
            , ipv4 = "192.168.0.6"
            , desc = "Xander's Windoze PC"
            , mac= Some "d8:bb:c1:54:1d:9d"
            , comments = [ "Ethernet" ] : List Text
            }

            -- Appliances ------------------------------------------------------

          , { fqdn = "years.sixears.co.uk."
            , ipv4 = "192.168.0.29"
            , desc = "Garmin Epix Gen 2 (Mx)"
            , mac  = Some "90:f1:57:e8:f5:45"
            , comments = [] : List Text
            }

          , { fqdn = "healer.sixears.co.uk."
            , ipv4 = "192.168.0.94"
            , desc = "RaspberryPi2 (Rune)"
            , mac= Some "b8:27:eb:a6:58:dd"
            , comments = [] : List Text
            }

          , { fqdn = "vertigen.sixears.co.uk."
            , ipv4 = "192.168.0.87"
            , desc = "HP Color Laserjet Pro MFP M281fdw (Ethernet)"
            , mac= Some "80:e8:2c:ae:c2:6a"
            , comments = [] : List Text
            }

          , { fqdn = "kitchen-tv.sixears.co.uk."
            , ipv4 = "192.168.0.85"
            , desc = "Samsung"
            , mac= Some "c4:57:6e:70:fa:a2"
            , comments = [] : List Text
            }

          , { fqdn = "remix.sixears.co.uk."
            , ipv4 = "192.168.0.119"
            , desc = "Roku Ultra 4660X (Kitchen)"
            , mac= Some "c8:3a:6b:e7:1e:e5"
            , comments = [ "Device ID: CK38D2382293" ]
            }

          , { fqdn = "remix-wl.sixears.co.uk."
            , mac= Some "c8:3a:6b:e7:1e:e4"
            , ipv4 = "192.168.0.119"
            , desc = "Roku Ultra 4660X (Kitchen)"
            , comments = [] : List Text
            }

          , { fqdn = "reduction.sixears.co.uk."
            , mac= Some "c8:3a:6b:e6:24:0f"
            , ipv4 = "192.168.0.120"
            , desc = "Roku Ultra 4660X (Living Room)"
            , comments = [ "Device ID: CK38D6651791"
                         , "Serial: YJ006R651791" ]
            }

          , { fqdn = "reduction-wl.sixears.co.uk."
            , mac= Some "c8:3a:6b:e6:24:0e"
            , ipv4 = "192.168.0.120"
            , desc = "Roku Ultra 4660X (Living Room)"
            , comments = [] : List Text
            }

          , { fqdn = "rj.sixears.co.uk."
            , mac= Some "d8:14:df:59:8c:15"
            , ipv4 = "192.168.0.121"
            , desc = "Roku TV (Day Room)"
            , comments = [] : List Text
            }

          , { fqdn = "veronica.sixears.co.uk."
            , ipv4 = "192.168.0.115"
            , desc = "iRobot Roomba 980"
            , mac= Some "40:9f:38:05:1f:6f"
            , comments = [] : List Text
            }

          , { fqdn = "conexoon.sixears.co.uk."
            , ipv4 = "192.168.0.109"
            , desc = "Somfy Conexoon RTS Window"
            , mac= Some "f8:81:1a:54:0a:a5"
            , comments = [ "Somfy F-74300 CLUSES" ] : List Text
            }

          , { fqdn = "easee1.sixears.co.uk."
            , ipv4 = "192.168.0.154"
            , desc = "Easee Home Charger UKVYN9PT"
            , mac = Some "9c:9c:1f:cd:0f:84"
            , comments = [] : List Text
            }

            -- Networking ------------------------------------------------------

          , { fqdn = "barry.sixears.co.uk."
            , ipv4 = "192.168.0.1"
            , desc = "Ubiquiti EdgeRouter X"
            , mac = Some "44:d9:e7:93:be:28"
            , comments = [] : List Text
            }

          , { fqdn = "ground.sixears.co.uk."
            , ipv4 = "192.168.0.151"
            , desc = "TP-Link Wireless N Nano Access Point TL-WA901N (Garage)"
            , mac = Some "b4:b0:25:c5:cb:80"
            , comments = [] : List Text
           }

          , { fqdn = "disbeliever.sixears.co.uk."
            , ipv4 = "192.168.0.50"
            , desc = "TP-Link AC1750 WAPRouter (Archer C7) v5.0"
            , mac= Some "ac:84:c6:8d:ff:32"
            , comments = [] : List Text
            }

          , { fqdn = "dub.sixears.co.uk."
            , ipv4 = "192.168.0.112"
            , desc = "Asus RT-AC56U WiFi/Eth Router (eth)"
            , mac= Some "ac:22:0b:1f:02:d0"
            , comments = [] : List Text
            }

          , { fqdn = "dub-wl.sixears.co.uk."
            , ipv4 = "192.168.0.112"
            , desc = "Asus RT-AC56U WiFi/Eth Router (wifi)"
            , mac= Some "ac:22:0b:1f:02:d4"
            , comments = [] : List Text
            }

          , { fqdn = "strings.sixears.co.uk."
            , ipv4 = "192.168.0.202"
            , desc = "TP-Link WR-801N 300Mbps Wireless N Router"
            , mac = Some "5c:e9:31:d1:a2:cc" -- LAN
            -- WAN, mac = Some "a4:2b:b0:f9:b3:b7"
            , comments = [] : List Text
           }

          , { fqdn = "to.sixears.co.uk."
            , ipv4 = "192.168.0.199"
            , desc = "Ubiquiti UAP-AC-M (kitchen) WAP Mesh"
            , mac = Some "d8:b3:70:b0:a9:3e" -- LAN
            , comments = [] : List Text
           }

          -- Security ----------------------------------------------------------

          , { fqdn = "control.sixears.co.uk."
            , ipv4 = "192.168.0.200"
            , desc = "Visonic PowerMaxComplete / PowerLink"
            , mac  = Some "00:12:6c:10:79:a5"
            , comments = [] : List Text
            }

          -- Cameras -----------------------------------------------------------

          , { fqdn = "edit.sixears.co.uk."
            , ipv4 = "192.168.0.84"
            , desc = "ReoLink RLN8-410 NVR"
            , mac  = Some "ec:71:db:87:d5:ec"
            , comments = [] : List Text
            }

          , { fqdn = "cam-front.sixears.co.uk."
            , ipv4 = "192.168.0.75"
            , desc = "Reolink RLC-410-5MP (PoE)"
            , mac= Some "ec:71:db:71:f5:72"
            , comments = [] : List Text
            }

          , { fqdn = "cam-hall-lower.sixears.co.uk."
            , ipv4 = "192.168.0.78"
            , desc = "Reolink RLC-520A cam lower hall"
            , mac= Some "ec:71:db:61:05:a0"
            , comments = [] : List Text
            }

          , { fqdn = "cam-hall-upper.sixears.co.uk."
            , ipv4 = "192.168.0.76"
            , desc = "Reolink RLC-520A cam upper hall"
            , mac= Some "ec:71:db:02:b0:ee"
            , comments = [] : List Text
            }

          , { fqdn = "cam-kitchen.sixears.co.uk."
            , ipv4 = "192.168.0.83"
            , desc = "Reolink RLC-520 (PoE)"
            , mac= Some "ec:71:db:e2:58:cb"
            , comments = [] : List Text
            }

          , { fqdn = "cam-lounge.sixears.co.uk."
            , ipv4 = "192.168.0.80"
            , desc = "wansview NCB541W cam lounge"
            , mac= Some "78:a5:dd:00:d0:46"
            , comments = [] : List Text
            }

          , { fqdn = "cam-study.sixears.co.uk."
            , ipv4 = "192.168.0.82"
            , desc = "wansview NCB541W cam study"
            , mac= Some "ec:71:db:92:f6:6f"
            , comments = [] : List Text
            }

          , { fqdn = "cam-rear.sixears.co.uk."
            , ipv4 = "192.168.0.77"
            , desc = "Reolink RLC-410-5MP (PoE)"
            , mac= Some "ec:71:db:92:f6:6f"
            , comments = [] : List Text
            }

          , { fqdn = "cam-garage.sixears.co.uk."
            , ipv4 = "192.168.0.79"
            , desc = "Reolink Duo 2 PoE"
            , mac= Some "ec:71:db:ce:07:fa"
            , comments = [] : List Text
            }

          -- Cars --------------------------------------------------------------

          , { fqdn = "yondu.sixears.co.uk."
            , ipv4 = "192.168.0.152"
            , desc = "Tesla Model 3 LG71YND"
            , mac = Some "4c:fc:aa:16:4c:45"
            , comments = [] : List Text
            }

          , { fqdn = "drax.sixears.co.uk."
            , ipv4 = "192.168.0.153"
            , desc = "Tesla Model X BL68FHN"
            , mac = Some "04:4e:af:c2:09:c3"
            , comments = [] : List Text
            }

          -- Guest -------------------------------------------------------------

          , { fqdn = "joshua-phone.sixears.co.uk."
            , ipv4 = "192.168.0.89"
            , desc = "Samsung Galaxy Mini 2 GT-S6500"
            , mac= Some "bc:79:ad:95:39:05"
            , comments = [] : List Text
            }

          , { fqdn = "andrew-vh.sixears.co.uk."
            , ipv4 = "192.168.0.100"
            , desc = "Andrew VH Samsung Camera"
            , mac= Some "b4:79:a7:07:8a:15"
            , comments = [] : List Text
            }

          , { fqdn = "joshua-vh.sixears.co.uk."
            , ipv4 = "192.168.0.101"
            , desc = "Joshua VH iPhone 5S"
            , mac= Some "f8:27:93:47:9D:cc"
            , comments = [] : List Text
            }

          , { fqdn = "anya-vh.sixears.co.uk."
            , ipv4 = "192.168.0.102"
            , desc = "Anya VH iPhone 5C"
            , mac= Some "f0:db:f8:92:87:80"
            , comments = [] : List Text
            }

          , { fqdn = "daniel-vh.sixears.co.uk."
            , ipv4 = "192.168.0.103"
            , desc = "Daniel VH Samsung Young GTS36AS"
            , mac= Some "e8:4e:84:ab:8d:19"
            , comments = [] : List Text
            }

          , { fqdn = "dad-p.sixears.co.uk."
            , ipv4 = "192.168.0.104"
            , desc = "Dad P Samsung S5"
            , mac= Some "90:B6:86:D1:B4:B1"
            , comments = [] : List Text
            }

          , { fqdn = "natalie-w.sixears.co.uk."
            , ipv4 = "192.168.0.107"
            , desc = "Natalie Winner Blue Laptop"
            , mac= Some "74:e5:43:59:62:cf"
            , comments = [] : List Text
            }

          , { fqdn = "natalie-x.sixears.co.uk."
            , ipv4 = "192.168.0.108"
            , desc = "Natalie Winner XPeria Phone"
            , mac= Some "a0:e4:53:fa:5f:3f"
            , comments = [] : List Text
            }

          , { fqdn = "dad-p-mac.sixears.co.uk."
            , ipv4 = "192.168.0.110"
            , desc = "Dad P MacBook Air"
            , mac= Some "98:e0:d9:7f:80:d9"
            , comments = [] : List Text
            }

          , { fqdn = "dad-p-tab.sixears.co.uk."
            , ipv4 = "192.168.0.111"
            , desc = "Dad P Samsung Tab"
            , mac= Some "28:27:bf:0d:c2:f1"
            , comments = [] : List Text
            }
          ]
 } : ./HostsType

