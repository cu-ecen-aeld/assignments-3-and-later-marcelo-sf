#!/bin/sh
if [ $# -lt 2 ]
then
  echo "missing arguments filestr searchstr"
  exit 1
fi

filesdir=$1
searchstring=$2

if [ ! -d "$filesdir"  ]
then
  echo "filestr must be a directory"
  exit 1
fi

file_count=`ls -pR $filesdir | fgrep -v / | wc -l`
match_count=`fgrep -r  $searchstring $filesdir | wc -l`
echo "The number of files are $file_count and the number of matching lines are $match_count"
