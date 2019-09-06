#!/bin/sh

T="White_Raven_Coffee"
F="flent -x -H flent-fremont.bufferbloat.net -t $T"

$F --te=download_streams=4 tcp_ndown
$F --te=upload_streams=4 --socket-stats tcp_nup
$F --te=upload_streams=4 tcp_2up_square
$F rrul
$F rrul_be

