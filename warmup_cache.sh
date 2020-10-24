#!/bin/bash
BASEDIR=/media/pi/76700c60-5762-4953-b768-9c155925b5d3/virb/virb-export/DCIM/102_VIRB
DIRECTORY=/media/pi/76700c60-5762-4953-b768-9c155925b5d3/virb/virb-export/GMetrix
#BASEDIR=/Users/tomklaasen/Workspace/virb-autoimport/sample_data/DCIM/101_VIRB
#DIRECTORY=/Users/tomklaasen/Workspace/virb-autoimport/sample_data/GMetrix
FILES="$DIRECTORY/*"
echo "$FILES"
for f in $FILES
do
  echo "Processing $f file..."
  ruby warmup_cache.rb "$BASEDIR" "$DIRECTORY" "$f"
done

