#!/bin/sh
if [ $# -lt 2 ]
then
  echo "missing arguments writefile writestr"
  exit 1
fi

writefile=$1
writestr=$2

target_name=$writefile
base_path="$(dirname $writefile)"

if [ ! -d "$base_path"  ]
then
  mkdir -p $base_path
  if [ $? -ne 0 ] 
  then
    echo "file could not be created"
    exit 1
  fi
fi
echo "$writestr" > "$target_name"
if [ $? -ne 0 ] 
then
  echo "file could not be created"
  exit 1
fi
