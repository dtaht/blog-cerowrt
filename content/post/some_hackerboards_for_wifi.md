+++
date = "2016-04-24T22:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat" ]
title = "Some hackerboards for benchmarking networks"
description = "Cheaping out for the sake of science"
+++

The original CeroWrt effort was built on a 70 dollar piece of hardware.
Fixes for the whole Internet have been rolling out worldwide ever since.

CeroWrt, as a separate router distro - is currently dead - Bufferbloat project related fixes and improvements tend to go directly upstream  into several distros without us needing to build and distribute our own. This is a good thing -
because [adding fq_codel to wifi](/post/fq_codel_ath10k)- has taken 2+ years of design and architectural work to
even conceptualize,  and work on that has got to take place on higher end
systems that are easier to debug.

It's not every day you can make such a difference on a low budget.

Still, that doesn't stop me from being cheap, wherever I can, and I hope
if I thoroughly document how to build a cheap networking lab, that others
will follow, and help explore interesting problems in wired, wireless, and
home routing and network naming services.

So - this is about the 7th lab I've designed in 5 years - this time:

I'd like to be testing the latest outputs of the homenet working group,
babeld - basically functionality that the cerowrt project enabled that
also required some host support, dncp, and the mdns-proxy.

A secondary goal is to get on top of the latest generation of hardware
and make sure our requirements - debloating, wifi, kernel support for
IPV6_SUBTREES, and other features are all in there - and "just work" by
default.

(I could really use a "helper" for this sort of stuff, bringing up new
gear is a matter of reading a lot of web pages and fiddling, and I'm at
the stage in life where I'd like stuff to "just work", but oh, well.)

Lastly, (and most importantly) I wanted a set of devices to drive various loads on the wifi/fq_codel testbed. What I used to use was old laptops or spare routers I had lying around, but given that I have severe power and space
constraints it seemed logical to investigate using the latest generation
of hackerboards - small arm based boxes like the rasberry pi - to see if
they were up to the job.

So I burned a couple hundred dollars on the latest batch, to see what
worked with minimal effort.

## Tested Hackerboards

I got into the hackerboard revolution early. Too early. My vision was to
have a set of small in-home boxes, for basic services (like email),
network measurement, NAS, and so on. In the first phase of the cerowrt
project... none ever made it out of the lab.

### Beaglebone Black

The beaglebone black was my first choice of hackerboard in 2012.

I chose it (over the raspberry pi) as it seemed, well, heftier, better designed, without
parts that stuck out and broke, and capable of handling 100Mbit in
both directions because the ethernet was hooked up directly to the
system bus, rather than through USB.

I did the port of BQL to it, and [it behaved really well](http://snapon.lab.bufferbloat.net/~d/beagle_bql/bql_makes_a_difference.png). However I was
perpetually rebooting them, after a few days, or weeks, or months.

I had a few cases where the SD card fried completely, also. 

Kernel development on that platform has continued, so I figured that
by now they'd become stable, and I'd become cautious enough about getting
genuine SD cards out of amazon to maybe get something that lasted.

But, foolishly, this time, I thought I'd try minix on it.

I flashed a card, it failed to boot,
and I moved onto other problems. It still seems like a viable board
to be using, but it wasn't as sexy as the new stuff.

I still think bringing up minix would be *cool*. And the estimate
I did of [how many hours it would take to add BQL to everything](https://lists.bufferbloat.net/pipermail/bloat/2014-June/001980.html), still
holds. It would not take that much to make the world that much less latent.

Sadly the number of BQL enabled drivers in the linux kernel remains 
a slight proportion of the ones that could be done.

### can't even remember the name.

I was totally unable to figure out the flasher enough to flash something
on it. Maybe it works, maybe it doesn't. It was the most expensive of
the boards I wanted to try and had a nice cpu on it... it's in a box somewhere...

### Raspberry Pis

The Pi is simply the best known hackerboard, the board that defined a catagory,
the board that showed the world there was more to computing than shiny 
tablets, and I love what it's done to get more hands in there, with soldering
irons, to go and "make" stuff. That said, I haven't had time to fiddle with
a single GPIO, yet, on one, I merely want to make the network stack the
best in the world, and have more early adoptors using that, and wondering
why their main OS didn't perform as well.

#### Pi1

I had a terrible experience with the rasberry pi 1s - they were flaky, 
and slow, and in two cases the device fell off a shelf, breaking the SD card
slot. I am grateful to the pi's existence, however - it in particular made
armhf (hard float) a viable concept across all of linux. Having spent years working on arms with soft floating point, and being frustrated at the inefficiencies of the EABI (a better soft floating point) - hard float was a major step forward, that was rapidly adopted across the arm-using industry.

You don't need floating point, until you *need* it. That said, I no longer
use any pi's in my testbed, I broke too many of the sd card slots.

#### Pi2

The pi2 was *much better*, with no parts sticking out, good thermals, and
an overall reliability and user support unmmatched by any of the other 
hacker boards. It's still got lousy ethernet, fed through a usb port,
but it is enough to almost drive 100Mbit ethernet at a decent rate.

The video support is the best of all the hackerboards I've tested though,
and my pi2 does double duty as a video/audio server that I'm loathe to give up
to use in a testbed scenario.

#### Pi3

The pi3 is a pretty exciting harbringer of things to come - integral wifi,
and 64 bits. What could go wrong? Well, the 64 bit support is not quite done
yet, and the onboard wifi sucks. It is getting better rapidly, though.

### Odroid C1

This is stuck running kernel 3.10, which is just 1 kernel too old for
my purposes. I might try it as a sound machine or for something else,
but every time I turned around there was a kernel feature missing,
so it just sits there and glows.

### Odroid C2

This is, by far, the fastest hackerboard I've tried on every
benchmark. It can drive GigE (with offloads). It is 64 bit. It runs
full blown ubuntu. There is a lot to like about this board, except the
kernel. The video and sound support currently sucks also.

### Banana Pi Pro

It has the advantage of having a sata port, which is something I thought
I'd be able to use to fit some serious storage on. Regrettably it seems
nobody makes a case that fits the banana pi pro with a sata drive in it,
the kernel was ancient, and sorting out what to boot from was an issue.

Haven't booted this up yet. 

### Intel Galieo gen2

I don't know what Intel is thinking. Not only does their hackerboard
cost twice as much as everything else, there is nearly no aftermarket
established - you can't easily get a case, for example, the software
infrastructure is built around yocto which nobody seems to use, and
it's totally unclear how to use it in many ways. 

About the only major advantage to the architecture is that there is a
mini-pcie card, which happened to be something I need. The board sits
idle awaiting a case and time for me to hack on it, and learn enough
about yocto to do something useful with it.

I wish there was, at least, some debian support for it.

## Random Thoughts

Looking at the plethora of power supplies on the power strip, I can't help
but want some sort of USB based power strip with remote power control to
control them. Kind of like a digiloggers. I'd save 6 bucks on power
supplies AND get something I could control remotely to reboot stuff
with.

Issues along the way included: IPV6_SUBTREES was not in most of the kernels -
but filing a few bug reports got the rpi2, rpi3, and odroid C2 fixed. A responsive community is very helpful for any given hackerboard.

## Summary

My own goal was quite different from others: I wanted to be
able to drive a network fast, and be able to experiment with routing
protocols, fair queuing and aqm algorithms, and do it on the cheap, while using
minimal power and space. 

Where I setting a different goal - say audio or video support - the
rpis would win hands down over the odroids. But who knows what will happen
in the coming year? It's entirely possible the C2 will evolve into a
machine with good enough video and sound to compete with the rpi3,
and the GigE and emmc capability really sets C2 in a class by itself.

But at least at the moment, the rpi is far ahead on kernel support (4.4 vs 3.14), which also means far more aftermarket gear works with it.

I still don't have enough trust in booting off of flash cards to want
to give any hackerboard any but basic duties - nothing mission critical, like mail
servers, and for dns I rely on a proven openwrt server....

I do daydream of turning one into a cnews server - that ought to sort out
the flash card problem quick! 

So I've settled on using C2s and RPI3s as some of the test drivers 
in the network, and gone looking for higher end devices also.

That gets me to dealing with:

## The wifi problem. - onboard and usb

The next generation of nearly everything will have integrated wifi on
board, and the wifi stick market will slowly start to die. I *fear* that
that integrated wifi will suck, will have proprietary components (much
like how cell's baseband processors have evolved) and be unfixable. Thus
getting in "early" on the next generation fully integrated chips 
seems like a good idea, and also exploring what the current generation of
wifi sticks was like, also a good idea.

Thx to the wonders of amazon it's actually possible to go shopping for
wifi sticks that explicitly say they support Linux, which is a timesaver.

But the exercise of getting sticks that worked... will have to wait for
another article, tenatively entitled [why wifi sticks suck](/post/wifi_sticks_suck).

In the end, given how horrible those usb sticks were, I decided to explore
higher end devices instead, which is what led me to [prototyping a nextgen wifi router](/post/prototyping_a_nextgen_wifi_router).
