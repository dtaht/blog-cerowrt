+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat"  ]
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

iw dev wlp4s0 set power_save off

worked beautifully on the ath10k driver I'm using. The babel metric stayed stable, the route stayed stable, life was good, throughput increased, latency dropped...

That said, I know how hard wifi device driver writers are hammering at trying to reduce multicast effects, and save power... and I haven't exactly found the root cause of this problem, in this driver... but I think I've seen it elsewhere also, while chasing this -l failover issue.

multicast beacons are supposed to say "hey, chips, wake up, you need to hear this".


