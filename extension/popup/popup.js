'use strict';

function getUiElements () {
  ui.logo.element = document.getElementById('logo-status');
  ui.buttons.connect = document.getElementById('connect-button');
  ui.buttons.disconnect = document.getElementById('disconnect-button');
  ui.buttons.settings = document.getElementById('settings-button');
}

function resetButtonText () {
  ui.buttons.connect.innerText = 'Connect';
  ui.buttons.disconnect.innerText = 'Disconnect';
}

function isConnected() {
  ui.logo.element.src = ui.logo.connectedImage;

  resetButtonText();

  ui.buttons.connect.style.display = 'none';
  ui.buttons.disconnect.style.display = 'initial';
}

function isDisconnected() {
  ui.logo.element.src = ui.logo.disconnectedImage;

  resetButtonText();

  ui.buttons.connect.style.display = 'initial';
  ui.buttons.disconnect.style.display = 'none';
}

var bgPage = chrome.extension.getBackgroundPage();
var ui = {
  buttons: {
    connect: null,
    disconnect: null,
    settings: null
  },
  logo: {
    element: null,
    connectedImage: '../img/logos/128.png',
    disconnectedImage: '../img/logos/bw-128.png'
  }
};


chrome.runtime.onMessage.addListener(function (message) {
  if (typeof message !== 'undefined' && message) {
    if (message.type === 'status') {
      switch (message.status) {
        case 'connecting':
          ui.buttons.connect.innerText = 'Connecting...';
          break;
        case 'disconnecting':
          ui.buttons.disconnect.innerText = 'Disconnecting...';
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
    } else {
      console.error('Unhandled "type" for message: "%s"', message.status);
    }
  }
});

document.addEventListener('DOMContentLoaded', function () {
  getUiElements();

  if (bgPage.connectionState.active) {
    isConnected();
  } else {
    isDisconnected();
  }

  ui.buttons.connect.addEventListener('click', bgPage.psiphon.connect);
  ui.buttons.disconnect.addEventListener('click', bgPage.psiphon.disconnect);
  ui.buttons.settings.addEventListener('click', function () { chrome.runtime.openOptionsPage(); });
});
