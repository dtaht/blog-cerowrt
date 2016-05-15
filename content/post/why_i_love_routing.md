+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Why I love routing"
description = "We could use ethernet, wifi, and usb more efficently"
+++

```
root@rudolf:~# ip route
default via 172.26.64.1 dev enp3s0  proto babel onlink 
73.252.200.0/23 via 172.26.17.45 dev usb0  proto babel onlink 
76.102.224.0/21 via 172.26.64.1 dev enp3s0  proto babel onlink 
172.26.16.0/24 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.16.3 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.17.45 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.17.47 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.18.0/24 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.18.21 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.19.0/24 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.19.23 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.32.0/22 via 172.26.17.45 dev usb0  proto babel onlink 
172.26.48.0/24 via 172.26.64.236 dev enp3s0  proto babel onlink 
172.26.64.0/24 dev enp3s0  proto kernel  scope link  src 172.26.64.200 
172.26.128.0/24 dev enp2s0  proto kernel  scope link  src 172.26.128.1 linkdown 
```
