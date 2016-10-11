+++
date = "2016-10-10T22:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath9k", "lab" ]
title = "Exploring wifi mcs rates with fq_codel"
description = "There's always something else wrong..."
+++

I don't trust anyone else's test tools. I make enough mistakes using
[flent](https://flent.org) to not trust *me*, and I spend a maddening amount of time trying
to figure out ways to test no more than two variables in isolation -
or to confidently test dozens and draw a sane conclusion from large
set of statistically significant results. Often, I fail.

Over the next few months we are trying to land a bunch of interrelated
fixes for the ath9k portion of the stack. First up - we are trying to
break the current, fixed relationship, in wifi latency to the
available bandwidth , by dynamically adjusting the buffer size to the
rate, in addition to adding fair queuing to make sparser packets
closer to the front of the queue.

We're winning, or so I thought last night. 

{{< figure src="/flent/mcs/mcs8_15.svg">}}

All I wanted to do was see the relationship between wifi rate,
throughput, and buffering.

## How to go about testing different mcs rates?

Wifi uses a "rate set" which in 802.11n varies from mcs0 to
mcs15. MCS8-15 are slightly faster but relative to mcs0-7 - 0 and 8
are close, etc - but in order to fit that graph on the page, I'm not showing
that.

Simple test, on the laptop acting as an AP:

````
T="-t whatever"
H="-H server -H delay -H server -H delay"

for i in `seq 0 15`
do
iw set bitrates ht-5 $i
flent -x ${T}_mcs_$i $H --test-parameter=upload_streams=4 rtt_fair_up 
done
````

Simple, right? Well, no.

* I'm driving this from an AP not from a client of the AP
  So I'm testing the host TCP stack, on the AP. It's not being a router.
* on the other side of the link I'm testing a router as a client
* I'm using 4 flows, rather than 1 to try to stress out the fq part of the algo

I usually start off with testing things with an ath9k at using HT20 mode.

HT20 mode at 5ghz has several advantages:

* I can generally find a clean channel
* The lowest possible rate (mcs0 6mbits) is comfortably above the lower limits (2.5mbit) where we've seen codel misbehave.

Another problem is getting consistent results over time. If *all else
is constant* you have a good chance that a result you got on wifi last
week will match what you got this week. Even if something moves a
millimeter, you might have mucked with the box.

So - are my results constant?

No. The loma prieta fire last week forced me to pack up the whole lab,
and the box I had been using for ath9k tests - when I set it up
again it looks like one antenna had got disconnected internally and
I'll have to rip it out of the stack. It took a while to figure that
out. I thought the new code was broken til I switched to the laptop -
which of course, has the latest net-next code and the new ath9k/ath10k
fq_codel and airtime fairness code on top of that.

So I'm now testing the wrong device, in the wrong place, with an
entirely different network card, and patches layered on top of the
latest net-next stack that had several other significant changes in
it, and can't look at last week's results with any confidence.

Sigh. I don't mind that I'm only getting 50Mbit out of the laptop, but
at ht20 5ghz I've done better on other hardware. Are we using up
all the available capacity? Is TSQ getting in the way? Can't tell.

{{< figure src="">}}

Normally for me, I have a delay box to simulate common internet level
RTTs - 11ms, 28ms and 48ms are what I use. Here I have no delay
configured, but the "server" box is one ethernet hop further than the
the delay box, so it's a few us further up the chain than the "delay" box.
That shouldn't make much of a difference, and it doesn't. 

All I wanted to do was test things at different MCS rates, and compare
them against last week's data....

## Postive note #1 

The overall test exhibits bounded latency. The 12ms of delay at mcs8
adds up ok... I have 4 flows going at this speed (~10mbit), or 5.2ms
total, with a bit more for the measurement flows - one in the driver,
one in the hardware - 12ms is close enough, or so it seems.

(Going from 12ms to 3ms (4x1 ratio) from lowest to highest bandwidth
is a heck of a lot better than the 200x1 [we used to get](/post/fq_codel_on_ath10k)!)

But: we may be leaving potential bandwidth on the floor. The 3.6-6ms
of latency induced at the higher rates seems too small.

{{< figure src="">}}

- although seeing bounded latency when some other traffic enters the
link, and it changing rapidly to adjust is a good sign.

{{< figure src="">}}

## Steps forward

Performance is NOT being regulated by the [fqbug](/post//crypto_fq_bug/) anymore - at least not on this test series! - and for that I'm grateful - all flows
are pretty fair, there are no gaps, bandwidth is consistent.

{{< figure src="">}}

I spend a lot of time trying to attack the simulation. We are now
bounded by something else.

## What else could be different?

In a world of [all up testing](/post/all_up_testing), there are many other
pieces also changing at the same time. Really key in this new string of tests
has been trying to figure out what difference - if any - the new softirq fix
does. 

## SoftIrq fix

A major change in how softirq handling landed in net-next,
also. Jonathan Corbet summarized the issue in
https://lwn.net/Articles/687617/
    
````
commit: 4cd13c21b207e80ddb1144c576500098f2d5f882
Tested:
    
     - NIC receiving traffic handled by CPU 0
     - UDP receiver running on CPU 0, using a single UDP socket.
     - Incoming flood of UDP packets targeting the UDP socket.
    
    Before the patch, the UDP receiver could almost never get CPU cycles and
    could only receive ~2,000 packets per second.
    
    After the patch, CPU cycles are split 50/50 between user application and
    ksoftirqd/0, and we can effectively read ~900,000 packets per second,
    a huge improvement in DOS situation. (Note that more packets are now
    dropped by the NIC itself, since the BH handlers get less CPU cycles to
    drain RX ring buffer)
````

* I love this - it means packet processing at the driver ring can fire off
stuff in userspace WAY faster. Maybe some of the issues I've had driving
APs for tests will go away.
* I hate this - it means packet processing at the driver ring can fire off
stuff in userspace WAY faster. All my prior test data just became difficult
to reason about.

What can this particular box do? Are we seeing the change in tcp small
queues, or the softirq change? or is codel doing the right thing? Are
we still fair queuing? Hmm.. it looks like FQ is still working but we'd
need an aircap to be sure.

# Is codel working? 

No. A check against the packet capture showed no loss. It's gotta be
TSQ. Or the new softIRQ fix. Something holding the size and number of
txops outstanding down. Boy am I glad it's not the fq-crypto bug...

##  Poking harder at the "good" packet capture

````
dave@nemesis:~/mcs$ tcptrace -G mcs4.cap 
1 arg remaining, starting with 'mcs4.cap'
Ostermann's tcptrace -- version 6.6.7 -- Thu Nov  4, 2004

95361 packets seen, 88894 TCP packets traced
elapsed wallclock time: 0:00:02.496478, 38198 pkts/sec analyzed
trace file elapsed time: 0:00:53.717990
TCP connection info:
  1: delay:22 - 172.22.224.1:47874 (a2b)                            1>    1<
  2: 172.22.224.10:56456 - filter17.adblockplus.org:443 (c2d)     270>  206<  (complete)
  3: 172.22.224.1:34976 - wepro1.somafm.com:80 (e2f)               12>    8<
  4: 172.22.224.10:56438 - sfo03s01-in-f14.1e100.net:443 (g2h)      2>    2<
  5: 172.22.224.10:55924 - sfo07s13-in-f14.1e100.net:443 (i2j)      8>    8<
  6: 172.22.224.1:44445 - delay:12865 (k2l)                         7>    5<  (complete)
  7: 172.22.224.1:36075 - delay:12865 (m2n)                         7>    5<  (complete)
  8: 172.22.224.1:40409 - rudolf:12865 (o2p)                        7>    5<  (complete)
  9: 172.22.224.1:48397 - rudolf:12865 (q2r)                        7>    5<  (complete)
 10: 172.22.224.1:39651 - delay:33263 (s2t)                      13353> 7496<  (complete)
 11: 172.22.224.1:44055 - rudolf:42339 (u2v)                     13300> 7490<  (complete)
 12: 172.22.224.1:35327 - delay:36171 (w2x)                      16566> 8958<  (complete)
 13: 172.22.224.1:39355 - rudolf:37703 (y2z)                     13497> 7526<  (complete)
 14: 172.22.224.10:56372 - sfo03s01-in-f14.1e100.net:443 (aa2ab)   10>   10<
 15: 172.22.224.1:34972 - wepro1.somafm.com:80 (ac2ad)              2>    3<
 16: wepro1.somafm.com:80 - 172.22.224.1:34974 (ae2af)              2>    1<
 17: pg-in-f189.1e100.net:443 - 172.22.224.1:57362 (ag2ah)          7>    6<
 18: 172.22.224.1:52436 - sfo07s16-in-f5.1e100.net:443 (ai2aj)      2>    1<
 19: 172.22.224.10:56467 - sfo07s16-in-f14.1e100.net:443 (ak2al)   25>   18<
 20: 172.22.224.10:56449 - sfo03s07-in-f14.1e100.net:443 (am2an)    1>    1<
 21: 172.22.224.1:34662 - sfo03s07-in-f14.1e100.net:443 (ao2ap)    10>   11<
 22: icei.org:143 - 172.22.224.10:54304 (aq2ar)                     6>   10<
 23: mail.taht.net:993 - 172.22.224.10:54303 (as2at)
````

Not a significant amount of traffic, but I'd forgot I'd left a box (.10)
on the AP for the test, and for all I know at some point during some other
test it'd tried for an update on some active program or another.

But the capture showed... no losses, no CWRs, nothing that indicates codel was being applied.  

{{< figure src="/flent/mcs/screenshot.png" >}}

But to see what things look like in the air, I'd need an aircap - and
the machine I'm using to drive this is the machine I normally use to
do that!

I have to think on this, but since I mostly want to fix the AP's behavior,
the next string of tests queued up is against the AP, acting as an AP.

## What's up with mcs-15?

The mcs-15 result was a bit jittery, so I poked into a bit harder:

{{< figure src="/flent/mcs/mcs-15-struggle.svg" title="mcs-15 struggles" >}}

MCS-14 was stabler and faster than what MCS-15 got.

{{< figure src="/flent/mcs/mcs-14-stabler-faster.svg" title="mcs-14 stabler" >}}

Was it some other traffic entering the link? Or, interference?

Retesting mcs15, this morning - it really struggles - getting 1/20th
the throughput mcs4 does:

````
root@prancer:~# tcpdump -i enp4s0 -w mcs15.cap
tcpdump: listening on enp4s0, link-type EN10MB (Ethernet), capture size 262144 bytes
6092 packets captured
6094 packets received by filter
0 packets dropped by kernel
root@prancer:~# tcpdump -i enp4s0 -w mcs4.cap
tcpdump: listening on enp4s0, link-type EN10MB (Ethernet), capture size 262144 bytes
95367 packets captured
95369 packets received by filter
0 packets dropped by kernel
````

This is why [wifi rate control](/tags/minstrel) monitors the
connection quality at any given rate, and adjusts the mcs rate to
suit. The highest set of mcs rates tend to fail under anything but
lab conditions. I *know* this - so I sometimes DO test the highest
rates, totally prepared to throw them out - and otherwise, just use
minstrel and try to capture what it thinks is the right rate...

... which impacts retries, and has a 5% failure rate induced, and a horde
of other headaches that I'm letting the minstrel-blues folk figure out.

Turning off rate control entirely is stupid, unless you know what you
are doing - or - as I was trying to do - explicitly explore rate
control.

I don't pay much attention to the highest rate results in the lab
either, it's not real world enough.

## Conclusions

* The patch set doesn't crash!
* It appears to work, at least what I tested
* Something else is regulating the AP - it may be starving the queues 
* I need to rebuild the missing box to get aircaps
* iw set bitrates can be used at the AP to change them in future tests
  (before I was changing it in hostapd.conf)

I suppose I should be happy, but I would like to have solidly, definitively
proved *something*, and, well, more testing awaits.

I've now been at fixing wifi for 6 years - 8 if you count my time in
Nicaragua - and these were my last few weeks of headaches. There are
more. I like to think we are one or two kernel generations away from
being this phase of make-wifi-fast, but who knows what the next test
series will bring?

...

Last note: In moving about the room, been able to interfere with the
wifi signal - I should probably show that in a test at some point.
