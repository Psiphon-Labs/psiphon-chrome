var bgPage = chrome.extension.getBackgroundPage();

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

document.addEventListener('DOMContentLoaded', function() {
  //restoreOptions();
  //document.getElementById('save-button').addEventListener('click', saveOptions);
  document.getElementById('view-logs-button').addEventListener('click', bgPage.viewLogs);
  document.getElementById('force-system-proxy-button').addEventListener('click', bgPage.proxySettings.forceToSystemProxy);
});
