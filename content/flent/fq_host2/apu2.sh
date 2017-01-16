#!/bin/sh
sleep 10
flent -4 --te=download_streams=1 -H flent-fremont.bufferbloat.net -t ipv4-flows_1-apu2-nat tcp_ndown
sleep 20
flent -4 --te=upload_streams=1 -H flent-fremont.bufferbloat.net -t ipv4-flows_1-apu2-nat tcp_nup
sleep 20
flent -6 --te=download_streams=1 -H flent-fremont.bufferbloat.net -t ipv6-flows_1-apu2-nat tcp_ndown
sleep 20
flent -6 --te=upload_streams=1 -H flent-fremont.bufferbloat.net -t ipv6-flows_1-apu2-nat tcp_nup


