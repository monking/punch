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
			var statusElement;

			statusElement = d.getElementById('status');

			statusElement.innerHTML = '<div class="time">' +
				'<div class="today">' + hash.today + '</div>' +
				'<div class="elapsed' + timerClass + '" title="Set timer">' + hash.elapsed + '</div>' +
				'<div class="break">' + hash.break + '</div>' +
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
