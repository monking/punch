#!/bin/bash
function refresh_punch {
  cd `dirname $0`
  . ../punch.sh
  statusDir="`pwd`"
  statusPath="$statusDir/status.txt"
  while true; do
    punch -r > "$statusPath"
    punch -o >> "$statusPath"
    sleep 5
  done
}
refresh_punch > /dev/null &
pid=$!
echo "updating status in the background (PID $pid)"
