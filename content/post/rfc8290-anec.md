+++
date = "2018-02-15T12:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k", "ath10k", "cable", "dsl", "5g" ]
title = "You are going to like this!"
description = "Go forth and fix your fucking routers already!"
+++

Early evening, May 21th, 2012: The email arrived from Eric Dumazet:

"You are going to like this." The first fq_codel patch had arrived.

Excitedly - I ran it through the battery of tests we'd developed... By 4AM that morning, I knew we'd won. We'd fixed the internet. Bufferbloat was dead. He'd successfully combined every technique we'd come up with to solve every problem with network latency we'd hit. On his hammock. On a saturday afternoon.



Unlike who figured 


In the years since we've tried to fill in the blanks, 

Early on the prospect of deploying fq_codel on *everything* terrified me. It is one thing to - and I spent the first year looking for holes, looking for flaws, looking for reasons to not push for this technology on every router...

First up, I knew that we were going to completely obsolete the field of 
low priority congestion control (as 
https://iris.polito.it/retrieve/handle/11583/2647530/120034/tompecs_submitted_010415.pdf

even with tons of flows, worked better than the alternative FIFO or AQM
in 

Second

Even more radical group that wanted to change the definition of ECN.
