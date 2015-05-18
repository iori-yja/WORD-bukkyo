#!/bin/bash

# comannd amount user

current=`grep "$2" user.csv`
balance=`echo $current | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' -e '{print $4}'`
echo $balance
newbalance=`expr $balance - \( $1 \)`
echo $newbalance

if [ $newbalance -gt 0 ]; then
	next=`echo $current | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' -e '{print $1 "," $2 "," $3 ",'$newbalance'," $5 "," $6 "," $7 }'`
	echo `date` ": s/"$current"/"$next"/" >> sed.log
	sed -i -e "s/"$current"/"$next"/" user.csv
	exit 0
else
	exit -1
fi


