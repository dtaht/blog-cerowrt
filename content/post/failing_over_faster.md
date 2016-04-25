+++
date = "2016-04-16T18:02:58+01:00"
draft = true
tags = [ "Fair queuing", "bufferbloat", "papers" ]
title = "Fair Queuing and queue depth"
description = "Fair queuing scales with sufficient multiplexing"
+++

This ended up being a deeply philosophical digression into routing behaviors that I think I'll have to blog about, with pictures, to fully describe.

What I want is a world of ubiquitous always-on connectivity[1] - where you can be at your desk with 20 connections nailed up, listening to an audio stream, doing a big upload or download - then pull your box out of the ethernet dock, go to wifi, move to another room, plug in again, and everything survive and take advantage of the better link after a few seconds.

8+ years ago, with ahcp and babel, and a network configured to use that with a single static ip address on both the ethernet and wifi, I could do that. My own networks were setup that way, anyway...

It was massively disconcerting to attempt to move back into the "regular" world where wifi and ethernet were treated as distinct, where taking an interface offline lost its address, where taking a new /64 was considered mandatory, and no host changes allowed, as part of homenet. I'd switch to how things were done "in the real world" - get up from my desk - despite having both the wifi and ethernet online at the same time - and all my connections would drop. Agh.... Sure, new protocols like mosh-multipath, quic, etc, recover from a move, but they don't...

that wasn't the case I was testing, I was testing multiple routes through the middle of the network, where I'd hope for better behavior while there is load.

So what I get currently from trying to do failover in the middle of the network right now, using the -l option and the supplied patch, is that usually the failover is not quite quick enough, and 1 or more connections fails like this: (using the flent rrul test here)

Program output:
  netperf: send_omni: recv_data failed: No route to host
  netperf: send_omni: recv_data failed: No route to host
  Interim result:   33.47 10^6bits/s over 0.200 seconds ending at 1461547666.713
  Interim result:   22.99 10^6bits/s over 0.201 seconds ending at 1461547666.914
  Interim result:

I've harped on a need for atomic updates, but I still think that a userspace routing daemon simply can't react fast enough to a change in an ethernet routing table to prevent no-route messages being sent to one or more flows on a busy link when it goes down.

So I got a mildly better result by installing a static backup link, like this:

172.26.64.0/24 via 172.26.64.1 dev usbnet0  proto babel onlink
172.26.64.0/24 dev usbnet0  proto kernel  scope link  src 172.26.64.231  metric 100
172.26.64.0/24 via 172.26.16.5 dev eth0  metric 200

for which the traffic survives the ifconfig usbnet0 down event better.

I imagine that putting in the "3 best routes" into the kernel RIB is not something most meshy daemons do?

A newer problem that I haven't thunk much about before was that babel aims for a stable route, so if I have 3 routes - one stable, but lousy, and both the better routes flap twice in under 60 seconds or so, we end up choosing the stablest route, sometimes for a very long time.

I still see many seconds before stuff recovers in some instances.

[1] http://frankston.com/public/?n=IAC.UAC"

Program output:
  netperf: send_omni: recv_data failed: No route to host
  netperf: send_omni: recv_data failed: No route to host
  Interim result:   33.47 10^6bits/s over 0.200 seconds ending at 1461547666.713
  Interim result:   22.99 10^6bits/s over 0.201 seconds ending at 1461547666.914
  Interim result:  


root@c2:~# sleep 90; ifconfig usbnet2 down; sleep 50; ifconfig usbnet2 up
usbnet2: ERROR while getting interface flags: No such device

^C
root@c2:~# ifconfig usbnet0 down
root@c2:~# sleep 50; ifconfig usbnet0 up

i
root@apu2:~/git/persta# ip route
default via 172.26.16.1 dev enp3s0  proto babel onlink 
10.0.0.0/24 dev enp1s0  proto kernel  scope link  src 10.0.0.3 
10.1.1.0/24 via 172.26.64.1 dev enp2s0  proto babel onlink 
10.1.2.0/24 via 172.26.64.1 dev enp2s0  proto babel onlink 
73.252.200.0/23 via 172.26.16.1 dev enp3s0  proto babel onlink 
76.102.224.0/21 via 172.26.64.1 dev enp2s0  proto babel onlink 
169.254.22.140 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.16.0/24 dev enp3s0  proto kernel  scope link  src 172.26.16.5 
172.26.16.3 via 172.26.16.3 dev enp3s0  proto babel onlink 
172.26.17.247 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.18.0/24 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.18.21 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.19.0/24 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.64.0/24 dev enp2s0  proto kernel  scope link  src 172.26.64.5 
172.26.64.0/24 via 172.26.16.130 dev enp3s0  metric 200 
192.168.2.0/24 via 172.26.16.1 dev enp3s0  proto babel onlink 



root@c2:~# ip route
default via 172.26.16.1 dev eth0  proto babel onlink 
default via 172.26.16.1 dev eth0  proto static  metric 100 
default via 172.26.64.1 dev usbnet0  proto static  metric 101 
10.1.1.0/24 via 172.26.64.1 dev usbnet0  proto babel onlink 
10.1.2.0/24 via 172.26.64.1 dev usbnet0  proto babel onlink 
73.252.200.0/23 via 172.26.16.1 dev eth0  proto babel onlink 
76.102.224.0/21 via 172.26.64.1 dev usbnet0  proto babel onlink 
169.254.0.0/16 dev usbnet0  scope link  metric 1000 
169.254.22.140 via 172.26.16.224 dev eth0  proto babel onlink 
172.26.16.0/24 via 172.26.16.224 dev eth0  proto babel onlink 
172.26.16.0/24 dev eth0  proto kernel  scope link  src 172.26.16.130  metric 100 
172.26.16.3 via 172.26.16.3 dev eth0  proto babel onlink 
172.26.17.247 via 172.26.16.224 dev eth0  proto babel onlink 
172.26.18.0/24 via 172.26.16.224 dev eth0  proto babel onlink 
172.26.18.21 via 172.26.16.224 dev eth0  proto babel onlink 
172.26.19.0/24 via 172.26.16.224 dev eth0  proto babel onlink 
172.26.64.0/24 via 172.26.64.1 dev usbnet0  proto babel onlink 
172.26.64.0/24 dev usbnet0  proto kernel  scope link  src 172.26.64.231  metric 100 
172.26.64.0/24 via 172.26.16.5 dev eth0  metric 200 
192.168.2.0/24 via 172.26.16.1 dev eth0  proto babel onlink 

root@apu2:~/git/persta# ip route
default via 172.26.16.1 dev enp3s0  proto babel onlink 
10.0.0.0/24 dev enp1s0  proto kernel  scope link  src 10.0.0.3 
10.1.1.0/24 via 172.26.64.1 dev enp2s0  proto babel onlink 
10.1.2.0/24 via 172.26.64.1 dev enp2s0  proto babel onlink 
73.252.200.0/23 via 172.26.16.1 dev enp3s0  proto babel onlink 
76.102.224.0/21 via 172.26.64.1 dev enp2s0  proto babel onlink 
169.254.22.140 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.16.0/24 dev enp3s0  proto kernel  scope link  src 172.26.16.5 
172.26.16.3 via 172.26.16.3 dev enp3s0  proto babel onlink 
172.26.17.247 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.18.0/24 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.18.21 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.19.0/24 via 172.26.16.224 dev enp3s0  proto babel onlink 
172.26.64.0/24 dev enp2s0  proto kernel  scope link  src 172.26.64.5 
172.26.64.0/24 via 172.26.16.130 dev enp3s0  metric 200 
192.168.2.0/24 via 172.26.16.1 dev enp3s0  proto babel onlink 

