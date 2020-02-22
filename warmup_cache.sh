#!/bin/bash
BASEDIR=/mnt/backups/virb/virb-export/DCIM/101_VIRB
DIRECTORY=/mnt/backups/virb/virb-export/GMetrix
#BASEDIR=/Users/tomklaasen/Workspace/virb-autoimport/sample_data/DCIM/101_VIRB
#DIRECTORY=/Users/tomklaasen/Workspace/virb-autoimport/sample_data/GMetrix
FILES="$DIRECTORY/*"
echo "$FILES"
for f in $FILES
do
  echo "Processing $f file..."
  ruby warmup_cache.rb "$BASEDIR" "$DIRECTORY" "$f"
done

