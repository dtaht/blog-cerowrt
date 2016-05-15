+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "UDP floods help"
description = "Measuring basic capacity is good"
+++

in a long thread. 

iperf3 has two useful modes for figuring out the baseline channel capacity.

iperf3 -u -b1450 -t 60

d@dancer:~/git/sites/cerowrt/content/post$ iperf3 -u -b1450 -t 60 -R -c 172.26.16.185

## Lab notebook

And the struggle to get a baseline. In my tests I was unable to crack

## Parsing aircaps

fiddling with setting mcs-1 or mcs-2 didn't seem to be accurate.
## Tracking RSSI

## Tracking rate control information

## Tracking cpu info

Early on in most of my tests I was not tracking the remote cpu in use.
(Mostly because I forgot that the capability had recently been 
 added to flent universally)
## APS

Why did it want to channel switch so aggressively? Multiple APS

The difference between debugging and science.

Reverse mode, remote host 172.26.16.185 is sending
[  4] local 172.26.16.3 port 57773 connected to 172.26.16.185 port 5201
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  4]   0.00-1.00   sec  8.00 KBytes  65.5 Kbits/sec  2.564 ms  0/1 (0%)  
[  4]   1.00-2.00   sec  0.00 Bytes  0.00 bits/sec  2.564 ms  0/0 (-nan%)  

