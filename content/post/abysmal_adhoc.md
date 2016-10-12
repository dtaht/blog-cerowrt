+++
date = "2016-03-30T18:02:58+01:00"
draft = false
tags = [ "wifi", "adhoc" ]
title = "Abysmal adhoc"
description = "Wifi adhoc mode is often not well debugged"
+++

WiFi adhoc mode is an artifact of the earliest days of wifi, back when
we thought that mesh networking was the totally right way to do things.
Nobody's ever made it work "good enough", and gradually, as it's power 
hungry, in particular, newer chipsets and drivers don't support it. Then
people find that adhoc networking of some sort is often needed, and either
invent a new version (p2p) of the same basic idea, or try to leverage 
things like bluetooth for local network discovery and configuration.

Still, the mesh networking communities continue to try to make basic
adhoc work. But it's getting harder and harder.

## Just one bug among many

[85845.595973] ieee80211 phy1: rt2x00usb_watchdog_tx_dma: Warning - TX queue 3 DMA timed out, invoke forced forced reset
[85845.596539] ieee80211 phy1: rt2800usb_txdone: Warning - Data pending for entry 12 in queue 2
[85846.595304] ieee80211 phy1: rt2800usb_watchdog: Warning - TX HW queue 0 timed out, invoke forced kick
[85847.565374] ieee80211 phy1: rt2800usb_watchdog: Warning - TX HW queue 0 timed out, invoke forced kick
[85848.595342] ieee80211 phy1: rt2800usb_watchdog: Warning - TX HW queue 0 timed out, invoke forced kick
[85849.595357] ieee80211 phy1: rt2800usb_watchdog: Warning - TX HW queue 0 timed out, invoke forced kick
[85850.565385] ieee80211 phy1: rt2800usb_watchdog: Warning - TX HW queue 0 timed out, invoke forced kick
[85851.565384] ieee80211 phy1: rt2800usb_watchdog: Warning - TX HW queue 0 timed out, invoke forced kick
[85852.565394] ieee80211 phy1: rt2800usb_watchdog: Warning - TX HW queue 0 timed out, invoke forced kick
[85855.535476] ieee80211 phy1: rt2x00usb_watchdog_tx_dma: Warning - TX queue 2 DMA timed out, invoke forced forced reset
[85855.655230] ieee80211 phy1: rt2x00usb_watchdog_tx_dma: Warning - TX queue 3 DMA timed out, invoke forced forced reset

The only chipset I have that does adhoc even semi-decently is the ath9k,
and our work on make-wifi-fast works with adhoc great. It's long been my
hope that the new ideas we've added to make bandwidth and latency scale
better will enhance existing mesh networking routing protocols in particular,
but there are still pesky problems like "hidden stations" left to resolve.

On my bad days, well, I wish we could bring UWB back, with what we
understand today, and the kind of DSPs we have now.
