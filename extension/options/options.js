function getUiElements () {
  ui.buttons.viewLogs = document.getElementById('view-logs-button');
  ui.buttons.forceSystemProxy = document.getElementById('force-system-proxy-button');
}

function saveOptions () {
  chrome.storage.local.set({
    // Settings object to save
  }, function() {
    if (!chrome.runtime.lastError) {
      // Successful settings save
    } else {
      // Error updating settings
    }
  });
}

function restoreOptions () {
  chrome.storage.local.get({
    // Default object to populate if none is found
  }, function(items) {
    // Items is an object keyed to the previously stored values/default object above
    // Set options DOM elements based on retrieved settings
    if (!chrome.runtime.lastError) {
      // Successful settings retrieval
    } else {
      // Error retrieving settings
    }
  });
}

var bgPage = chrome.extension.getBackgroundPage();

var ui = {
  buttons: {
    viewLogs: null,
    forceSystemProxy: null
  }
}

document.addEventListener('DOMContentLoaded', function() {
  getUiElements();

  ui.buttons.viewLogs.innerText = chrome.i18n.getMessage('options_view_logs_button');
  ui.buttons.forceSystemProxy.innerText = chrome.i18n.getMessage('options_force_system_proxy_button');

  ui.buttons.viewLogs.addEventListener('click', bgPage.viewLogs);
  ui.buttons.forceSystemProxy.addEventListener('click', bgPage.proxySettings.forceToSystemProxy);
});
