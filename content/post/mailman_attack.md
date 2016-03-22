+++
date = "2015-12-12T18:02:58+01:00"
draft = true
tags = [ "security" ]
title = "Attacks on mailman"
description = "Some days it doesn't pay to run your own email server"
+++

My mailman servers have been under attack for months. 

I thought about adding [capcha support to mailman](https://www.dragonsreach.it/2014/05/03/adding-recaptcha-support-to-mailman/) - but that ended up relying
on a google service to do it, and I am sort of on a quest to live google-free,
so...

221.178.182.57 - - [02/Jan/2016:20:47:21 -0500] "GET /listinfo/uberwrt-commits HTTP/1.1" 404 8800 "-" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"
221.178.182.57 - - [02/Jan/2016:20:47:23 -0500] "POST /subscribe/uberwrt-commits HTTP/1.1" 404 608 "https://lists.bufferbloat.net/listinfo/uberwrt-commits" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"

221.178.182.79 - - [02/Jan/2016:20:52:28 -0500] "GET /listinfo/bloat HTTP/1.1" 200 6632 "-" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"
221.178.182.79 - - [02/Jan/2016:20:52:29 -0500] "POST /subscribe/bloat HTTP/1.1" 200 1036 "https://lists.bufferbloat.net/listinfo/bloat" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"

221.178.182.88 blocked
75.102.129.2 blocked
221.178.182.33 blocked
221.178.182.7 blocked
190.63.157.226 blocked
200.223.97.194 blocked
123.231.229.182 blocked
221.178.182.43 blocked
ipset v6.25.1: Syntax error: cannot parse 2001:41d0:a:4f83::: resolving to IPv4 address failed
2001:41d0:a:4f83:: blocked
174.142.90.166 blocked
221.178.182.47 blocked
190.12.144.12 blocked
221.178.182.77 blocked
221.178.182.38 blocked
93.189.80.130 blocked
ipset v6.25.1: Syntax error: cannot parse 2001:41d0:c:1087::: resolving to IPv4 address failed
2001:41d0:c:1087:: blocked
221.178.182.81 blocked
62.204.241.146 blocked
213.24.60.52 blocked
87.106.162.134 blocked
103.54.148.2 blocked
112.78.137.42 blocked
113.53.255.242 blocked
189.213.65.98 blocked
186.91.245.160 blocked
221.178.182.96 blocked
184.107.162.146 blocked
202.62.85.186 blocked
92.222.237.26 blocked
ipset v6.25.1: Syntax error: cannot parse 2607:f298:6050:b1f0:f816:3eff:fee5:b8b0: resolving to IPv4 address failed
2607:f298:6050:b1f0:f816:3eff:fee5:b8b0 blocked
176.106.127.1 blocked
91.214.179.4 blocked
221.178.182.69 blocked
81.29.251.177 blocked
202.183.32.6 blocked
221.178.182.101 blocked
122.152.53.182 blocked


