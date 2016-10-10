+++
date = "2016-05-07T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k", "osx" ]
title = "OSX keeps winning, darn it"
description = "Is OSX cheating?"
+++

I've got odd results from my OSX mavericks machine over wifi, and I
was encouraged to upgrade to the latest OSX. Which I finally did last
week. Still, they are odd, compared to the linux tests i run. Do they
have better radios? yep! Better driver? Possibly - Apple must have a
1000 people dedicated to making their wireless stuff work. Cheating?
No.... Apple wouldn't *cheat*... would they?

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

An internal optimization for acks over data? But that doesn't explain why
an ath9k laptop gets so outcompeted by the ath10k osx box?

Are they transmitting at a higher rate more often? Could be. Better antennas
and better DSPs count for a lot - 802.11ac cards regularly achieve one step
better MCS rate than a 802.11n does on the same link.

Boy, I could use more tools for parsing aircaps.

Side note:

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
rely on the "bssid", more. The only FQCODELROCKS SSID here was a
station configured as a client.
