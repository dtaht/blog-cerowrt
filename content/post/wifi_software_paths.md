+++
date = "2016-05-07T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "Tracing the code paths for mac80211 and ath9k"
description = "in a maze of function calls full of locks"
author = "Toke Høiland-Jørgensen"
+++

Trying to understand how wifi really works on the wire is hard. Trying to understand how the network stack queues up stuff [is also hard](/tags/bufferbloat). Trying to understand how the code talks to the various forms of wifi hardware out there is *also* hard, and it's rare to find one person that understands how any two of these systems actually interact. And we need way, way, more people that
understand all three.

[Toke](https://blog.tohojo.dk/) has been diagramming the ath9k
driver's structure, in relation to and preparing for adapting the [fq_codel
for ath10k patches](/tags/ath10k). The mac80211 layer is a software abstraction
used for devices that offload mac processing to software...

{{< figure src="https://blog.tohojo.dk/media/mac80211-tx-push-4.4.svg" >}}

And the ath9k layer interoperates with it to a huge extent. 
{{< figure src="https://blog.tohojo.dk/media/ath9k-tx-push-4.4.svg" >}}
