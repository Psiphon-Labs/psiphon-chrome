'use strict';

var logs = [];
function logMessage (message) {
  logs.push(message);
}

function viewLogs () {
  chrome.tabs.create({'url': chrome.extension.getURL('logs/logs.html')});
}

var nativeHost = null;

var connectionState = {
  active: false,
  tunnels: 0,
  egressRegions: [],
  homepage: {
    url: null,
    shown: false
  },
  proxies: {
    socks: null,
    http: null
  }
};

var proxySettings = {
  initial: null,
  storeCurrent: function () {
    chrome.proxy.settings.get({'incognito': false}, function(config) {
      proxySettings.initial = config.value;
      console.log(JSON.stringify(config));
    });
  },
  restoreInitial: function () {
    if (proxySettings.initial) {
      chrome.proxy.settings.set({value: proxySettings.initial, scope: 'regular'}, function() {});
    } else {
      console.warn('No initial settings to restore');
    }
  },
  forceToSystemProxy: function () {
    chrome.proxy.settings.set({value: {mode: "system"}}, function() {});
    proxySettings.storeCurrent()
  },
  set: function (port, bypassList) {
    if (typeof port === 'undefined') {
      console.warn('proxySettings.set - port was undefined, defaulting to 1080');
      port = 1080;
    }
    if (typeof bypassList === 'undefined') {
      console.warn('proxySettings.set - bypassList was undefined, defaulting to []');
      bypassList = [];
    }

    chrome.proxy.settings.set({value: {
      mode: 'fixed_servers',
      rules: {
        singleProxy: {
          scheme: 'socks5',
          host: 'localhost',
          port: port
        },
        bypassList: bypassList
      }
    }, scope: 'regular'}, function() {});
  }
};

var psiphon = {
  connect: function () {
    chrome.runtime.sendMessage({type: 'status', status: 'connecting'});
    nativeHost.postMessage({'psi':'connect'});
  },
  disconnect: function () {
    chrome.runtime.sendMessage({type: 'status', status: 'disconnecting'});
    nativeHost.postMessage({'psi':'disconnect'});
  }
};

function onNativeMessage(message) {
  if (message.noticeType) {
    switch (message.noticeType) {
      case 'AvailableEgressRegions':
        connectionState.egressRegions = message.data.regions;
        break;
      case 'ListeningHttpProxyPort':
        connectionState.proxies.http = message.data.port;
        break;
      case 'ListeningSocksProxyPort':
        connectionState.proxies.socks = message.data.port;
        break;
      case 'Tunnels':
        connectionState.tunnels = message.data.count;
        break;
      case 'Homepage':
        connectionState.homepage.url = message.data.url;
        break;
      default:
        break;
    }

    if (!connectionState.active && connectionState.tunnels > 0 && connectionState.proxies.socks) {
      connectionState.active = true;
      tunnelAvailable();
    } else if (connectionState.active && (connectionState.tunnels < 1 || !connectionState.proxies.socks)) {
      connectionState.active = false;
      noTunnelAvailable();
    }
  }

  logMessage(JSON.stringify(message));
}

function tunnelAvailable() {
  console.log('A tunnel is available, setting proxy');

  proxySettings.set(connectionState.proxies.socks, ['localhost']);
  chrome.runtime.sendMessage({type: 'status', status: 'connected'});
  chrome.browserAction.setIcon({path: 'img/logos/38.png'});

  if (connectionState.homepage.url && connectionState.homepage.shown === false) {
    connectionState.homepage.shown = true;
    window.setTimeout(function () {
      window.open(connectionState.homepage.url);
    }, 1000);
  }
}

function noTunnelAvailable() {
  console.log('No tunnel is available, resetting proxy');

  proxySettings.restoreInitial();
  chrome.runtime.sendMessage({type: 'status', status: 'disconnected'});
  chrome.browserAction.setIcon({path: 'img/logos/bw-38.png'});
}

// Store proxy settings prior to beginning managing them in the extension
proxySettings.storeCurrent();

// Initialize connection to native host
nativeHost = chrome.runtime.connectNative('ca.psiphon.chrome');
nativeHost.onMessage.addListener(onNativeMessage);
nativeHost.onDisconnect.addListener(function() {
  logMessage('failed to connect to native host');
  nativeHost = null;
});

chrome.proxy.onProxyError.addListener(function(error) {
  logMessage('proxy error: ' + JSON.stringify(error));
});
