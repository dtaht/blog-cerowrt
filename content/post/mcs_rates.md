+++
date = "2016-05-07T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "Exploring wifi mcs rates with fq_codel"
description = ""
+++

We are trying to land a bunch of interrelated fixes for the ath9k portion
of the stack. We are trying to break the current, fixed relationship,
in wifi latency to the speed it is running at.

I don't really trust anyone elses test tools. I make enough mistakes
using flent to not trust *me*, and I spend a maddening amount of time
trying to figure out ways to test no more than two variables in
isolation - or to confidently test dozens and draw a sane conclusion
from the results. Sometimes I fail.

HT20 mode at 5ghz has several advantages:

* I can generally find a clean channel
* The lowest possible rate (6mbits) is comfortably above the lower limits (2.5mbit) where we've seen codel misbehave.
*

Well, no. The loma prieta fire last week forced me to pack up the
whole lab, and the box I had been using for ath9k tests - well, when I
set it up again it looks like one antenna had got disconnected
internally and I'll have to rip it out of the stack. It took a while
to figure that out. I thought the new code was broken til I switched
to the laptop!

{{< figure src="">}}

Normally for me, I have a delay box. Here I have no delay configured, but the
"server" box is one ethernet hop further than the the delay box.

## Postive note #1 

Exhibits bounded latency

I'd really love to believe this result, but for all I know we're
leaving potential bandwidth on the floor. The 3.6-6ms of latency
induced at the higher rates seems too small - although seeing bounded
latency when some other traffic enters the link, and it changing
rapidly to adjust is a good sign:

{{< figure src="">}}

# SoftIrq fix

I love this - it means packet processing at the driver ring can
I hate this -

What can this particular box do? Are we seeing the change in tcp small
queues, or the softirq change? or is codel doing the right thing?


## Steps forward

But! Performance is NOT being regulated by the fqbug anymore - at
least not on this test series! - and for that I'm grateful - all flows
are pretty fair, there are no gaps, bandwidth is consistent.

* HT20 mode
*

Is there an interaction between codel? 

Trying to attack the simulation

Sampling rate of 50ms - so we could think that maybe we weren't fq-ing anymore
either

Er, um, ah, no. At mcs15, this morning - really struggles -

Packet captures are good.

```
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
 ```

Not a significant amount of traffic, but I'd forgot I'd left a box (.10)
on the AP for the test, and for all I know at some point during the
test it'd tried for an update on some active program or another.

Are we FQ-ing?

{{< figure src="" >}}

Yes, we're fq-ing - but to see what things look like on the wire, I'd need
an aircap - and the machine I'm using to drive this is the machine I
normally use to do that!

Killing bufferbloat inside the stack.

Except, if you have an application, like videoconferencing, that's not TCP
based!

# interaction with rate control.

```
root@prancer:~# tcpdump -i enp4s0 -w mcs15.cap
tcpdump: listening on enp4s0, link-type EN10MB (Ethernet), capture size 262144 bytes
^C6092 packets captured
6094 packets received by filter
0 packets dropped by kernel
root@prancer:~# tcpdump -i enp4s0 -w mcs4.cap
tcpdump: listening on enp4s0, link-type EN10MB (Ethernet), capture size 262144 bytes
^C95367 packets captured
95369 packets received by filter
0 packets dropped by kernel
```

Moving about the room, been able to interfere with the wifi signal - I should probably show that in a test at some point.