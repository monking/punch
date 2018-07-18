function whisper {
	1>&2 echo $*
}
## pad a string with any character (e.g. " " or "0")
function pad {
  local len str pad padAmt
  if [ -n "$1" ]; then
    len=$1
  else
    return 0
  fi
  if [ -n "$2" ]; then
    str="$2"
  else
    str=""
  fi
  if [ -n "$3" ]; then
    pad="$3"
  else
    pad=" "
  fi
  padAmt=$(($len - ${#str}))
  if [ $padAmt -gt 0 ]; then
    for i in $(eval echo \{1..$padAmt\}); do
      echo -n "$pad"
    done
  fi
  echo -n $str
}
## turn seconds input to string output as HH:MM:SS
function formatSeconds {
  local dayPlural days formatted granularity hours minutes maxScale scale seconds unit unitPlural
  if [ -z "$1" ]; then
    return 0
  fi
  if [ -n "$2" ]; then
    unit="$2"
  else
    unit="seconds"
  fi
  case "$3" in
    seconds) maxScale=1;;
    minutes) maxScale=2;;
    hours) maxScale=3;;
    *) maxScale=4;;
  esac
  if [ $unit = "days" ]; then
    granularity=4
  elif [ $unit = "hours" ]; then
    granularity=3
  elif [ $unit = "minutes" ]; then
    granularity=2
  else
    granularity=1
  fi

  seconds=0
  minutes=0
  hours=0
  days=0
  if [ $maxScale -gt 1 ]; then
    seconds=$(($1 % 60))
  elif [ $maxScale -eq 1 ]; then
    seconds=$1
  fi
  if [ $maxScale -gt 2 -a $1 -gt 60 ]; then
    minutes=$(($1 / 60 % 60))
  elif [ $maxScale -eq 2 ]; then
    minutes=$(($1 / 60))
  fi
  if [ $maxScale -gt 3 -a $1 -gt 3600 ]; then
    hours=$(($1 / 3600 % 24))
  elif [ $maxScale -eq 3 ]; then
    hours=$(($1 / 3600))
  fi
  if [ $maxScale -ge 4 ]; then
    days=$(($1 / 86400))
  fi

  unitPlural="$unit"
  if [ "$(eval "echo \$$unit")" -eq 1 ]; then
    unitPlural="$(echo $unitPlural | sed 's/s$//')"
  fi

  if [ $days -gt 0 ]; then
    scale=4
  elif [ $hours -gt 0 ]; then
    scale=3
  elif [ $minutes -gt 0 ]; then
    scale=2
  else
    scale=1
  fi

  if [ $granularity -gt $scale ]; then
    # echo -n "0 $unitPlural"
    echo -n "0:00"
    return 0
  fi

  formatted=""
  if [ $scale -ge 4 -a $granularity -le 4 ]; then
    if [ $days -ne 1 ]; then
      dayPlural="s"
    fi
    formatted="$formatted $days day$dayPlural"
  fi
  if [ $scale -ge 2 -a $granularity -le 3 ]; then
    if [ -n "$formatted" ]; then
      formatted="$formatted "
    fi
    formatted="$formatted$hours"
  fi
  if [ $scale -ge 2 -a $granularity -le 2 ]; then
    if [ -n "$formatted" ]; then
      formatted="$formatted:"
    fi
    formatted="$formatted$(pad 2 $minutes 0)"
  fi
  if [ $scale -ge 1 -a $granularity -le 1 ]; then
    if [ -n "$formatted" ]; then
      formatted="$formatted:"
    fi
    formatted="$formatted$(pad 2 $seconds 0)"
  fi
  echo -n "$formatted"
}
