#!/bin/bash

DIR=./opencaster-3.2.2/tools
TMP=/tmp
LOOP=$DIR/tsloop/tsloop
UDPSEND=$DIR/tsudpsend/tsudpsend
BITRATE=${1:-2049952}
FILE=./stream.m2t

NUM=5

chmod +x $LOOP
chmod +x $UDPSEND

for (( i=1; i<=$NUM; i++ ))
do
    ADDRESS="224.1.2.$i"
    PORT=1234
    echo "Launching stream at $ADDRESS:$PORT with bitrate=${BITRATE}bps"
    FIFO=$TMP/fifo$i.ts
    if [ ! -p $FIFO ]; then
        mkfifo $FIFO
    fi
    $LOOP $FILE > $FIFO &> /dev/null &
    $UDPSEND $FIFO $ADDRESS $PORT $BITRATE &> /dev/null &
done

wait
trap 'echo "exit" && kill $(jobs -p)' EXIT
