'use strict';

var bgPage = chrome.extension.getBackgroundPage();
document.addEventListener('DOMContentLoaded', function () {
  var logViewer = document.getElementById('logs');

  document.getElementById('select-response-text-button').addEventListener('click', function() {
    var range = document.createRange();

    range.selectNodeContents(logViewer);

    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
  });

  // Initial dump of existing logs to page
  for (var i=0, len=bgPage.logs.length; i < len; i++) {
    logViewer.innerHTML += '<p>' + bgPage.logs[i] + '</p>';
  }

  // Add newly available log entries into the log box every 1 second
  var numberOfLogs = bgPage.logs.length;
  var logRefreshInterval = setInterval(function() {
    if (bgPage.logs.length > numberOfLogs) {
      for (var i=numberOfLogs-1, len=bgPage.logs.length; i < len; i++) {
        logViewer.innerHTML += '<p>' + bgPage.logs[i] + '</p>';
      }
      numberOfLogs = bgPage.logs.length;
    }
  }, 1000)
});
