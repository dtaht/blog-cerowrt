+++
date = "2016-09-08T10:02:58+01:00"
draft = true
tags = [ "babel", "lab", "routing", "wifi" ]
title = "Babel is still hard"
description = "Babel is still harder"
+++

Babeld is a distance vector routing protocol, which is a full
replacement for RIP, and something simpler than OSPFv2 and ISIS.

I'd made an early architectural decision to not use VLANS. VLANS
provide a useful abstraction that everybody else uses, but seeing
queue delay induced by some vlan you aren't monitoring is a PITA. This
somewhat dumb (everybody else uses vlans!) decision has driven a lot
of my desine and need for things like routing protocols.

VLAN's are also a security nightmare. 1 Misconfigured entrance,

1 Wire. A set of FQ'd flows. Layer 3 security only.

I'm really swimming uphill here. All the SDN researchers are filled
with folk who want to break things into the "control plane" and "data
plane".

## Why do I use babel?

A babel failure is easy to see, and that's often helpful (and also,
often annoying).

## Chatty protocol

Cut down on message traffic. Weirdly, I actually want more
message traffic - babel hasn't been tested to really huge scales and I
have a constant need to make sure multicast is actually working - as well as transfers of larger routing tables.

I want to make the same mistakes new users make, I want to see the
impact of multicast lost and routing changes on the whole network.

## Yurtlab gateway

## IPv4

exports a 172.22.0.0/16 route to the global network
imports a 172.20.0.0/14 route internally

Among other things, devices like 192.168.1.1 tend to appear and disappear frequently, and (sigh) there is a 192.168.1
network elsewhere that I should renumber, so... this blocks out this overlap.

## IPv6 is trickier

I use source specific routing throughout the campus, and random ULAs in many places,

Since ipv6 is in limited deployment, and traffic is low, I just let all that through. I probably shouldn't.

## Wifi makes for hell

But not always will choose the same BSSID. It is best to "lock" a given adhoc mesh to a fixed BSSID.
And the specific route tends to override the more general one.

So the lab uses BSSID X.Y.Z

## Transparent bridges

Most people bridge wifi and ethernet together.

## Anycast

Off and on, I've experimented with using anycast babel for replicated
servers, notably dns. It's a technique widely used on the global
internet and it would be a great boon on my frequently bifirbated
network to have a set of say - 10 dns servers - reachable from all
points, and to only have to announce (and configure) two ip addresses
for them all. I could lose a key machine and have it always be found.

## short RTT metrics

A now 4 years deferred research project of mine is to find a way to make a RTT metric work on short distances.

in conjuction with the fq_codel work (offering basically flat latency at all rates), is that rates stay pretty
flat no matter the load, *except*

|10Mbit|100Mbit|

somewhere between 1.4 and 14ms

Tends to be an all or nothing decision. Route switchover could be more gradual.

## Overall lessons learned

Once you start doing tricky things with babel, it's hard to stop. It's also pretty easy to mess things up.
There's a need for a book on babel, as for all I know it will become the
next great routing protocol.
