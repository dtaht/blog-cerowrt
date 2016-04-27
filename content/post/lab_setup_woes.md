+++
date = "2016-04-27T11:02:58+01:00"
draft = false
tags = [ "lab" ]
title = "Lab Setup Woes"
description = "When things break before that first cup of coffee"
+++

This morning I woke up to no DNS service. On either gateway to the internet.
One router was not taking the root password it was taking the day before.
I could ping 8.8.8.8, but attempts to use that as name service didn't work
from anywhere in the network.

I had *zero* idea wtf was going on. I rebooted everything. The backup
router did not supply a route to itself via babel (although it has a ssh key
on it from the master server, I couldn't get to it without that route)

I rebooted everything again. I twiddled with dns everywhere. After an hour of fiddling... things started to work. 

Why did it go to hell in the first place? No freaking idea. In retrospect
I should have done a bit more diagnostics (maybe we had a power flicker
overnight that forced the backup router to it's old flash?) - but it was
pre-coffee, and I needed internet with that.

In poking around my configs...

* Bad idea - what if the ntp pool for openwrt goes down? Hmm.. I think 
I'll add [a local ntp stratum one server](http://esr.ibiblio.org/?p=7159).

I have dnssec universally enabled, that might have been a cause...

* I should probably prioritize using ipv6 dns over ipv4 - it saves on 
nat entries...

* And it's not clear how good the comcast ipv4 and ipv6 firewall is, I'll
have to poke into that. It won't be the first time someone successfully
or even semi-successfully hacked me...

In all the hassles I've had in getting the [new lab](/tags/lab) up, I've been slowly drafting a piece on [All up testing](/post/all_up_testing) that explains
my engineering and testing philosophy better... but briefly it boils down
to: you write the code, you test the code, you write (or follow) the RFC, you push the code upstream to as many places as matter, and then you sit
and you wait, to see if what you did actually made it into the new
products, correctly... you sit on the web and watch the early adopters create innovative ways to violate your assumptions - you revise the code and RFC... and then you pretend you are a new user and you test the hell out of them as they emerge out the productization pipeline to apply course corrections until it is *right*.

It is astonishing how fragile some ideas end up being.

It takes 5+ years for an innovation to reach consumer products, usually.

In the first round of the fq_codel work, we got lucky, it made it out in
under 2, but in our R&D phase we'd missed something entirely - all the
new products did GRO extensively and that messed up the codel algorithm slghtly... so we've worked on fixing that in [cake](http://www.bufferbloat.net/projects/codel/wiki/CakeTechnical). But fixing GRO - for the products already in the field - is hard to do without automated updates - which most don't have.

The GRO problem is not horrible, just not ideal - and I am still grumpy in that most that shipped fq_codel in real products never
bothered to test with the [free test tools we developed](https://flent.org) - or talked to the
original developers on it on our open mailing lists - they just assumed
everything worked, slapped a marketing label on the box - and shipped it.

The guy that developed the first waterbed was smart enough - and kind enough - to give one to the guy that invented it - Robert Heinlein - and I wish more IoT vendors would twig to the amount of free QA they'd get by letting someone in on their
new product - before it shipped - that had written some of the code for it.

As for what went wrong this morning? Well, I am testing all new gear, 
trunk code for openwrt, the latest babeld, and a mixture of kernels on
various platforms (pi2,pi3,c2,x86) ranging in age from days old to 4
years old. Damned if I know what went wrong! I'm just glad it recovered
and I can go back to fixing each known remaining problem, which
include the [linksys 1200ac misbehaving *badly* at GigE](/post/1200ac_gige_weirdness), the [ath10k doing
weird things in powersave](/post/poking_at_powersave), all the usb wifi
sticks behaving badly in general, and trying to get a stable lab configuration
that will let me consistently explore applying fq_codel to wifi.

I have no idea how normal people build working networks. But I break
these things because, well, someone has to sort the bugs out. I wish
it paid better. I wish I had an AI assistant for diagnostics.

My thanks to [my gf](https://www.instagram.com/om_lorna/) who was perfectly happy to let me sleep in this morning...  because she could still use the internet on her phone, over 3G. And she made a huge pot of coffee, because she knew I'd be grumpy without connectivity.
