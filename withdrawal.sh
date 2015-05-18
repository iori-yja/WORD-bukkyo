#!/bin/bash

# comannd amount user

current=`grep $2 user.csv`
next=`echo $current | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' -e ' {print $1 "," $2 "," $3 "," $4-'$1'"," $5 "," $6 "," $7 }'`
echo `date` ": s/"$current"/"$next"/" >> sed.log
sed -i -e "s/"$current"/"$next"/" user.csv
