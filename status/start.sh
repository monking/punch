#!/bin/bash
cd `dirname $0`
. ../punch.sh
statusDir="`pwd`"
statusPath="$statusDir/status.txt"
function refresh_punch {
  while true; do
    punch -r > "$statusPath"
    punch -I >> "$statusPath"
    punch -niqm minimal >> "$statusPath"
    sleep 1
  done
}
pid_file="`dirname $0`/.status_pid"
if [ -f "$pid_file" ]; then
  . ./stop.sh
fi
echo 'starting punch status watcher'
refresh_punch > /dev/null &
backgroundPID=$!
echo $backgroundPID > $pid_file
echo "point your browser to file://$statusDir/index.html"
echo "psp to stop"
