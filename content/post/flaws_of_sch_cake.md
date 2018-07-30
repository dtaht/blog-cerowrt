+++
date = "2018-07-25T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "flent", "rants" ]
title = "Running sch_cake at line rate"
description = "Let packets be packets!"
+++

# Cake and local ecn

5ms of local buffering. 
The codel AQM 

we drop the AQM marking interval by half, for example, as the link goes
less idle.

syn/ack's are not protected via ECN. 

one piece of future work is that we could improve the 
drop behavior in linux for when a syn/ack is dropped, locally,
it tears down the stack.

syn floods are very real

Maybe we need more queues. Maybe 1024 queues is enough. 

What happens? The self-inflicted rtt grows and grows until some other
system limit is hit.

trigger doing something else

classifying traffic as reactive/non-reactive

cap cwnd

reduce the iw


