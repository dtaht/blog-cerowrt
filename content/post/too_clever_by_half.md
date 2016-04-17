+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "rants" ]
title = "Too clever by half"
description = "Sometimes it's turtles all the way down"
+++

My gf wanted to watch netfix, but the netflix box said the network
wasn't working. I got on the network, it worked. I rebooted her box. No dice.

odroid c1, c2, pi2, pi3, and an x86 box

Then babel started crashing

I have most of the boxes on that side on the network on one big switch
so I just slammed it off.

Babel crashed some more.

When you reboot that particular comcast gateway, it starts handing out
a new ipv6 address range, usually a /64.

Sometimes it doesn't even get a /60, and either you wait (for days) or reboot again.

## the aftermath

It turned out that the box was handing out a fdXX ULA address, but dnsmasq needed to be restarted to hand out dhcp.

AFTER all that, I didn't have much interest in watching a movie anymore.
