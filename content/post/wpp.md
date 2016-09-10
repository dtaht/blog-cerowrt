+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "cake", "bufferbloat" ]
title = "The wost possible protocol"
description = "You want to attack a network?"
+++

What would be the worst possible protocol?
So I did.

It would only run over ipv6.
The dest addr would be an entire /64 subnet, only.
I'd use the 20 bit "flowid" field as an index into the IV.
I'd use an unknown protocol number - lets say, 242.
Heck, use up all the protocol numbers.

All packets would be fragments.
Use undefined protocol headers (notably one for timestamps). Use
a lot of headers.

The tos field would vary randomly, except that
It would use ecn, but invert the definition - all packets would
always be marked CE.

using a whole /64 would make the thing immune to fq efforts. the always-ce would bypass aqms on the path that depend on it, varying the destaddr randomly 
would blow up statefull firewalls, fiddling with tos would do other things...

## Making this saner

Use the 20 bit field as a flow identifier, as per spec. Put the crypto 
IV into the address field itself, via negotiating a spread spectrum-like
set of changes to the destaddr on initial connect.
