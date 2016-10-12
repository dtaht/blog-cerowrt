+++
date = "2016-10-11T18:02:58+01:00"
draft = true
tags = [ "ath10k", "wifi", "bufferbloat", "bbr" ]
title = "BBR vs Wifi"
description = "E2E needs assistance"
+++

I had great hope that [BBR](/tag/bbr) would solve all my problems, and I could quit hacking on wifi, and go back to surfing every day. No such luck. I
set up a few tests on an overbuffered ath10k in the hope that BBR would
"just work", E2E, and we wouldn't need to continue modifying the drivers to 
do fair queuing and codel at the mac80211 layer. 

## BBR wins all the internets? Not. Darn it.

{{< figure src="/flent/airtime-c2/bbr_crushed_by_cubic.svg">}}

{{< figure src="/flent/airtime-c2/bbr_does_not_win_all_the_internets.svg" >}}

## BBR vs BBR

{{< figure src="/flent/airtime-c2/a_matter_of_luck_for_bbr.svg">}}

No such luck.

{{< figure src="/flent/airtime-c2/my_tests_break_bbrs_assumptions.svg" >}}

## Flaw in flent

All these BBRs start at almost exactly the same time. The first one
to "win" gets a good RTT estaimate

My test is NOT realistic. What happens if you stagger the start of all
the BBRs?

## Staggered start

FIXME, have graph for this
