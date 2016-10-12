+++
date = "2016-04-07T16:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "papers" ]
title = "Analyzing EDCA"
description = "APs should be dynamically adjusting the edca parameters"
+++

I've been trying to comprehensively write down my understanding of how
the 802.11e queues work today - and should work - for a very long time now.
It's a big elephant.

But from reading the EDCA related sections of the 802.11n-2012 standard,
it's clear, Linux is doing it wrong.

EDCA setters should be dynamically setting parameters based on the workload,
tightening up some as more stations join, loosening others, responding
to bugs in the detected stations, and so on.

