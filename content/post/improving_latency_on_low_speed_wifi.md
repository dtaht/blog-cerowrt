+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Improving latency on low speed p2p wifi"
description = "Wifi adhoc mode is often not well debugged"
+++

Recently I picked up a couple rasberry pi, and the odroid c1 and c2,
to use as testbeds for the make-wifi-fast effort. The pi2, in particular,
with the native wifi onboard is a fairly ideal test case for worst
case wifi performance - it has a lousy 

And indeed

Adhoc mode performance is *dismal*, at present. In my environment it
never gets past 6.5 mbits. On the plus side it never gets much lower
than that, so I thought I'd try to improve the latency by plugging in 

[sqm-scripts]()


you can get overall better performance out of it than otherwise.

Or can you?

I did 4 test runs, all set at the seemingly good 5.5 mbit rate.

[rate control](/post/wifi_rate_control), [airtime fairness](/post/airtime_fairness), [interference](/post/interference),



Diversity-aware routing - PPS
www.pps.univ-paris-diderot.fr/~jch/software/babel/wbmv4.pdf

C) TCP comes up with a mildly better estimate for the BDP with multiple hops in the way. Most likely it's A, though. I can think of a few other reasons. If you are interested I collected some data driving a verizon FIOS connection over cerowrt's wifi and ethernet a week back, it's here:

http://snapon.lab.bufferbloat.net/~d/verizon_tests.tgz

Wifi had some very interesting behavior.

I note that in my MIT talk

http://www.youtube.com/watch?v=Wksh2DPHCDI&feature=youtu.be


I have resolved to read 1 paper per day of the backlog related to bufferbloat. Yours was today.

http://www.shihada.com/F11-344/papers/WMNBuffers.pdf

While this is an EXCELLENT paper (the best this week!), the addition of packet aggregation to the wireless-n standard has thus far needed (in practice) greater than 32 buffers per node in order to fully utilize the link, at least in our tests using cerowrt, and even then aggregation opportunities are frequently missed. I have been taking many, many, many captures of streams but not doing enough analysis, of late....

"cerowrt" currently defaults to 37 txqueuelen, and we were only able to reduce buffering to this level after multiple bugs related to aggregation and retries were fixed in mid august)


