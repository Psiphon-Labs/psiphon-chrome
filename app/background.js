(function () {
  'use strict';
  var mainWindowTabId = null;

  chrome.tabs.onRemoved.addListener(function (tabId) {
    if (tabId === mainWindowTabId) {
      chrome.browserAction.setIcon({path: 'logos/psiphon-logo-bw-38.png'});
    }
  });

  chrome.browserAction.onClicked.addListener(function (tab) {
    chrome.tabs.create({'url': chrome.extension.getURL('index.html')}, function (tab) {
      mainWindowTabId = tab.id;
    });
  });
})();
