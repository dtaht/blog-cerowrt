+++
date = "2016-03-28T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Testing the apu2"
description = "USB sticks generally suck"
+++

And in most cases, the primary struggle is to *get something that doesn't crash*


On Fri, Apr 22, 2016 at 10:45 PM, Luis E. Garcia <luis@bitamins.net> wrote:
> How about FQ_CODEL?
> Does it eat up the CPU at the same rate when shaping?

Haven't got round to it yet. Shaping to a gigabit has not been a goal
for me generally, on this low end hardware - 400MBit - about double
the current max of what I can get from comcast, is. I HAVE noticed
that the hardware can kind of "hang" for an interactive ssh session
using the default mq + 4 pfifo_fast queues vs the flent rrul benchmark
at a gbit, which is a bit surprising.

Switching to mq + fq or mq + fq_codel fixed that in theory at line
rate... but in all cases the results were very odd... (see attached -
I think it's mostly the ac1200 acting up - I'll put a saner target up
for that benchmark soon). I will do more comprehensive benchmarks, but
those of you using it as a router might benefit from setting
/etc/sysctl.conf to have

net.core.default_qdisc=fq_codel
net.ipv4.tcp_ecn=1 # if so inclined
# I tend to also use notsentlowat

and

# Sometimes sysctl runs too late to get on by default you may need to try
# putting in a file /etc/network/iface.pre.up/debloat

#!/bin/sh

[ "$IFACE" != "lo" ] || exit 0

tc qdisc del dev $IFACE root
tc qdisc add dev $IFACE root fq_codel # ignore hw mq
# tc qdisc del dev $IFACE root # if you want to give mq + fq_codel a shot
# no I haven't tried integrating sqm with this yet
exit 0

Definitely it's a terrible idea to use pfifo_fast on a router.... am
concerned about no hpet timer...

...

I did manage to get one to take an ath10k card... I LOVED the honesty
in the relevant doc on it:

http://pcengines.ch/wle600vx.htm

"Software support Expect some pain, ath10k drivers required."

bricked another one (temporarily) somehow with a kernel update (does
this thing use grub?)

I am attempting to melt one by doing a kernel compile on it as I
write, but my older tree blew up with

include/linux/compiler-gcc.h:103:30: fatal error:
linux/compiler-gcc5.h: No such file or directory compilation
terminated

... and all the other joys of attempting a new platform. I should
probably not bore you with this but blog

...

I installed lm-sensors (I do worry about heat and could, for example,
overheat my last rangeley box easily on a compile) - not sure what
else can be done to govern power vs heat on this platform, I don't
know if this is measuring the right stuff...

# sensors
fam15h_power-pci-00c4
Adapter: PCI adapter
power1:           N/A  (crit =   6.00 W)

k10temp-pci-00c3
Adapter: PCI adapter
temp1:        +59.9°C  (high = +70.0°C)
                       (crit = +105.0°C, hyst = +104.0°C)

ath10k_hwmon-pci-0400
Adapter: PCI adapter
temp1:        +28.0°C


...
ath10k_hwmon-pci-0400
Adapter: PCI adapter
temp1:        +28.0°C


...

it is really nice to have 64GB of ssd to play with on a router....

...

I hate GRO. I am told a means to minimize GRO to be less aggressive
now exists in ethtool but I don't know how it works.

root@apu2:/etc/network/if-pre-up.d# tc -s qdisc show dev enp2s0
qdisc mq 0: root
 Sent 6967045633 bytes 5184378 pkt (dropped 0, overlimits 0 requeues 4586)
 backlog 0b 0p requeues 4586
qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514
target 5.0ms interval 100.0ms ecn
 Sent 4800232811 bytes 3476072 pkt (dropped 0, overlimits 0 requeues 2783)
 backlog 0b 0p requeues 2783
  maxpacket 68130 drop_overlimit 0 new_flow_count 3484 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc fq_codel 0: parent :2 limit 10240p flows 1024 quantum 1514
target 5.0ms interval 100.0ms ecn
 Sent 156902010 bytes 123018 pkt (dropped 0, overlimits 0 requeues 958)
 backlog 0b 0p requeues 958
  maxpacket 68130 drop_overlimit 0 new_flow_count 750 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc fq_codel 0: parent :3 limit 10240p flows 1024 quantum 1514
target 5.0ms interval 100.0ms ecn
 Sent 1994178739 bytes 1327804 pkt (dropped 0, overlimits 0 requeues 811)
 backlog 0b 0p requeues 811
  maxpacket 40878 drop_overlimit 0 new_flow_count 448 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc fq_codel 0: parent :4 limit 10240p flows 1024 quantum 1514
target 5.0ms interval 100.0ms ecn
 Sent 15732073 bytes 257484 pkt (dropped 0, overlimits 0 requeues 34)
 backlog 0b 0p requeues 34
  maxpacket 66 drop_overlimit 0 new_flow_count 23 ecn_mark 0
  new_flows_len 0 old_flows_len 0


A

	Link detected: yes
root@apu2:~# while :; do ifconfig enp3s0 | grep RX; sleep 10; done
          RX packets:627797573 errors:0 dropped:46 overruns:67783276 frame:0
          RX bytes:911858706021 (911.8 GB)  TX bytes:12787330446 (12.7 GB)



