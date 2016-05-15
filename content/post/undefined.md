+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Fixing wifi involves finally addressing gaps in the standards"
description = ""
+++

9.7 Multirate support
The algorithm for performing rate switching is beyond
the scope of this standard, but in order to provide coexistence and interoperability on multirate-capable PHYs,
this standard defines a set of rules to be followed by all STAs.
Only the data transfer rates of the mandatory rate set of the attach

The constituent MSDUs of an A-MSDU shall all have the same priority parameter value from the
corresponding MA-UNITDATA.request primitive.
An A-MSDU shall be carried, without fragmentation, within a single QoS data MPDU.
The Address 1 field of an MPDU carrying an A-MSDU shall be set to an individual address.
The channel access rules for a QoS data MPDU carrying an A-MSDU are the same as a data MPDU carrying
an MSDU (or fragment thereof) of the same TID.

When an A-MPDU contains multiple QoS Control fields, bits 4 and 8–15 of these QoS Control fields shall be
identical.
