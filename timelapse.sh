#!/bin/bash

d=`date +%Y%m%d-%H%M`
BRANDING="/var/bigdata/tdcctv/bloomberg_100x18.png"

# Usage: timelapse.sh [webcam code] [nb of minutes]

if [ $# -lt 1 ]
then
    exit
fi

c=${1}
t=3600
if [ $# -gt 1 ]
then
    t=$2
fi
f=${c}.${t}.${d}

find img -name ${c}_\* -type f -cmin -${t} | sort > timelapses/${f}.txt
mkdir -p timelapses/${f}
n=0
while read i
do
    I=`printf %04d $n`
    let n=$n+1
    cp -p $i timelapses/${f}/frame${I}.jpg
done < timelapses/${f}.txt

ffmpeg -framerate 15 -i timelapses/${f}/frame%04d.jpg -c:v libx264 -pix_fmt yuv420p -crf 15 timelapses/out/${f}_15fps.nobrand.mp4 > /dev/null 2> /dev/null
ffmpeg -framerate 25 -i timelapses/${f}/frame%04d.jpg -c:v libx264 -pix_fmt yuv420p -crf 25 timelapses/out/${f}_25fps.nobrand.mp4 > /dev/null 2> /dev/null

ffmpeg -i timelapses/out/${f}_15fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=10:5" timelapses/out/${f}_15fps.mp4 > /dev/null 2> /dev/null
ffmpeg -i timelapses/out/${f}_25fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=10:5" timelapses/out/${f}_25fps.mp4 > /dev/null 2> /dev/null

ffmpeg -i timelapses/out/${f}_15fps.mp4 timelapses/out/${f}_15fps.webm > /dev/null 2> /dev/null
ffmpeg -i timelapses/out/${f}_25fps.mp4 timelapses/out/${f}_25fps.webm > /dev/null 2> /dev/null

rm timelapses/out/${c}.${t}.latest_15fps.nobrand.mp4 timelapses/out/${c}.${t}.latest_15fps.mp4
rm timelapses/out/${c}.${t}.latest_25fps.nobrand.mp4 timelapses/out/${c}.${t}.latest_25fps.mp4

rm timelapses/out/${c}.${t}.latest_15fps.webm
rm timelapses/out/${c}.${t}.latest_25fps.webm

ln -s ${f}_15fps.nobrand.mp4 timelapses/out/${c}.${t}.latest_15fps.nobrand.mp4
ln -s ${f}_25fps.nobrand.mp4 timelapses/out/${c}.${t}.latest_25fps.nobrand.mp4

ln -s ${f}_15fps.mp4 timelapses/out/${c}.${t}.latest_15fps.mp4
ln -s ${f}_25fps.mp4 timelapses/out/${c}.${t}.latest_25fps.mp4

ln -s ${f}_15fps.webm timelapses/out/${c}.${t}.latest_15fps.webm
ln -s ${f}_25fps.webm timelapses/out/${c}.${t}.latest_25fps.webm
