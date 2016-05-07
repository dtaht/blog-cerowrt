+++
date = "2016-05-05T23:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "boards" ]
title = "IoT wifi on the 'C.H.I.P.'"
description = "Wifi on absolutely everything, even stuff that costs 9 bucks"
+++

A guy from the [C.H.I.P](http://getchip.com) 9 dollar computer effort
stopped in at archive.org's weekly lunch last week to spread around a
few of their boards, and gave me two to play with.

These are *amazing*. A full install of debian that "just works" on
something no bigger than two of my fingers. A few minutes of effort and
I 'd booted both right into an environment I was comfortable with.

With a bit more effort, I started powering them from the other bigger
devices I have sprinkled around the lab, and got rid of the usb serial
"gadget" interface and substituted g_ether in /etc/modules
[as per the instructions](/fixme). (I am still going through hell with
systemd on the boxes I plugged it into wanting to rename the usb
interfaces on other products all the time), but the usb networking is
wonderful, this is marvelous - there's a back way in if I turn off the
wifi or usb, and I can transfer stuff at 90+Mbits over the usb
networking portion of the stack, route stuff via babel, etc.

It's a usb to wifi *router* or test endpoint I can sprinkle anywhere I
need one. For 9 bucks + shipping.

I have to add this to
[hackerboards for wifi](/post/hackerboards_for_wifi) page.

Flaw #1: They are not quite shipping yet.

Flaw #2: The wifi chip is 2.4 ghz only. While I'm cool with that, I
looked with fear on the size of the antenna on the thing. Come on - you
have a device that uses wifi almost exclusively with a 4mm (?) antenna on
the board? That's *nuts*.

Or so I thought. It turned out it got [pretty good performance with that antenna](/flent/chip).

Still, in a world with an ever increasing number of devices in it, I'd
like good antennas everywhere, and a good wifi stack, everywhere,
minimizing transmit times and power.

Admittedly, the kind of
[wifi performance testing and latency reduction work I'm doing](/tags/bufferbloat)
tends towards not mapping well to all the world of IoT - the performance
problems are somewhat mitigated by their use cases - a lightbulb on wifi
is typically not going to be sending tons of data
[unless it's taken over by a spammer](https://mjg59.dreamwidth.org/40397.html)!

But: Other IoT use cases - like flying a drone with a wifi camera on
it - or using a [petcam](/fixme) could be far more demanding.

The test results of the chip's wifi are *remarkably good*. With one
located about 15 feet from the AP...

## Tuned for 20Mbits?

{{< figure src="/flent/chip/mindblowingly_good_unexplainable_result.svg"  title="mindblowinglyg good unexplainable result">}}

{{< figure src="/flent/chip/irreproducable.svg"  title="mindblowingly good unexplainable result">}}

The only thing I can think of is that the driver on the chip is tuned to
give a good result at 20Mbits, only, and nobody has tried to push it
far, far faster than that.

I am extremely tempted to sink some time into improving the realtek this chip as sprinkling a
dozen around the [SFlab](/tags/sflab) won't break my budget. Unfortunately the kernel for
it lacks tc and [IPV6_SUBTREES support](/fixme), presently. (I'd rather skip tc
and just move the fq_codel layer into mac80211) They have a lot of
market motivation to make their wifi the best possible within their
constraints, so I hope to lure some folk in over there to make it so.

I'd like to take a bit of timeout to get the rest of the homenet stack
working on debian in general. What I did instead was assign a static
ipv6 IP to the local network interface and let babeld figure it out.

It turns out that I could compile on a pi2 and the binaries "jsut
worked" on the - so that saves me on qemu.

The chip has an absolute surplus of computing power, and applying a
little of that to make for better wifi seems like a good idea. Nearly
all of the wifi products targeted at IoT could use the best wifi stack
possible.
