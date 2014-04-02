#!/bin/bash
cd `dirname $0`
. ../punch.sh
statusDir="`pwd`"
statusPath="$statusDir/status.txt"
function refresh_punch {
  echo 'starting punch status watcher'
  while true; do
    punch -r > "$statusPath"
    punch -o >> "$statusPath"
    sleep 5
  done
}
pid_file="`dirname $0`/status_pid"
. ./stop.sh
refresh_punch > /dev/null &
backgroundPID=$!
echo $backgroundPID > $pid_file
echo "point your browser to file://$statusDir/index.html"
echo "pss to stop"
