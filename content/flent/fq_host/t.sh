#!/bin/sh

flent -4 --te=download_streams=8 -H flent-fremont.bufferbloat.net -t ipv4-flows_8-dancer-nat tcp_ndown
sleep 20
flent -4 --te=upload_streams=8 -H flent-fremont.bufferbloat.net -t ipv4-flows_8-dancer-nat tcp_nup
sleep 20
flent -4 --te=download_streams=8 -H flent-fremont.bufferbloat.net -t ipv6-flows_8-dancer-nat tcp_ndown
sleep 20
flent -4 --te=upload_streams=8 -H flent-fremont.bufferbloat.net -t ipv6-flows_8-dancer-nat tcp_nup
sleep 20

