+++
date = "2016-05-07T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "Firewalls have tons of overhead"
description = "Stateful firewalls suck, and slow systems suck harder"
+++

I have a comcast modem configured for the absolute maximum throughput you can get - 236Mbits down, 33Mbits up.

I don't get that. I don't even get half that. I don't know why.

Before:
50% idle

So I said to heck with that...

ip6tables -F

97% idle

And Ilost connectivity

iptables -P FORWARD ACCEPT

50%


