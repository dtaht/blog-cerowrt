+++
date = "2012-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Predictive coddling"
description = "Because, sometimes, you know when the wifi is going to burp..."
+++

CAB (formally known as "Content after beacon") treats multicast packets
as an afterthought. Multicast can really slow down wifi.

But crap after beacon is annoying in other ways. It injects a latency spike
that totally dominates the air for a long time, and holds up progress for
all other packets, which may well be transmitting at rates hundreds of
times higher than what multicast transmits at.

Thus you find people doing all sorts of contortions to eliminate multicast
from the baseline protocols that rely on them - not just arp, and nd,
but mdns and upnp - or blocking them entirely.

The thing is, multicast, and beacons, and channel scans *happen on a schedule*.

{{< figure src="/flent/qca-10.2-fqmac35-codel-5/beaconimpactmaybe.svg" >}}

IF you know that a multicast transmission is coming up, it's a fixed
length quantity packet_bytes*transmission_rate (1 or 6mbits usually).

Same goes for a scan but that's hardware dependent.

Instead of waiting for that burst to happen, you can signal the backlogged
flows to start slowing down a little bit, beforehand, building a bandwidth
"hole" around the pending spike and thus smoothing out the afteraffects and related carnage by a lot. 

There's a couple ways to do it - reducing the codel target temporarily
is one, another would be to start supplying an advanced clock to codel
drop for a few moments. (sort of how ntp does it but more violent - at least 20ms ahead of the pending interruption would be good). Actually there's even
more ways to do it than that but they are too long to fit into the margins
of this blog.

What people did before we fq_codel'd wifi was just eat 100s of ms of 
induced delay, which totally messes up voip and gaming traffic:

{{< figure src="/flent/qca-10.2-fqmac35-codel-5/long_comparison.svg" >}}

And we can just smooth that out even more than codel already does reactively,
predictively, instead, by being smart about understanding the multicast schedule.

Another thing that people do with multicast wrong is just dump all the
outstanding packets into the multicast queue and expect the hardware to
sort it out. Rate limiting what's in the queue would reduce the size of
the typical multicast burst and smooth things out further. There are 
already recommendations that high level protocols do this, but perhaps
it would better to spread things out in the mac80211 layer itself,
managing duplicate transmissions, and floods and so on.

...

Most - not all - management frames could be accounted for in this way,
also. They tend towards being sparse in nature however, and nowhere near
the big, obvious problem multicast can be.

...

I have a few more things left in my bag of tricks to further reduce the latency impact on simple 1 station tests as we've done so far, but the overal reduction
in latency from 100+ms down to 20ms we've got so far is marvelous and I'd 
like to spend more time polishing that up, and getting it to run well
on more than just the [ath10k](/tags/ath10k) chipset.

...

BTW:

There are other things that can be done to minimize the impact of 
powersave also. If you have just sent a bunch of packets, there's pretty
good odds you'll be getting some back. If you have a good idea of the 
actual rtt, you can schedule your next wakeup (or sleep) period as
to when you'll want to get them..

{{< figure src="/flent/qca-10.2-fqmac35-codel-5/powersave.svg" >}}

More details on [make-wifi-fast here](/tags/wifi).

