#!/bin/sh

USER_PREFIX="bench"
echo "<?xml version="1.0"?>"
echo "<allocations>"
for i in `seq -f "%03.0f" 1 100`; do
  POOL=${USER_PREFIX}${i}
  m4 --define USER=$POOL allocation-file-template.xml
done;
echo "</allocations>"
