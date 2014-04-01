(function() {
  var updateStatus, interval, statusPattern, statusMessage;

  statusPattern = /(.*) -- (.*)   (.*)   ([\d:]+) \(([\d:]+)\)\n(.*) -- (.*)   (.*)   ([\d:]+) \(([\d:]+)\)/;

  updateStatus = function() {
    var statusElement, request, portions;
    statusElement = document.getElementById('status');
    request = new XMLHttpRequest();
    request.open('GET', punchStatusPath+'?'+(new Date().getTime()), true);
    request.onreadystatechange = function() {
      if (
      request.readyState == 4
      && (request.status == 0 || request.status == 200)
      && request.responseText
      && request.responseText != statusMessage) { // local filesystem gives status of 0
        statusMessage = request.responseText;
        portions = statusMessage.match(statusPattern);
        statusElement.innerHTML = '<div class="time">' +
            '<div class="punched">' + portions[4] + '</div>' +
            '<div class="elapsed">' + portions[5] + '</div>' +
            '<div class="break">' + portions[10] + '</div>' +
          '</div>' +
          '<span class="client">' + portions[1] + '</span>' +
          ' <span class="project">' + portions[2] + '</span>' +
          ' <span class="task">' + portions[3] + '</span>';
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
})();
