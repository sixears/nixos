#!@bash@/bin/bash

set -eu -o pipefail

chmod 0711 /htdocs/podcasts
chmod 0711 /htdocs/podcasts/*
thttpd" "-p" "80" "-d" "/htdocs" "-c" "*"
                  "-l" "/thttpd.log" "-i" "/thttpd.pid"
                  "-D" "-u" "root" "-nos"
