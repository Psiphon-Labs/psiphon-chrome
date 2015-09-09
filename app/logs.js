'use strict';

var bgPage = chrome.extension.getBackgroundPage();
document.addEventListener('DOMContentLoaded', function () {
  var logViewer = document.getElementById('logs');

  for (var i=0, len=bgPage.logs.length; i < len; i++) {
    var li = document.createElement("li");
    li.appendChild(document.createTextNode(bgPage.logs[i]));
    logViewer.appendChild(li)
  }
});
