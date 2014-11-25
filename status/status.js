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

			self.update(handler);
		}

	};

	if (typeof process !== 'undefined') { // node process
		var commands, fs, sys, clc, toMinutes, formatByDegree;

		fs = require('fs');
		sys = require('sys');
		clc = require('cli-color');

		toMinutes = function(time) {
			var timeParts;

			if (typeof time !== 'string') {
				return time;
			}

			timeParts = time.split(':');

			if (timeParts.length === 2) {
				return Number(timeParts[0] * 60 + timeParts[1]);
			}

			return Number(timeParts[0]);
		};

		formatByDegree = function(originalValue, max, min) {
			var value, degrees, degree;

			value = toMinutes(originalValue);
			max = toMinutes(max);
			min = min ? toMinutes(min) : 0;

			degrees = [
				clc.blue,
				clc.green,
				clc.yellow,
				clc.red
			];

			degree = Math.floor((value - min) / (max - min) * degrees.length);
			degree = Math.min(degree, degrees.length - 1);

			return degrees[degree](originalValue);

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

					output = '[' + formatByDegree(hash.today, '8:00') + ' today' +
					', ' + formatByDegree(hash.elapsed, '5:00') + ' now'+
					', ' + formatByDegree(hash.break, '4:00') + ' since break]' +
					'\n' + hash.client+'/'+hash.project+' -- '+ hash.task;

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
