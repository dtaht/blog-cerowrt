+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat"  ]
title = "Doing diversity routing more right"
description = "We *can* scale wifi to more stations"
+++

The babel routing daemon (and several others like olsr2) depend on diversity routing to find an optimal path (explicitly choosing a wifi radio that doesn't interfere)

This can provide the illusion of full duplex.

"Progress" in wifi is messing that up.

1) DFS detection requires that a radio automatically switch from a channel with radar on it, to one without. That's fine, but in a mesh network setup, it may be that only one radio detects a sweep (or mis-detects one), and moves off.

Moving to a new channel needs to be fully co-ordinated in order for the
network to stay up.

There's a related problem - what's the "Best" channel for a radio to be on?

The radios it is talking to, obviously, all need to be on the same channel

2) The Linux API for getting channel setup information is deprecated

3) Newer standards, like 802.11n and

4) 
