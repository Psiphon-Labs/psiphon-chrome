'use strict';

function isConnected() {
  logoStatus.element.src = logoStatus.connectedSource;
  document.getElementById('connect-button').disabled = true;
  document.getElementById('disconnect-button').disabled = false;
}

function isDisconnected() {
  logoStatus.element.src = logoStatus.disconnectedSource;
  document.getElementById('connect-button').disabled = false;
  document.getElementById('disconnect-button').disabled = true;
}

function uiStateFromBackgroundPage () {
  if (bgPage.connectionState.active) {
    isConnected();
  } else {
    isDisconnected();
  }
}

var bgPage = chrome.extension.getBackgroundPage();
var logoStatus = {
  element: null,
  connectedSource: 'logos/psiphon-logo-128.png',
  disconnectedSource: 'logos/psiphon-logo-bw-128.png'
};

chrome.runtime.onMessage.addListener(function (message) {
  if (typeof message !== 'undefined' && message) {
    if (message.type === 'status') {
      switch (message.status) {
        case 'connecting':
          console.log('connecting');
          break;
        case 'disconnecting':
          console.log('disconnecting');
          break;
        case 'connected':
          isConnected();
          break;
        case 'disconnected':
          isDisconnected();
          break;
        default:
          console.error('Unhandled "status" message of type "%s"', message.status);
          break;
      }
    }
  }
});

document.addEventListener('DOMContentLoaded', function () {
  logoStatus.element = document.getElementById('logo-status');
  uiStateFromBackgroundPage();

  document.getElementById('connect-button').addEventListener('click', bgPage.psiphon.connect);
  document.getElementById('disconnect-button').addEventListener('click', bgPage.psiphon.disconnect);
  document.getElementById('settings-button').addEventListener('click', function () { chrome.runtime.openOptionsPage(); });
});
