punch
=====

Bash script to track time on projects in CSV files.

Installation
------------

Copy the following into your `~/.bash_rc` file (or `~/.bash_profile`, as the
case may be), and modify to suit your file structure:

    export PUNCHDIR="$HOME/punch"
    export TIMECLOCKDIR="$PUNCHDIR/timeclock"
    export CLIENTSDIR="$PUNCHDIR/clients"
    source $PUNCHDIR/punch.sh

Edit these variables so that:

- `PUNCHDIR` is the path to the directory where this script lies.
- `TIMECLOCKDIR` is the path to the directory where your logs will be
  stored.
- `CLIENTSDIR` is the path to the directory where links to your project
  directories will be stored.

Futher optional environment variables are:
- `REMOTETIMECLOCKDIR` (for `-d` and `-u` options) an scp-compatible path to a
  copy of `TIMECLOCKDIR`
- `TIMECLOCKEDITOR` to determine which editor to use (default Vim)

**If you're on a Mac**, you'll need to install `gdate`, packaged in `coreutils`. If
you're using Homebrew, you can do `brew install coreutils`. The BSD `date`
utility doesn't allow formatting a date other than NOW.

Usage
-----

The script defines many aliases for itself. The most commonly used are:
- `p <task>`to switch to a task
- `p [out|break|lunch]` to punch out quickly with a mildly descriptive message
- `pgr` to return to the directory of the current project
- `pr` to see what your current task is, when it was started, and how long
  you've been on it
- `pk` to see a summary of time spent today
- `pkv` to see the time spent on all tasks today
- `pd|pu` to download/upload at the beginning/end of the day
- `p -Scf Monday -t Friday` to generate a daily summary for a week with one client

Typing just `punch` in the command-line will give you the function's manpage,
copied here:

    NAME
           punch - Record and calculate timeclock entries
g
    SYNOPSIS
           punch [-c | -C <client>] [j | -J <project>] [-t <time> | -i | -o]
                 [-s | -S] [-f <time> | -p | -h | -k] [-wr] [-vq | -m <format>]
         [-du] [-elg] [<action> | -a]
g
    OPTIONS
           -a
               Resume the last action, not counting breaks.
g
           -c
         Specify a client. If no other argument supplies the client name,
       then you will be prompted to enter the name. Previously entered
       names can be auto-completed using the <TAB> key.
g
           -C <client>
               Specify the client name explicitly.
g
           -d
         Download the latest punch file from the server. OVERWRITES
       WITHOUT CHECKING
g
           -e
         Open the timeclock file in VIM. Which timeclock file is opened
       depends on the value of -t.
g
           -f <time>
         Set the time from which to start. This can be in any format that
       GNU date can parse. The default is the first of day  of the month
       specified by -t.
g
           -g
         Go to the directory linked to a project. (non-functional as a
       script. Save this as a function to use this feature)
g
           -h <date>
         Supply  a  date  to  get  the  hours  worked  on  that  day.
       This is equivalent to using -s -f "MM/DD/YYYY 00:00:00" -t
       "MM/DD/YYYY 23:59:59", where "MM/DD/YYYY" is the given date, in any
       format. Implies -s.
g
           -i
               Use / show the last IN record in the timeclock.
g
           -j
         Enter the project at a prompt, with previous project records
       available for  autocomplete  by  pressing  <TAB>.  This  is enabled
       by default when recording an entry in the timeclock.
g
           -J <project>
               Specify the project name explicitly.
g
           -k
         Set the beginning of the time range to midnight today.  Implies
       -s, overrides -f.
g
           -l
         Create a link to the current working directory under the given
       client and project.
g
           -m
         Specify the output format: "default", "minimal", or
       "spreadsheet".
g
           -o
               Use / show the last OUT record in the timeclock.
g
           -p
         Use the time stored in the client record as the beginning of the
       time range (see -w). Implies -s, overrides -f.
g
           -q
         Do not show percent progress. Use this option when piping
       stdout.
g
           -r
               Use / show the last record in the timeclock.
g
           -s
         Calculate the sum of all the records in a given range, from a
       specific client if provided.
g
           -S
         Calculate  daily sums of all the records in a given range, from
       a specific client if provided. Implies "minimal" format.
g
           -t <time>
         Set the current time for a new timeclock entry, or when summing,
       set the end of the time range. This can be in any  format that GNU
       date can parse. The default is "now".
g
           -u
         Upload the latest punch file to the server. OVERWRITES WITHOUT
       CHECKING
g
           -v
         Show a verbose sum, with totals by task, not just by project.
       Implies -s.
g
           -w
         Write the beginning of the time range to the client record
       (see -p).
g
    BUGS
     If a block of time crosses midnight, it is counted in the day in which
       it begins, rather than being divided at midnight.

     If the last entry in the logs is not "clocking out", then sums which end
     with that entry will be capped at the end of the period specified.  E.G.
     Summing with the -k option will treat the task as ending at the current
     time, while using the -h option will treat it as ending at midnight.

     punch rounds all times down to the minute when printing sums, so that
     the individual sums in a report may not add up exactly to the total
     shown. The larger number will always be the more accurate.

Notes / Caveats
---------------

The first field in every log entry is a Unix timestamp. This makes sorting the
list a breeze, but also makes it very impractical to change the time value of
an item. If you made a mistaken entry, you need to use `punch -e`, or its alias
`pe` to manually remove the line. Then use `punch -t` or `pt` to make the
correct entry. Any other fields can easily be changed in the log file.

One feature of the punch script is to help you quickly navigate to your
projects' working directories. In order do this `punch` must be defined as a
function of your current shell session, rather than a script with its own
session scope. This is the reason for doing `source punch.sh` once rather than
putting `punch.sh` in your `PATH`.


Todo
----

- show summary and detailed sums in one command
