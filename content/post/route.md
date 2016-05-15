+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Sorting out a routing failure"
description = "Routing can be finicy "
+++

pi3 can "route" but does not take an ssh login
pi2 unreachable because it's on the other side of the net
apu - gone completely
cerowrt also gone
add route 172.26.18.0/24-9f0550-::/0 prefix 172.26.18.0/24 from ::/0 installed yes id 12:0d:7f:ff:fe:64:c9:91 metric 49344 refmetric 0 via fe80::100d:7fff:fe64:c990 if wlp4s0
add route 172.26.18.21/32-9f0550-::/0 prefix 172.26.18.21/32 from ::/0 installed yes id ba:27:eb:ff:fe:87:21:77 metric 49392 refmetric 48 via fe80::100d:7fff:fe64:c990 if wlp4s0
add route 172.26.19.0/24-9f0550-::/0 prefix 172.26.19.0/24 from ::/0 installed yes id 12:0d:7f:ff:fe:64:c9:91 metric 49344 refmetric 0 via fe80::100d:7fff:fe64:c990 if wlp4s0

add route 172.26.17.247/32-9f0550-::/0 prefix 172.26.17.247/32 from ::/0 installed yes id ba:27:eb:ff:fe:87:21:77 metric 65535 refmetric 48 via fe80::100d:7fff:fe64:c990 if wlp4s0
add route 172.26.18.0/24-9f0550-::/0 prefix 172.26.18.0/24 from ::/0 installed yes id 12:0d:7f:ff:fe:64:c9:91 metric 65535 refmetric 0 via fe80::100d:7fff:fe64:c990 if wlp4s0
add route 172.26.18.21/32-9f0550-::/0 prefix 172.26.18.21/32 from ::/0 installed yes id ba:27:eb:ff:fe:87:21:77 metric 65535 refmetric 48 via fe80::100d:7fff:fe64:c990 if wlp4s0

root@apu2:/etc# ip route
default via 172.26.64.231 dev enp2s0  proto babel onlink 
73.252.200.0/23 via 172.26.64.231 dev enp2s0  proto babel onlink 
76.102.224.0/21 via 172.26.64.1 dev enp2s0  proto babel onlink 
unreachable 169.254.22.140  proto babel  metric 4294967295 onlink 
172.26.16.0/24 dev enp3s0  proto kernel  scope link  src 172.26.16.5 
172.26.16.3 via 172.26.64.231 dev enp2s0  proto babel onlink 
unreachable 172.26.17.247  proto babel  metric 4294967295 onlink 
unreachable 172.26.18.0/24  proto babel  metric 4294967295 onlink 
unreachable 172.26.18.21  proto babel  metric 4294967295 onlink 
172.26.19.0/24 dev wlp4s0  proto kernel  scope link  src 172.26.19.24 
unreachable 172.26.19.0/24  proto babel  metric 4294967295 onlink 
172.26.64.0/24 dev enp2s0  proto kernel  scope link  src 172.26.64.5 
unreachable 172.26.128.0/24  proto babel  metric 4294967295 onlink 
unreachable 172.26.129.0/24  proto babel  metric 4294967295 onlink 
192.168.2.0/24 via 172.26.64.231 dev enp2s0  proto babel onlink

dancer:

d@dancer:~/git/sites/cerowrt/content/post$ ip route
default via 172.26.16.1 dev eno1 onlink 
73.252.200.0/23 via 172.26.16.1 dev eno1  proto babel onlink 
76.102.224.0/21 via 172.26.16.130 dev eno1  proto babel onlink 
169.254.0.0/16 dev eno1  scope link  metric 1000 
172.26.16.0/24 dev eno1  proto kernel  scope link  src 172.26.16.3 
172.26.64.0/24 via 172.26.16.130 dev eno1  proto babel onlink 
172.26.128.0/24 via 172.26.16.130 dev eno1  proto babel onlink 
172.26.129.0/24 via 172.26.16.130 dev eno1  proto babel onlink 
192.168.2.0/24 via 172.26.16.1 dev eno1  proto babel onlink 
d@dancer:~/git/sites/cerowrt/content/post$ ping 172.26.16.5
PING 172.26.16.5 (172.26.16.5) 56(84) bytes of data.
^C
--- 172.26.16.5 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 1999ms

add route 172.26.18.0/24-9f3290-::/0 prefix 172.26.18.0/24 from ::/0 installed yes id 12:0d:7f:ff:fe:64:c9:91 metric 361 refmetric 265 via fe80::ba27:ebff:fec9:3c08 if enp3s0
add route 172.26.18.0/24-9f2020-::/0 prefix 172.26.18.0/24 from ::/0 installed no id 12:0d:7f:ff:fe:64:c9:91 metric 421 refmetric 325 via fe80::823f:5dff:fe09:f9fd if enp2s0
add route 172.26.18.0/24-9f31d0-::/0 prefix 172.26.18.0/24 from ::/0 installed no id 12:0d:7f:ff:fe:64:c9:91 metric 384 refmetric 0 via fe80::100d:7fff:fe64:c990 if wlp4s0
add route 172.26.19.0/24-9f3290-::/0 prefix 172.26.19.0/24 from ::/0 installed yes id 12:0d:7f:ff:fe:64:c9:91 metric 361 refmetric 265 via fe80::ba27:ebff:fec9:3c08 if enp3s0
add route 172.26.19.0/24-9f2020-::/0 prefix 172.26.19.0/24 from ::/0 installed no id 12:0d:7f:ff:fe:64:c9:91 metric 421 refmetric 325 via fe80::823f:5dff:fe09:f9fd if enp2s0
add route 172.26.19.0/24-9f31d0-::/0 prefix 172.26.19.0/24 from ::/0 installed no id 12:0d:7f:ff:fe:64:c9:91 metric 384 refmetric 0 via fe80::100d:7fff:fe64:c990 if wlp4s0


ok
^Cdump
dump

dump

