#!/bin/bash

read barcode 
grep $barcode item.csv | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' '{print $4}'
