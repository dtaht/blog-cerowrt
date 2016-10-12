+++
date = "2016-05-05T10:02:58+01:00"
draft = true
tags = [ "wifi", "ath9k" ]
title = "The ath9k (and probably softmac) VI queue is broken"
description = "And has been, for all eternity"
results = "cs5"
+++

[cs5_lockout](cs5_lockout)

I've pointed to this many times before, but until recently lacked
the time and tools to poke into it more deeply. As fallout from the 
fqcrypto bug, we ended up taking a lot of aircaps, and exercising
the basic rrul test got to me. And while looking at those, something
clicked.

What's the principal difference between these queues?

cwnd
minstrel_get_rate *ignores this*, and always returns a 
This of course, works, so long as you only are touching that queue
once in a while.

a nice, contained problem.

classes_compared.svg  cs1_cs6_ok.png  cs1_cs6_ok.svg  vi_sucks_on_downsvg.png  vi_sucks_on_up.svg



