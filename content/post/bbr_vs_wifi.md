+++
date = "2016-10-11T18:02:58+01:00"
draft = true
tags = [ "ath9k", "wifi", "bufferbloat", "bbr" ]
title = "BBR vs Wifi"
description = ""
+++

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


