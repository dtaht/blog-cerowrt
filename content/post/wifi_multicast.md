+++
date = "2016-05-07T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "Looking at wifi multicast"
description = ""
+++

ooh! shiny!

Airtime fairness! Victory!

I've pointed elsewhere at how channel scans really muck with
performance also.

FIXME: Merge with managing_multicast

But I didn't believe it. So I delved into the raw data.

```

```

And a few exchanges with the current author, figured out that
multicast and beacons were being stripped from the default pie
chart. this is an ordinary, background level of multicast, for that
particular lab:

The real airtime plot, looked more like this:

## 

And despite being seriously tempted to add that into the mix, I've
deferred.  Life is hard enough testing what we got.

Filtering out what others consider as "noise" - and looking hard at
the sources.  multicast on wifi is a huge problem - made worse by ipv6
and tools people use in the real world that use upnp (kodi), mdns
(apple, printers)... and I'm really glad someone else is taking a stab
at improving matters there.  I worry about the side effects - most
mesh networking protocols rely upon multicast packet loss in order to
make decisions -

One of the things that is not in the airtime fairness patch is any
means of regulating multicast.

multicast over time, and things like using mdns, upnp, etc,
have a tendency to put a spike there. I'd much rather spread out
multicast use over time, and limit it to a tiny percentage of stuff
and prioritize what was sent - 
