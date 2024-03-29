#!/bin/bash

d=`date +%Y%m%d-%H%M`
#BRANDING="/var/bigdata/tdcctv/bloomberg_100x18.png"
DIR="timelapses"

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

find img -name ${c}_\* -type f -mmin -${t} -not -size 10981c -printf "%C@ %p\n" | sort -n | cut -d" " -f2 > ${DIR}/${f}.txt
#find img -name ${c}_\* -type f -mmin -${t} -not -size 10981c -printf "%T@ %p\n" | sort -n | cut -d" " -f2 > ${DIR}/${f}.txt
mkdir -p ${DIR}/${f}
sumlist=${DIR}/${f}/sumlist.txt
touch ${sumlist}

n=0
while read fn
do
    I=`printf %04d $n`
    sum=`md5sum $fn | cut -d" " -f1`
    if [ `grep "${sum}" ${sumlist} | wc -l` -ne 0 ]
    then
      continue
    fi
    echo ${sum} >> ${sumlist}
    cp -p $fn ${DIR}/${f}/frame${I}.jpg
    let n=$n+1
done < ${DIR}/${f}.txt

ffmpeg -y -framerate 15 -i ${DIR}/${f}/frame%04d.jpg -c:v libx264 -pix_fmt yuv420p -crf 15 ${DIR}/out/${f}_15fps.nobrand.mp4 > /dev/null 2> /dev/null
ffmpeg -y -framerate 25 -i ${DIR}/${f}/frame%04d.jpg -c:v libx264 -pix_fmt yuv420p -crf 25 ${DIR}/out/${f}_25fps.nobrand.mp4 > /dev/null 2> /dev/null

ffmpeg -y -i ${DIR}/out/${f}_15fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=10:5" ${DIR}/out/${f}_15fps.mp4 > /dev/null 2> /dev/null
ffmpeg -y -i ${DIR}/out/${f}_25fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=10:5" ${DIR}/out/${f}_25fps.mp4 > /dev/null 2> /dev/null

rm ${DIR}/out/${c}.${t}.latest_15fps.nobrand.mp4 ${DIR}/out/${c}.${t}.latest_15fps.mp4
rm ${DIR}/out/${c}.${t}.latest_25fps.nobrand.mp4 ${DIR}/out/${c}.${t}.latest_25fps.mp4

ln -s ${f}_15fps.nobrand.mp4 ${DIR}/out/${c}.${t}.latest_15fps.nobrand.mp4
ln -s ${f}_25fps.nobrand.mp4 ${DIR}/out/${c}.${t}.latest_25fps.nobrand.mp4

ln -s ${f}_15fps.mp4 ${DIR}/out/${c}.${t}.latest_15fps.mp4
ln -s ${f}_25fps.mp4 ${DIR}/out/${c}.${t}.latest_25fps.mp4
