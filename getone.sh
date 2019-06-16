#!/bin/bash

URLBASE="http://tdcctv.data.one.gov.hk/"

LATESTDIR="latest"
IMGDIR="img"
DLDIR="download"

if [ $# -lt 1 ]
then
    exit
fi

cd ${DLDIR}
FI="${1}.JPG"
wget -q "${URLBASE}${FI}" -O "${FI}"

D=$(stat --printf=%Y ${FI} 2> /dev/null) || D=$(stat -f "%Sm" -t %s ${FI})
D=`echo $D | cut -d. -f1`
DD=$(date -d@${D} +%Y%m%d-%H%M%S 2> /dev/null) || DD=$(date -jf %s ${D} +%Y%m%d-%H%M)

cd - > /dev/null

FO="${1}_${DD}.jpg"

if [ ! -s "${DLDIR}/${FI}" ] # exit if we didn't download anything
then
    exit
fi

if [ ! -s "${IMGDIR}/${FO}" ] # if does not exist, move the img there
then
    mv "${DLDIR}/${FI}" "${IMGDIR}/${FO}"
    rm "${LATESTDIR}/${FI}"
    ln -s "../${IMGDIR}/${FO}" "${LATESTDIR}/${FI}"
else
    rm "${DLDIR}/${FI}"
fi
