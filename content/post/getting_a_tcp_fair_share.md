+++
date = "2016-04-07T16:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "papers" ]
title = "Getting a fair share at various RTTs"
description = ""
+++

{{< figure src="10mbits" >}}

The plank length of the various flows is so large that fq + AQM will always
force the longer RTT flow to have less priority than the main flows.

However.

The difference between FQ wth AQM  essentially vanishes at higher speeds,
the sawtooth is preserved and the two sets of flows in this test do
exchange sides and share the bandwidth equally.

{{< figure src="100mbits" >}}

