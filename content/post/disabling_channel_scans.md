+++
date = "2016-05-13T12:02:58+01:00"
draft = false
tags = [ "lab", "wifi", "bufferbloat", "ath9k", "rant" ]
title = "Wifi Channel scans suck!"
description = "Network Manager messes up wifi more than needed"
+++

How would you like it, if, every 2 minutes, someone interrupted you
or stopped paying attention to you, for 5 seconds, or more?

The datasets I have for ath9k performance have been polluted by a
channel scan every two minutes for
[every test I've run to date](/tags/wifi), an interruption in
connectivity with aftereffects that last for *seconds*.

{{< figure src="/flent/channel_scan/channelscan.svg" title="Channel Scans suck">}}

UPDATE: This blog post kicked off a long G+ threaded discussion. [PLEASE Go there for more detail](https://plus.google.com/u/0/107942175615993706558/posts/WA915Pt4SRN).

Naturally...

I want things like bar charts and cdfs, and other forms of total
measurements that are repeatable, and are consistent and make sense over
any interval... over months of testing...

... and I'm running tests that only last for 1 minute - so sometimes I
see the scan killing throughput and latency for 6 or more seconds,
sometimes I don't, and it
[always happens at an inconvenient time](/post/anomolies_thus_far) on
more complex tests. It also does interesting things to relative
throughput and latency when comparing OSX (ath10k) to stock Linux ath9k, for example:

{{< figure src="/flent/channel_scan/osxvslinux.svg" title="OSX (.11) vs Linux (.12)" >}}

as OSX doesn't scan on this interval. Linux network manager does, for no
good reason I can discern. I thought also, briefly, that the problem
might have been bluetooth co-existence... but no, the problem was
definately the channel scan.

(for the record, you can turn bluetooth OFF with "hci config off")

The easiest fix: [stopping, not killing, network manager after a connect](http://ubuntuforums.org/showthread.php?t=2163994) finally got me to a result that worked...

{{< figure src="/flent/channel_scan/starved_tcps.svg" >}}

... *for 300 out of the 600 seconds* I'd configured for this test. The device lost it's IP address for no reason I can think of and dropped off the network. I gave it a static address... and checked to make sure [powersave was off](/post/poking_at_powersave), and resumed testing in a few minutes - and then it dropped
off again, but not before I got a *lovely* result from the fully
[fq_codeled at the wifi layer AP in place](/tags/ath10k) at T+120 - T+140.

{{< figure src="/flent/channel_scan/kickass_fq_codel_on_the_ap.svg" title="codel holding latency flat in a rate change">}}

This is beautiful, this is exciting, this is seeing a 40% real world (as
opposed to simulated) wifi rate change, tcp (with these short queues)
responding quickly and grabbing all the new bandwidth, and fq_codel then
smoothly adjusting TCP's rate and latency when it went back to the old rate.

My first guess with the second loss of connectivity was that
[the problems in the 802.11e QoS queues run deep](/post/cs5_lockout), which dhcp uses by default, sadly enough. And that the periodic channel scan
we were doing before, reset the ath9k driver enough to keep it alive.

No: NetworkManager came back from the grave and messed things up again.

I kind of regard stopping NetworkManager, going with a static ip address, disabling powersave and only being able to test for 5 minutes as a drastic non-solution. I would certainly like to ensure that the device under test [re-associate when it loses association](/posts/10.1firmware), in particular.

How to to tell NetworkManager to stop with the !@#@!@ scanning already? Is it that that does it or wpa_supplicant? (I'll try that next).

It totally makes sense to scan when the connection is going bad, but not like this.

I can't possibly be the only person that has these problems with Linux wifi, can I? Does nobody test devices for 10 minutes or more or use it to make a phone call?

## Update:

[Nope, this insane scanning behavior is commonly reported bug](https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/373680). It's totally nuts to scan for a new channel unless your current channel is going bad... Aggh... While
it is explained on that bug report that this behavior is necessary for roaming to work... I'm not roaming, I'm never going to move off the channel for as
long as I have power!

...

Moving on, after sort of fixing this problem, we still get an interesting result -

{{< figure src="/flent/channel_scan/starved_tcps.svg" >}}

The overall fairness found by the tcp flows is totally out of wack. They
never converge for 10s of seconds. This actually looks a bit similar to
the [cs5 lockout](/post/cs5_lockout) problem....

Why is this? Well, the qdisc used on the baseline stock ath9k driver
under test was pfifo_fast. Would adding fq_codel to the mix take the
edge off it, or is this still a relic of the channel scan?

I ran out of time to pursue this further today.

Flent test results are (mostly) [here](/flent/channel_scan).

Have I mentioned how
[massively better than stock behavior](/post/stock_behavior) this is
already? That link still being broken... is because writing up the stock wifi driver
behaviors was too depressing.
