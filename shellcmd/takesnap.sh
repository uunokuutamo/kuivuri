#!/bin/sh
HOST='www.savilampi.net'
USER='kuivuri'
PASSWD='Salasan1'
FILE='/tmp/snap.jpg'

fswebcam -r 640x480 -q --jpeg 99 /tmp/snap.jpg

ftp -in $HOST <<END_SCRIPT
quote USER $USER 
quote PASS $PASSWD
pass
binary
cd /var/www/html/kuivuri
put $FILE /var/www/html/kuivuri/snap.jpg
quit
END_SCRIPT
exit 0
