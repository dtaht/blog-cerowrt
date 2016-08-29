+++
date = "2016-08-28T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Peak Bandwidth"
description = "Does more than 20Mbit matter?"
+++

Our projection back then was that we'd see a typical web page

Appears to have flattened out. No matter how you draw the curve

# The rise of Apps

mask latency and bandwidtho

# Static site generators

# Primarily a function of RTT


In ath9k/xmit

         * We mark tx descriptors to receive a DESC interrupt
         * when a tx queue gets deep; otherwise waiting for the
         * EOL to reap descriptors.  Note that this is done to
         * reduce interrupt load and this only defers reaping
         * descriptors, never transmitting frames.  Aside from
         * reducing interrupts this also permits more concurrency.
         * The only potential downside is if the tx queue backs
         * up in which case the top half of the kernel may backup
         * due to a lack of tx descriptors.
         *
         * The UAPSD queue is an exception, since we take a desc-
         * based intr on the EOSP frames.
         */
        if (ah->caps.hw_caps & ATH9K_HW_CAP_EDMA) {
                qi.tqi_qflags = TXQ_FLAG_TXINT_ENABLE;
        } else {
                if (qtype == ATH9K_TX_QUEUE_UAPSD)
                        qi.tqi_qflags = TXQ_FLAG_TXDESCINT_ENABLE;
                else
                        qi.tqi_qflags = TXQ_FLAG_TXEOLINT_ENABLE |
                                        TXQ_FLAG_TXDESCINT_ENABLE;
        }

like measuring all the packets in flight on the sender side, rather than those recieved. 

Or even to pick another station to transmit to entirely.

130us to arrive.

Is the ideal

TCP del-ack

grabbing the media at a more optimim opportunity might get it all back, and then some.

It also sidesteps other issues

The leads to a third technique

Or induce latency, 

