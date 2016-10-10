+++
date = "2016-10-10T19:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath9k", "osx" ]
title = "OSX keeps winning, darn it..."
description = "Is OSX cheating?"
+++

I've got odd results from my OSX mavericks machine over wifi, and I
was encouraged to upgrade to the latest OSX, which I finally did last
week. Still, the results are odd, compared to the Linux tests I
run. Do they have better radios? Yep! Better driver? Possibly - Apple
must have a 1000 people dedicated to making their wireless stuff
work. Cheating?  No.... Apple wouldn't *cheat*... would they?

But how do you explain this?

{{< figure src="/flent/mcs/osx_unfairness.svg" >}}

The .10 address is the osx box, .11 is a lede AP configured to be a
client. In this case I'm testing *down* from each device through the
AP, and OSX is killing the other box in terms of achieved throughput.

One of my first thoughts was suspecting they were grabbing airtime at
a better QoS service level. eBDP suggested doing this - and it makes
sense if the volume of your higher priority traffic is lower than the
bigger traffic.

Comcast, essentially does this - a lot of their traffic is marked CS1
downstream allowing the upstream going out to have a BE marking.

So I took apart some osx based aircaps deeply and... didn't find anything
like that.

Stretch acks? I don't really have a tool that can show that easily - though
you can pick out when apple's TCP switches to it.

An internal optimization for acks over data? But that doesn't explain
why the lede ath10k AP gets so outcompeted by the ath10k osx box? Are
they transmitting at a higher rate more often? Could be. Better
antennas and better DSPs count for a lot - 802.11ac cards regularly
achieve one step better MCS rate than a 802.11n does on the same link.

This much better? Not possible. Could it be the softirq stuff that I'm
not testing yet, for lede? Something else?

Boy, I could use more tools for parsing aircaps. At least, even with
the vastly slower rate - the fq_codel code has lower latency than osx:

{{< figure src="/flent/mcs/osx_vs_linux_fairness.svg" >}}

And with fq_codel and airtime fairness enabled, we get a really good result for *up* from the AP.

{{< figure src="/flent/mcs/osx_airtime_fair_down.svg" >}}

That result is *so good* that I don't believe it either, I've got another
post [coming up](/post/mcs_rates) poking into it. Still:

{{< figure src="/flent/mcs/idliketobelieveit.svg" title="I'd love to believe this">}}

... but what's with the !@#@! down result???
 
## Side note:

From looking at the captures, that I had a premonition that I wasn't
always testing the right AP. I was. :whew:

````
pdsh -g routers cat /etc/config/wireless | grep ssid

        option ssid     ATH10kTEST
	option ssid     babel
        option bssid '7E:4D:0A:42:D7:B0'
	option ssid     babel
        option bssid '7E:4D:0A:42:D7:B0'
	option ssid     FQCODELROCKS
        option ssid     babel
        option bssid '7E:4D:0A:42:D7:B0'
	option ssid     babel
        option bssid '7E:4D:0A:42:D7:B0'
	option ssid     babel
        option bssid '7E:4D:0A:42:D7:B0'
	option ssid     babel
        option bssid '7E:4D:0A:42:D7:B0'
````

pdsh gives me enormous powers and I use it throughout the lab to give
me parallel, consistent results. One "feature" of the meshy routing
protocols is that they predate the notion of a "ssid", and instead
rely on the "bssid", more. The only FQCODELROCKS SSID here was that
lede AP configured as a client, on the as-yet-unmodified ath10k driver.
