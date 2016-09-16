+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Random rescheduling"
description = "Achieving imperfect flow balance might help sometimes"
+++

Note to self: This was triggered by seeing a neat graph of four
flows going wildly out of balance for a while, syncing, and
getting worse, then converging. Then it sort of became a digression
into the problems too few queues introduce and then I started thinking
about aqms random behavior...

I can't find the original graph now..

{{< figure src="/flent/sprong.svg" title="Sprong!" >}}

Something happens at T+100 to mildly permute the flows, and the slight 
difference in rates ultimately causes one flow to suddenly get a 
big slice of more bandwidth and it takes seconds for the other flows to
recover.

DRR service packets in byte quanta. This can do weird things to acks, and
I've fiddled with the concept of ranomly rescheduling bursts of acks
to fall back to other things.

The effect is more pronounced on reno.

It sure is a pretty picture, though.

I am not sure if adding in this feature is important or not.
Flows not limited to 4

Is so small and so limited to 

and vastly better than any pure aqm system yet devised.

These queues are not there to provide quality of service, no, these
provide a form of load balancing to multiple processors servicing them,
and are basically doing a simple form of fair queuing to do so.

However, many devices have an insufficient number of hardware queues


Worse these queues (on a single cpu system) are serviced by a strictly prioritized interrupt controller.  irq 1 will allways get a bit more priority than
irq 2, which may be one cause of the discrepancy.

Or maybe not. It may well be the tx handlers are serviced by something like:

```
for( int i = 0 ; i < MAX_QUEUES; i++) {
	service_queue(i);
}
```

Which might be contributing to the birthday problem observed. It would
be interesting to try something like

```
int start = random() % MAX_QUEUES;

for( i = (start+1) % MAX_QUEUES ; i != start; i++ % MAX_QUEUES ) {
	service_queue(i);
}
```

The idea came back to me today after looking at the long periods of time
where tons of packets fit into very large (4ms) quanta in wifi aggregation.
Once you have a link acting like this, even with fq_codel pushing things to
the forground, the assymmetry of the ack path coule be leading to 
the long term unfairness shown here:

## fq-pie

The original version of "fq-pie" showed that if you explicitly and nearly
perfectly randomized the input, the output achieved results better than
the more typically bursty behavior of the flows themselves. I liked this
work, I'm sorry it died. There is a wide gap between the mathematics of
randomness, and fair queueing, and the actual real-world behavior of flows.
