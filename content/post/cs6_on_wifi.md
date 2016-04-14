+++
date = "2016-04-22T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "On the role of Network Control in wifi"
description = "What's the right way to use wifi multicast?"
+++

I have been meaning to talk about the complexities the 802.11e standard
brought into wifi and it's negative side effects for successor
standards, for a very long time now. I have tried to incorporate the problem into
several talks but have realized it needs a talk all to itself.

This is NOT a piece comprehensively discussing 802.11e. It's going to
take me [several](/post/hw_queue_selection_in_wifi) attempts to describe
the shape of the elephant, and then maybe after I'm done I can go back
and get it all more right.

{{< quote text="but what I said was not what I meant" cite="Humpty
Dumpty" src="http://www.authorama.com/files/humpty-dumpty.gif" >}}

## What CS6 is used for

There is a common diffserv codepoint, "CS6", used by several daemons
(dhcp, babel, off the top of my head), to indicate to the network that
there is something about it that needs to be changed. It is, at best,
a weak indicator of "change needed", it's an old codepoint,
inconsistently used, and it doesn't adapt to wifi well.

For starters...

802.11e media access is

- a scheduling problem
- a packet packing problem
- a queuing problem.

The proposed [dscp to 802.11e mapping standard](http://fixme) currently
makes no difference between multicast and unicast as to how diffserv
should be handled.

## CS6 usage

On 802.11n, the VO queue cannot aggregate, so at least in the case of
CS6, it is REALLY inefficient to use VO for anything other than VOIP.

Wifi telephony never worked worth a damn in the first place.

As originally envisioned, usage of the VO queue had an implicit "sparsity"
requirement - if you used it once for one destination, the odds were
that you would not use it again for at least 10-20ms, so grabbing the media
early and releasing it fast, was OK. A wifi telephone was not going to
request airtime again for a while. You can fill that time with other stuff.

Therefore I've long thought that CS6 should end up in the VI, rather
than VO queue.

There are other cases where CS6 might be used for larger updates of
network control traffic for where VO was *really* inappropriate - a BGP
update, for example, and 802.11ac adds the ability to aggregate back
into VO, but I still lean towards VI for CS6.

... more text to follow ...

## Multicast & PowerSave

That gets me to multicast. Multicast is *it's own queue*. It is
separately scheduled. A diffserv marking of anything multicast makes no
difference "on the wire".

It *might* be a good idea to treat it differently in the scheduler, but
I'll get to that later.

Multicast is very different in wifi than in ethernet - the basic
multicast stuff occurs on a CAB (content after beacon) DTIM timer,
depending on whether or not "powersave" is in use. With powersave on,
all stations in wifi get scheduled (typically on a 250ms interval) to
"wake up" to see if they have any packets.

Turning off the radio
[saves enormous energy on the clients](http://fixme), but wreaks havoc
on anything resembling scheduling, and all the conventional isochronous
assumptions that most packet protocols and aqms have goes out the
window.

On wifi - multicast is a second class citizen. By default, it runs at
the lowest rate in the standard - 1Mbit in 2.4ghz, 6Mbit in 5ghz. The
ath9k documentation infamously refers to "CAB" as "Crap after beacon".
That's ironic, because multicast is basically how wireless works -
everybody can hear everybody else.

Multicast in wifi is heavily overloaded. It is used not only for small
"ant-like" packets but for MDNS and UPNP discovery packets, which are
tremendously useful on a local network. "Where are my printers?"

Many core multicast protocols use CS6 to indicate they are important
(certainly more important than upnp), and should be scheduled for a
multicast transmission sooner than non-marked packets. On the other
hand, I am a big fan of fq, which basically will spread the sparser
packets around fairly optimally in most cases, and I tend to favor not
doing anything special with CS6 on multicast at the present time, but to
work on keeping the size of the multicast queue more under control.

(I have also worked on a means to make rtt-fairness actually work in
routing protocols that are partially based on multicast, and factoring
in fq's effects on routing packet updates is part of it.)

Still...

There is a lot more that can be done to reduce the impact of multicast
on wifi, particularly with upnp and mdns requests (which tend towards
large), notably not treating multicast hw queue as a single long FIFO
queue but also fq scheduling appropriately across multiple TXOP
intervals. Keeping the hw multicast queue as short as possible will let
higher priority packets into it faster, and make for easier accounting
from a aqm perspective if the multicast bursts are smaller.

I have seen it take minutes for a busy network to handle a dhcp request,
for example.

Not enough people have test tools that expose just how bad multicast on
wifi can get, but in response to the observed problem, the industry has
largely deployed in dense environments crippled versions of wifi that
disable, or nearly disable, nearly every useful multicast protocol,
using things like AP isolation, and so on.

Linux wifi bridges typically suppress SNAP packets entirely (other
manufacturers don't), there are arp enhancements, nd enhancements, means
of turning mdns into regular dns, and so on.

We can do better multicast in wifi, certainly.

## Management Frames

And then... there's management frames. These are so important to the
basic functioning of wifi, and have such tight latency constraints, that
most chipsets have dedicated hardware queues for them. There are not a
lot of statistics generated, and not a lot of insight as to what's going
on there.

## Multicast, reachability, and routing protocols

... fix me....

## Towards a better multicast

In the long run somehow, we need variable rate wifi multicast to work
well in environments that support it.

There are multiple proposals for reliable multicast, turning multicast
into unicast, a different form of the frame, etc, and so on.

One "hack" I have hope for would be to have a given AP multicast at the
lowest known rate for all stations within reach, rather than the fixed
amount.


## Getting back to CS6

...
