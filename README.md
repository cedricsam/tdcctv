# tdcctv

## Getting started

### getone.sh / getall.sh

Install dependencies, which are `wget`, `ffmpeg` and `imagemagick` (`convert`). You can either install them with `brew` on Mac, or `apt` on Ubuntu/Debian Linux.

After you download this repo, set up this cronjob (adjust for your directory where you download it to, where mine was `/var/bigdata/tdcctv`):

```
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:~/bin
* * 10-18 6 *   cd /var/bigdata/tdcctv; ./getall.sh
```

This $PATH is mine on Linux (Ubuntu), but you might want to just make sure it sees all the utilities.

`getall.sh` is a wrapper for `getone.sh`. You may tweak the webcams you want to follow using `tdcctv.txt`. If you have all the webcams on, you might be saving about 3 GB per 24 hour of images.

### archive_files.sh

Creates a tar.gz archive per day timestamp, deletes the images of that day and sends the archive to AWS Glacier. Make sure to delete the archive to save space on your machine.

Might be dangerous (might delete without saving, if your machine isn't set up properly). Comment out line 32 where it `find` and `rm` images, if you're worried.

The newest version of this script assumes you have a vault on Glacier called `tdcctv`.

### timelapse.sh

This reads in your `img` directory and creates MP4 and WEBM videos.

Usage: `timelapse.sh [webcam code] [nb of minutes]`

You can use a cronjob to automate the generation, and it will replace the latest version with a symlink.
 
The videos are created into `timelapses/out`. It might be a good idea to expose that directory as a web-accessible folder or something like that. This [interactive](http://multimedia.scmp.com/occupylapse/) from the 2014 protests was built on top of such web folder.

You may want to change the watermark to your own logo. The `nobrand` video is the one without a watermark, so delete the current image if you don't need one of those generated.

The branding image can be of any size, but it's suggested to be around 20-30px high. The opacity should be around 70% to see through what's behind it.

### timelapse.retro.sh

The retroactive version of the previous script.

Usage: `timelapse.retro.sh [webcam code] [date of end] [nb of minutes]`

e.g. `timelapse.retro.sh H203F 20190616-1200 360` creates a timelapse for the last 6 hours prior to noon on June 16 (so 6am-12pm).

## References

* Government XML: [http://data.one.gov.hk/code/td/imagelist_new.xml](http://data.one.gov.hk/code/td/imagelist_new.xml)

* List of webcams: [http://theme.gov.hk/en/theme/psi/datasets/Summary_of_traffic_snapshot_images(Eng).pdf](http://theme.gov.hk/en/theme/psi/datasets/Summary_of_traffic_snapshot_images(Eng).pdf)

* Data One Hong Kong portal page: [https://data.gov.hk/en-data/dataset/hk-td-tis_2-traffic-snapshot-images](https://data.gov.hk/en-data/dataset/hk-td-tis_2-traffic-snapshot-images)

* Previous GitHub project version of this: [https://github.com/cedricsam/scmpdata/tree/master/webcams/tdcctv](https://github.com/cedricsam/scmpdata/tree/master/webcams/tdcctv)

## Caveats

* The timestamps are local to your machine. Hong Kong is in the UTC+0800 tz all year long.

* Was originally written in a Ubuntu Linux environment, so it wasn't fully tested on macos/freebsd.
