+++
date = "2016-04-24T18:02:58+01:00"
draft = true
tags = [ "wifi", "ath10k" ]
title = "Too perfect connectivity costs"
description = ""
+++

60 second test, 296131 packets, 103 marks. Total rate 33mbits

This actually strikes me as low. Total induced latency of about 60ms
on what is essentially about a 2ms path, on the fq side, but the xplot
shows that the as-experienced by tcp latency closer to 100ms.

You can look at this two ways. 

1) This is about 20x less induced latency than we've seen on Linux wifi in years.
GREAT!

or

2) it's about 50x more induced latency than we need to hold the connection
up.

Adding fq into the mix confuses things in a couple ways.

"Sparse" tcp flows get a much lower RTT than ones that are backlogged,
 so they ramp up quicker (good), but can be fooled on the base RTT of the
 path.

In this test we are always giving quantum 300, so we are not messing 
with the tcp smoothing algorithm as much. 

stuffed.

[ath10k_ecn_capture](/captures/ath10k/fqwifi.cap.gz)

I'm actually not a huge fan of ecn, but when the lowest layer of the
stack refuses to ever drop packets, it may be the only way out.

The RTTs experienced on the network will be different.

tcptrace

While I use the flent tests a lot to create repeatable, complex tests,a

set up the lab to get something closer to what we want, which would be

and codel is set for a fixed target of 20ms (why? I chickened out),
rather than 5ms. In this scenario, we could easily cut it down to 10ms.


