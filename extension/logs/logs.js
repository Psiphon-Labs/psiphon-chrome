'use strict';

var bgPage = chrome.extension.getBackgroundPage();
document.addEventListener('DOMContentLoaded', function () {
  var logViewer = document.getElementById('logs');

  for (var i=0, len=bgPage.logs.length; i < len; i++) {
    logViewer.innerHTML += '<p>' + bgPage.logs[i] + '</p>';
  }

  document.getElementById('select-response-text').addEventListener('click', function() {
    var range = document.createRange();

    range.selectNodeContents(logViewer);

    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
  });
});
