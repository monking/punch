(function() {
	var statusMessage, timerTimeout, timerDuration, timerMessage,
	durationInputPattern, createTimer, dingTimer, notification;

  timerTimeout = null;

  durationInputPattern = /^([0-9.]+)( (.*))?/;

  createTimer = function() {
    var inputMatch;
    timerDuration = window.prompt('timer: minutes and mssage (e.g. "5 tea")');
    clearTimeout(timerTimeout);
    if (timerDuration) {
      inputMatch = timerDuration.match(durationInputPattern);
      if (inputMatch) {
        timerDuration = inputMatch[1];
        timerMessage = inputMatch[2];
      }
      if (window.webkitNotifications && window.webkitNotifications.checkPermission() != 0) {
        window.webkitNotifications.requestPermission();
      }
      timerTimeout = setTimeout(dingTimer, timerDuration * 60000);
      document.querySelector('#status .elapsed').className = 'elapsed timer';
    } else {
      document.querySelector('#status .elapsed').className = 'elapsed';
    }
  };

  dingTimer = function() {
    var title, message;
    title = 'punch';
    message = timerMessage || 'DING!';
    document.querySelector('#status .elapsed').className = 'elapsed';
    timerTimeout = null;
    if (!/^file:/.test(window.location.href) && window.webkitNotifications && window.webkitNotifications.checkPermission() == 0) {
      notification = window.webkitNotifications.createNotification('na.png', title, message);
      notification.show();
    } else {
      window.alert(title + ': ' + message);
    }
  };

  updateSize = function() {
    document.body.style.fontSize = (window.innerWidth / 100) + 'px';
  }

  window.onload = function() {

		var handlStatus = function(hash) {
			var statusElement;

			statusElement = document.getElementById('status');

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

		window.statusDriver.repeat(handleStatus, 5000);
    updateSize();
    window.onresize = updateSize;
  };

  window.createTimer = createTimer;
  window.dingTimer = dingTimer;
  window.timerTimeout = timerTimeout;

})();
