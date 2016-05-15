+++
date = "2016-05-07T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "Producing arbitrary pings"
description = "Sane limits are good, except when doing insane things"
+++

Warning: Command produced no valid data.
Data series: Ping (ms) ICMP1 172.26.130.12
Runner: PingRunner
Command: /usr/bin/fping -D -p 50 -c 12200   172.26.130.12
Standard error output:
  /usr/bin/fping: count 12200 not valid, must be less than 10000
Warning: Program exited non-zero (1).
Command: /usr/bin/fping -D -p 50 -c 12200   172.26.130.12
Program output:
  /usr/bin/fping: count 12200 not valid, must be less than 10000
  
Warning: Command produced no valid data.
Data series: Ping (ms) ICMP2 172.26.130.12
Runner: PingRunner
Command: /usr/bin/fping -D -p 50 -c 12200   172.26.130.12
Standard error output:
  /usr/bin/fping: count 12200 not valid, must be less than 10000


