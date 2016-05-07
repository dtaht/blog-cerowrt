+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Reducing network latency on hackerboards is easy"
description = "Still Cheaping out for the sake of science"
+++

net.ipv4.tcp_ecn=1
net.core.default_qdisc=fq_codel
net.ipv4.tcp_notsent_lowat=4096
