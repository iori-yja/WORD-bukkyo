#!/bin/bash

grep $1 item.csv | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' '{print $4}'
