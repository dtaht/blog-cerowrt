#!/bin/sh

T="tethered_t_mobile_wifi"
F="flent -x -H flent-fremont.bufferbloat.net -t $T"

$F --te=download_streams=4 tcp_ndown
$F --te=upload_streams=4 tcp_nup
$F --te=upload_streams=4 tcp_2up_square
$F rrul
$F rrul_be

