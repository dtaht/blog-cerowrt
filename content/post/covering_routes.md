+++
date = "2016-04-26T14:02:58+01:00"
draft = true
tags = [ "wifi", "routing" ]
title = "exporting covering routes in babel"
description = "complex route tables are a pita"
+++

Covering routes

I stick 

ip route add unreachable 172.26.32.0/22 proto static

and this into babeld.conf

redistribute ip 0.0.0.0/0 le 22 allow
redistribute local deny

powers of 2

root@lorna-gw config# ip route
default via 73.252.200.1 dev eth0  proto static  src 73.252.201.217  metric 10 
73.252.200.0/23 dev eth0  proto static  scope link  metric 10 
73.252.200.1 dev eth0  proto static  scope link  src 73.252.201.217  metric 10 
76.102.224.0/21 via 172.26.16.5 dev br-lan  proto babel onlink 
172.26.16.0/24 dev br-lan  proto kernel  scope link  src 172.26.16.1 
172.26.16.3 via 172.26.16.3 dev br-lan  proto babel onlink 
172.26.18.0/24 via 172.26.16.224 dev br-lan  proto babel onlink 
172.26.19.0/24 via 172.26.16.224 dev br-lan  proto babel onlink 
172.26.32.0/22 via 172.26.16.4 dev br-lan  proto babel onlink 
172.26.64.0/24 via 172.26.16.5 dev br-lan  proto babel onlink 
172.26.128.0/23 via 172.26.16.5 dev br-lan  proto babel onlink 

babel command language 

le 22

has two better routes locally that override it.

And you want in general to look in the mac table for forwarding
stuff rather than the route table, so having local announcements
is bad.

Except when it's good.


