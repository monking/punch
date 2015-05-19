// punch - time tracker

var nconf = require('nconf');
var defaults = require('./defaults.json');

// TODO - default values
  // TODO: get last timesheet path
  // TODO: read last timesheet into memory
  // TODO: read the last line of the last timesheet as default values for each attribute

// TODO - parse arguments
  // arguments
nconf
  .argv(defaults)
  .add('user', { type: 'file', file: './config.json' });

// console.log(defaults); // XXX
console.log(nconf.get()); // XXX

// TODO - show the manpage if not enough arguments given to do anything
// TODO - take the user to the timeclock document directory
// TODO - default value: end date (varies if logging up to now, or a whole day)
// TODO - determine to which file to write
// TODO - get the last filename, when sorted alphanumerically
// TODO - gather context for the command: what was the last relevant entry?
// TODO - store client/project metadata (1/?)
// TODO - if the user is indending to add an entry, gather all necessary info from input or sheet context
// TODO - determine if the entry is logging in or out
// TODO - if no client provided, prompt with autocomplete of previously logged clients
// TODO - write client metadata
// TODO - if no project, prompt for project name with autocomplete of previous projects on this client
// TODO - project metadata: symlink to working directory
// TODO - if user desires, go to the project's working directory
// TODO - show summary of new entry
// TODO - write new entry to file
// TODO - sum between two dates, filtering by client, project, external ID, or text search
// TODO - determine sum start date for different behaviors (one day, last pay period start)
// TODO - print out the sums for each day separately
// TODO - OR print out one sum for the whole time period
// TODO - open the desired timesheet in the text editor
// TODO - show the previous line from the timesheet, formatted and showing time running
// TODO - pad a string with any character (e.g. " " or "0")
// TODO - turn seconds input to string output as HH:MM:SS
// TODO - find the full path of a file or directory, following all symlinks
// TODO - preset shortcut shell aliases

// FIXME - current CSV format needs to have an "out" entry at the beginning, or it will fail its math

/*
 * determine mode of operation: sum, edit, go, link
 */
