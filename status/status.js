(function() {
  var updateStatus, interval, statusPattern, statusMessage, timerTimeout,
  timerDuration, timerMessage, durationInputPattern, createTimer, dingTimer, notification;

  timerTimeout = null;

  statusPattern = /(.*) -- (.*)   (.*)   ([\d:]+) \(([\d:]+)\)\n(.*) -- (.*)   (.*)   ([\d:]+) \(([\d:]+)\)\n.*\n\s*([0-9:]+)\s+(.*)/;

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

  updateStatus = function() {
    var statusElement, request, portions;
    statusElement = document.getElementById('status');
    request = new XMLHttpRequest();
    request.open('GET', 'status.txt?'+(new Date().getTime()), true);
    request.onreadystatechange = function() {
      if (request.readyState == 4
      && (request.status == 0 || request.status == 200)
      && request.responseText
      && request.responseText != statusMessage) { // local filesystem gives status of 0
        statusMessage = request.responseText;
        portions = statusMessage.match(statusPattern);
        if (portions) {
          timerClass = (timerTimeout !== null ? ' timer' : '');
          statusElement.innerHTML = '<div class="time">' +
              '<div class="today">' + portions[11] + '</div>' +
              '<div class="elapsed' + timerClass + '" title="Set timer">' + portions[5] + '</div>' +
              '<div class="break">' + portions[10] + '</div>' +
            '</div>' +
            '<div class="client">' + portions[1] + '</div>' +
            ' <div class="project">' + portions[2] + '</div>' +
            ' <div class="task">' + portions[3] + '</div>';
          statusElement.querySelector('.elapsed').onclick = createTimer;
        }
      }
    };
    request.send();
  };

  updateSize = function() {
    document.body.style.fontSize = (window.innerWidth / 100) + 'px';
  }

  window.onload = function() {
    updateStatus();
    interval = setInterval(updateStatus, 5000);
    updateSize();
    window.onresize = updateSize;
  };

  window.createTimer = createTimer;
  window.dingTimer = dingTimer;
  window.timerTimeout = timerTimeout;

})();
