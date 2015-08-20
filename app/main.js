(function () {
  'use strict';

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
    getCurrent: function () {
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
      proxySettings.getCurrent()
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
      nativeHost.postMessage({'psi':'connect'});
      document.getElementById('connect-button').disabled = true;
      document.getElementById('disconnect-button').disabled = false;
    },
    disconnect: function () {
      nativeHost.postMessage({'psi':'disconnect'});
      document.getElementById('connect-button').disabled = false;
      document.getElementById('disconnect-button').disabled = true;
    }
  };

  function appendMessage(text) {
    document.getElementById('response').innerHTML += '<p>' + text + '</p>';
  }

  function updateStatus(type, text) {
    document.getElementById(type).innerHTML = text;
  }

  function onNativeMessage(message) {
    if (message.noticeType) {
      switch (message.noticeType) {
        case 'AvailableEgressRegions':
          updateStatus(message.noticeType, message.data.regions);
          connectionState.egressRegions = message.data.regions;
          break;
        case 'ListeningHttpProxyPort':
          updateStatus(message.noticeType, message.data.port);
          connectionState.proxies.http = message.data.port;
          break;
        case 'ListeningSocksProxyPort':
          updateStatus(message.noticeType, message.data.port);
          connectionState.proxies.socks = message.data.port;
          break;
        case 'Tunnels':
          updateStatus(message.noticeType, message.data.count);
          connectionState.tunnels = message.data.count;
          break;
        case 'Homepage':
          updateStatus(message.noticeType, message.data.url);
          connectionState.homepage.url = message.data.url;
          break;
        default:
          break;
      }

      if (!connectionState.active && connectionState.tunnels > 0 && connectionState.proxies.socks && connectionState.homepage.url) {
        connectionState.active = true;
        tunnelAvailable();
      } else if (connectionState.active && (connectionState.tunnels < 1 || !connectionState.proxies.socks)) {
        connectionState.active = false;
        noTunnelAvailable();
      }

      appendMessage(JSON.stringify(message));
    } else {
      appendMessage('<span style="font-weight:bold;color:gold;">Unhandled Message: ' + JSON.stringify(message) + '</span>');
    }
  }

  function tunnelAvailable() {
    console.log('A tunnel is available, setting proxy');

  proxySettings.set(connectionState.proxies.socks, ['localhost']);
    document.getElementById('ProxyStatus').innerHTML = '<span style="color: green;">In Use</span>';

    if (connectionState.homepage.shown === false) {
      connectionState.homepage.shown = true;
      window.setTimeout(function () {
        window.open(connectionState.homepage.url);
      }, 1000);
    }
  }

  function noTunnelAvailable() {
    console.log('No tunnel is available, resetting proxy');

    proxySettings.restoreInitial();
    document.getElementById('ProxyStatus').innerHTML = '<span style="color: red;">Not Used</span>';
  }

  document.addEventListener('DOMContentLoaded', function () {
    // Register an unload handler to cleanup when the tab is closing
    window.addEventListener('beforeunload', function (event) {
      console.log('Extension unloaded, cleaning up');
      psiphon.disconnect();
      proxySettings.restoreInitial();
    });

    // Store proxy settings prior to beginning managing them in the extension
    proxySettings.getCurrent();

    // Initialize connection to native host
    nativeHost = chrome.runtime.connectNative('ca.psiphon.chrome');
    nativeHost.onMessage.addListener(onNativeMessage);
    nativeHost.onDisconnect.addListener(function() {
      appendMessage('Failed to connect: ' + chrome.runtime.lastError.message);
      nativeHost = null;
    });

    // Set up click handlers for connect and disconnect buttons
    document.getElementById('connect-button').addEventListener('click', psiphon.connect);
    document.getElementById('disconnect-button').addEventListener('click', psiphon.disconnect);
    document.getElementById('force-system-proxy-button').addEventListener('click', proxySettings.forceToSystemProxy);

    document.getElementById('select-response-text').addEventListener('click', function() {
      var range = document.createRange();
      var toSelect = document.getElementById('response');

      range.selectNodeContents(toSelect);

      var selection = window.getSelection();
      selection.removeAllRanges();
      selection.addRange(range);
    });

    // Set up event handler for Chrome proxy errors
    chrome.proxy.onProxyError.addListener(function(error) {
      appendMessage('<b style="color: red;">Proxy Error: </b>' + JSON.stringify(error));
    });
  });
})();
