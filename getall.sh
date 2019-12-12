#!/bin/bash

D=`date +%y%m%d_%H%M`

PS=`ps xc | grep getall.sh | wc -l`

# exit if already running
echo $PS
if [ ${PS} -ge 3 ]
then
    exit
fi

while read i
do
    #echo $i
    ./getone.sh $i
done < tdcctv.txt
