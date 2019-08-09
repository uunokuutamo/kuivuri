#!/bin/sh
# RESULT=`iwconfig eth1|grep Quality|cut -d"=" -f2|cut -d"/" -f1`
WLAN=`cat /proc/net/wireless |grep eth1|cut -c16-17`
BATT=`cat /proc/acpi/battery/BAT1/state |grep remaining | cut -d":" -f2 |sed s/mWh//`
#echo $WLAN $BATT

psql testi -q -Uesa -t -c "insert into wlan(LinkQuality,batt) values ($WLAN, $BATT);"
