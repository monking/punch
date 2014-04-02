#!/bin/bash
pid_file="`dirname $0`/status_pid"
if [ -f "$pid_file" ]; then
  echo 'stopping punch status watcher';
  kill `cat $pid_file`
  rm $pid_file
else
  echo 'no punch status watcher is running';
fi
