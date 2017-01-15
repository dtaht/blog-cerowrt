#!/bin/sh

#flent -4 --te=download_streams=8 -H flent-freemont.bufferbloat.net -t ipv4-8flows-dancer-nat tcp_ndown
flent -4 --te=upload_streams=8 -H flent-freemont.bufferbloat.net -t ipv4-8flows-dancer-nat tcp_nup

