+++
date = "2016-04-14T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath10k" ]
title = "Adapting DQL to wifi, patch 3"
description = "Can the dynamic queue limits infrastructure in linux be adapted to wifi?"
author = "Michal Kazior"
+++

This is the 3rd part of a series exploring how to go about adding
fq_codel to wifi. This is the now obsolete
[fq_codel_on_wifi v3 patchset](https://lists.bufferbloat.net/pipermail/codel/2016-April/002165.html),
exploring the interactions between DQL, FQ, and FQ_CODEL on the
[ath10k wifi driver](/tags/ath10k).

## Test Setup

- 1x qca988x 10.1.467 as AP limited to 6mbps via `iw set bitrates`
- 2x qca9377 as clients
- "dql" plot title keyword means the
  [ath10k dql RFC](http://lists.infradead.org/pipermail/ath10k/2016-March/007143.html)

- test commands (rc shell):

```
cherry_names=(normal dql); cherries=(HEAD sw/ath10k_dql); names=(fqcodel
fq taildrop base); for (k in 1 2) { for (j in 3 2 1 0) { git checkout
sw/fq2~^$j && git cherry-pick --keep-redundant-commits $cherries($k) &&
git exec make-linux 'M=net/mac80211' && git exec make-linux
'M=drivers/net/wireless/ath/ath10k' && echo 'pkill hostap; modprobe -r
ath10k_pci; modprobe ath10k_pci; timeout 30 sh -c "while ! test -e
/sys/class/net/wlan1; do sleep 1; done"; hostapd /root/hostapd-pere.conf
-B; ip link del veth0; ip netns del veth; ip netns add veth; ip link add
veth0 type veth peer name veth1; brctl addbr br; brctl addif br veth0;
ip link set veth1 netns veth; ifconfig veth0 up; ifconfig br up;
ifconfig br 192.168.99.1; ip netns exec veth ifconfig veth1
192.168.99.20 up; ' | ssh bob ssh vm0 sh -ax && { for (i in 2 11) { echo
'timeout 15 sh -c ''while ! ping -c1 -w1 192.168.99.'^$i^'; do sleep 1;
done'' ' | ssh bob ssh vm0 ip netns exec veth sh -x } } ; ssh bob ssh
vm0 iw wlan1 set bitrates legacy-5 6 ht-mcs-5 vht-mcs-5 ; ssh bob ssh
vm0 ip netns exec veth flent rtt_fair_up -H 192.168.99.2 -H 192.168.99.2
-H 192.168.99.11 -H 192.168.99.11 -l 30 -t
$cherry_names($k)^'-'^$names(`{expr $j + 1}) } }
```

## Baseline results

{{< figure src="/flent/2016-04-12-flent-fqmac-ath10k-dql/normal-base.svg" title="Todays normal, terrible baseline wifi performance at low rates">}}

{{< figure src="/flent/2016-04-12-flent-fqmac-ath10k-dql/normal-fqcodel.svg" title="fq-codel at qdisc layer accomplishes nothing" >}}

{{< figure src="/flent/2016-04-12-flent-fqmac-ath10k-dql/normal-taildrop.svg" title="Essentially indistinguishable from a fifo">}}

{{< figure src="/flent/2016-04-12-flent-fqmac-ath10k-dql/normal-fq.svg" title="FQ by itself is no help with an uncontrolled queue under it, either.">}}

{{< figure src="/flent/2016-04-12-flent-fqmac-ath10k-dql/dql-base.svg" title="DQL's default estimator doesn't figure out the right buffersize" >}}

## Patch series results

{{< figure src="/flent/2016-04-12-flent-fqmac-ath10k-dql/dql-taildrop.svg" title="Getting a decent estimate from DQL cuts the latency a lot" >}}

{{< figure src="/flent/2016-04-12-flent-fqmac-ath10k-dql/dql-fq.svg" title="DQL+FQ gets the baseline delay under control">}}

{{< figure src="/flent/2016-04-12-flent-fqmac-ath10k-dql/dql-fqcodel.svg" title="DQL w/fq_codel at the mac80211 layer takes it in for the score!" >}}

## Notes

- why `dql-fq` has an ugly upload plot compared to taildrop? because
  dql-taildrop uses TOTAL_MAX_TX_BUFFER(512) and STA_MAX_TX_BUFFER(64)
  compared to total 8192 and no per-sta limit. Hence latency inertia in
  taildrop case is smaller which translates to TCP still catching up.
  Super long, uncontrolled queues of dql-fq confuse the hell out of TCP
  but since ICMP and TCP are classified as distinct flows ICMP latency
  is excellent (all things considered).

- CoDel visibly fixes TCP in `dql-fqcodel` :)

- "dql" plots compared to "normal" prove the importance of keeping tx
  queue at minimum fill level with regard to link speed/quality...
  at low speeds. [Higher speeds may be a problem](/post/dql_on_wifi), as yet.
  (dtaht) doesn't agree (yet) that basic DQL is "good enough" and that some
  integration with wifi rate control would be much better.

See here for more posts on [fq_codel for ath10k](/tags/ath10k/).
