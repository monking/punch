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

Configure these variables so that:

- `PUNCHDIR` is the path to the directory where this script lies.
- `TIMECLOCKDIR` is the path to the directory where your logs will be
  stored.
- `CLIENTSDIR` is the path to the directory where links to your project
  directories will be stored.

Futher optional environment variables are:
- `REMOTETIMECLOCKDIR` is a scp-compatible path to remote copy of
  `TIMECLOCKDIR`, for use with the `-d` and `-u` options.
- `TIMECLOCKEDITOR` to determine which editor to use (default Vim).

**If you're on a Mac**, you'll need to install `gdate`, packaged in `coreutils`. If
you're using Homebrew, you can do `brew install coreutils`.

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
    
    SYNOPSIS
           punch [-c | -C <client>] [j | -J <project>] [-t <time> | -i | -o]
                 [-s | -S] [-f <time> | -p | -h | -k] [-wr] [-vq | -m <format>]
				 [-du] [-elg] [<action> | -a]
    
    OPTIONS
           -a
               Resume the last action, not counting breaks.
    
           -c
			   Specify a client. If no other argument supplies the client name,
		   then you will be prompted to enter the name. Previously entered
		   names can be auto-completed using the <TAB> key.
    
           -C <client>
               Specify the client name explicitly.
    
           -d
			   Download the latest punch file from the server. OVERWRITES
		   WITHOUT CHECKING
    
           -e
			   Open the timeclock file in VIM. Which timeclock file is opened
		   depends on the value of -t.
    
           -f <time>
			   Set the time from which to start. This can be in any format that
		   GNU date can parse. The default is the first of day  of the month
		   specified by -t.
    
           -g
			   Go to the directory linked to a project. (non-functional as a
		   script. Save this as a function to use this feature)
    
           -h <date>
			   Supply  a  date  to  get  the  hours  worked  on  that  day.
		   This is equivalent to using -s -f "MM/DD/YYYY 00:00:00" -t
		   "MM/DD/YYYY 23:59:59", where "MM/DD/YYYY" is the given date, in any
		   format. Implies -s.
    
           -i
               Use / show the last IN record in the timeclock.
    
           -j
			   Enter the project at a prompt, with previous project records
		   available for  autocomplete  by  pressing  <TAB>.  This  is enabled
		   by default when recording an entry in the timeclock.
    
           -J <project>
               Specify the project name explicitly.
    
           -k
			   Set the beginning of the time range to midnight today.  Implies
		   -s, overrides -f.
    
           -l
			   Create a link to the current working directory under the given
		   client and project.
    
           -m
			   Specify the output format: "default", "minimal", or
		   "spreadsheet".
    
           -o
               Use / show the last OUT record in the timeclock.
    
           -p
			   Use the time stored in the client record as the beginning of the
		   time range (see -w). Implies -s, overrides -f.
    
           -q
			   Do not show percent progress. Use this option when piping
		   stdout.
    
           -r
               Use / show the last record in the timeclock.
    
           -s
			   Calculate the sum of all the records in a given range, from a
		   specific client if provided.
    
           -S
			   Calculate  daily sums of all the records in a given range, from
		   a specific client if provided. Implies "minimal" format.
    
           -t <time>
			   Set the current time for a new timeclock entry, or when summing,
		   set the end of the time range. This can be in any  format that GNU
		   date can parse. The default is "now".
    
           -u
			   Upload the latest punch file to the server. OVERWRITES WITHOUT
		   CHECKING
    
           -v
			   Show a verbose sum, with totals by task, not just by project.
		   Implies -s.
    
           -w
			   Write the beginning of the time range to the client record
		   (see -p).
    
    BUGS
		   If a block of time crosses midnight, it is counted in the day in
	   which it begins, rather than being divided at midnight.

Notes / Caveats
---------------

One feature of the punch script is to help you quickly navigate to your
projects' working directories. In order do this `punch` must be defined as a
function of your current shell session, rather than a script with its own
session scope. This is the reason for doing `source punch.sh` once rather than
putting `punch.sh` in your `PATH`.

The first entry in every log line is a Unix timestamp. This makes sorting the
list a breeze, but also makes it very impracticle to change the time value of
an item. If you made a mistaken entry, you need to use `punch -e` or its alias
`pe` to manually remove the line. Then use `punch -t` or `pt` to make the
correct entry, and sort the now disordered lines (in Vim: visual select lines
with <Shift>+V `:!sort`)
