+++
date = "2016-04-07T16:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "papers" ]
title = "Exploring tcp_notsent_nowat"
description = "Dumping all your data into the kernel is stupid sometimes"
+++

Apple disabled tcp_notsent_lowat everywhere.

it looked like notsent_lowat helps wifi, too. It may be a bit low at
4096, tho, and the underlying buffering of 50-200+ms is a bit more
than the 500us of the ethernet path....

This was a failover test from usb to wifi and back again, starting
with usb. Nice to see it survive the transitions from up and down.

Dave,

You are definitely not bothering me in the least, this is all super
helpful, it'll just take me a little bit to digest it and give
reasonable responses.

The Allwinner R8 Usermanual and Datasheet are here:
https://github.com/NextThingCo/CHIP-Hardware/tree/master/CHIP%5Bv1_0%5D/CHIPv1_0-BOM-Datasheets

I am sure the kernel has better than just a jiffies clocksource, but
it is completely possible that we have setup the kernel incorrectly to
use said source in the network stack / wifi driver.

The attached plots are for flent rrul tests on the wifi side I
presume, not usb gadget ethernet?

If so, have you tried disabling power-save on the wifi?
iw wlan0 set power_save off

That download performance looks unreasonably low from what I recall of
my testing.

