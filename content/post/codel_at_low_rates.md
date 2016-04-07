+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "aqm" ]
title = "Codel at low rates"
description = "Today's TCP is very, very, very agressive at low speeds"
+++

```

https://github.com/raspberrypi/linux/issues/1371

```

## Output shaping

```

root@pi3:~# tc -s qdisc show dev eth0
qdisc htb 1: root refcnt 2 r2q 10 default 12 direct_packets_stat 0 direct_qlen 1000
 Sent 27360294 bytes 50488 pkt (dropped 11, overlimits 35526 requeues 0)
 backlog 0b 0p requeues 0
qdisc codel 110: parent 1:11 limit 1001p target 20.0ms interval 100.0ms ecn
 Sent 2560700 bytes 22054 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  count 0 lastcount 0 ldelay 2us drop_next 0us
  maxpacket 946 ecn_mark 0 drop_overlimit 0
qdisc codel 120: parent 1:12 limit 1001p target 20.0ms interval 100.0ms ecn
 Sent 24799552 bytes 28433 pkt (dropped 11, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  count 1 lastcount 1 ldelay 9us drop_next 0us
  maxpacket 1514 ecn_mark 23 drop_overlimit 0
qdisc codel 130: parent 1:13 limit 1001p target 20.0ms interval 100.0ms ecn
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  count 0 lastcount 0 ldelay 0us drop_next 0us
  maxpacket 0 ecn_mark 0 drop_overlimit 0
qdisc ingress ffff: parent ffff:fff1 ----------------
 Sent 37681238 bytes 123244 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

```

## Input shaping

```

root@pi3:~# tc -s qdisc show dev ifb4eth0
qdisc htb 1: root refcnt 2 r2q 10 default 10 direct_packets_stat 0 direct_qlen 32
 Sent 39870595 bytes 124635 pkt (dropped 1, overlimits 20822 requeues 0)
 backlog 0b 0p requeues 0
qdisc codel 110: parent 1:10 limit 1001p target 20.0ms interval 100.0ms ecn
 Sent 39870595 bytes 124635 pkt (dropped 1, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  count 1 lastcount 1 ldelay 3us drop_next 0us
  maxpacket 1514 ecn_mark 37 drop_overlimit 0

```

## Looking at captures

```

root@pi3:~# tcpdump -i eth0 -s 128 -w fq_^Cdel_target_20ms.cap &
root@pi3:~# tc -s qdisc show dev eth0
qdisc htb 1: root refcnt 2 r2q 10 default 12 direct_packets_stat 4 direct_qlen 1000
 Sent 15506 bytes 125 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc fq_codel 110: parent 1:11 limit 1001p flows 1024 quantum 300 target 28.0ms interval 123.0ms ecn
 Sent 452 bytes 4 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 166 drop_overlimit 0 new_flow_count 1 ecn_mark 0
  new_flows_len 0 old_flows_len 1
qdisc fq_codel 120: parent 1:12 limit 1001p flows 1024 quantum 300 target 28.0ms interval 123.0ms ecn
 Sent 12798 bytes 105 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 190 drop_overlimit 0 new_flow_count 2 ecn_mark 0
  new_flows_len 0 old_flows_len 1
qdisc fq_codel 130: parent 1:13 limit 1001p flows 1024 quantum 300 target 28.0ms interval 123.0ms ecn
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc ingress ffff: parent ffff:fff1 ----------------
 Sent 13004 bytes 151 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

```

## More stats

```

root@pi3:~# tc -s qdisc show dev eth0
qdisc htb 1: root refcnt 2 r2q 10 default 12 direct_packets_stat 4 direct_qlen 1000
 Sent 5796501 bytes 4198 pkt (dropped 0, overlimits 8662 requeues 0)
 backlog 0b 0p requeues 0
qdisc fq_codel 110: parent 1:11 limit 1001p flows 1024 quantum 300 target 28.0ms interval 123.0ms ecn
 Sent 5226 bytes 45 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 230 drop_overlimit 0 new_flow_count 2 ecn_mark 0
  new_flows_len 0 old_flows_len 1
qdisc fq_codel 120: parent 1:12 limit 1001p flows 1024 quantum 300 target 28.0ms interval 123.0ms ecn
 Sent 5789019 bytes 4137 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 1514 drop_overlimit 0 new_flow_count 91 ecn_mark 0
  new_flows_len 0 old_flows_len 1
qdisc fq_codel 130: parent 1:13 limit 1001p flows 1024 quantum 300 target 28.0ms interval 123.0ms ecn
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc ingress ffff: parent ffff:fff1 ----------------
 Sent 309571 bytes 2908 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
```
