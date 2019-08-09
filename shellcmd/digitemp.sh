#!/bin/sh  
##########
#
# a shell script to extract 1wire thermometer values to remote database
#
##########
# set password
PGPASSWORD='dt'
export PGPASSWORD

# set the base temperature
PERUS=10.00

# extract temperature from wires > $RIVI
RIVI=`digitemp_DS9097 -a -q -o2 -s /dev/ttyS0`

# extract wire 1 value > $ULKO
ULKO=`echo $RIVI|cut -d" " -f2`

# extract wire 3 value > $POISTO
POISTO=`echo $RIVI|cut -d" " -f4`
# POISTO=$(awk 'BEGIN{printf ("%2.2f", '$EKA')}') # if needs to format

# extract wire 2 value > $TULO
TULO=`echo $RIVI|cut -d" " -f3`

#EROTUS=$TULO-$POISTO
# comparison if the value $TULO is bigger than value $PERUS
# if so, then add values to database
COMP=$(echo "$TULO > $PERUS" | bc)
if 	[ $COMP -eq 1 ]; then 
	psql kuivuri -q -h 192.168.1.2 -Udt -t -c "insert into temp(ulko, meno, paluu) values ($ULKO, $TULO, $POISTO);"  
	psql kuivuri -q -h 192.168.1.80 -Udt -t -c "insert into temp(ulko, meno, paluu) values ($ULKO, $TULO, $POISTO);" 
else
	exit 0 ;
fi

# awk 'BEGIN{if ($EKA < $TOKA) print "eka on pienempi"; else print "toka on pienempi"}'
# TEST=$(awk 'BEGIN{printf ("%.2f", '$EKA' + '$TOKA')}')
# TULOS=$(echo "$EKA - $PERUS" | bc)

