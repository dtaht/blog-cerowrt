+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat"  ]
title = "Full Airtime Fairness"
description = "We *can* scale wifi to more stations"
+++

The fundamental unit of a wifi transaction is a TXOP - a transmission
opportunity. Getting one is arbitrated by a complex process based
(usually) on something called the EDCA scheduler.

Strict Round robin, although an enormous improvement over merely taking
packets in random order, still has problems.



Starve the beast

