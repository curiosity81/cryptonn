#!/bin/bash

# 4 arguments are needed by the script:
# $1: term to search for
# $2: from date (format: 2017-07-27)
# $3: to date (format analogous to $2)
# $4: directory for saving result (format: /<some_global_path>/ or <some_local_path>/)

# bc-binary
bc_exec=bc;

# epoch to start
start_epoch=$(date --date=$3 +%s);

# time of day in hours for a break
break_from="1";
break_to="5";

# time of day in seconds for a break
break_from_seconds=$(echo "obase=10;ibase=10;$break_from*60*60/1" | $bc_exec);
break_to_seconds=$(echo "obase=10;ibase=10;$break_to*60*60/1" | $bc_exec);

echo "$break_from_seconds"
echo "$break_to_seconds"

# loop over 1000 days
for (( i=0; i<=1000; i++ ))
do
   # wait until break is over
   b=$(echo "$break_from_seconds");
   while [[ $b -ge $break_from_seconds && $b -le $break_to_seconds ]]
   do
      current_hours=$(date +"%H");
      current_minutes=$(date +"%M");
      current_seconds=$(date +"%S");
      b=$(echo "obase=10;ibase=10;scale=10;$current_hours*60*60+$current_minutes*60+$current_seconds" | $bc_exec);

      echo "break";
      sleep 10;
   done

   # compute epochs in between the data is gathered
   from_epoch=$(echo "obase=10;ibase=10;scale=10;$start_epoch+$i*24*60*60" | $bc_exec);
   to_epoch=$(echo "obase=10;ibase=10;scale=10;$start_epoch+($i+1)*24*60*60" | $bc_exec);

   # make human readable date from epochs
   from_date=$(date +%F -d @$from_epoch);
   to_date=$(date +%F -d @$to_epoch);
   echo "$from_date - $to_date";

   # get data
   python Exporter.py --querysearch $1 --since $from_date --until $to_date --maxtweets $2 --output $4"out.$1.$2.$from_date.$to_date.csv"

   # wait 5 minutes
   sleep 300;
done

