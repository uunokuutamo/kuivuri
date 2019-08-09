#!/bin/sh
EKA=`digitemp_DS9097 -a -q -o2| cut -f2`
TOKA=`digitemp_DS9097 -a -q -o2| cut -f3`
psql temperature -q -h 192.168.1.10 -Udt -t -c "insert into temp(anturi1, anturi2) values ($EKA, $TOKA);"
#echo $EKA
#echo $TOKA
