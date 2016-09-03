+++
date = "2016-09-01T16:02:58+01:00"
draft = false
tags = [ "vpns", "bufferbloat", "fq_codel" ]
title = "Adding fq_codel capability to VPNs"
description = "VPNs tend to bottleneck on the crypto step"
+++

I took a timeout to go play with a new VPN implementation, [Wireguard](http://wireguard.io), last week. VPNs have two issues with fq_codel. One is - internally - they tend to bottleneck on the crypto step, so that packets can go in, much faster than they can come out. Nearly all vpn implementations have this problem -
that once you are out of CPU, bad things happen to the network flows.
They get bufferbloated *inside* the vpn code.

The other big problem (which I'll cover in [Part 3](/post/wireguard_plus_fq))
is that encapsulating many flows into a single one does not interact as
well with fq_codel elsewhere on the path as I'd like. But let me skip that one, and focus on the internal bottlenecks of several vpns and how to fix them.

## IPsec is awful
I gave up on IPsec long ago. It's WAY too hard to configure; way too finicky
to deploy in practice - it's a good way for vendors to make money selling
specialized hardware and keep system administrators employed.

## OpenVPN is easier

OpenVPN is the goto simple vpn for most people, and I do use that for a
few sites. It's in userspace, which has quite a few advantages and disadvantages. It runs on everything - which is a huge advantage. It can use udp or tcp.
It's vastly easier to configure and maintain than IPsec, and it's easy
on NATs. It's also slow - because it runs in userspace and doesn't do anything
sane with its read buffer or crypto buffers.

## Tinc is more flexible

Elsewhere in my worldwide network, I use [tinc](http://tinc-vpn.org) a lot. Tinc has been around a *long* time, so long, it actually has an official port number below 1024, and it has a ton of features I like - it's meshy (so any site can talk to any other site), it can run over any transport(ipv6,ipv4,udp,tcp), it can hole-punch, it's
self-healing, etc, etc. IF you tunnel raw IP you can run a routing protocol
like babel over it... It, like openvpn, is also in userspace with the corresponding advantages and disadvantages.

(Tinc's meshy-ness means the "fq" portion of fq_codel works better,
in that I can be on 20 sites and have each fully congestion controlled, but
I'll get to that elsewhere)

Tinc 1.1 - which tries to make things simpler, has also been in development
a long time. A year (or two?) back, I'd taken a stab at making it do
ecn, and queuing better, and gave up.  Dealing with the characteristics of the "tun" device is a PITA; the overriding suggestion is to re-write tun, I ran away screaming. Certainly if I took a few days at it, I could add ecn encapsulation and make a stab at threading the read path, and then writing a userspace fq_codel implementation might take me a week or three. (famous last words - I'd wanted to have a generalized C based fq_codel library for a long time now, and the design effort to get that even mildly right
is probably longer than that. [sendmmsg](http://man7.org/linux/man-pages/man2/sendmmsg.2.html) anyone? Have you ever seen the userspace APIs for [cmsg](http://linux.die.net/man/3/cmsg) and [IP header info](https://www.ietf.org/rfc/rfc2292.txt)? YUCK. The linux in-kernel facilities are much nicer) 

## And wireguard has much potential

Last week, I encountered [Wireguard](https://wireguard.io), via review
by Greg Kroah-Hartman - and, um....

Ooh! shiny! A minimalistic (4000 line) in-linux-kernel VPN design that took advantage of many already well-tested kernel facilities, that used modern cryptography, and bypassed a whole lot of basically broken ideas in IPsec and most
(maybe all) other VPN designs. It runs over udp, it's "silent" when 
approached by aliens, it's easy to setup, and it's not quite tinc, but could be
made more like it - and is promoted as faster than ipsec....

Also:

In a day, the author (while on a plane!) tossed off an ecn encapsulation
implementation (it worked! but it's not currently as modern RFC compliant as it should be), and we exchanged a flurry of emails where I was already at maximum
cognitive load [on other stuff](/tags/ath9k). Wow, he knows his
stuff in depth. He found kernel facilities I didn't even know existed!

OK. I'm in love. Something new and shiny, that's not wifi, but could take
advantage of the structures we just developed for [fq_codel on wifi](/tags/ath9k) to make
for a better VPN than any that ever existed before. 

Naturally I got it setup and compiled and had some teething issues, got those
sorted, (it 'just worked' on arm and x86! over both ipv4 and ivp6 transports! yay!)... and then I pounded it flat with a [flent](https://flent.org) rrul
test.

{{<figure src="/data/wireguard/whatIwasexpecting.png" >}}

See that latency spike?

Ugh. We're talking 5 minutes after I got it setup, I blew wireguard up,
with rrul. It's a damn nasty test, I wish everybody ran it by default on everything. Doing the rrul well is the pentultimate test of whether network hardware
and software is any good or not.

It was kind of unexpected to get a spike like that so quick
while operating at such a low bandwidth, (I'd expected it to bottleneck
on the path long before it did, but this test is repeatable) and after a few exchanges with Jason I'd figured out why it was happening. It is a classic "coupled
queuing" problem..

Almost any vpn will bottleneck on packets per second (PPS) if you feed it a lot of small packets (e.g. TCP acks). All of Jason's tests tended towards being focused on one way throughput, not bidirectional, so where he claims the code can do a gbit, he's only measuring big fat tcp flows, where rrul stresses things out
with acks and measurement flows in the reverse direction. Once we hit a threshold where
packets were going into wireguard faster than coming out, it started accrueing packets (wireguard has a default 1000 packet buffer internally), TCP cubic started inflating
its estimate of the RTT of the path faster than the fq_codel implementation on the wire could compensate, and in the end it took over 30 seconds for enough
drops to happen for things to settle down to the base latency of the path. 

Now - you can say TCP cubic is the problem here (and it is), or you could
say the vpn is the problem  here (and it is), or that an AQM  should adjust well to lots of small packets in the path (none do) or the test itself is too
nasty (and it is), but any way you slice it, it's lousy behavior for any
network to get that slow under any load.

There IS hope, however - given that the code base is so simple!

More [in part II](/post/wireguard_ii).

# Aside: Some wireguard negatives

Not having protocol agility built in makes me queasy. The protocol itself
has no way to select any crypto parameters at all, it seems, and I think
that doesn't look forward far enough. This can be finessed by adding a 
new message for some sort of extended negotiation facility.

It hasn't been audited yet, either.

Another downside is that I *hate* kernel programming, amd something that
is kernel only makes it hard to deploy in my cloud. 

All that said, wireguard looks eminently *fixable*, in it's current state.
And shiny!

