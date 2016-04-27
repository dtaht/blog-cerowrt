+++
date = "2016-04-26T14:02:58+01:00"
draft = false
tags = [ "wifi", "routing" ]
title = "Poking at powersave"
description = "Wifi is often optimized to save power at a cost in connectivity"
+++

For weeks now I've been puzzling over why a variety of links flapped the way they did, routes coming and going, failing over to weird paths, and I think I have finally isolated one part of the problem..

In an age where adhoc does not work particularly well, and AP/sta mode does (as in 6mbit vs 500 in one case), I've had a tendency to nail up links in ap/sta mode. 

Well, at least one ( probably several) of the devices I have in the new lab has *very aggressive* power save, to where babel ipv6 multicast traffic either doesn't sync up to the AP's request for multicast (or the sta's), or it is merely completely suppressed by the stack. (or lost due to a bug!)...

Anyway...

So long as there is unicast traffic on the local part of the link, you don't see a problem. And there's almost always a bit of traffic on the link. So, perversely... like when I'm looking at it... like, pinging from one side of the link to the other... it works. When I go away for a bit... it fails. Eventually. 

If I run a test, after getting everything all setup and verified the network looks correct... it works. 

If I walk away and run a test that has a few minutes :grump: between runs to let things "settle down", things actually deteriorate. 

Babel misses multicast traffic and gradually increases the metric due to the loss - causing a given route, in my case, to eventually fall over to an adhoc wifi radio elsewhere on the network, which reduces the probability of unicast traffic still more, until ultimately the local link, otherwise nailed up, drops off the network completely.

to "fix" this:

```
iw dev wlp4s0 set power_save off
```

worked beautifully on the ath10k driver I'm using. The babel metric stayed stable, the route stayed stable, life was good, throughput increased, latency dropped...

{{< figure src="/flent/wifi_powersave/powersave_disabled.png" >}}

And I went and confirmed that powersave was on, on a few ap/sta links, 
and off on adhoc. This was my pi3:

```
root@pi3:/home/d# iw dev wlan0 get power_save
Power save: on
root@pi3:/home/d# iw dev wlan1 get power_save
Power save: off
```

The first interface is ap/sta. the second, adhoc. The ap/sta interface
gets something like 70mbits, btw, and the adhoc doesn't get past 6mbit.
That said, I know how hard wifi device driver writers are hammering at trying to reduce multicast effects, and save power... and I haven't exactly found the root cause of this problem, in this driver... but I think I've seen it elsewhere also, while chasing this -l failover issue.

multicast beacons are supposed to say "hey, chips, wake up, you need to hear this".

In looking over the test run with powersave on ("really") and powersave off("powersave") - there was an interesting pattern revealed that I don't quite 
understand. This is two separate test runs, taken minutes apart, and yet
roughly the same pattern of delay exists for both.

{{< figure src="/flent/wifi_powersave/symmetry2.svg" >}}

Now, both tcp and codel are remarkably deterministic in their operation.
Codel, in particular, has a fixed latency before inducing drops, so I suspect
that we are seeing an interesting interaction between the driver and 
the stack, relative to the allocations of airtime each is giving it.

One of the goals of an aqm is to not have synchronized drops,
and that's what we got right now.

Anyway [test data](/flent/wifi_powersave/) is here, and I'm off to go
disable powersave completely across my entire network (for now).

Update: So, I went and changed the pi over to not use power save...
and it *still* chose the lousy adhoc interface over everything else.
Damned if I know why. I applied a bigger metric to it...

But at least the basic other route is staying feasible... but the, 
the adhoc interface is overriding the main interface, supplying
a better metric than the good interface:

```
73.252.200.0/23 via 172.26.16.1 dev enp3s0  proto babel onlink 
76.102.224.0/21 via 172.26.64.1 dev enp2s0  proto babel onlink 
169.254.22.140 via 172.26.16.183 dev enp3s0  proto babel onlink 
172.26.16.0/24 dev enp3s0  proto kernel  scope link  src 172.26.16.5 
172.26.16.3 via 172.26.16.3 dev enp3s0  proto babel onlink 
172.26.17.247 via 172.26.16.183 dev enp3s0  proto babel onlink 
172.26.18.0/24 via 172.26.16.183 dev enp3s0  proto babel onlink 
172.26.18.21 via 172.26.16.183 dev enp3s0  proto babel onlink 
172.26.19.0/24 dev wlp4s0  proto kernel  scope link  src 172.26.19.24 
172.26.64.0/24 dev enp2s0  proto kernel  scope link  src 172.26.64.5 
172.26.128.0/24 via 172.26.64.200 dev enp2s0  proto babel onlink 
172.26.129.0/24 via 172.26.64.200 dev enp2s0  proto babel onlink 
192.168.2.0/24 via 172.26.16.1 dev enp3s0  proto babel onlink 
root@apu2:/sys/kernel/debug/ieee80211/phy0# netperf -H 172.26.19.1
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.26.19.1 () port 0 AF_INET : demo
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.05       7.87   
root@apu2:/sys/kernel/debug/ieee80211/phy0# netperf -H 172.26.18.1

hangs - that interface *sucks*
```

Hmm.... Maybe if I turn off powersave at the AP? 

For now, I just killed the pi3 as a router. I got other fish to fry.
