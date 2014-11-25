/* global w d */

(function(w, d) {
	var timerTimeout, timerDuration, timerMessage, updateSize, timerClass,
	durationInputPattern, createTimer, dingTimer, notification;

	timerClass = '';

  timerTimeout = null;

  durationInputPattern = /^([0-9.]+)( (.*))?/;

  createTimer = function() {
    var inputMatch;
    timerDuration = w.prompt('timer: minutes and mssage (e.g. "5 tea")');
    clearTimeout(timerTimeout);
    if (timerDuration) {
      inputMatch = timerDuration.match(durationInputPattern);
      if (inputMatch) {
        timerDuration = inputMatch[1];
        timerMessage = inputMatch[2];
      }
      if (w.webkitNotifications && w.webkitNotifications.checkPermission() !== 0) {
        w.webkitNotifications.requestPermission();
      }
      timerTimeout = setTimeout(dingTimer, timerDuration * 60000);
      d.querySelector('#status .elapsed').className = 'elapsed timer';
    } else {
      d.querySelector('#status .elapsed').className = 'elapsed';
    }
  };

  dingTimer = function() {
    var title, message;
    title = 'punch';
    message = timerMessage || 'DING!';
    d.querySelector('#status .elapsed').className = 'elapsed';
    timerTimeout = null;
    if (!/^file:/.test(w.location.href) && w.webkitNotifications && w.webkitNotifications.checkPermission() === 0) {
      notification = w.webkitNotifications.createNotification('na.png', title, message);
      notification.show();
    } else {
      w.alert(title + ': ' + message);
    }
  };

  updateSize = function() {
    d.body.style.fontSize = (w.innerWidth / 100) + 'px';
  };

  w.onload = function() {

		var handleStatus = function(hash) {
			var statusElement, todayColor, elapsedColor, breakColor;

			statusElement = d.getElementById('status');

			todayColor = w.statusDriver.colorByDegree(
				hash.today,
				w.statusDriver.ranges.today.max,
				w.statusDriver.ranges.today.min
			);
			elapsedColor = w.statusDriver.colorByDegree(
				hash.elapsed,
				w.statusDriver.ranges.now.max,
				w.statusDriver.ranges.now.min
			);
			breakColor = w.statusDriver.colorByDegree(
				hash.break,
				w.statusDriver.ranges.break.max,
				w.statusDriver.ranges.break.min
			);

			statusElement.innerHTML = '<div class="time">' +
				'<div class="today ' + todayColor + '">' + hash.today + '</div>' +
				'<div class="elapsed ' + elapsedColor + ' ' + timerClass + '" title="Set timer">' + hash.elapsed + '</div>' +
				'<div class="break ' + breakColor + '">' + hash.break + '</div>' +
				'</div>' +
				'<div class="client">' + hash.client + '</div>' +
				' <div class="project">' + hash.project + '</div>' +
				' <div class="task">' + hash.task + '</div>';

			statusElement.querySelector('.elapsed').onclick = createTimer;

			timerClass = (timerTimeout !== null ? ' timer' : '');
		};

		w.statusDriver.repeat(handleStatus, 5000);
    updateSize();
    w.onresize = updateSize;
  };

  w.createTimer = createTimer;
  w.dingTimer = dingTimer;
  w.timerTimeout = timerTimeout;

})(window, document);
