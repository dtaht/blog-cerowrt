+++
date = "2016-12-12T16:02:58+01:00"
draft = false
tags = [ "bufferbloat", "tcp", "bbr" ]
title = "(not) Getting a fair share from 4 queues"
description = "Hardware queues can be a PITA"
+++

More and more hardware has hardware queues for the network interface.
Some (such as my apu2) have only 4. Hardware queues are "in there"
not to make the network better, but to make the cpu load more even,
but this tends to unevenly service any given load whenever there is a 
hash collision. The [birthday problem](https://en.wikipedia.org/wiki/Birthday_problem) is one reason why fq_codel has 1024 queues
by default, and the [cake qdisc](https://www.bufferbloat.net/projects/codel/wiki/CakeTechnical/) uses an 8 way set associative hash.

When you make a new qdisc the default in Linux via a sysctl, it will automatically
be attached to each of the "mq" devices' presented, and attached to each hardware queue, which re-introduces the birthday problem. Under
any given load, you end up with clear bands for how the randomness
works out. If you use the new pure "fq" qdisc, AND if you only have 4 hardware queues,
using cubic tcp, using 50 flows, this is really easy to see:

{{< figure src="/flent/birthday/birthday_problem_cubic.png" >}}

Under TCP BBR, however, the result was even more "interesting", as each
bbr instance is trying to find the right rate for the connection,
and if you start 50 of 'em, some flows get a good RTT and bandwidth
estimate, and some do not. You can still see the banding from the
birthday problem, however, it's obscured by some flows wildly exceeding their fair share.

{{< figure src="/flent/birthday/birthday_problem_bbr.png" >}}

NOTE: I need to go look at packet drop statistics under workloads
like these.
