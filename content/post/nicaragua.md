+++
date = "2016-10-12T04:02:58+01:00"
draft = false
tags = [ "bufferbloat" ]
title = "Some traceroutes from Nicaragua"
description = "It seemed like the entire country was behind one big nat"
+++ 

What does your internet look like? How can you figure out anything
about your userbase if your users are behind 7! Yes 7! layers of private
network? When I was in Nicaragua earlier this year I had a chance to
deploy a few fq_codel enabled APs on two networks there, and run a few
tests on how things behaved on these longer RTTs. I wasn't expecting
to discover that a goodly portion of the country, seems to be behind
a giant NAT.

```
dair-2384:cerowrt d$ traceroute -n 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 64 hops max, 52 byte packets
 1  192.168.2.1  443.298 ms  319.503 ms  80.494 ms
 2  10.219.128.1  733.503 ms  1182.595 ms  1608.169 ms
 3  10.219.4.1  913.401 ms  822.641 ms  320.615 ms
 4  10.192.101.94  1482.439 ms  1893.829 ms  3095.516 ms
 5  10.192.101.97  952.175 ms  308.858 ms *
 6  10.192.101.161  3448.414 ms  1163.302 ms  90.328 ms
 7  10.192.4.245  160.219 ms  98.875 ms  108.994 ms
 8  173.205.46.113  313.685 ms  438.507 ms  674.673 ms
 9  72.14.210.140  1941.582 ms  2776.799 ms  2132.500 ms
10  209.85.252.93  1659.355 ms  1565.422 ms
    209.85.253.79  1182.059 ms
11  216.239.50.105  1951.123 ms
    216.239.50.103  1091.300 ms
    216.239.50.105  1153.353 ms
12  8.8.8.8  1340.056 ms *  661.494 ms
```

Yes - 1143ms RTT on this test. And I at least - had no extra traffic on
the link.

```
dair-2384:cerowrt d$ traceroute -n 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 64 hops max, 52 byte packets
 1  192.168.2.1  43.003 ms  47.484 ms  19.852 ms
 2  10.219.128.1  955.136 ms  971.374 ms  942.277 ms
 3  10.219.4.1  25.376 ms  52.522 ms  62.537 ms
 4  10.192.101.94  545.573 ms  810.856 ms *
 5  10.192.101.97  1145.894 ms  1104.235 ms  2392.947 ms
 6  10.192.101.161  2497.802 ms  2440.840 ms  2652.786 ms
 7  10.192.4.245  1491.957 ms  2761.196 ms  2380.723 ms
 8  173.205.46.113  2060.333 ms  951.202 ms  154.644 ms
 9  72.14.210.140  704.381 ms  2544.021 ms  833.675 ms
10  209.85.255.177  922.219 ms
    209.85.253.79  1002.748 ms  1276.292 ms
11  216.239.51.163  1843.627 ms
    216.239.50.103  2660.625 ms
    216.239.51.133  3112.878 ms
12  8.8.8.8  867.064 ms  837.938 ms  1853.168 ms

```
Later on I tried this at a different location, on the cable provider,
that was only behind 3 layers of NAT, before crossing underseas and
finding a google dns server. Look at these RTTs and variance. WTF?

```

traceroute to 8.8.8.8 (8.8.8.8), 64 hops max, 52 byte packets
 1  192.168.0.1  2.349 ms  1.461 ms  1.384 ms
 2  10.9.1.1  10.704 ms  19.084 ms  8.724 ms
 3  172.16.20.1  16.621 ms  16.278 ms  20.308 ms
 4  186.148.111.81  100.845 ms  51.724 ms  55.964 ms
 5  62.115.46.41  64.737 ms  56.701 ms  78.253 ms
 6  213.248.96.254  72.919 ms  77.343 ms  102.189 ms
 7  216.239.51.171  198.816 ms
    209.85.142.145  92.711 ms
    216.239.51.175  68.764 ms
 8  216.239.51.131  73.180 ms
    216.239.50.103  60.361 ms
    216.239.51.163  113.963 ms
 9  8.8.8.8  120.779 ms  45.879 ms  48.143 ms

```

How the heck can IPv6 ever deploy with this much nat in the way?
