+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "rants" ]
title = "Tale of the lost router"
description = "An edgerouter is awesome... when you can find it"
+++

I've had an edgerouter X for ages. 

Anyway, I was scanning my network for another device and found one 
that responded to ping. Thankfully attempting to login showed the
ULA disclaimer message, I remembered the password....

and great. I've had this thing plugged in, glowing away, for months,
now, and I haven't had much to do with it.

Problem is that although I've been told, multiple times, how to compile
stuff for it, it's beyond me to fire up qemu.

I *like* very much that it has a good routing protocol implementation
and it's an object lesson to me that off-the-shelf products don't 
have babel support by default. I sure wish it was available tho,
because integrating it into my network would be easier.

I gave it a fixed ip address (which eliminated it from dynamic dns)
and lost it.

https://help.ubnt.com/hc/en-us/articles/205202560-EdgeMAX-Add-other-Debian-packages-to-EdgeOS

Welcome to EdgeOS

By logging in, accessing, or using the Ubiquiti product, you
acknowledge that you have read and understood the Ubiquiti
License Agreement (available in the Web UI at, by default,
http://192.168.1.1) and agree to be bound by its terms.

It also lacks dhcp-pd, sm

which makes it not useful in my environment. Which is too bad - a 52
dollar box is handy.

edgex

Now... off to find the box that I had lost earlier this week.
