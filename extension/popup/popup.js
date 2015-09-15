'use strict';

function getUiElements () {
  ui.logo.element = document.getElementById('logo-status');
  ui.buttons.connect = document.getElementById('connect-button');
  ui.buttons.disconnect = document.getElementById('disconnect-button');
  ui.buttons.settings = document.getElementById('settings-button');
}

function initialButtonText () {
  ui.buttons.connect.innerText = chrome.i18n.getMessage('popup_connect_button');
  ui.buttons.disconnect.innerText = chrome.i18n.getMessage('popup_disconnect_button');
}

function updateUiState(state) {
  switch (state) {
    case 'connecting':
      ui.buttons.connect.innerText = chrome.i18n.getMessage('popup_connecting_button');
      ui.buttons.connect.disabled = true;
      break;
    case 'connected':
      ui.logo.element.src = ui.logo.connectedImage;

      initialButtonText();

      ui.buttons.connect.style.display = 'none';
      ui.buttons.disconnect.style.display = 'initial';
      ui.buttons.disconnect.disabled = false;

      break;
    case 'disconnecting':
      ui.buttons.disconnect.innerText = chrome.i18n.getMessage('popup_disconnecting_button');
      ui.buttons.disconnect.disabled = true;
      break;
    case 'disconnected':
      ui.logo.element.src = ui.logo.disconnectedImage;

      initialButtonText();

      ui.buttons.connect.style.display = 'initial';
      ui.buttons.disconnect.style.display = 'none';
      ui.buttons.connect.disabled = false;

      break;
    default:
      break;
  }
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
          updateUiState('connecting');
          break;
        case 'connected':
          updateUiState('connected');
          break;
        case 'disconnecting':
          updateUiState('disconnecting');
          break;
        case 'disconnected':
          updateUiState('disconnected');
          break;
        default:
          console.error(chrome.i18n.getMessage('error_unhandled_background_message_status'), message.status);
          break;
      }
    } else {
      console.error(chrome.i18n.getMessage('error_unhandled_background_message_type'), message);
    }
  }
});

document.addEventListener('DOMContentLoaded', function () {
  getUiElements();
  initialButtonText();

  if (bgPage.connectionState.active) {
    updateUiState('connected');
  } else {
    updateUiState('disconnected');
  }

  ui.buttons.connect.addEventListener('click', bgPage.psiphon.connect);
  ui.buttons.disconnect.addEventListener('click', bgPage.psiphon.disconnect);
  ui.buttons.settings.addEventListener('click', function () { chrome.runtime.openOptionsPage(); });
});
