/*
 * global: process, require, window, XMLHttpRequest
 */

(function() {

	var status;

	status = {

		pattern: /(.*) -- (.*) {3}(.*) {3}([\d:]+) \(([\d:]+)\)\n(.*) -- (.*) {3}(.*) {3}([\d:]+) \(([\d:]+)\)\n.*\n\s*([0-9:]+)\s+(.*)/,

		message: null,

		interval: null,

		ranges: {
			"today": {
				min: '0:00',
				max: '8:00'
			},
			"now": {
				min: '0:00',
				max: '2:00'
			},
			"break": {
				min: '0:00',
				max: '2:00'
			},
		},

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
								"topic"   : portions[2],
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

			self.update(handler);
		},

		toMinutes: function(time) {
			var timeParts, minutes;

			if (typeof time !== 'string') {
				minutes = time;
			} else {
				timeParts = time.split(':');

				if (timeParts.length === 2) {
					minutes = Number(timeParts[0]) * 60 + Number(timeParts[1]);
				} else {
					minutes = Number(timeParts[0]);
				}
			}

			return minutes;
		},

		colorByDegree: function(originalValue, max, min) {
			var value, degrees, degree;

			value = this.toMinutes(originalValue);
			max = this.toMinutes(max);
			min = min ? this.toMinutes(min) : 0;

			degrees = [
				"blue",
				"cyan",
				"green",
				"yellow",
				"red"
			];

			degree = Math.floor((value - min) / (max - min) * (degrees.length - 1)); // only exceeding max gives last color
			degree = Math.min(degree, degrees.length - 1);

			return degrees[degree];

		}

	};

	if (typeof process !== 'undefined') { // node process
		var commands, fs, sys, clc, formatByDegree;

		fs = require('fs');
		sys = require('sys');
		clc = require('cli-color');

		formatByDegree = function(time, max, min) {
			var color;

			color = status.colorByDegree(time, max, min);

			return clc[color](time);
		};

		status.getFile = function(path, callback) {
			var absolutePath = __dirname+'/'+path;
			fs.readFile(absolutePath, callback);
		};

		if (process.argv.length > 2) {
			commands = process.argv.slice(2);
			if ('watch' === commands[0]) {
				status.repeat(function(hash) {
					var output;

					output = '[' + formatByDegree(hash.today, status.ranges.today.max, status.ranges.today.min) + ' today' +
					', ' + formatByDegree(hash.elapsed, status.ranges.now.max, status.ranges.now.min) + ' now'+
					', ' + formatByDegree(hash.break, status.ranges.break.max, status.ranges.break.min) + ' since break]' +
					'\n' + hash.client+'/'+hash.topic+' -- '+ hash.task;

					sys.print(clc.reset+output);
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
