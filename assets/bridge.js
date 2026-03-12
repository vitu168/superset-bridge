
window.SupersetBridge = {
  dashboard: null,
  _fetchToken: async function (domain, uuid) {
    const url = domain + '/guest-token?dashboard_id=' + encodeURIComponent(uuid);
    const resp = await fetch(url);
    if (!resp.ok) throw new Error('Token fetch failed: HTTP ' + resp.status);
    const data = await resp.json();
    return data.token;
  },

  initWithTokenFetch: async function (
    uuid, domain, theme, languageCode,
    siteIds, hideTitle, filtersExpanded, urlParamsRefresh
  ) {
    try {
      const token = await this._fetchToken(domain, uuid);
      await this._embed(uuid, domain, token, theme, languageCode, siteIds, hideTitle, filtersExpanded, urlParamsRefresh);
    } catch (e) {
      console.error('[SupersetBridge] ❌ initWithTokenFetch failed:', e);
      this._showError('Failed to load dashboard: ' + e.message);
    }
  },

  init: async function (
    uuid, domain, token, theme, languageCode,
    siteIds, hideTitle, filtersExpanded, urlParamsRefresh
  ) {
    try {
      await this._embed(uuid, domain, token, theme, languageCode, siteIds, hideTitle, filtersExpanded, urlParamsRefresh);
    } catch (e) {
      console.error('[SupersetBridge] ❌ init failed:', e);
      this._showError('Failed to load dashboard: ' + e.message);
    }
  },

  updateUI: function (theme) {
    const isDark = theme === 'dark';
    document.body.classList.toggle('dark', isDark);
    document.body.classList.toggle('light', !isDark);
    console.log('[SupersetBridge] ✅ Theme → ' + theme);
  },

  _embed: async function (
    uuid, domain, token, theme, languageCode,
    siteIds, hideTitle, filtersExpanded, urlParamsRefresh
  ) {
    if (typeof supersetEmbeddedSdk === 'undefined') {
      console.error('[SupersetBridge] ❌ Superset SDK not loaded');
      this._showError('Superset SDK failed to load. Check network.');
      return;
    }

    const mountPoint = document.getElementById('superset-mount');
    if (!mountPoint) {
      console.error('[SupersetBridge] ❌ Mount point #superset-mount not found');
      return;
    }

    this._showLoading(true);

    const urlParams = {};
    if (urlParamsRefresh) urlParams.refresh = true;
    urlParams.theme = theme;
    if (languageCode && typeof languageCode === 'string') {
      urlParams.lang = languageCode;
    }
    if (siteIds && Array.isArray(siteIds) && siteIds.length > 0) {
      urlParams.siteId = siteIds;
    }

    if (hideTitle || hideTitle === 'true') {
      urlParams.hideTitle = true;
    }

    try {
      this.dashboard = await supersetEmbeddedSdk.embedDashboard({
        id: uuid,
        supersetDomain: domain,
        mountPoint: mountPoint,
        fetchGuestToken: () => Promise.resolve(token),
        dashboardUiConfig: {
          hideTitle: hideTitle,
          standalone: true,
          filters: { expanded: filtersExpanded },
          urlParams: urlParams,
          languageCode: languageCode,
        },
        iframeSandboxExtras: ['allow-top-navigation', 'allow-popups-to-escape-sandbox'],
      });
      this._showLoading(false);
      this.updateUI(theme);
      console.log('[SupersetBridge] ✅ Dashboard ready');
    } catch (e) {
      this._showLoading(false);
      console.error('[SupersetBridge] ❌ embedDashboard failed:', e);
      this._showError('Failed to embed dashboard: ' + e.message);
    }
  },
   
  _showLoading: function (show) {
    const el = document.getElementById('_bridge_loading');
    if (el) el.className = show ? '' : 'hidden';
  },

  _showError: function (message) {
    const el = document.getElementById('_bridge_error');
    if (el) { el.className = 'visible'; el.textContent = message; }
    this._showLoading(false);
  },

  _showInfo: function (message) {
    const el = document.getElementById('_bridge_info');
    if (el) { el.className = 'visible'; el.textContent = message; }
    this._showInfo(false);
  },

  _showWarning: function (message){
    const el = document.getElementById('_bridge_warning');
    if (el ) {
      el.className = 'visible';
      el.textContent = message;
    }
    else {
      console.warn('[SupersetBridge] ⚠️ ' + message);
    }
  }
};
