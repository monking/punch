#---------------------------------------------------------#
#                          PUNCH                          #
#---------------------------------------------------------#
# indent all with tab character, run, repeat until only vars remain on
# their own lines:
#     :%s /.\{-\}\(\w\+\)=\(.*\)/\1\r\t\2/
# then `sort -u` to make `local` list
function punch {
  local onBreak T Y Z a action actionFilter actionFilterInvert b bold client clientDefault clientMarker clientReq d dailySum dailySumFrom date dayCount dayMax doit dosum fUTime externalID format from fromPaid harvest hclAction goToDir goToTimeclockDir io latestfile line lineArray makeLink month normal oneDay other pAction pClient pDate pInOut pProject pT pUTime pY pZ pa pb pd project projectDefault projectReq quiet readLog resumeIn to today uTime verbose wd wdmarker writeFile writePaid year
  ## parse arguments
  while getopts "cC:d:jJ:t:sSf:pl:L:wevkgGhriIoaAm:nqx:" flag
  do
    case $flag in
      a ) resumeIn=y;readLog=lastInLine;clientReq=y;projectReq=y;;
      A ) resumeIn=y;readLog=previousInLine;clientReq=y;projectReq=y;;
      c ) clientReq=y;;
      C ) client="$OPTARG";;
      d ) oneDay="$OPTARG";dosum=y;;
      e ) readLog=whole;;
      f ) from="$OPTARG";;
      g ) goToDir=y;clientReq=y;projectReq=y;;
      G ) goToTimeclockDir=y;;
      h ) harvest=y;hclAction=;;
      i ) readLog=lastInLine;;
      I ) readLog=firstInLine;;
      j ) projectReq=y;clientReq=y;;
      J ) project="$OPTARG";;
      k ) makeLink=y;clientReq=y;projectReq=y;;
      l ) actionFilter="$OPTARG";dosum=y;verbose=y;;
      L ) actionFilter="$OPTARG";actionFilterInvert=y;dosum=y;verbose=y;;
      m ) format="$OPTARG";;
      n ) today=y;dosum=y;;
      o ) readLog=lastOutLine;;
      p ) fromPaid=y;clientReq=y;dosum=y;;
      q ) quiet=y;;
      r ) readLog=lastLine;;
      s ) dosum=y;;
      S ) dosum=y;dailySum=y;format=minimal;;
      t ) to="$OPTARG";;
      v ) verbose=y;dosum=y;;
      w ) writePaid=y;clientReq=y;;
      x ) externalID=$OPTARG;;
    esac
  done
  shift $((OPTIND-1)); OPTIND=1
  wd="$PWD"
  ## read input message (description)
  action="$(echo $@ | sed 's/^\s+|\s+$|\r|\n//g')" 
  if [ -z "$action$readLog$addToIndex" -a "$dosum" != y -a "$goToDir" != y -a "$goToTimeclockDir" != y -a "$writePaid" != y -a "$makeLink" != y ]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    ## show the manpage if not enough arguments given to do anything
    man $PUNCHDIR/.punch.1.gz
    return 0
  fi
  ## default value: format, text editor
  if [ "$(echo $format | perl -pe 's/default|minimal|spreadsheet/y/')" != y ]; then
    format=default
  fi
  if [ -z "$TIMECLOCKEDITOR" ]; then
    TIMECLOCKEDITOR=vim
  fi
  case "$format" in
    default ) ;;
    minimal ) ;;
    spreadsheet ) quiet=y;;
  esac
  ## take the user to the timeclock document directory
  if [ "$goToTimeclockDir" = y ]; then
    cd $TIMECLOCKDIR
    return 0
  fi
  ## default value: end date (varies if logging up to now, or a whole day)
  if [ -z "$to" ]; then
    if [ -n "$oneDay" ]; then
      to="$oneDay 23:59:59"
    else
      to="now"
    fi
  fi
  ### bash hack: underscores # discard [
  if [ -n "$(command -v gdate)" ]; then
    read year month uTime date <<< $(gdate --date="$to" "+%Y %m %s %a_%b_%d_%T_%Z_%Y")
  else
    read year month uTime date <<< $(date --date="$to" "+%Y %m %s %a_%b_%d_%T_%Z_%Y")
  fi
  date="${date//_/ }"
  if [ -z "$year" -o -z "$month" ]; then
    echo "ERROR: invalid time"
    return 0
  fi
  ### ] discard
  ## determine to which file to write
  writeFile="$TIMECLOCKDIR/workclock_${year}_${month}.tsv"
  ## get the last filename, when sorted alphanumerically
  read latestfile other <<< $(\ls -r1 $TIMECLOCKDIR/workclock_*.tsv 2>/dev/null)
  if [ -n "$latestfile" ]; then
    ## gather context for the command: what was the last relevant entry?
    if [ "$readLog" = lastInLine ]; then
      while read -e line; do
        if [ "${line/\"*\"	\"*\"	\"i\"	*/y}" = y ]; then
          eval "lineArray=($line)"
          pUTime="${lineArray[0]}"
          pDate="${lineArray[1]}" # a d b Y T Z
          pIO="${lineArray[2]}"
          pClient="${lineArray[3]}"
          pProject="${lineArray[4]}"
          pAction="${lineArray[5]}"
          pExtID="${lineArray[6]}"
        fi
      done <<< "$(tail -50 "$latestfile")"
    elif [ "$readLog" = previousInLine ]; then
      previousLine=
      while read -e line; do
        if [ -n "$previousLine" ]; then
          eval lineArray=($(echo $previousLine | sed 's/,//g'))
          pUTime="${lineArray[0]}"
          pDate="${lineArray[1]}" # a d b Y T Z
          pIO="${lineArray[2]}"
          pClient="${lineArray[3]}"
          pProject="${lineArray[4]}"
          pAction="${lineArray[5]}"
          pExtID="${lineArray[6]}"
        fi
        if [ "${line/\"*\"	\"*\"	\"i\"	*/y}" = y ]; then
          previousLine=$line
        fi
      done <<< "$(tail -50 "$latestfile")"
    elif [ "$readLog" = firstInLine ]; then
      onBreak=n
      while read -e line; do
        if [ "${line/\"*\"	\"*\"	\"o\"	*/y}" = y ]; then
          onBreak=y
        elif [ $onBreak = y ]; then
          onBreak=n
          eval lineArray=($line)
          pUTime="${lineArray[0]}"
          pDate="${lineArray[1]}" # a d b Y T Z
          pIO="${lineArray[2]}"
          pClient="${lineArray[3]}"
          pProject="${lineArray[4]}"
          pAction="${lineArray[5]}"
          pExtID="${lineArray[6]}"
        fi
      done <<< "$(tail -50 "$latestfile")"
    elif [ "$readLog" = lastOutLine ]; then
      while read -e line; do
        if [ "${line/\"*\"	\"*\"	\"o\"	*/y}" = y ]; then
          eval lineArray=($line)
          pUTime="${lineArray[0]}"
          pDate="${lineArray[1]}" # a d b Y T Z
          pIO="${lineArray[2]}"
          pClient="${lineArray[3]}"
          pProject="${lineArray[4]}"
          pAction="${lineArray[5]}"
          pExtID="${lineArray[6]}"
        fi
      done <<< "$(tail -50 "$latestfile")"
    else
      eval lineArray=($(tail -1 "$latestfile"))
      pUTime="${lineArray[0]}"
      pDate="${lineArray[1]}" # a d b Y T Z
      pIO="${lineArray[2]}"
      pClient="${lineArray[3]}"
      pProject="${lineArray[4]}"
      pAction="${lineArray[5]}"
      pExtID="${lineArray[6]}"
    fi

    if [[ $resumeIn = y ]]; then
      action="$pAction"
      externalID="$pExtID"
      if [[ $pInOut = o ]]; then
        hclAction="resume"
      else
        hclAction="note"
      fi
    fi
  fi
  ## store client/project metadata (1/?)
  if [ ! -a "$CLIENTSDIR" ]; then
    mkdir -p "$CLIENTSDIR"
  fi
  ## if the user is indending to add an entry, gather all necessary info from input or sheet context
  if [ -n "$action" ]; then
    clientReq=y
    projectReq=y
    ## determine if the entry is logging in or out
    if [[ $action =~ ^(stop|out|break|lunch|done)(:.*)?$ ]]; then
      readLog=lastLine
      io=o
      if [[ -z $hclAction ]]; then hclAction="stop"; fi
    else
      io=i
      if [[ -z $hclAction ]]; then hclAction="start"; fi
    fi
  elif [ "$readLog" = lastInLine ]; then
    # sum up the project you're currently on
    clientReq=y
    projectReq=y
  fi
  if [ -z "$client" -a "$clientReq" == y ]; then
    if [ -n "$pClient" -a -n "$readLog" ]; then
      client=$pClient
    else
      if [ -n "$pClient" ]; then
        clientDefault=" [$pClient]"
      fi
      printf "client$clientDefault: "
      cd "$CLIENTSDIR/"
      ## if no client provided, prompt with autocomplete of previously logged clients
      read -e client
      cd "$wd"
      if [ -z "$client" ]; then
        client="$pClient"
      fi
    fi
  fi
  ### bash hack: underscores
  client="$(echo $client | perl -pe 's/\/|\n|\r//g' | perl -pe 's/[^\w]+/_/g')"
  ## write client metadata
  clientMarker="$CLIENTSDIR/$client"
  if [ ! -d "$clientMarker" ]; then
    mkdir "$clientMarker"
  fi
  if [ "$writePaid" = y ]; then
    echo "$from" > "$clientMarker/.paid"
  fi
  if [ -z "$project" -a "$projectReq" == y ]; then
    if [ -n "$pProject" -a -n "$readLog" ]; then
      project=$pProject
    else
      if [ -n "$pProject" ]; then
        projectDefault=" [$pProject]"
      fi
      printf "project$projectDefault: "
      cd "$clientMarker"
      ## if no project, prompt for project name with autocomplete of previous projects on this client
      read -e project
      cd "$wd"
      if [ -z "$project" ]; then
        project="$pProject"
      fi
    fi
  fi
  ### bash hack: underscores
  project="$(basename "$project" | perl -pe 's/\/|\n|\r//g' | perl -pe 's/[^\w]+/_/g')"
  if [ ! -d "$clientMarker/$project" ]; then
    mkdir -p "$clientMarker/$project"
  fi
  ## project metadata: symlink to working directory
  wdmarker="$clientMarker/$project/working_directory"
  branch_marker="$clientMarker/$project/working_branch"
  if [ "$makeLink" = y ]; then
    unlink "$wdmarker" 2>/dev/null
    ln -s "$wd" "$wdmarker"
    branch="$(git branch | grep '\*' | sed 's/^\* //')"
    [[ -n "$branch" ]] && echo -n "$branch" > "$branch_marker"
    echo "link established"
  fi
  ## if user desires, go to the project's working directory
  if [[ "$goToDir" = y ]]; then
    if [[ -L "$wdmarker" ]]; then
      cd "$(readlink "$wdmarker")"
      if [[ -f  "$branch_marker" ]]; then
        current_branch="$(git branch | grep '\*' | sed 's/^\* //')"
        linked_branch="$(cat "$branch_marker")"
        if [[ -n "$current_branch" && -n "$linked_branch" && "$current_branch" != "$linked_branch" ]]; then
          read -p "Checkout $linked_branch? [Y/n]"
          if [[ "$REPLY" =~ ^([yY].*)?$ ]]; then
            git checkout "$linked_branch"
          fi
        fi
      fi
    elif [[ -d "$wdmarker" ]]; then
      read -ep "Which directory do you want? $(ls -1 "$wdmarker")"
    else
      echo "No working directory is set for this project. Make one with the -k option."
    fi
  fi
  if [[ -n "$action" ]]; then
    ## show summary of new entry
    echo "$client -- $project   $action   #$externalID   ($date)"
    ## write new entry to file
    echo "\"$uTime\"	\"$date\"	\"$io\"	\"$client\"	\"$project\"	\"$action\"	\"$externalID\"" >> "$writeFile"
    sort "$writeFile" -o "$writeFile"

    ### harvest integration: discard [
    if [[ $harvest = y && -n $hclAction ]]; then
      if [[ $hclAction = note ]]; then
        hcl $hclAction $action
      else
        hcl $hclAction
      fi
    fi
    ### ] discard
  elif [ "$dosum" = y ]; then

    ## sum between two dates, filtering by client, project, external ID, or text search
    function punchsum {
      local T Y Z a actionFilterOptions actionSum actionTitle actions b clientTitle d date fDate fMonth fSDate fUTime fYear fYMD hours hoursTitle lastAction lastProject lastUTime line lineAction lineClient lineExtID lineIO lineProject lineUTime maxClLen maxPrLen minutes month numLines onLine period projectSum projectTitle projects readFile readMonth readYear sum sumFrom sumProject sumTo uTime year
      sumFrom="$1"
      sumTo="$2"
      if [ -z "$quiet" -a "$(uname | perl -pe 's/.*CYGWIN.*/CYGWIN/i')" = "CYGWIN" ]; then
        echo "WARNING: Cygwin calculates very slowly."
      fi
      if [ -n "$(command -v gdate)" ]; then
        read fYear fMonth fUTime fDate fSDate fYMD <<< $(gdate --date="$sumFrom" "+%Y %m %s %a_%b_%d_%T_%Z_%Y %a_%m/%d %Y/%m/%d")
        read year month uTime date <<< $(gdate --date="$sumTo" "+%Y %m %s %a_%b_%d_%T_%Z_%Y")
      else
        read fYear fMonth fUTime fDate fSDate fYMD <<< $(date --date="$sumFrom" "+%Y %m %s %a_%b_%d_%T_%Z_%Y %a_%m/%d %Y/%m/%d")
        read year month uTime date <<< $(date --date="$sumTo" "+%Y %m %s %a_%b_%d_%T_%Z_%Y")
      fi
      fDate="${fDate//_/ }"
      fSDate="${fSDate//_/ }"
      date="${date//_/ }"
      hoursTitle="HOURS"
      clientTitle="CLIENT"
      projectTitle="PROJECT"
      actionTitle="ACTION"
      sum=0; lastUTime=0; projects=""; actions=""; readYear=$fYear; readMonth=$fMonth; maxPrLen=${#projectTitle}; maxClLen=${#clientTitle};
      actionFilterOptions="-ic"
      if [[ $actionFilterInvert = y ]]; then
        actionFilterOptions="-v $actionFilterOptions"
      fi
      while [ $readYear$readMonth -le $year$month ]; do
        readFile="$TIMECLOCKDIR/workclock_${readYear}_${readMonth}.tsv"
        if [ -r "$readFile" ]; then
          numLines=$(grep -c '^' "$readFile")
          onLine=0
          while read line; do
            if [ -z "$line" ]; then continue; fi
            onLine=$(($onLine + 1))
            if [ -z "$quiet" ]; then
              echo -ne "  computing $readYear/$readMonth ($numLines entries) -- $((${onLine}*100/${numLines}))%\r"
            fi

            eval lineArray=($line)
            lineUTime="${lineArray[0]}"
            lineDate="${lineArray[1]}" # a d b Y T Z
            lineIO="${lineArray[2]}"
            lineClient="${lineArray[3]}"
            lineProject="${lineArray[4]}"
            lineAction="${lineArray[5]}"
            lineExtID="${lineArray[6]}"

            if [ "$lastUTime" -ne 0 ]; then
              period="$(expr $lineUTime - $lastUTime)"
              if [ -z "$(eval "echo \$sum_$lastProject")" ]; then
                projects="$projects $lastProject"
              fi
              eval "local sum_$lastProject=\"\$(expr 0\$sum_$lastProject + $period)\""
              if [ -z "$(eval "echo \$sum_$lastAction")" ]; then
                actions="$actions $lastAction"
              fi
              eval "local sum_$lastAction=\"\$(expr 0\$sum_$lastAction + $period)\""
              sum="$(expr $sum + $period)"
              lastUTime=0
            fi
            if [ $lineUTime -gt $fUTime -a $lineUTime -lt $uTime ]; then
              if [[ $lineIO = i && ( -z "$client" || "$lineClient" = "$client" ) && ( -z "$project" || "$lineProject" = "$project" ) && ( -z "$actionFilter" || ( $(echo $lineAction | grep $actionFilterOptions "$actionFilter") -gt 0 ) ) ]]; then
                if [ ${#lineClient} -gt $maxClLen ]; then maxClLen=${#lineClient}; fi
                if [ ${#lineProject} -gt $maxPrLen ]; then maxPrLen=${#lineProject}; fi
                lastProject="${lineClient}___$(echo "$lineProject" | perl -pe 's/[^a-zA-Z0-9\n\r]+/_/g')"
                lastAction="${lastProject}__$(echo "$lineAction" | perl -pe 's/[^a-zA-Z0-9\n\r]+/_/g')__$lineExtID"
                lastUTime=$lineUTime
              else 
                lastUTime=0
                lastProject=""
                lastAction=""
              fi
            fi
          done < "$readFile"
        fi
        if [ -a "$(command -v gdate)" ]; then
          read readYear readMonth <<< $(gdate --date="$readMonth/1/$readYear +1 month" "+%Y %m")
        else
          read readYear readMonth <<< $(date --date="$readMonth/1/$readYear +1 month" "+%Y %m")
        fi
      done
      if [ -z "$quiet" ]; then
        echo -ne "                     \r"
      fi
      if [ "$lastUTime" -ne 0 ]; then
        period=$(($uTime - $lastUTime))
        if [ -z "$(eval "echo \$sum_$lastProject")" ]; then
          projects="$projects $lastProject"
        fi
        eval "local sum_$lastProject=\"\$(expr 0\$sum_$lastProject + $period)\""
        if [ -z "$(eval "echo \$sum_$lastAction")" ]; then
          actions="$actions $lastAction"
        fi
        eval "local sum_$lastAction=\"\$(expr 0\$sum_$lastAction + $period)\""
        sum="$(expr $sum + $period)"
      fi
      if [ $sum -eq 0 ]; then
        return 0
      fi
      case "$format" in
        minimal ) echo -e "$fSDate : $(formatSeconds $sum minutes hours)";;
        spreadsheet ) ;;
        * ) echo -e "$fDate (from)\n$date ('til)\n";;
      esac

      if [ "$format" == "default" ]; then
        if [ -z "$client" ]; then
          echo "$(pad $((7 - ${#hoursTitle})))$hoursTitle  $clientTitle$(pad $(($maxClLen - ${#clientTitle})))  $projectTitle"
        else
          echo "$(pad $((7 - ${#hoursTitle})))$hoursTitle  $projectTitle"
        fi
      fi
      for sumProject in $projects; do
        eval "projectSum=\$sum_$sumProject"
        read lineClient lineProject <<< $(echo $sumProject | perl -pe 's/__+/ /g')
        hours="$(formatSeconds $projectSum minutes hours)"
        if [ -z "$client" ]; then
          case "$format" in
            spreadsheet ) echo "$fYMD  $hours  $lineClient  ${lineProject//_/ }";;
            * ) echo "$(pad $((7 - ${#hours})))$hours  $lineClient$(pad $(($maxClLen - ${#lineClient})))  ${lineProject//_/ }";;
          esac
        else
          case "$format" in
            spreadsheet ) echo "$fYMD  $hours  ${lineProject//_/ }";;
            * ) echo "$(pad $((7 - ${#hours})))$hours  ${lineProject//_/ }";;
          esac
        fi
      done

      if [ "$verbose" = y ]; then
        if [ "$format" == "default" ]; then
          echo ''
          if [ -z "$client" ]; then
            echo "$(pad $((7 - ${#hoursTitle})))$hoursTitle  $(pad $(($maxClLen - ${#clientTitle})))$clientTitle  $(pad $(($maxPrLen - ${#projectTitle})))$projectTitle  $actionTitle"
          else
            echo "$(pad $((7 - ${#hoursTitle})))$hoursTitle  $(pad $(($maxPrLen - ${#projectTitle})))$projectTitle  $actionTitle"
          fi
        fi
        for action in $actions; do
          eval "actionSum=\$sum_$action"
          read lineClient lineProject lineAction lineExtID <<< $(echo $action | perl -pe 's/__+/ /g')
          hours="$(formatSeconds $actionSum minutes hours)"
          if [ -z "$client" ]; then
            case "$format" in
              spreadsheet ) echo "$fYMD  $hours  $lineClient  $lineProject  ${lineAction//_/ }";;
              * ) echo "$(pad $((7 - ${#hours})))$hours  $(pad $(($maxClLen - ${#lineClient})))$lineClient  $(pad $(($maxPrLen - ${#lineProject})))$lineProject  ${lineAction//_/ } #$lineExtID";;
            esac
          else
            case "$format" in
              spreadsheet ) echo "$fYMD  $hours  $lineProject  ${lineAction//_/ }";;
              * ) echo "$(pad $((7 - ${#hours})))$hours  $(pad $(($maxPrLen - ${#lineProject})))$lineProject  ${lineAction//_/ } #$lineExtID";;
            esac
          fi
        done
        case "$format" in 
          spreadsheet ) ;;
          * ) echo "----------------------------------------------------";;
        esac
      fi

      if [ "$format" == "default" ]; then
        echo "hours: $(formatSeconds $sum minutes hours)"
      fi
    }

    ## determine sum start date for different behaviors (one day, last pay period start)
    if [ -n "$oneDay" ]; then
      from="$oneDay 00:00:00"
    elif [ "$fromPaid" = y ]; then
      from="$(cat "$clientMarker/.paid")"
    elif [ "$today" = y ]; then
      from="today 0:00"
    fi
    if [ -z "$from" ]; then
      from="$month/1/$year"
    fi
    if [ "$dailySum" = y ]; then
      ## print out the sums for each day separately
      if [ -a "$(command -v gdate)" ]; then
        fUTime=$(gdate --date="$from" "+%s")
      else
        fUTime=$(date --date="$from" "+%s")
      fi
      dayMax=$(((uTime - fUTime) / 86400))
      if [ $(((uTime - fUTime) % 86400)) -ne 0 ]; then
        dayMax=$((dayMax+1))
      fi
      dayCount=0
      dailySumFrom="$(echo $from | perl -pe 's/ \d:\d+(:\d+)//')"
      if [ "$format" == "default" ]; then
        echo "----------------------------------------------------"
      fi
      while [ $dayCount -lt $dayMax ]; do
        punchsum "$dailySumFrom +${dayCount}days" "$dailySumFrom +$(($dayCount+1))days"
        dayCount=$((dayCount+1))
      done
    else
      ## OR print out one sum for the whole time period
      punchsum "$from" "$to"
    fi
  elif [ "$readLog" = "whole" ]; then
    ## open the desired timesheet in the text editor
    if [ -r "$writeFile" ]; then
      $TIMECLOCKEDITOR "$writeFile"
    else
      $TIMECLOCKEDITOR "$latestfile"
    fi
    return 0
  elif [ -n "$readLog" ]; then
    ## show the previous line from the timesheet, formatted and showing time running
    echo "$pClient -- $pProject   $pAction    #$pExtID  $(echo $pT | perl -pe 's/:\d+$//') $(formatSeconds $(($uTime - $pUTime)) minutes hours) ago ($pDate)"
    return 0
  fi
}

#---------------------------------------------------------#
#                   NUMBER FORMATTING                     #
#---------------------------------------------------------#
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
## find the full path of a file or directory, following all symlinks
function canon {
  local wd PHYS_DIR RESULT TARGET_FILE
  TARGET_FILE=$1

  wd=`pwd`
  cd `dirname $TARGET_FILE`
  TARGET_FILE=`basename $TARGET_FILE`

  # Iterate down a (possible) chain of symlinks
  while [ -L "$TARGET_FILE" ]
  do
    TARGET_FILE=`readlink $TARGET_FILE`
    cd `dirname $TARGET_FILE`
    TARGET_FILE=`basename $TARGET_FILE`
  done

  # Compute the canonicalized name by finding the physical path 
  # for the directory we're in and appending the target file.
  PHYS_DIR=`pwd -P`
  RESULT=$PHYS_DIR/
  if [ ! "$TARGET_FILE" = "." ]; then
    RESULT=$RESULT$TARGET_FILE
  fi
  if [ -t 1 ]; then
    echo $RESULT
  else
    printf $RESULT
  fi
  cd "$wd"
}

#---------------------------------------------------------#
#                       ALIASES                           #
#---------------------------------------------------------#
## preset shortcut shell aliases
alias p='punch'
alias pe='punch -e'
alias pg='punch -g'
alias pgg='punch -G'
alias pgr='punch -gr'
alias pd='punch -d'
alias pdv='punch -vd'
alias pin='punch -a'
alias pbk='punch -A'
alias pn='punch -n'
alias pnv='punch -nv'
alias pk='punch -k'
alias pkr='punch -kr'
alias pl='punch -l'
alias pr='punch -r'
alias pt='punch -t'
alias pss='$PUNCHDIR/status/start.sh'
alias psp='$PUNCHDIR/status/stop.sh'
# alias pw='while true; do echo -en "\n\n\n\n\n\n\n\n\n\n$(punch -r)"; sleep 2; done'
alias pw='pss; node $DESKDIR/punch/status/status.js watch' # more info, a little bit slower since it relies on pss
