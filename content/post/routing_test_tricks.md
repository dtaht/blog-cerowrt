+++
date = "2016-10-10T10:02:58+01:00"
draft = false
tags = [ "babel", "lab", "routing", "wifi" ]
title = "A simple routing trick makes my tests easier"
description = "Try this in your topology!"
+++

The APs in the yurtlab are mostly in a routed configuration, where all
the devices under test are on the same ethernet switch. To do a test
of some configuration, all I do is do a ifdown lan on the devices I
want to talk to wirelessly, and the babel protocol figures out which
way to go.

There's another trick in this however- all the servers and clients -
and the default gateway - announce themselves over the babel routing
protocol as /32 p2p destinations. This is babel's default mode - no
configuration required, and this potentially overrides the default /24
everything is on, and makes it possible to create *arbitrary
topologies* - without having to change IP addresses - you just down a
set of interfaces, or plug things in differently, and the protocol
figures out the new topology for you.

This saves hugely on renaming, and renumbering things.

In this example, I disconnected the AP from the switch so it would
pick up a route over the wireless. I then plugged my laptop into
the AP for a quick test.

In a few seconds the network discovered its new topology and I didn't
even lose my connections.

````
root@m2-1:~# # plug into laptop directly
root@m2-1:~# ip route
default via 172.22.254.26 dev wlan0 onlink 
172.22.0.0/16 via 172.22.254.26 dev wlan0 onlink 
172.22.64.0/22 via 172.22.254.26 dev wlan0 onlink 
172.22.192.0/22 via 172.22.254.26 dev wlan0 onlink 
172.22.192.3 via 172.22.254.26 dev wlan0 onlink 
172.22.148.0/24 dev eth0  src 172.22.148.22 
172.22.148.3 via 172.22.254.26 dev wlan0 onlink 
172.22.148.8 via 172.22.148.8 dev eth0 onlink # Laptop behind the ap
172.22.148.9 via 172.22.254.25 dev wlan0 onlink 
172.22.254.0/24 via 172.22.254.26 dev wlan0 onlink 
172.22.254.24 via 172.22.254.24 dev wlan0 onlink 
172.22.254.25 via 172.22.254.25 dev wlan0 onlink 
172.22.254.26 via 172.22.254.26 dev wlan0 onlink 
172.22.254.27 via 172.22.254.27 dev wlan0 onlink 

````

## Laptop's route

````
dave@nemesis:~/git/sites/blog-cerowrt/content/post$ ip route
default via 172.22.148.22 dev enp2s0  proto babel onlink 
172.20.6.0/24 dev wlp3s0  proto kernel  scope link  src 172.20.6.119  metric 600 
172.22.0.0/16 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.64.0/22 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.148.0/24 dev enp2s0  proto kernel  scope link  src 172.22.148.8 
172.22.148.3 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.148.9 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.148.22 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.192.0/22 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.192.3 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.254.0/24 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.254.22 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.254.24 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.254.25 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.254.26 via 172.22.148.22 dev enp2s0  proto babel onlink 
172.22.254.27 via 172.22.148.22 dev enp2s0  proto babel onlink 
````

## Side note

Having this level of no-matter-what connectivity is sometimes a pain.
For example, I wrote this piece before I realized my main laptop had
been behind this split topology for *days*.

## server

````
d@rudolf:~$ ip route
default via 172.22.64.1 dev enp3s0  proto babel onlink 
172.20.6.119 via 172.22.192.3 dev enp4s0  proto babel onlink 
unreachable 172.22.0.0/16  proto 44 # covering route for teh whole lab
172.22.64.0/24 dev enp3s0  proto kernel  scope link  src 172.22.64.169 
172.22.64.0/22 via 172.22.64.1 dev enp3s0  proto babel onlink 
172.22.148.0/24 via 172.22.192.3 dev enp4s0  proto babel onlink 

Arguably the server could filter out the p2p links but I didn't bother.

172.22.148.3 via 172.22.192.3 dev enp4s0  proto babel onlink 
172.22.148.8 via 172.22.192.3 dev enp4s0  proto babel onlink 
172.22.148.9 via 172.22.192.3 dev enp4s0  proto babel onlink 
172.22.148.22 via 172.22.192.3 dev enp4s0  proto babel onlink 
172.22.192.0/24 dev enp4s0  proto kernel  scope link  src 172.22.192.1 
unreachable 172.22.192.0/22  proto 44 
172.22.192.3 via 172.22.192.3 dev enp4s0  proto babel onlink 
172.22.194.0/24 dev wlp1s0  proto kernel  scope link  src 172.22.194.1 linkdown 
172.22.195.0/24 dev wlp5s0  proto kernel  scope link  src 172.22.195.1 
172.22.254.0/24 via 172.22.192.3 dev enp4s0  proto babel onlink

````

## Changing Station Parameters

if you don't have pdsh:

````
dave@nemesis:~/maccap$ for i in lite-1 lite-2 lite-3 lite-4 m2-1; do ssh root@$i 'sed -i s/HT40+/HT20/g /etc/config/wireless'; done
dave@nemesis:~/maccap$ for i in lite-1 lite-2 lite-3 lite-4 m2-1; do ssh root@$i 'reboot; exit'; done
````

Psh is nicer tho:

````
pdsh -g lites 'sed -i s/HT40+/HT20/g /etc/config/wireless; reboot; exit'
````

Now I can repeat the same test in HT20 mode... but I just reset all the
devices back to their bridged ethernet defaults and need to recreate
the topology.

````
pdsh -g topo-3 'ifdown lan'
````

