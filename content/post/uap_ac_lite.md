+++
date = "2016-09-05T12:02:58+01:00"
draft = false
tags = [ "ath9k", "ath10k", "ubnt" ]
title = "The UAP ac Lite"
description = "an ideal router for make-wifi-fast - well, it's more of a bridge"
+++

When I fire up Toke's code, the theme from star wars goes through my head. He's a big Darth Vader fan.

"Dum, dum, dum, da, da dum, da da dum."

My memory for music is so good that frequently I can replay an entire song in my head while doing a flash. It's the only way I can deal with my PTFD.

# Evaluating the factory firmware

I'll get around to this. For now I was too excited. I just needed to get in there and blow things up.

## Figuring out what was already in lede

## Some early tests

The basic work in 


Offending RSA key in /root/.ssh/known_hosts:12
  remove with:
  ssh-keygen -f "/root/.ssh/known_hosts" -R 192.168.1.1
RSA host key for 192.168.1.1 has changed and you have requested strict checking.
Host key verification failed.


firing up my second one did not give me a conflicting ssh id for that IP. Uh-oh... maybe they all have the same
key? That would be *bad*.

https://wiki.openwrt.org/toh/ubiquiti/unifiac

<pre>
he openwrt-ar71xx-generic-ubnt-unifiac-squashfs-sysupgrade.bin image and copy it to /tmp using scp:

scp openwrt-ar71xx-generic-ubnt-unifiac-squashfs-sysupgrade.bin ubnt@192.168.1.20:/tmp/

UniFi AP AC Lite devices

In the SSH session run the following command to replace the primary firmware partition by OpenWrt:

# mtd -r write /tmp/openwrt-ar71xx-generic-ubnt-unifiac-squashfs-sysupgrade.bin kernel0
Unlocking kernel0 ...
</pre>

Reboot, and lede will be up on 192.168.1.1

root@lede:/sys/kernel/debug/ieee80211/phy0/netdev:wlan0/stations/48:d7:05:c0:9a:d9# cat rc_stats

## The good

at 65Mbit, the AP motors along at a mere 12% of cpu spent in sirq. We're not cpu-bound, per se'. We may be interrupt latency bound, but that's harder to measure.

### Linux has gained MUCH better statistics for measuring minstrel behavior

<pre>
              best   ____________rate__________    ________statistics________    ________last_______    ______sum-of________
mode guard #  rate  [name   idx airtime  max_tp]  [avg(tp) avg(prob) sd(prob)]  [prob.|retry|suc|att]  [#success | #attempts]
CCK    LP  1          1.0M  120   10548     0.7       0.7      95.7      1.3     100.0   0     0 0            15   21       
CCK    SP  1          2.0M  125    5380     1.5       1.5     100.0      0.0     100.0   0     0 0             1   1        
CCK    SP  1          5.5M  126    2315     3.8       3.8     100.0      0.0     100.0   0     0 0             1   1        
CCK    SP  1         11.0M  127    1439     6.1       6.1     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  1         MCS0     0    1477     5.9       5.9     100.0      0.0     100.0   3     0 0             1   1        
HT20  LGI  1         MCS1     1     739    11.9      11.9     100.0      0.0     100.0   0     0 0             2   2        
HT20  LGI  1         MCS2     2     493    17.7      17.7     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  1         MCS3     3     369    23.3      23.3     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  1         MCS4     4     246    34.3      34.3     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  1         MCS5     5     185    44.8      44.8     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  1         MCS6     6     164    50.0      50.0      99.4      0.8     100.0   2     0 0           443   449      
HT20  LGI  1         MCS7     7     148    55.0      55.0      97.2      1.3     100.0   2     0 0          5523   5676     
HT20  LGI  2         MCS8    10     739    11.9      11.9     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  2         MCS9    11     369    23.3      23.3     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  2         MCS10   12     246    34.3      34.3     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  2         MCS11   13     185    44.8      44.8     100.0      0.0     100.0   0     0 0             1   1        
HT20  LGI  2         MCS12   14     123    64.8      64.8     100.0      0.0     100.0   3     0 0             5   5        
HT20  LGI  2         MCS13   15      93    83.3      83.3      96.9      1.5     100.0   3     0 0         28484   35325    
HT20  LGI  2     D   MCS14   16      82    92.0      92.0      97.0      1.6     100.0   4     0 0         15247   21990    
HT20  LGI  2   B     MCS15   17      74   100.5     100.5      95.0      1.2     100.0   5     0 0        158505   205308   
HT20  SGI  1         MCS0    30    1329     6.5       6.5     100.0      0.0     100.0   0     0 0             2   2        
HT20  SGI  1         MCS1    31     665    13.1      13.1     100.0      0.0     100.0   0     0 0             1   1        
HT20  SGI  1         MCS2    32     443    19.5      19.5     100.0      0.0     100.0   0     0 0             1   1        
HT20  SGI  1         MCS3    33     332    25.7      25.7     100.0      0.0     100.0   0     0 0             1   1        
HT20  SGI  1         MCS4    34     222    37.8      37.8     100.0      0.0     100.0   5     0 0             1   1        
HT20  SGI  1         MCS5    35     166    49.4      49.4     100.0      0.0     100.0   2     0 0             2   2        
HT20  SGI  1         MCS6    36     148    55.0      55.0      96.1      1.3     100.0   2     0 0            50   53       
HT20  SGI  1      P  MCS7    37     133    60.5      60.5      99.5      0.9     100.0   4     0 0          8867   9320     
HT20  SGI  2         MCS8    40     665    13.1      13.1     100.0      0.0     100.0   0     0 0             2   2        
HT20  SGI  2         MCS9    41     332    25.7      25.7     100.0      0.0     100.0   0     0 0             1   1        
HT20  SGI  2         MCS10   42     222    37.8      37.8     100.0      0.0     100.0   0     0 0             1   1        
HT20  SGI  2         MCS11   43     166    49.4      49.4     100.0      0.0     100.0   0     0 0             1   1        
HT20  SGI  2         MCS12   44     111    71.1      71.1      99.9      0.0     100.0   3     0 0          1897   1901     
HT20  SGI  2         MCS13   45      83    91.0      91.0      95.1      1.2     100.0   4     0 0        213936   249516   
HT20  SGI  2    C    MCS14   46      74   100.4     100.4      98.2      1.7     100.0   4     0 0         65675   81052    
HT20  SGI  2  A      MCS15   47      67   109.5     109.5      97.0      1.3      96.8   5    93 96       406970   489256   

Total packet count::    ideal 1012931      lookaround 8113
Average # of aggregated frames per A-MPDU: 20.9

</pre>

One of minstrel's key observations was that in wifi, it was faster to retry something at a high rate, than
to fall back on a lower rate. Still, minstrel choosing to retry 5 times as it is here, rather than selecting a lower
rate, makes getting a good value for aggregation harder.

Retries suck. The upper bound is 30 retries, which is nuts.

### Less RTT equals more measurement flows

So as RTTs go down, the amount of data in the measurement flows goes up. If we halve the RTT from 40ms to 20ms,
we're going to be sending 

The original spec of the rrul test was for an isochronous fixed rate flow with a universal one way delay

there was also hope that we'd measure the latency of the TCP flows directly.

It's kind of like quantum physics

We have specialized tests that can just measure bandwidth, or apply a voip-like measurement flow, but the
first doesn't give as much information as I'd like, and the second requires setup and configuration of d-itg.

Worst of all, we're not measuring normal traffic. Normal wifi traffic looks more like web traffic - a 2 second burst, then silence for a while - or a movie, streaming along at a basic, but fixed, rate.

As the lab settles down, I'll start adding those tests.

I had babel enabled, exchanging routes via multicast. Multicast *can hurt*. Several things are on the todo list for
babel - to minimize multicast and 

## But the first questions have been answered

* Will it crash?

Yes, on the rrul test which tests all queues.
Otherwise, no.

* Did we reduce the latency via fq?

Yes, toke halved the latency from 40ms to 15ms

* Did we hurt throughput?

We might have!



[ 3149.226254] WARNING: CPU: 0 PID: 0 at compat-wireless-2016-06-20/net/mac80211/tx.c:1514 ieee80211_tx_dequeue+0x17c/0x968 [mac80211]()
[ 3149.238662] Modules linked in: ath9k ath9k_common iptable_nat ath9k_hw ath nf_nat_ipv4 nf_conntrack_ipv6 nf_conntrack_ipv4 mac80211 ipt_REJECT ipt_MASQUERADE ebtable_nat ebtable_filter ebtable_broute cfg80211 xt_time xt_tcpudp xt_tcpmss xt_statistic xt_state xt_recent xt_nat xt_multiport xt_mark xt_mac xt_limit xt_length xt_id xt_hl xt_helper xt_ecn xt_dscp xt_conntrack xt_connmark xt_connlimit xt_connbytes xt_comment xt_TCPMSS xt_REDIRECT xt_LOG xt_IPMARK xt_HL xt_DSCP xt_CT xt_CLASSIFY nf_reject_ipv4 nf_nat_redirect nf_nat_masquerade_ipv4 nf_nat nf_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 nf_conntrack_rtcache nf_conntrack_netlink nf_conntrack iptable_raw iptable_mangle iptable_filter ipt_ECN ip_tables ebtables ebt_vlan ebt_stp ebt_snat ebt_redirect ebt_pkttype ebt_mark_m ebt_mark ebt_limit ebt_ip6 ebt_ip ebt_dnat ebt_arpreply ebt_arp ebt_among ebt_802_3 crc_ccitt compat_xtables compat br_netfilter arptable_filter arpt_mangle arp_tables sch_cake em_nbyte sch_htb sch_prio sch_dsmark sch_pie sch_gred em_meta sch_teql cls_basic act_ipt sch_red em_text sch_tbf act_police sch_codel sch_sfq em_cmp sch_fq act_skbedit act_mirred em_u32 cls_u32 cls_tcindex cls_flow cls_route cls_fw sch_hfsc sch_ingress leds_wndr3700_usb ledtrig_usbdev xt_set ip_set_list_set ip_set_hash_netiface ip_set_hash_netport ip_set_hash_netnet ip_set_hash_net ip_set_hash_netportnet ip_set_hash_mac ip_set_hash_ipportnet ip_set_hash_ipportip ip_set_hash_ipport ip_set_hash_ipmark ip_set_hash_ip ip_set_bitmap_port ip_set_bitmap_ipmac ip_set_bitmap_ip ip_set nfnetlink ip6t_rt ip6t_frag ip6t_hbh ip6t_eui64 ip6t_mh ip6t_ah ip6t_ipv6header ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 nf_log_common ip6table_raw ip6table_mangle ip6table_filter ip6_tables x_tables ifb sit tunnel4 ip_tunnel tun ohci_platform ohci_hcd ehci_platform ehci_hcd gpio_button_hotplug usbcore nls_base usb_common
[ 3149.407661] CPU: 0 PID: 0 Comm: swapper Tainted: G        W       4.4.19 #0
[ 3149.414857] Stack : 804205e4 00000000 00000001 80480000 8046f058 8046ece3 803f9bd0 00000000
[ 3149.414857] 	  804f37e0 b74e8ba5 87011000 87011008 871c3bd0 800ada74 80400a84 80460000
[ 3149.414857] 	  00000003 b74e8ba5 803fea6c 8046597c 871c3bd0 800ab9a0 00000002 00000000
[ 3149.414857] 	  8046b1a0 80231300 00000000 00000000 00000000 00000000 00000000 00000000
[ 3149.414857] 	  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 3149.414857] 	  ...
[ 3149.451871] Call Trace:
[ 3149.454419] [<80072378>] show_stack+0x50/0x84
[ 3149.458927] [<80084240>] warn_slowpath_common+0xa4/0xd4
[ 3149.464334] [<800842f8>] warn_slowpath_null+0x18/0x24
[ 3149.469827] [<8712cf2c>] ieee80211_tx_dequeue+0x17c/0x968 [mac80211]
[ 3149.476728] [<870ea900>] ath_tid_dequeue+0x98/0x13c [ath9k]
[ 3149.482506] [<870ea9f8>] ath_tx_get_tid_subframe+0x54/0x1ec [ath9k]
[ 3149.489024] [<870eb354>] ath_txq_schedule+0x540/0x650 [ath9k]
[ 3149.494989] [<870ec018>] ath_tx_process_buffer+0x9d0/0xa18 [ath9k]
[ 3149.501391] [<870ecd6c>] ath_tx_edma_tasklet+0x2d0/0x324 [ath9k]
[ 3149.507622] [<870e4fa0>] ath9k_tasklet+0x24c/0x2b0 [ath9k]
[ 3149.513310] [<80087634>] tasklet_action+0x80/0xc8
[ 3149.518185] [<80086f68>] __do_softirq+0x26c/0x32c
[ 3149.523059] [<8006a908>] plat_irq_dispatch+0xd4/0x10c
[ 3149.528291] [<80060830>] ret_from_irq+0x0/0x4
[ 3149.532802] [<8006ec00>] r4k_wait_irqoff+0x18/0x20
[ 3149.537769] [<800a87ac>] cpu_startup_entry+0xf8/0x184
[ 3149.542995] [<8049cbec>] start_kernel+0x488/0x4a8
[ 3149.547862] 
[ 3149.549403] ---[ end trace 103165cc10a64d95 ]---
[ 3149.554217] ------------[ cut here ]------------
[ 3149.559260] WARNING: CPU: 0 PID: 0 at compat-wireless-2016-06-20/net/mac80211/tx.c:1514 ieee80211_tx_dequeue+0x17c/0x968 [mac80211]()
[ 3149.571663] Modules linked in: ath9k ath9k_common iptable_nat ath9k_hw ath nf_nat_ipv4 nf_conntrack_ipv6 nf_conntrack_ipv4 mac80211 ipt_REJECT ipt_MASQUERADE ebtable_nat ebtable_filter ebtable_broute cfg80211 xt_time xt_tcpudp xt_tcpmss xt_statistic xt_state xt_recent xt_nat xt_multiport xt_mark xt_mac xt_limit xt_length xt_id xt_hl xt_helper xt_ecn xt_dscp xt_conntrack xt_connmark xt_connlimit xt_connbytes xt_comment xt_TCPMSS xt_REDIRECT xt_LOG xt_IPMARK xt_HL xt_DSCP xt_CT xt_CLASSIFY nf_reject_ipv4 nf_nat_redirect nf_nat_masquerade_ipv4 nf_nat nf_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 nf_conntrack_rtcache nf_conntrack_netlink nf_conntrack iptable_raw iptable_mangle iptable_filter ipt_ECN ip_tables ebtables ebt_vlan ebt_stp ebt_snat ebt_redirect ebt_pkttype ebt_mark_m ebt_mark ebt_limit ebt_ip6 ebt_ip ebt_dnat ebt_arpreply ebt_arp ebt_among ebt_802_3 crc_ccitt compat_xtables compat br_netfilter arptable_filter arpt_mangle arp_tables sch_cake em_nbyte sch_htb sch_prio sch_dsmark sch_pie sch_gred em_meta sch_teql cls_basic act_ipt sch_red em_text sch_tbf act_police sch_codel sch_sfq em_cmp sch_fq act_skbedit act_mirred em_u32 cls_u32 cls_tcindex cls_flow cls_route cls_fw sch_hfsc sch_ingress leds_wndr3700_usb ledtrig_usbdev xt_set ip_set_list_set ip_set_hash_netiface ip_set_hash_netport ip_set_hash_netnet ip_set_hash_net ip_set_hash_netportnet ip_set_hash_mac ip_set_hash_ipportnet ip_set_hash_ipportip ip_set_hash_ipport ip_set_hash_ipmark ip_set_hash_ip ip_set_bitmap_port ip_set_bitmap_ipmac ip_set_bitmap_ip ip_set nfnetlink ip6t_rt ip6t_frag ip6t_hbh ip6t_eui64 ip6t_mh ip6t_ah ip6t_ipv6header ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 nf_log_common ip6table_raw ip6table_mangle ip6table_filter ip6_tables x_tables ifb sit tunnel4 ip_tunnel tun ohci_platform ohci_hcd ehci_platform ehci_hcd gpio_button_hotplug usbcore nls_base usb_common
[ 3149.740660] CPU: 0 PID: 0 Comm: swapper Tainted: G        W       4.4.19 #0
[ 3149.747856] Stack : 804205e4 00000000 00000001 80480000 8046f058 8046ece3 803f9bd0 00000000
[ 3149.747856] 	  804f37e0 b75381f8 87011000 87011008 871c3bd0 800ada74 80400a84 80460000
[ 3149.747856] 	  00000003 b75381f8 803fea6c 8046597c 871c3bd0 800ab9a0 00000002 00000000
[ 3149.747856] 	  8046b1a0 80231300 00000000 00000000 00000000 00000000 00000000 00000000
[ 3149.747856] 	  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 3149.747856] 	  ...
[ 3149.784879] Call Trace:
[ 3149.787417] [<80072378>] show_stack+0x50/0x84
[ 3149.791925] [<80084240>] warn_slowpath_common+0xa4/0xd4
[ 3149.797333] [<800842f8>] warn_slowpath_null+0x18/0x24
[ 3149.802826] [<8712cf2c>] ieee80211_tx_dequeue+0x17c/0x968 [mac80211]
[ 3149.809726] [<870ea900>] ath_tid_dequeue+0x98/0x13c [ath9k]
[ 3149.815532] [<870ea9f8>] ath_tx_get_tid_subframe+0x54/0x1ec [ath9k]
[ 3149.822026] [<870eb354>] ath_txq_schedule+0x540/0x650 [ath9k]
[ 3149.827993] [<870ec018>] ath_tx_process_buffer+0x9d0/0xa18 [ath9k]
[ 3149.834413] [<870ecd6c>] ath_tx_edma_tasklet+0x2d0/0x324 [ath9k]
[ 3149.840634] [<870e4fa0>] ath9k_tasklet+0x24c/0x2b0 [ath9k]
[ 3149.846332] [<80087634>] tasklet_action+0x80/0xc8
[ 3149.851189] [<80086f68>] __do_softirq+0x26c/0x32c
[ 3149.856070] [<8006a908>] plat_irq_dispatch+0xd4/0x10c
[ 3149.861287] [<80060830>] ret_from_irq+0x0/0x4
[ 3149.865803] [<8006ec00>] r4k_wait_irqoff+0x18/0x20
[ 3149.870757] [<800a87ac>] cpu_startup_entry+0xf8/0x184
[ 3149.875994] [<8049cbec>] start_kernel+0x488/0x4a8
[ 3149.880851] 
[ 3149.882392] ---[ end trace 103165cc10a64d96 ]---
ash: getcwd: No such file or directory


default via 172.22.136.1 dev enp2s0 