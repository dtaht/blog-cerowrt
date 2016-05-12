+++
date = "2016-05-01T12:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Ripping out the reorder buffer"
description = "Most TCPs can recover from reordering. APs don't need to worry about it"
+++

I finally sat down to prove - that once we had small, fq_codeled queues, having a reorder buffer in the AP or client
was a futile waste of energy for at least two OSes - Linux and OSX. Having a reorder buffer was a symptom of having
overlarge queues in the first place.

