#!/bin/bash

SOURCE=/opt/local/app/sql.log*
DEST=/opt/local/data/sql-log

#ls $SOURCE| cut -d / -f 9 | xargs -I '{}' cp '{}' "$DEST"/'{}'."$(date +"%Y-%m-%d-%T")"
#ls $SOURCE| cut -d / -f 9 | xargs -I '{}' echo '{}' "$DEST"/'{}'."$(date +"%Y-%m-%d-%T")"

for f in $( ls $SOURCE ); do
  FILENAME=$( echo $f | cut -d / -f 9 )
  #echo $FILE
  TARGET=$DEST/$FILENAME.$(date +"%Y-%m-%d-%T")
  #echo $f $TARGET
  cp -p $f $TARGET
  gzip $TARGET
done
