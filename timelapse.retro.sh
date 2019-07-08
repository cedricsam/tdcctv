#!/bin/bash

#BRANDING="bloomberg_100x18.png"
DIR="timelapses"

# Usage: timelapse.retro.sh [webcam code] [date of end] [nb of minutes]

if [ $# -lt 2 ]
then
    exit
fi

c=${1}
t=1440
if [ $# -gt 1 ]
then
    d=$2
fi
if [ $# -gt 2 ]
then
    t=$3
fi
f=${c}.${t}.${d}
df=`echo $d | grep -Eo "[0-9]{8}-[0-9]{4}" | sed 's/-/ /'`
now=$(date +%s) || now=$(date -jf "%a %b %d %T %Z %Y" "`date`" "+%s")
prev=$(date -d"${df}" +%s 2> /dev/null) || prev=$(date -jf "%Y%m%d %H%M" "${df}" "+%s")
let secsend=${now}-${prev}
let minsend=${secsend}/60
let minsstart=${minsend}+${t}

find img -name ${c}_\* -type f -mmin -${minsstart} -mmin +${minsend} -not -size 10981c | sort > ${DIR}/${f}.txt
mkdir -p ${DIR}/${f}
n=0
while read i
do
    I=`printf %04d $n`
    let n=$n+1
    cp -p $i ${DIR}/${f}/frame${I}.jpg
done < ${DIR}/${f}.txt

ffmpeg -y -framerate 15 -i ${DIR}/${f}/frame%04d.jpg -c:v libx264 -pix_fmt yuv420p -crf 15 ${DIR}/out/${f}_15fps.nobrand.mp4 > /dev/null 2> /dev/null
ffmpeg -y -framerate 25 -i ${DIR}/${f}/frame%04d.jpg -c:v libx264 -pix_fmt yuv420p -crf 25 ${DIR}/out/${f}_25fps.nobrand.mp4 > /dev/null 2> /dev/null

ffmpeg -y -i ${DIR}/out/${f}_15fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=10:5" ${DIR}/out/${f}_15fps.mp4 > /dev/null 2> /dev/null
ffmpeg -y -i ${DIR}/out/${f}_25fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=10:5" ${DIR}/out/${f}_25fps.mp4 > /dev/null 2> /dev/null
