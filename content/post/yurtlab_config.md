+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Re-Entering the yurtlab"
description = "The yurtlab was not so much built, as evolved"
+++

## Some advantages this time around

## OpenWrt delta is small

Less - as the folk involved bless them.

But one sticking point is that to be able to find the darn router again, it either needs to be part of a normally routable network

or I have to merge babeld into the system so it can be found again.


## Edges

Make for damn sure everything else works before you move to relying on it every day.

## Routing

Devices are usually assigned a /22 IPv4 address to play with. This is enough
to configure 2 radios, 1 ethernet, and 1 "spare".

They also self-generate an ipv6 address. Rather than centrally assigning all the
ipv6 addresses, I just let them self-generate.

This address too I limit down to a /48.

At one point or another, I tired of relying on ipv6 address assignment. I'd use
babel to export a single ipv6 IP to the network.  

So all I have to do is scan the /48s on the network, and there I was.

## Babel BSSID

The babel BSSID is established statically throughout the mesh network.
I'd really managed to mess up my life while testing a dynamically

Worse, you want to isolate the lab as much as possible so that everything there
talks to itself and not the outside world. I did this to myself multiple times
where a babel route would "escape" the network.

## 
