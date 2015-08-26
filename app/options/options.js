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

document.addEventListener('DOMContentLoaded', restoreOptions);
document.getElementById('save').addEventListener('click', saveOptions);
