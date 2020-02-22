#!/bin/bash
DIRECTORY=/mnt/backups/virb/virb-export/DCIM/101_VIRB
FILES="$DIRECTORY/*"
echo "$FILES"
for f in $FILES
do
  echo "Processing $f file..."
  ruby warmup_cache.rb "$DIRECTORY" "$f"
done

