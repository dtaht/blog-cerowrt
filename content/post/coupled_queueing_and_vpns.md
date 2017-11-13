+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Coupled queuing in VPNS"
description = ""
+++

{{< figure src="/flent/wireguard" >}}

*eventually*, drop on read
serialized

There's a reason why most hardware vendors include a PPS figure for small
and full size packets - it's a lot harder, without considering the impact
of the reverse traffic.

One of the huge (if only in potential) advantages of doing fair queuing more
universally is you can avoid the costs of a per packet destination lookup
if you have a flow

So if you have 15 packets queued up, with the same hash value on the 5 tuple...

and then just bottleneck on the crypto (in the vpn case)

PPS (packets per second) 

# Side notes
