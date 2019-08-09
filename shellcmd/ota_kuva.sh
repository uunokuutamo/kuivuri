#!/bin/sh
HOST='www.savilampi.net'
USER='kuivuri'
PASSWD='Salasan1'
FILE='/tmp/snap.jpg'

ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
put $FILE
quit
END_SCRIPT
exit 0
