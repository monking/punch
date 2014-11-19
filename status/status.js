/*
 * global: process, require, window, XMLHttpRequest
 */

(function() {

	var status;

	status = {

		pattern: /(.*) -- (.*) {3}(.*) {3}([\d:]+) \(([\d:]+)\)\n(.*) -- (.*) {3}(.*) {3}([\d:]+) \(([\d:]+)\)\n.*\n\s*([0-9:]+)\s+(.*)/,

		message: null,

		interval: null,

		update: function(handler) {
			var self = this;

			self.getFile('status.txt', function(err, data) {
				if (!err) {
					var result, portions, hash;

					result = String(data);
					if (result != self.message) {
						portions = result.match(self.pattern);
						if (portions) {
							hash = {
								"today"   : portions[11],
								"elapsed" : portions[5],
								"break"   : portions[10],
								"client"  : portions[1],
								"project" : portions[2],
								"task"    : portions[3]
							};

							handler(hash);
						}
					}
				} else {
					console.log('getFile: error', err);
				}
			});
		},

		repeat: function(handler, period) {
			var self = this;

			period = period || 1000;

			clearInterval(self.interval);

			self.interval = setInterval(function() {
				self.update(handler);
			}, period);
		}

	};

	if (typeof process !== 'undefined') { // node process
		var commands, fs, sys, clc, term;

		fs = require('fs');
		sys = require('sys');
		clc = require('cli-color');

		status.getFile = function(path, callback) {
			var absolutePath = __dirname+'/'+path;
			fs.readFile(absolutePath, callback);
		};

		if (process.argv.length > 2) {
			commands = process.argv.slice(2);
			term = {
				clear: '\033[2J'+"\r"
			};
			if ('watch' == commands[0]) {
				status.repeat(function(hash) {
					var output;

					output = '[' + clc.red(hash.today) +
					' ' + clc.yellow(hash.elapsed) +
					' ' + clc.blue(hash.break) + ']' +
					' ' + hash.client+'/'+hash.project+' -- '+ hash.task;

					sys.print(term.clear+output);
				});
			}
		}
	} else if (window) { // web browser script
		status.getFile = function(path, callback) {
			var request, freshPath;

			freshPath = path+'?'+(new Date().getTime());
			request = new XMLHttpRequest();
			request.open('GET', freshPath, true);
			request.onreadystatechange = function() {
				if (request.readyState === 4) {
					if ((request.status === 0 || request.status === 200)
					&& request.responseText) { // local filesystem gives status of 0
						callback(null, request.responseText);
					} else {
						callback(request.responseText, null);
					}
				}
			};
			request.send();
		};

		window.statusDriver = status;
	}

})();
