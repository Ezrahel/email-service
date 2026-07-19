// ══════════════════════════════════════════════════════
// Email Service Dashboard — Vanilla SPA
// ══════════════════════════════════════════════════════

// ── State ────────────────────────────────────────────
const state = {
  token: localStorage.getItem('token') || '',
  apiKey: localStorage.getItem('apiKey') || '',
  page: 'login',
  tab: '',
  params: null,
  loading: false,

  emails: [],
  emailDetail: null,
  domains: [],
  templates: [],
  templateDetail: null,
  templateVersions: [],
  webhooks: [],
  webhookDetail: null,
  apiKeys: [],
  apiKeyDetail: null,
  analytics: null,
  analyticsDeliverability: null,
  analyticsEvents: null,
  organization: null,
  health: null,
  healthReadiness: null,
  healthLiveness: null,
  dashboardOverview: null,
  dashboardDeliverability: null,
  dashboardUsage: null,
  dashboardProviders: null,
  dashboardActivity: null,
  dashboardAlerts: null,
};

// ── Router ───────────────────────────────────────────
const routes = {
  login:         { render: renderLogin,        mount: mountLogin,        guard: false },
  dashboard:     { render: renderDashboard,    mount: mountDashboard,    guard: true },
  emails:        { render: renderEmails,       mount: mountEmails,       guard: true },
  domains:       { render: renderDomains,      mount: mountDomains,      guard: true },
  templates:     { render: renderTemplates,    mount: mountTemplates,    guard: true },
  webhooks:      { render: renderWebhooks,     mount: mountWebhooks,     guard: true },
  apiKeys:       { render: renderApiKeys,      mount: mountApiKeys,      guard: true },
  analytics:     { render: renderAnalytics,    mount: mountAnalytics,    guard: true },
  organization:  { render: renderOrganization, mount: mountOrganization, guard: true },
  health:        { render: renderHealth,       mount: mountHealth,       guard: true },
};

function navigate(page, params, tab) {
  state.page = page;
  state.params = params;
  state.tab = tab || getDefaultTab(page);
  render();
  const isSubRoute = params && typeof params === 'string' && params.includes('/');
  const tabPart = state.tab && !isSubRoute ? '/t/' + state.tab : '';
  const hash = '#' + page + (params ? '/' + params : '') + tabPart;
  history.pushState({ page, params, tab: state.tab }, '', hash);
}

function getDefaultTab(page) {
  const defaults = {
    dashboard: 'overview',
    emails: 'list',
    templates: 'list',
    analytics: 'overview',
    organization: 'view',
    health: 'main',
  };
  return defaults[page] || '';
}

window.addEventListener('popstate', () => {
  const parts = location.hash.replace('#', '').split('/');
  const page = parts[0] || (state.token || state.apiKey ? 'dashboard' : 'login');
  let params = null;
  let tab = '';
  for (let i = 1; i < parts.length; i++) {
    if (parts[i] === 't' && parts[i + 1]) { tab = parts[i + 1]; i++; }
    else if (parts[i] === 'show') { params = parts[i + 1]; i++; }
    else if (parts[i] === 'send') { params = parts[i + 1]; i++; }
    else { params = parts[i]; }
  }
  state.page = page;
  state.params = params;
  state.tab = tab || getDefaultTab(page);
  render();
});

// ── API Client ────────────────────────────────────────
const API = (() => {
  const BASE = '';
  function headers() {
    const h = { 'Content-Type': 'application/json' };
    if (state.token) h['Authorization'] = `Bearer ${state.token}`;
    else if (state.apiKey) h['Authorization'] = `Bearer ${state.apiKey}`;
    return h;
  }
  async function handleResponse(r) {
    if (r.status === 401) {
      if (state.token) {
        try {
          const refreshRes = await fetch(BASE + '/api/v1/auth/refresh', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${state.token}` },
            body: JSON.stringify({ refresh_token: localStorage.getItem('refreshToken') })
          });
          if (refreshRes.ok) {
            const data = await refreshRes.json();
            state.token = data.access_token || data.token;
            localStorage.setItem('token', state.token);
            const retry = await fetch(BASE + path, { method, headers: headers(), body: body ? JSON.stringify(body) : undefined });
            return retry.json();
          }
        } catch {}
      }
      logout();
      throw new Error('Unauthorized');
    }
    if (!r.ok) {
      const err = await r.json().catch(() => ({ error: r.statusText }));
      throw new Error(err.error || err.message || `Request failed (${r.status})`);
    }
    return r.json();
  }
  let path = '';
  let method = '';
  let body = null;
  const client = {
    get: async (p) => { path = p; method = 'GET'; body = null; const r = await fetch(BASE + path, { headers: headers() }); return handleResponse(r); },
    post: async (p, b) => { path = p; method = 'POST'; body = b; const r = await fetch(BASE + path, { method: 'POST', headers: headers(), body: JSON.stringify(b) }); return handleResponse(r); },
    put: async (p, b) => { path = p; method = 'PUT'; body = b; const r = await fetch(BASE + path, { method: 'PUT', headers: headers(), body: JSON.stringify(b) }); return handleResponse(r); },
    del: async (p) => { path = p; method = 'DELETE'; body = null; const r = await fetch(BASE + path, { method: 'DELETE', headers: headers() }); return handleResponse(r); },
  };
  return client;
})();

// ── Utilities ─────────────────────────────────────────
function toast(msg, type = 'success') {
  const container = document.querySelector('.toast-container');
  if (!container) return;
  const el = document.createElement('div');
  el.className = `toast toast-${type}`;
  el.textContent = msg;
  el.onclick = () => el.remove();
  container.appendChild(el);
  setTimeout(() => { if (el.parentNode) el.remove(); }, 4000);
}

function logout() {
  try { API.del('/api/v1/auth/logout').catch(() => {}); } catch {}
  state.token = '';
  state.apiKey = '';
  localStorage.removeItem('token');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('apiKey');
  navigate('login');
}

function html(strings, ...vals) {
  return strings.reduce((acc, s, i) => acc + s + (vals[i] || ''), '');
}

function esc(str) {
  const d = document.createElement('div');
  d.textContent = str ?? '';
  return d.innerHTML;
}

function statusBadge(status) {
  const map = {
    delivered: 'badge-success', sent: 'badge-success',
    failed: 'badge-danger', bounced: 'badge-danger', rejected: 'badge-danger',
    pending: 'badge-warning', queued: 'badge-warning', sending: 'badge-info',
    processing: 'badge-warning',
    active: 'badge-success', verified: 'badge-success',
    unverified: 'badge-warning', revoked: 'badge-danger',
  };
  const cls = map[(status || '').toLowerCase()] || 'badge-info';
  return html`<span class="badge ${cls}">${esc(status)}</span>`;
}

function showModal(content, wide) {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.onclick = (e) => { if (e.target === overlay) closeModal(); };
  overlay.innerHTML = `<div class="modal${wide ? ' modal-wide' : ''}">${content}</div>`;
  document.body.appendChild(overlay);
}

function closeModal() {
  document.querySelector('.modal-overlay')?.remove();
}

function loadingSpinner(msg = 'Loading...') {
  return html`<div class="loading"><div class="spinner"></div><div class="mt-1 text-muted">${msg}</div></div>`;
}

function skeletonBlock() {
  return html`<div class="card"><div class="skeleton skeleton-block"></div><div class="skeleton skeleton-line w80"></div><div class="skeleton skeleton-line w60"></div><div class="skeleton skeleton-line w40"></div></div>`;
}

function tabBar(tabs, active, page) {
  return html`<div class="tabs">${tabs.map(t => html`<a class="${t.id === active ? 'active' : ''}" onclick="navigate('${page}', null, '${t.id}')">${t.label}</a>`).join('')}</div>`;
}

function confirmDialog(msg) {
  return window.confirm(msg);
}

// ── App Shell ─────────────────────────────────────────
function renderShell() {
  const page = state.page;
  const isActive = (p) => p === page || (p === 'emails' && page === 'emails');

  document.getElementById('app').innerHTML = html`
    <div class="sidebar-overlay" id="sidebar-overlay" onclick="toggleSidebar()"></div>
    <button class="menu-toggle" onclick="toggleSidebar()">☰</button>
    <aside class="sidebar" id="sidebar">
      <div class="brand"><h1><span>✉</span> Email Service</h1></div>
      <nav>
        ${navItem('dashboard', '📊', 'Dashboard')}
        ${navItem('emails', '📨', 'Emails')}
        ${navItem('domains', '🌐', 'Domains')}
        ${navItem('templates', '📄', 'Templates')}
        ${navItem('webhooks', '🔗', 'Webhooks')}
        ${navItem('apiKeys', '🔑', 'API Keys')}
        ${navItem('analytics', '📈', 'Analytics')}
        ${navItem('organization', '🏢', 'Organization')}
        ${navItem('health', '❤️', 'Health')}
      </nav>
      <div class="sidebar-footer">
        <button onclick="logout()">🚪 Logout</button>
      </div>
    </aside>
    <div class="main">
      <div class="toast-container"></div>
      <div id="page-content"></div>
    </div>
  `;
  document.querySelectorAll('.sidebar nav a').forEach(a => {
    a.classList.toggle('active', a.dataset.page === page);
  });
}

function toggleSidebar() {
  document.getElementById('sidebar')?.classList.toggle('open');
  document.getElementById('sidebar-overlay')?.classList.toggle('open');
}

function navItem(page, icon, label) {
  return html`<a href="#${page}" data-page="${page}" onclick="navigate('${page}')">${icon} ${label}</a>`;
}

function render() {
  const route = routes[state.page] || routes.dashboard;
  if (route.guard && !state.token && !state.apiKey) return navigate('login');

  if (state.page === 'login') {
    document.getElementById('app').innerHTML = '<div class="toast-container"></div><div id="page-content"></div>';
    document.getElementById('page-content').innerHTML = route.render();
    if (route.mount) setTimeout(() => route.mount(), 0);
    return;
  }

  renderShell();
  const content = document.getElementById('page-content');
  if (!content) return;
  content.innerHTML = route.render();
  if (route.mount) setTimeout(() => route.mount(), 0);
}

// ══════════════════════════════════════════════════════
// 1. LOGIN
// ══════════════════════════════════════════════════════
function renderLogin() {
  return html`
    <div class="login-page">
      <div class="login-card">
        <h1>✉ Email Service</h1>
        <p class="subtitle">Sign in with your API key</p>
        <div class="form-group">
          <label>API Key</label>
          <input type="password" id="login-key" placeholder="em_dev_..." autofocus>
        </div>
        <button class="btn btn-primary" style="width:100%" onclick="doLogin()">Sign In</button>
        <div class="hint">Use your API key to sign in. You can manage API keys from the dashboard once signed in.</div>
      </div>
    </div>
  `;
}

function mountLogin() {
  document.getElementById('login-key')?.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') doLogin();
  });
}

async function doLogin() {
  const key = document.getElementById('login-key')?.value.trim();
  if (!key) return toast('Enter an API key', 'error');
  state.apiKey = key;
  localStorage.setItem('apiKey', key);
  try {
    await API.get('/api/v1/emails?per_page=1');
    navigate('dashboard');
    toast('Signed in successfully');
  } catch (e) {
    state.apiKey = '';
    localStorage.removeItem('apiKey');
    toast(e.message || 'Invalid API key', 'error');
  }
}

// ══════════════════════════════════════════════════════
// 2. DASHBOARD (6 tabs)
// ══════════════════════════════════════════════════════
const dashboardTabs = [
  { id: 'overview', label: 'Overview' },
  { id: 'deliverability', label: 'Deliverability' },
  { id: 'usage', label: 'Usage' },
  { id: 'providers', label: 'Providers' },
  { id: 'activity', label: 'Activity' },
  { id: 'alerts', label: 'Alerts' },
];

function renderDashboard() {
  return html`
    <div class="page-header"><div><h2>Dashboard</h2><p class="subtitle">Overview of your email service</p></div></div>
    ${tabBar(dashboardTabs, state.tab, 'dashboard')}
    <div id="dashboard-content">${loadingSpinner()}</div>
  `;
}

function mountDashboard() {
  loadDashboardTab(state.tab || 'overview');
}

async function loadDashboardTab(tab) {
  const el = document.getElementById('dashboard-content');
  if (!el) return;
  el.innerHTML = loadingSpinner();
  try {
    switch (tab) {
      case 'overview': await loadDashboardOverview(el); break;
      case 'deliverability': await loadDashboardDeliverability(el); break;
      case 'usage': await loadDashboardUsage(el); break;
      case 'providers': await loadDashboardProviders(el); break;
      case 'activity': await loadDashboardActivity(el); break;
      case 'alerts': await loadDashboardAlerts(el); break;
      default: el.innerHTML = '<div class="empty-state"><h3>Select a tab</h3></div>';
    }
  } catch (e) {
    el.innerHTML = html`<div class="empty-state"><h3>Failed to load</h3><p class="text-sm">${esc(e.message)}</p></div>`;
  }
}

async function loadDashboardOverview(el) {
  const data = await API.get('/api/v1/dashboard/overview');
  state.dashboardOverview = data;
  const d = data.data || data;
  el.innerHTML = html`
    <div class="stat-grid">
      <div class="stat-card accent"><div class="label">Total Emails</div><div class="value">${esc(d.total_sent || d.total || 0)}</div></div>
      <div class="stat-card"><div class="label">Delivered</div><div class="value" style="color:var(--green)">${esc(d.delivered || 0)}</div></div>
      <div class="stat-card"><div class="label">Failed</div><div class="value" style="color:var(--red)">${esc(d.failed || 0)}</div></div>
      <div class="stat-card"><div class="label">Bounced</div><div class="value" style="color:var(--yellow)">${esc(d.bounced || 0)}</div></div>
      <div class="stat-card"><div class="label">Opened</div><div class="value">${esc(d.opened || d.opens || 0)}</div></div>
      <div class="stat-card"><div class="label">Clicked</div><div class="value">${esc(d.clicked || d.clicks || 0)}</div></div>
    </div>
    <div class="card">
      <h3>Delivery Rate</h3>
      ${d.total_sent > 0 ? html`<div class="text-lg font-bold" style="color:var(--green)">${((d.delivered || 0) / d.total_sent * 100).toFixed(1)}%</div>` : html`<div class="text-muted">No data yet</div>`}
    </div>
    <div class="card">
      <h3>Quick Actions</h3>
      <div class="flex">
        <button class="btn btn-primary" onclick="navigate('emails', null, 'compose')">✏ Compose Email</button>
        <button class="btn btn-secondary" onclick="navigate('emails')">📨 View Emails</button>
        <button class="btn btn-secondary" onclick="navigate('domains')">🌐 Manage Domains</button>
        <button class="btn btn-secondary" onclick="navigate('analytics')">📈 Analytics</button>
      </div>
    </div>
  `;
}

async function loadDashboardDeliverability(el) {
  const data = await API.get('/api/v1/dashboard/deliverability');
  state.dashboardDeliverability = data;
  const d = data.data || data;
  const byStatus = d.by_status || d.statuses || {};
  el.innerHTML = html`
    <div class="stat-grid">
      <div class="stat-card"><div class="label">Delivery Rate</div><div class="value" style="color:var(--green)">${esc(d.delivery_rate || d.rate || '0')}${typeof d.delivery_rate === 'number' ? '%' : ''}</div></div>
      <div class="stat-card"><div class="label">Bounce Rate</div><div class="value" style="color:var(--yellow)">${esc(d.bounce_rate || '0')}${typeof d.bounce_rate === 'number' ? '%' : ''}</div></div>
      <div class="stat-card"><div class="label">Complaint Rate</div><div class="value" style="color:var(--red)">${esc(d.complaint_rate || '0')}${typeof d.complaint_rate === 'number' ? '%' : ''}</div></div>
    </div>
    <div class="card"><h3>By Status</h3>
      ${Object.keys(byStatus).length > 0 ? html`
        <table><thead><tr><th>Status</th><th>Count</th></tr></thead><tbody>
          ${Object.entries(byStatus).map(([k,v]) => html`<tr><td>${esc(k)}</td><td>${esc(v)}</td></tr>`).join('')}
        </tbody></table>
      ` : '<div class="empty-state text-sm"><h3>No data</h3></div>'}
    </div>
  `;
}

async function loadDashboardUsage(el) {
  const data = await API.get('/api/v1/dashboard/usage');
  state.dashboardUsage = data;
  const d = data.data || data;
  el.innerHTML = html`
    <div class="stat-grid">
      <div class="stat-card"><div class="label">Today</div><div class="value">${esc(d.today || d.today_count || 0)}</div></div>
      <div class="stat-card"><div class="label">This Week</div><div class="value">${esc(d.this_week || d.week_count || 0)}</div></div>
      <div class="stat-card"><div class="label">This Month</div><div class="value">${esc(d.this_month || d.month_count || 0)}</div></div>
      <div class="stat-card accent"><div class="label">Monthly Limit</div><div class="value">${esc(d.limit || d.monthly_limit || '—')}</div></div>
    </div>
    ${d.daily_volumes || d.daily ? html`
      <div class="card"><h3>Daily Volume (last 7 days)</h3>
        <div class="bar-chart-wrap">
          <div class="bar-chart">
            ${(d.daily_volumes || d.daily || []).map(v => html`<div class="bar" style="height:${Math.max((v.count || v) / Math.max(...(d.daily_volumes || d.daily || []).map(x => x.count || x)) * 100, 5)}%"></div>`).join('')}
          </div>
          <div class="bar-labels">${(d.daily_volumes || d.daily || []).map(v => html`<span>${v.label || v.date || ''}</span>`).join('')}</div>
        </div>
      </div>` : ''}
  `;
}

async function loadDashboardProviders(el) {
  const data = await API.get('/api/v1/dashboard/providers');
  state.dashboardProviders = data;
  const d = data.data || data;
  const providers = d.providers || d.breakdown || [];
  el.innerHTML = html`
    <div class="card"><h3>Provider Distribution</h3>
      ${providers.length > 0 ? html`
        <table><thead><tr><th>Provider</th><th>Sent</th><th>Delivered</th><th>Failed</th><th>Rate</th></tr></thead><tbody>
          ${providers.map(p => html`
            <tr><td><strong>${esc(p.name || p.provider)}</strong></td>
            <td>${esc(p.sent || p.count || 0)}</td>
            <td>${esc(p.delivered || 0)}</td>
            <td>${esc(p.failed || 0)}</td>
            <td>${p.sent > 0 ? ((p.delivered || 0) / p.sent * 100).toFixed(1) + '%' : '—'}</td></tr>
          `).join('')}
        </tbody></table>
      ` : '<div class="empty-state"><h3>No provider data</h3></div>'}
    </div>
  `;
}

async function loadDashboardActivity(el) {
  const data = await API.get('/api/v1/dashboard/activity');
  state.dashboardActivity = data;
  const d = data.data || data;
  const items = d.activities || d.recent || d.events || [];
  el.innerHTML = html`
    <div class="card"><h3>Recent Activity</h3>
      ${items.length > 0 ? html`
        <div>${items.map(a => {
          const dotClass = a.status === 'success' || a.status === 'delivered' ? 'success' : a.status === 'failed' || a.status === 'bounced' ? 'fail' : 'info';
          return html`<div class="activity-item"><div class="dot ${dotClass}"></div><div class="content"><strong>${esc(a.action || a.event || a.type || 'Event')}</strong> — ${esc(a.description || a.detail || '')}</div><div class="time">${a.created_at || a.timestamp ? new Date(a.created_at || a.timestamp).toLocaleString() : ''}</div></div>`;
        }).join('')}</div>
      ` : '<div class="empty-state"><h3>No recent activity</h3></div>'}
    </div>
  `;
}

async function loadDashboardAlerts(el) {
  const data = await API.get('/api/v1/dashboard/alerts');
  state.dashboardAlerts = data;
  const d = data.data || data;
  const alerts = d.alerts || d.alert || [];
  el.innerHTML = html`
    <div class="card-header"><h3>Active Alerts</h3></div>
      ${alerts.length > 0 ? html`
        ${alerts.map(a => html`
          <div class="card" style="border-left: 4px solid ${a.severity === 'critical' ? 'var(--red)' : a.severity === 'warning' ? 'var(--yellow)' : 'var(--accent)'}">
            <div class="flex-between"><strong>${esc(a.title || a.name)}</strong> ${statusBadge(a.severity || 'info')}</div>
            <div class="text-sm text-muted mt-1">${esc(a.message || a.description || '')}</div>
            <div class="text-xs text-muted mt-1">${a.created_at ? new Date(a.created_at).toLocaleString() : ''}</div>
          </div>
        `).join('')}
      ` : '<div class="empty-state"><h3>No active alerts</h3><p>Everything looks good</p></div>'}
    </div>
  `;
}

// ══════════════════════════════════════════════════════
// 3. EMAILS (4 tabs + detail modal)
// ══════════════════════════════════════════════════════
const emailTabs = [
  { id: 'list', label: 'All Emails' },
  { id: 'compose', label: 'Compose' },
  { id: 'batch', label: 'Batch Send' },
  { id: 'validate', label: 'Validate' },
];

function renderEmails() {
  return html`
    <div class="page-header"><div><h2>Emails</h2><p class="subtitle">Send and manage transactional emails</p></div></div>
    ${tabBar(emailTabs, state.tab, 'emails')}
    <div id="emails-content">${loadingSpinner()}</div>
  `;
}

function mountEmails() {
  loadEmailsTab(state.tab || 'list');
}

async function loadEmailsTab(tab) {
  const el = document.getElementById('emails-content');
  if (!el) return;
  el.innerHTML = loadingSpinner();
  try {
    switch (tab) {
      case 'list': await loadEmailList(el); break;
      case 'compose': renderComposeForm(el); break;
      case 'batch': renderBatchForm(el); break;
      case 'validate': renderValidateForm(el); break;
      default: el.innerHTML = '<div class="empty-state"><h3>Select a tab</h3></div>';
    }
  } catch (e) {
    el.innerHTML = html`<div class="empty-state"><h3>Failed to load</h3><p class="text-sm">${esc(e.message)}</p></div>`;
  }
}

async function loadEmailList(el) {
  let emails = [];
  try {
    const res = await API.get('/api/v1/emails?per_page=50');
    emails = res.data || [];
    state.emails = emails;
  } catch { state.emails = []; }
  el.innerHTML = html`
    <div class="card">
      <div class="table-controls">
        <input type="text" placeholder="Search by recipient or subject..." id="email-search" oninput="filterEmailTable()">
        <span class="count">${emails.length} emails</span>
      </div>
      <div class="table-wrap">
      <table>
        <thead><tr><th>To</th><th>Subject</th><th>Status</th><th>Date</th><th></th></tr></thead>
        <tbody id="email-tbody">
          ${emails.length === 0 ? '<tr><td colspan="5" class="text-center text-muted">No emails yet</td></tr>' : ''}
          ${emails.map(e => html`
            <tr class="email-row" data-subject="${esc(e.subject || '')}" data-to="${esc(e.to || e.to_address || '')}">
              <td class="truncate">${esc(e.to || e.to_address || '—')}</td>
              <td class="truncate">${esc(e.subject || '—')}</td>
              <td>${statusBadge(e.status)}</td>
              <td class="text-sm text-muted">${e.created_at ? new Date(e.created_at).toLocaleDateString() : ''}</td>
              <td><button class="btn btn-secondary btn-sm" onclick="showEmailDetail('${e.id}')">View</button></td>
            </tr>
          `).join('')}
        </tbody>
      </table>
      </div>
    </div>
  `;
}

function filterEmailTable() {
  const q = document.getElementById('email-search')?.value.toLowerCase() || '';
  document.querySelectorAll('.email-row').forEach(r => {
    const match = (r.dataset.subject || '').toLowerCase().includes(q) || (r.dataset.to || '').toLowerCase().includes(q);
    r.style.display = match ? '' : 'none';
  });
}

async function showEmailDetail(id) {
  try {
    state.emailDetail = await API.get(`/api/v1/emails/${id}`);
  } catch { state.emailDetail = null; }
  if (!state.emailDetail) return toast('Could not load email', 'error');
  const e = state.emailDetail;
  const data = e.data || e;
  showModal(html`
    <h3>✉ Email Detail</h3>
    <div class="form-group"><label>To</label><div class="mono">${esc(data.to || data.to_address || '—')}</div></div>
    <div class="form-group"><label>From</label><div class="mono">${esc(data.from || data.from_address || '—')}</div></div>
    <div class="form-group"><label>Subject</label><div>${esc(data.subject || '—')}</div></div>
    <div class="form-group"><label>Status</label><div>${statusBadge(data.status)}</div></div>
    ${data.created_at ? html`<div class="form-group"><label>Sent</label><div class="text-sm">${new Date(data.created_at).toLocaleString()}</div></div>` : ''}
    ${data.id ? html`<div class="form-group"><label>ID</label><div class="mono text-sm">${esc(data.id)}</div></div>` : ''}
    ${data.html_body ? html`<div class="form-group"><label>HTML Body</label><div class="response-block"><code>${esc(data.html_body)}</code></div></div>` : ''}
    ${data.text_body ? html`<div class="form-group"><label>Text Body</label><div class="response-block"><code>${esc(data.text_body)}</code></div></div>` : ''}
    <div class="form-actions"><button class="btn btn-secondary" onclick="closeModal()">Close</button></div>
  `, true);
}

function renderComposeForm(el) {
  el.innerHTML = html`
    <div class="card" style="max-width:700px">
      <div class="form-row">
        <div class="form-group"><label>From</label><input id="email-from" value="" placeholder="sender@example.com"></div>
        <div class="form-group"><label>To</label><input id="email-to" placeholder="recipient@example.com"></div>
      </div>
      <div class="form-group"><label>Subject</label><input id="email-subject" placeholder="Email subject"></div>
      <div class="form-group"><label>HTML Body</label><textarea id="email-html" rows="6" placeholder="<h1>Hello!</h1>"></textarea></div>
      <div class="form-group"><label>Text Body</label><textarea id="email-text" rows="3" placeholder="Plain text version..."></textarea></div>
      <div class="form-actions">
        <button class="btn btn-secondary" onclick="navigate('emails', null, 'list')">Cancel</button>
        <button class="btn btn-primary" onclick="sendEmail()">📨 Send</button>
      </div>
      <div id="email-result" style="display:none" class="mt-2">
        <div class="form-group"><label>Response</label><div class="response-block"><code id="email-result-json"></code></div></div>
      </div>
    </div>
  `;
}

async function sendEmail() {
  const btn = document.querySelector('#email-result')?.previousElementSibling?.querySelector('.btn-primary');
  if (btn) btn.disabled = true;
  const body = {
    from: document.getElementById('email-from')?.value,
    to: document.getElementById('email-to')?.value,
    subject: document.getElementById('email-subject')?.value,
    html_body: document.getElementById('email-html')?.value,
    text_body: document.getElementById('email-text')?.value,
  };
  if (!body.to || !body.subject) { toast('To and Subject are required', 'error'); if (btn) btn.disabled = false; return; }
  try {
    const res = await API.post('/api/v1/emails', body);
    const el = document.getElementById('email-result');
    if (el) { el.style.display = 'block'; document.getElementById('email-result-json').textContent = JSON.stringify(res, null, 2); }
    toast('Email sent successfully!');
    if (res.data?.id) setTimeout(() => navigate('emails', null, 'list'), 500);
  } catch (e) {
    toast(e.message || 'Failed to send', 'error');
  }
  if (btn) btn.disabled = false;
}

function renderBatchForm(el) {
  el.innerHTML = html`
    <div class="card" style="max-width:700px">
      <div class="form-group"><label>From</label><input id="batch-from" placeholder="sender@example.com"></div>
      <div class="form-group"><label>Recipients (one per line)</label><textarea id="batch-to" rows="5" placeholder="alice@example.com&#10;bob@example.com&#10;carol@example.com"></textarea></div>
      <div class="form-group"><label>Subject</label><input id="batch-subject" placeholder="Batch email subject"></div>
      <div class="form-group"><label>HTML Body</label><textarea id="batch-html" rows="6" placeholder="<h1>Hello {{name}}!</h1>"></textarea></div>
      <div class="form-group"><label>Text Body</label><textarea id="batch-text" rows="3" placeholder="Plain text version..."></textarea></div>
      <div class="form-actions">
        <button class="btn btn-secondary" onclick="navigate('emails', null, 'list')">Cancel</button>
        <button class="btn btn-primary" onclick="sendBatchEmail()">📨 Batch Send</button>
      </div>
      <div id="batch-result" style="display:none" class="mt-2">
        <div class="form-group"><label>Response</label><div class="response-block"><code id="batch-result-json"></code></div></div>
      </div>
    </div>
  `;
}

async function sendBatchEmail() {
  const btn = document.querySelector('#batch-result')?.previousElementSibling?.querySelector('.btn-primary');
  if (btn) btn.disabled = true;
  const toRaw = document.getElementById('batch-to')?.value || '';
  const toList = toRaw.split('\n').map(s => s.trim()).filter(Boolean);
  if (toList.length === 0) { toast('Enter at least one recipient', 'error'); if (btn) btn.disabled = false; return; }
  const body = {
    from: document.getElementById('batch-from')?.value,
    to: toList,
    subject: document.getElementById('batch-subject')?.value,
    html_body: document.getElementById('batch-html')?.value,
    text_body: document.getElementById('batch-text')?.value,
  };
  try {
    const res = await API.post('/api/v1/emails/batch', body);
    const el = document.getElementById('batch-result');
    if (el) { el.style.display = 'block'; document.getElementById('batch-result-json').textContent = JSON.stringify(res, null, 2); }
    toast(`Batch sent to ${toList.length} recipient(s)`);
  } catch (e) {
    toast(e.message || 'Batch send failed', 'error');
  }
  if (btn) btn.disabled = false;
}

function renderValidateForm(el) {
  el.innerHTML = html`
    <div class="card" style="max-width:600px">
      <div class="form-group"><label>Email Address(es) to Validate</label>
        <textarea id="validate-addresses" rows="4" placeholder="user@example.com&#10;invalid-email"></textarea>
        <div class="help-text">One email per line</div>
      </div>
      <div class="form-actions">
        <button class="btn btn-primary" onclick="validateEmails()">✓ Validate</button>
      </div>
      <div id="validate-result" style="display:none" class="mt-2">
        <div class="form-group"><label>Results</label><div class="response-block"><code id="validate-result-json"></code></div></div>
      </div>
    </div>
  `;
}

async function validateEmails() {
  const raw = document.getElementById('validate-addresses')?.value || '';
  const addresses = raw.split('\n').map(s => s.trim()).filter(Boolean);
  if (addresses.length === 0) return toast('Enter at least one address', 'error');
  try {
    const res = await API.post('/api/v1/emails/validate', { email: addresses.length === 1 ? addresses[0] : addresses });
    const el = document.getElementById('validate-result');
    if (el) { el.style.display = 'block'; document.getElementById('validate-result-json').textContent = JSON.stringify(res, null, 2); }
  } catch (e) {
    toast(e.message || 'Validation failed', 'error');
  }
}

// ══════════════════════════════════════════════════════
// 4. DOMAINS
// ══════════════════════════════════════════════════════
function renderDomains() {
  return html`
    <div class="page-header"><div><h2>Domains</h2><p class="subtitle">Manage sending domains</p></div>
      <button class="btn btn-primary" onclick="showAddDomain()">+ Add Domain</button>
    </div>
    <div id="domains-content">${loadingSpinner()}</div>
  `;
}

async function mountDomains() {
  const el = document.getElementById('domains-content');
  if (!el) return;
  try {
    const res = await API.get('/api/v1/domains');
    state.domains = res.data || [];
  } catch { state.domains = []; }
  el.innerHTML = html`
    <div class="card">
      ${state.domains.length === 0 ? '<div class="empty-state"><div class="icon">🌐</div><h3>No domains</h3><p>Add a domain to start sending emails</p></div>' : ''}
      <div class="table-wrap">
      <table>
        <thead><tr><th>Domain</th><th>Status</th><th>Verified</th><th>Created</th><th></th></tr></thead>
        <tbody>
          ${state.domains.map(d => html`
            <tr>
              <td><strong>${esc(d.domain || d.name)}</strong></td>
              <td>${statusBadge(d.status)}</td>
              <td>${d.verified ? html`<span class="badge badge-success">Verified</span>` : html`<span class="badge badge-warning">Pending</span>`}</td>
              <td class="text-sm text-muted">${d.created_at ? new Date(d.created_at).toLocaleDateString() : ''}</td>
              <td>
                <div class="flex-nowrap">
                  <button class="btn btn-outline btn-sm" onclick="verifyDomain('${d.id}')">Verify</button>
                  <button class="btn btn-outline btn-sm" onclick="editDomain('${d.id}')">Edit</button>
                  <button class="btn btn-danger btn-sm" onclick="deleteDomain('${d.id}')">Delete</button>
                </div>
              </td>
            </tr>
          `).join('')}
        </tbody>
      </table>
      </div>
    </div>
  `;
}

function showAddDomain() {
  showModal(html`
    <h3>Add Domain</h3>
    <div class="form-group"><label>Domain Name</label><input id="new-domain-name" placeholder="example.com"></div>
    <div class="form-actions">
      <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="addDomain()">Add</button>
    </div>
  `);
}

async function addDomain() {
  const name = document.getElementById('new-domain-name')?.value.trim();
  if (!name) return toast('Enter a domain name', 'error');
  try {
    await API.post('/api/v1/domains', { domain: name });
    closeModal();
    navigate('domains');
    toast('Domain added');
  } catch (e) { toast(e.message || 'Failed to add domain', 'error'); }
}

async function verifyDomain(id) {
  try {
    await API.post(`/api/v1/domains/${id}/verify`);
    navigate('domains');
    toast('Verification requested');
  } catch (e) { toast(e.message || 'Verification failed', 'error'); }
}

async function editDomain(id) {
  const domain = state.domains.find(d => d.id === id);
  if (!domain) return toast('Domain not found', 'error');
  showModal(html`
    <h3>Edit Domain</h3>
    <div class="form-group"><label>Domain Name</label><input id="edit-domain-name" value="${esc(domain.domain || domain.name)}"></div>
    <div class="form-actions">
      <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="doEditDomain('${id}')">Save</button>
    </div>
  `);
}

async function doEditDomain(id) {
  const name = document.getElementById('edit-domain-name')?.value.trim();
  if (!name) return toast('Domain name is required', 'error');
  try {
    await API.put(`/api/v1/domains/${id}`, { domain: name });
    closeModal();
    navigate('domains');
    toast('Domain updated');
  } catch (e) { toast(e.message || 'Failed to update', 'error'); }
}

async function deleteDomain(id) {
  if (!confirmDialog('Delete this domain?')) return;
  try {
    await API.del(`/api/v1/domains/${id}`);
    navigate('domains');
    toast('Domain deleted');
  } catch (e) { toast(e.message || 'Failed to delete', 'error'); }
}

// ══════════════════════════════════════════════════════
// 5. TEMPLATES (4 tabs)
// ══════════════════════════════════════════════════════
const templateTabs = [
  { id: 'list', label: 'All Templates' },
  { id: 'create', label: 'Create' },
  { id: 'versions', label: 'Versions' },
];

function renderTemplates() {
  return html`
    <div class="page-header"><div><h2>Templates</h2><p class="subtitle">Reusable email templates</p></div></div>
    ${tabBar(templateTabs, state.tab, 'templates')}
    <div id="templates-content">${loadingSpinner()}</div>
  `;
}

function mountTemplates() {
  loadTemplatesTab(state.tab || 'list');
}

async function loadTemplatesTab(tab) {
  const el = document.getElementById('templates-content');
  if (!el) return;
  el.innerHTML = loadingSpinner();
  try {
    switch (tab) {
      case 'list': await loadTemplateList(el); break;
      case 'create': renderTemplateCreate(el); break;
      case 'versions': await renderTemplateVersions(el); break;
      default: el.innerHTML = '<div class="empty-state"><h3>Select a tab</h3></div>';
    }
  } catch (e) {
    el.innerHTML = html`<div class="empty-state"><h3>Failed to load</h3><p class="text-sm">${esc(e.message)}</p></div>`;
  }
}

async function loadTemplateList(el) {
  try {
    const res = await API.get('/api/v1/templates');
    state.templates = res.data || [];
  } catch { state.templates = []; }
  el.innerHTML = html`
    <div class="card">
      ${state.templates.length === 0 ? '<div class="empty-state"><div class="icon">📄</div><h3>No templates</h3><p>Create your first email template</p></div>' : ''}
      <div class="table-wrap">
      <table>
        <thead><tr><th>Name</th><th>Subject</th><th>Status</th><th>Updated</th><th></th></tr></thead>
        <tbody>
          ${state.templates.map(t => html`
            <tr>
              <td><strong>${esc(t.name)}</strong></td>
              <td class="truncate">${esc(t.subject || '—')}</td>
              <td>${statusBadge(t.status)}</td>
              <td class="text-sm text-muted">${t.updated_at ? new Date(t.updated_at).toLocaleDateString() : ''}</td>
              <td>
                <div class="flex-nowrap">
                  <button class="btn btn-outline btn-sm" onclick="editTemplate('${t.id}')">Edit</button>
                  <button class="btn btn-success btn-sm" onclick="navigate('templates', 'send/' + '${t.id}')">Send</button>
                  <button class="btn btn-outline btn-sm" onclick="viewTemplateVersions('${t.id}')">Versions</button>
                  <button class="btn btn-danger btn-sm" onclick="deleteTemplate('${t.id}')">Delete</button>
                </div>
              </td>
            </tr>
          `).join('')}
        </tbody>
      </table>
      </div>
    </div>
  `;
}

async function editTemplate(id) {
  let tpl;
  try {
    const res = await API.get(`/api/v1/templates/${id}`);
    tpl = res.data || res;
  } catch { tpl = state.templates.find(t => t.id === id); }
  if (!tpl) return toast('Template not found', 'error');
  showModal(html`
    <h3>Edit Template</h3>
    <div class="form-group"><label>Name</label><input id="edit-tpl-name" value="${esc(tpl.name)}"></div>
    <div class="form-group"><label>Subject</label><input id="edit-tpl-subject" value="${esc(tpl.subject || '')}"></div>
    <div class="form-group"><label>HTML Body</label><textarea id="edit-tpl-html" rows="5">${esc(tpl.html_body || tpl.body || '')}</textarea></div>
    <div class="form-actions">
      <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="doEditTemplate('${id}')">Save</button>
    </div>
  `);
}

async function doEditTemplate(id) {
  const body = {
    name: document.getElementById('edit-tpl-name')?.value.trim(),
    subject: document.getElementById('edit-tpl-subject')?.value.trim(),
    html_body: document.getElementById('edit-tpl-html')?.value,
  };
  if (!body.name) return toast('Name is required', 'error');
  try {
    await API.put(`/api/v1/templates/${id}`, body);
    closeModal();
    navigate('templates', null, 'list');
    toast('Template updated');
  } catch (e) { toast(e.message || 'Failed to update', 'error'); }
}

async function deleteTemplate(id) {
  if (!confirmDialog('Delete this template?')) return;
  try { await API.del(`/api/v1/templates/${id}`); navigate('templates', null, 'list'); toast('Template deleted'); }
  catch (e) { toast(e.message || 'Failed to delete', 'error'); }
}

function renderTemplateCreate(el) {
  el.innerHTML = html`
    <div class="card" style="max-width:700px">
      <div class="form-group"><label>Name</label><input id="new-tpl-name" placeholder="welcome-email"></div>
      <div class="form-group"><label>Subject</label><input id="new-tpl-subject" placeholder="Welcome {{name}}!"></div>
      <div class="form-group"><label>HTML Body</label><textarea id="new-tpl-html" rows="6"><h1>Hello {{name}}!</h1></textarea></div>
      <div class="form-actions">
        <button class="btn btn-secondary" onclick="navigate('templates', null, 'list')">Cancel</button>
        <button class="btn btn-primary" onclick="createTemplate()">Create</button>
      </div>
    </div>
  `;
}

async function createTemplate() {
  const body = {
    name: document.getElementById('new-tpl-name')?.value.trim(),
    subject: document.getElementById('new-tpl-subject')?.value.trim(),
    html_body: document.getElementById('new-tpl-html')?.value,
  };
  if (!body.name) return toast('Name is required', 'error');
  try { await API.post('/api/v1/templates', body); navigate('templates', null, 'list'); toast('Template created'); }
  catch (e) { toast(e.message || 'Failed to create', 'error'); }
}

async function renderTemplateVersions(el) {
  try {
    if (!state.templates.length) {
      const res = await API.get('/api/v1/templates');
      state.templates = res.data || [];
    }
  } catch {}
  if (state.templates.length === 0) {
    el.innerHTML = '<div class="empty-state"><h3>No templates yet</h3><p>Create a template first</p></div>';
    return;
  }
  el.innerHTML = html`
    <div class="card">
      <div class="form-group"><label>Select Template</label>
        <select id="version-template-select" onchange="loadTemplateVersions()">
          <option value="">— Select —</option>
          ${state.templates.map(t => html`<option value="${esc(t.id)}"${state.params === t.id ? ' selected' : ''}>${esc(t.name)}</option>`).join('')}
        </select>
      </div>
    </div>
    <div id="versions-list"></div>
    <div class="card">
      <h3>Create New Version</h3>
      <div class="form-group"><label>HTML Body</label><textarea id="new-version-html" rows="5"></textarea></div>
      <div class="form-actions"><button class="btn btn-primary" onclick="createTemplateVersion()">Create Version</button></div>
    </div>
  `;
  if (state.params) loadTemplateVersions();
}

async function loadTemplateVersions() {
  const sel = document.getElementById('version-template-select');
  const id = sel?.value;
  if (!id) return;
  const el = document.getElementById('versions-list');
  if (!el) return;
  el.innerHTML = loadingSpinner();
  try {
    const res = await API.get(`/api/v1/templates/${id}/versions`);
    state.templateVersions = res.data || [];
  } catch { state.templateVersions = []; }
  el.innerHTML = html`
    <div class="card"><h3>Versions for ${esc(sel.options[sel.selectedIndex]?.text || '')}</h3>
      ${state.templateVersions.length === 0 ? '<div class="empty-state text-sm"><h3>No versions yet</h3></div>' : ''}
      <div class="table-wrap"><table>
        <thead><tr><th>Version</th><th>Created</th><th></th></tr></thead>
        <tbody>${state.templateVersions.map(v => html`
          <tr><td><strong>v${esc(v.version || v.id)}</strong></td>
          <td class="text-sm text-muted">${v.created_at ? new Date(v.created_at).toLocaleString() : ''}</td>
          <td><button class="btn btn-outline btn-sm" onclick="showTemplateVersionDetail('${id}', '${v.id}')">View</button></td></tr>
        `).join('')}</tbody>
      </table></div>
    </div>
  `;
}

async function showTemplateVersionDetail(tplId, verId) {
  try {
    const res = await API.get(`/api/v1/templates/${tplId}/versions/${verId}`);
    const v = res.data || res;
    showModal(html`
      <h3>Version ${esc(v.version || v.id)}</h3>
      <div class="form-group"><label>HTML Body</label><div class="response-block"><code>${esc(v.html_body || v.body || '')}</code></div></div>
      <div class="form-actions"><button class="btn btn-secondary" onclick="closeModal()">Close</button></div>
    `, true);
  } catch { toast('Failed to load version', 'error'); }
}

async function createTemplateVersion() {
  const sel = document.getElementById('version-template-select');
  const id = sel?.value;
  if (!id) return toast('Select a template', 'error');
  const htmlBody = document.getElementById('new-version-html')?.value;
  if (!htmlBody) return toast('HTML body is required', 'error');
  try {
    await API.post(`/api/v1/templates/${id}/versions`, { html_body: htmlBody });
    document.getElementById('new-version-html').value = '';
    toast('Version created');
    loadTemplateVersions();
  } catch (e) { toast(e.message || 'Failed to create version', 'error'); }
}

function viewTemplateVersions(id) {
  navigate('templates', id, 'versions');
}

// ── Send from Template ──────────────────────────────
function renderTemplateSend(id) {
  return html`
    <div class="page-header"><div><h2>Send from Template</h2><p class="subtitle">Send an email using a template</p></div></div>
    <div id="template-send-content">${loadingSpinner()}</div>
  `;
}

async function mountTemplateSend(id) {
  const el = document.getElementById('template-send-content');
  if (!el) return;
  let tpl;
  try {
    const res = await API.get(`/api/v1/templates/${id}`);
    tpl = res.data || res;
  } catch { return void (el.innerHTML = '<div class="empty-state"><h3>Template not found</h3></div>'); }
  const vars = (tpl.html_body || tpl.body || '').match(/\{\{(\w+)\}\}/g) || [];
  const varNames = [...new Set(vars.map(v => v.replace(/\{|\}/g, '')))];
  el.innerHTML = html`
    <div class="card" style="max-width:700px">
      <div class="form-group"><label>Template</label><div><strong>${esc(tpl.name)}</strong> — ${esc(tpl.subject || '')}</div></div>
      <div class="form-row">
        <div class="form-group"><label>From</label><input id="send-tpl-from" placeholder="sender@example.com"></div>
        <div class="form-group"><label>To</label><input id="send-tpl-to" placeholder="recipient@example.com"></div>
      </div>
      ${varNames.map(v => html`
        <div class="form-group"><label>${esc(v)}</label><input class="tpl-var" data-var="${esc(v)}" placeholder="Value for {{${esc(v)}}}"></div>
      `).join('')}
      <div class="form-actions">
        <button class="btn btn-secondary" onclick="navigate('templates')">Cancel</button>
        <button class="btn btn-primary" onclick="sendFromTemplate('${id}')">📨 Send</button>
      </div>
      <div id="send-tpl-result" style="display:none" class="mt-2">
        <div class="response-block"><code id="send-tpl-result-json"></code></div>
      </div>
    </div>
  `;
}

async function sendFromTemplate(id) {
  const vars = {};
  document.querySelectorAll('.tpl-var').forEach(el => { vars[el.dataset.var] = el.value; });
  const body = {
    from: document.getElementById('send-tpl-from')?.value,
    to: document.getElementById('send-tpl-to')?.value,
    variables: vars,
  };
  if (!body.to) return toast('Recipient is required', 'error');
  try {
    const res = await API.post(`/api/v1/templates/${id}/send`, body);
    const el = document.getElementById('send-tpl-result');
    if (el) { el.style.display = 'block'; document.getElementById('send-tpl-result-json').textContent = JSON.stringify(res, null, 2); }
    toast('Email sent from template');
  } catch (e) { toast(e.message || 'Failed to send', 'error'); }
}

// ══════════════════════════════════════════════════════
// 6. WEBHOOKS
// ══════════════════════════════════════════════════════
function renderWebhooks() {
  return html`
    <div class="page-header"><div><h2>Webhooks</h2><p class="subtitle">Receive email event notifications</p></div>
      <button class="btn btn-primary" onclick="showAddWebhook()">+ Add Webhook</button>
    </div>
    <div id="webhooks-content">${loadingSpinner()}</div>
  `;
}

async function mountWebhooks() {
  const el = document.getElementById('webhooks-content');
  if (!el) return;
  try {
    const res = await API.get('/api/v1/webhooks');
    state.webhooks = res.data || [];
  } catch { state.webhooks = []; }
  el.innerHTML = html`
    <div class="card">
      ${state.webhooks.length === 0 ? '<div class="empty-state"><div class="icon">🔗</div><h3>No webhooks</h3><p>Create a webhook to receive email events</p></div>' : ''}
      <div class="table-wrap">
      <table>
        <thead><tr><th>URL</th><th>Events</th><th>Status</th><th></th></tr></thead>
        <tbody>
          ${state.webhooks.map(w => html`
            <tr>
              <td class="truncate mono">${esc(w.url)}</td>
              <td class="text-sm">${(w.events || []).join(', ') || '—'}</td>
              <td>${statusBadge(w.status)}</td>
              <td>
                <div class="flex-nowrap">
                  <button class="btn btn-outline btn-sm" onclick="editWebhook('${w.id}')">Edit</button>
                  <button class="btn btn-outline btn-sm" onclick="testWebhook('${w.id}')">Test</button>
                  <button class="btn btn-danger btn-sm" onclick="deleteWebhook('${w.id}')">Delete</button>
                </div>
              </td>
            </tr>
          `).join('')}
        </tbody>
      </table>
      </div>
    </div>
  `;
}

function showAddWebhook() {
  showModal(html`
    <h3>Add Webhook</h3>
    <div class="form-group"><label>URL</label><input id="new-webhook-url" placeholder="https://hooks.example.com/callback"></div>
    <div class="form-group"><label>Events (comma separated)</label><input id="new-webhook-events" value="email.delivered,email.failed,email.bounced"></div>
    <div class="form-actions">
      <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="addWebhook()">Add</button>
    </div>
  `);
}

async function addWebhook() {
  const body = {
    url: document.getElementById('new-webhook-url')?.value.trim(),
    events: (document.getElementById('new-webhook-events')?.value || '').split(',').map(s => s.trim()).filter(Boolean),
  };
  if (!body.url) return toast('URL is required', 'error');
  try { await API.post('/api/v1/webhooks', body); closeModal(); navigate('webhooks'); toast('Webhook added'); }
  catch (e) { toast(e.message || 'Failed to add webhook', 'error'); }
}

async function editWebhook(id) {
  let wh;
  try {
    const res = await API.get(`/api/v1/webhooks/${id}`);
    wh = res.data || res;
  } catch { wh = state.webhooks.find(w => w.id === id); }
  if (!wh) return toast('Webhook not found', 'error');
  showModal(html`
    <h3>Edit Webhook</h3>
    <div class="form-group"><label>URL</label><input id="edit-webhook-url" value="${esc(wh.url)}"></div>
    <div class="form-group"><label>Events (comma separated)</label><input id="edit-webhook-events" value="${esc((wh.events || []).join(', '))}"></div>
    <div class="form-actions">
      <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="doEditWebhook('${id}')">Save</button>
    </div>
  `);
}

async function doEditWebhook(id) {
  const body = {
    url: document.getElementById('edit-webhook-url')?.value.trim(),
    events: (document.getElementById('edit-webhook-events')?.value || '').split(',').map(s => s.trim()).filter(Boolean),
  };
  if (!body.url) return toast('URL is required', 'error');
  try { await API.put(`/api/v1/webhooks/${id}`, body); closeModal(); navigate('webhooks'); toast('Webhook updated'); }
  catch (e) { toast(e.message || 'Failed to update', 'error'); }
}

async function testWebhook(id) {
  try {
    const res = await API.post(`/api/v1/webhooks/${id}/test`);
    showModal(html`
      <h3>Webhook Test Result</h3>
      <div class="response-block"><code>${JSON.stringify(res, null, 2)}</code></div>
      <div class="form-actions mt-2"><button class="btn btn-secondary" onclick="closeModal()">Close</button></div>
    `, true);
    toast('Test event sent');
  } catch (e) { toast(e.message || 'Test failed', 'error'); }
}

async function deleteWebhook(id) {
  if (!confirmDialog('Delete this webhook?')) return;
  try { await API.del(`/api/v1/webhooks/${id}`); navigate('webhooks'); toast('Webhook deleted'); }
  catch (e) { toast(e.message || 'Failed to delete', 'error'); }
}

// ══════════════════════════════════════════════════════
// 7. API KEYS
// ══════════════════════════════════════════════════════
function renderApiKeys() {
  return html`
    <div class="page-header"><div><h2>API Keys</h2><p class="subtitle">Manage authentication keys</p></div>
      <button class="btn btn-primary" onclick="showCreateApiKey()">+ Create Key</button>
    </div>
    <div id="apikeys-content">${loadingSpinner()}</div>
  `;
}

async function mountApiKeys() {
  const el = document.getElementById('apikeys-content');
  if (!el) return;
  try {
    const res = await API.get('/api/v1/api_keys');
    state.apiKeys = res.data || [];
  } catch { state.apiKeys = []; }
  el.innerHTML = html`
    <div class="card">
      ${state.apiKeys.length === 0 ? '<div class="empty-state"><div class="icon">🔑</div><h3>No API keys</h3><p>Create an API key to authenticate requests</p></div>' : ''}
      <div class="table-wrap">
      <table>
        <thead><tr><th>Name</th><th>Key (prefix)</th><th>Status</th><th>Created</th><th></th></tr></thead>
        <tbody>
          ${state.apiKeys.map(k => html`
            <tr>
              <td><strong>${esc(k.name)}</strong></td>
              <td class="mono text-sm">${esc(k.key_prefix || (k.key ? k.key.substring(0, 16) + '...' : '—'))}</td>
              <td>${statusBadge(k.status || 'active')}</td>
              <td class="text-sm text-muted">${k.created_at ? new Date(k.created_at).toLocaleDateString() : ''}</td>
              <td>
                <div class="flex-nowrap">
                  <button class="btn btn-outline btn-sm" onclick="showApiKeyDetail('${k.id}')">View</button>
                  <button class="btn btn-danger btn-sm" onclick="revokeApiKey('${k.id}')">Revoke</button>
                </div>
              </td>
            </tr>
          `).join('')}
        </tbody>
      </table>
      </div>
    </div>
  `;
}

async function showApiKeyDetail(id) {
  try {
    const res = await API.get(`/api/v1/api_keys/${id}`);
    state.apiKeyDetail = res.data || res;
  } catch { state.apiKeyDetail = state.apiKeys.find(k => k.id === id); }
  if (!state.apiKeyDetail) return toast('Key not found', 'error');
  const k = state.apiKeyDetail;
  showModal(html`
    <h3>🔑 API Key Detail</h3>
    <div class="org-field"><div class="label">Name</div><div class="value">${esc(k.name)}</div></div>
    <div class="org-field"><div class="label">Key Prefix</div><div class="value mono">${esc(k.key_prefix || (k.key ? k.key.substring(0, 16) + '...' : '—'))}</div></div>
    <div class="org-field"><div class="label">Status</div><div class="value">${statusBadge(k.status || 'active')}</div></div>
    ${k.last_used_at ? html`<div class="org-field"><div class="label">Last Used</div><div class="value text-sm">${new Date(k.last_used_at).toLocaleString()}</div></div>` : ''}
    ${k.expires_at ? html`<div class="org-field"><div class="label">Expires</div><div class="value text-sm">${new Date(k.expires_at).toLocaleDateString()}</div></div>` : ''}
    ${k.scopes && k.scopes.length ? html`<div class="org-field"><div class="label">Scopes</div><div class="value text-sm">${k.scopes.join(', ')}</div></div>` : ''}
    <div class="org-field"><div class="label">Created</div><div class="value text-sm">${k.created_at ? new Date(k.created_at).toLocaleString() : ''}</div></div>
    <div class="form-actions"><button class="btn btn-secondary" onclick="closeModal()">Close</button></div>
  `);
}

function showCreateApiKey() {
  showModal(html`
    <h3>Create API Key</h3>
    <div class="form-group"><label>Name</label><input id="new-key-name" placeholder="My App"></div>
    <div class="form-actions">
      <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="createApiKey()">Create</button>
    </div>
  `);
}

async function createApiKey() {
  const name = document.getElementById('new-key-name')?.value.trim();
  if (!name) return toast('Name is required', 'error');
  try {
    const res = await API.post('/api/v1/api_keys', { name });
    closeModal();
    navigate('apiKeys');
    if (res.data?.key) toast(`Key created: ${res.data.key}`, 'info');
    else toast('API key created');
  } catch (e) { toast(e.message || 'Failed to create key', 'error'); }
}

async function revokeApiKey(id) {
  if (!confirmDialog('Revoke this API key?')) return;
  try { await API.post(`/api/v1/api_keys/${id}/revoke`); navigate('apiKeys'); toast('Key revoked'); }
  catch (e) { toast(e.message || 'Failed to revoke', 'error'); }
}

// ══════════════════════════════════════════════════════
// 8. ANALYTICS (3 tabs)
// ══════════════════════════════════════════════════════
const analyticsTabs = [
  { id: 'overview', label: 'Overview' },
  { id: 'deliverability', label: 'Deliverability' },
  { id: 'events', label: 'Events' },
];

function renderAnalytics() {
  return html`
    <div class="page-header"><div><h2>Analytics</h2><p class="subtitle">Delivery metrics and statistics</p></div></div>
    ${tabBar(analyticsTabs, state.tab, 'analytics')}
    <div id="analytics-content">${loadingSpinner()}</div>
  `;
}

function mountAnalytics() {
  loadAnalyticsTab(state.tab || 'overview');
}

async function loadAnalyticsTab(tab) {
  const el = document.getElementById('analytics-content');
  if (!el) return;
  el.innerHTML = loadingSpinner();
  try {
    switch (tab) {
      case 'overview': await loadAnalyticsOverview(el); break;
      case 'deliverability': await loadAnalyticsDeliverability(el); break;
      case 'events': await loadAnalyticsEvents(el); break;
      default: el.innerHTML = '<div class="empty-state"><h3>Select a tab</h3></div>';
    }
  } catch (e) {
    el.innerHTML = html`<div class="empty-state"><h3>Failed to load</h3><p class="text-sm">${esc(e.message)}</p></div>`;
  }
}

async function loadAnalyticsOverview(el) {
  try { state.analytics = await API.get('/api/v1/analytics'); } catch { state.analytics = {}; }
  const a = state.analytics || {};
  const total = a.total || 0;
  const rate = total > 0 ? ((a.delivered || 0) / total * 100).toFixed(1) : '0.0';
  el.innerHTML = html`
    <div class="stat-grid">
      <div class="stat-card accent"><div class="label">Total Sent</div><div class="value">${total}</div></div>
      <div class="stat-card"><div class="label">Delivered</div><div class="value" style="color:var(--green)">${esc(a.delivered || 0)}</div></div>
      <div class="stat-card"><div class="label">Failed</div><div class="value" style="color:var(--red)">${esc(a.failed || 0)}</div></div>
      <div class="stat-card"><div class="label">Bounced</div><div class="value" style="color:var(--yellow)">${esc(a.bounced || 0)}</div></div>
      <div class="stat-card"><div class="label">Delivery Rate</div><div class="value" style="color:var(--accent)">${rate}%</div></div>
      <div class="stat-card"><div class="label">Opened</div><div class="value">${esc(a.opened || a.opens || 0)}</div></div>
    </div>
  `;
}

async function loadAnalyticsDeliverability(el) {
  let data;
  try { data = await API.get('/api/v1/analytics/deliverability'); state.analyticsDeliverability = data; } catch { data = {}; }
  const d = data.data || data;
  const byStatus = d.by_status || d.statuses || {};
  el.innerHTML = html`
    <div class="stat-grid">
      <div class="stat-card"><div class="label">Delivery Rate</div><div class="value" style="color:var(--green)">${esc(d.delivery_rate || d.rate || '—')}</div></div>
      <div class="stat-card"><div class="label">Bounce Rate</div><div class="value" style="color:var(--yellow)">${esc(d.bounce_rate || '—')}</div></div>
      <div class="stat-card"><div class="label">Complaint Rate</div><div class="value" style="color:var(--red)">${esc(d.complaint_rate || '—')}</div></div>
    </div>
    ${Object.keys(byStatus).length > 0 ? html`
      <div class="card"><h3>By Status</h3>
        <table><thead><tr><th>Status</th><th>Count</th></tr></thead><tbody>
          ${Object.entries(byStatus).map(([k,v]) => html`<tr><td>${esc(k)}</td><td>${v}</td></tr>`).join('')}
        </tbody></table>
      </div>` : ''}
  `;
}

async function loadAnalyticsEvents(el) {
  let data;
  try { data = await API.get('/api/v1/analytics/events'); state.analyticsEvents = data; } catch { data = {}; }
  const d = data.data || data;
  const events = d.events || d.by_type || d.breakdown || [];
  el.innerHTML = html`
    <div class="card"><h3>Event Distribution</h3>
      ${Array.isArray(events) && events.length > 0 ? html`
        <table><thead><tr><th>Event Type</th><th>Count</th></tr></thead><tbody>
          ${events.map(e => html`<tr><td>${esc(e.type || e.event || e.name)}</td><td>${esc(e.count || 0)}</td></tr>`).join('')}
        </tbody></table>
      ` : html`<div class="empty-state"><h3>No event data</h3></div>`}
    </div>
  `;
}

// ══════════════════════════════════════════════════════
// 9. ORGANIZATION
// ══════════════════════════════════════════════════════
const orgTabs = [
  { id: 'view', label: 'View' },
  { id: 'edit', label: 'Edit' },
];

function renderOrganization() {
  return html`
    <div class="page-header"><div><h2>Organization</h2><p class="subtitle">Your organization settings</p></div></div>
    ${tabBar(orgTabs, state.tab, 'organization')}
    <div id="org-content">${loadingSpinner()}</div>
  `;
}

function mountOrganization() {
  loadOrgTab(state.tab || 'view');
}

async function loadOrgTab(tab) {
  const el = document.getElementById('org-content');
  if (!el) return;
  el.innerHTML = loadingSpinner();
  try {
    if (tab === 'view') await loadOrgView(el);
    else if (tab === 'edit') await loadOrgEdit(el);
  } catch (e) {
    el.innerHTML = html`<div class="empty-state"><h3>Failed to load</h3><p class="text-sm">${esc(e.message)}</p></div>`;
  }
}

async function loadOrgView(el) {
  try {
    const res = await API.get('/api/v1/organization');
    state.organization = res.data || res;
  } catch { state.organization = null; }
  const o = state.organization || {};
  el.innerHTML = html`
    <div class="card" style="max-width:600px">
      <div class="org-field"><div class="label">Organization Name</div><div class="value text-lg font-medium">${esc(o.name || '—')}</div></div>
      <div class="org-field"><div class="label">Email</div><div class="value">${esc(o.email || o.contact_email || '—')}</div></div>
      <div class="org-field"><div class="label">Plan / Tier</div><div class="value">${esc(o.plan || o.tier || '—')}</div></div>
      ${o.usage_limit || o.limit ? html`<div class="org-field"><div class="label">Monthly Limit</div><div class="value">${esc(o.usage_limit || o.limit || '—')}</div></div>` : ''}
      ${o.created_at ? html`<div class="org-field"><div class="label">Created</div><div class="value text-sm">${new Date(o.created_at).toLocaleDateString()}</div></div>` : ''}
      ${o.id ? html`<div class="org-field"><div class="label">ID</div><div class="value mono text-sm">${esc(o.id)}</div></div>` : ''}
      <div class="form-actions"><button class="btn btn-primary" onclick="navigate('organization', null, 'edit')">Edit</button></div>
    </div>
  `;
}

async function loadOrgEdit(el) {
  if (!state.organization) {
    try {
      const res = await API.get('/api/v1/organization');
      state.organization = res.data || res;
    } catch { state.organization = {}; }
  }
  const o = state.organization || {};
  el.innerHTML = html`
    <div class="card" style="max-width:600px">
      <div class="form-group"><label>Organization Name</label><input id="edit-org-name" value="${esc(o.name || '')}"></div>
      <div class="form-group"><label>Contact Email</label><input id="edit-org-email" value="${esc(o.email || o.contact_email || '')}"></div>
      <div class="form-actions">
        <button class="btn btn-secondary" onclick="navigate('organization', null, 'view')">Cancel</button>
        <button class="btn btn-primary" onclick="saveOrganization()">Save</button>
      </div>
    </div>
  `;
}

async function saveOrganization() {
  const body = {
    name: document.getElementById('edit-org-name')?.value.trim(),
    email: document.getElementById('edit-org-email')?.value.trim(),
  };
  if (!body.name) return toast('Name is required', 'error');
  try {
    const res = await API.put('/api/v1/organization', body);
    state.organization = res.data || res;
    navigate('organization', null, 'view');
    toast('Organization updated');
  } catch (e) { toast(e.message || 'Failed to update', 'error'); }
}

// ══════════════════════════════════════════════════════
// 10. HEALTH (3 tabs)
// ══════════════════════════════════════════════════════
const healthTabs = [
  { id: 'main', label: 'Health' },
  { id: 'readiness', label: 'Readiness' },
  { id: 'liveness', label: 'Liveness' },
];

function renderHealth() {
  return html`
    <div class="page-header"><div><h2>Health</h2><p class="subtitle">System health checks</p></div>
      <button class="btn btn-outline" onclick="refreshHealth()">↻ Refresh</button>
    </div>
    ${tabBar(healthTabs, state.tab, 'health')}
    <div id="health-content">${loadingSpinner()}</div>
  `;
}

function refreshHealth() {
  mountHealth();
}

function mountHealth() {
  loadHealthTab(state.tab || 'main');
}

async function loadHealthTab(tab) {
  const el = document.getElementById('health-content');
  if (!el) return;
  el.innerHTML = loadingSpinner();
  try {
    switch (tab) {
      case 'main': await loadHealthMain(el); break;
      case 'readiness': await loadHealthReadiness(el); break;
      case 'liveness': await loadHealthLiveness(el); break;
      default: el.innerHTML = '<div class="empty-state"><h3>Select a tab</h3></div>';
    }
  } catch (e) {
    el.innerHTML = html`<div class="empty-state"><h3>Check failed</h3><p class="text-sm">${esc(e.message)}</p></div>`;
  }
}

async function loadHealthMain(el) {
  const start = Date.now();
  try {
    const data = await API.get('/health');
    state.health = data;
    const ms = Date.now() - start;
    el.innerHTML = html`
      <div class="health-panel"><div class="status-indicator ok">✅ Healthy</div>
        <div class="text-sm text-muted mt-2">Response time: ${ms}ms</div>
        <div class="response-block mt-1"><code>${JSON.stringify(data, null, 2)}</code></div>
      </div>
    `;
  } catch (e) {
    const ms = Date.now() - start;
    el.innerHTML = html`
      <div class="health-panel"><div class="status-indicator fail">❌ Unhealthy — ${esc(e.message)}</div>
        <div class="text-sm text-muted mt-2">Response time: ${ms}ms</div>
      </div>
    `;
  }
}

async function loadHealthReadiness(el) {
  const start = Date.now();
  try {
    const data = await API.get('/health/readiness');
    state.healthReadiness = data;
    const ms = Date.now() - start;
    el.innerHTML = html`
      <div class="health-panel"><div class="status-indicator ok">✅ Ready</div>
        <div class="text-sm text-muted mt-2">Response time: ${ms}ms</div>
        <div class="response-block mt-1"><code>${JSON.stringify(data, null, 2)}</code></div>
      </div>
    `;
  } catch (e) {
    const ms = Date.now() - start;
    el.innerHTML = html`
      <div class="health-panel"><div class="status-indicator fail">❌ Not Ready — ${esc(e.message)}</div>
        <div class="text-sm text-muted mt-2">Response time: ${ms}ms</div>
      </div>
    `;
  }
}

async function loadHealthLiveness(el) {
  const start = Date.now();
  try {
    const data = await API.get('/health/liveness');
    state.healthLiveness = data;
    const ms = Date.now() - start;
    el.innerHTML = html`
      <div class="health-panel"><div class="status-indicator ok">✅ Alive</div>
        <div class="text-sm text-muted mt-2">Response time: ${ms}ms</div>
        <div class="response-block mt-1"><code>${JSON.stringify(data, null, 2)}</code></div>
      </div>
    `;
  } catch (e) {
    const ms = Date.now() - start;
    el.innerHTML = html`
      <div class="health-panel"><div class="status-indicator fail">❌ Not Alive — ${esc(e.message)}</div>
        <div class="text-sm text-muted mt-2">Response time: ${ms}ms</div>
      </div>
    `;
  }
}

// ══════════════════════════════════════════════════════
// 11. ROUTE OVERRIDES FOR PARAM-BASED PAGES
// ══════════════════════════════════════════════════════
// We handle "templates/send/:id" by checking params in renderTemplates
const origRender = {};
for (const [k, v] of Object.entries(routes)) {
  origRender[k] = v.render;
}

// Patch templates route to handle "send/:id"
const origTemplatesRender = routes.templates.render;
routes.templates.render = function() {
  if (state.params && state.params.startsWith && state.params.startsWith('send/')) {
    const id = state.params.replace('send/', '');
    return renderTemplateSend(id);
  }
  return origTemplatesRender();
};
routes.templates.mount = function() {
  if (state.params && state.params.startsWith && state.params.startsWith('send/')) {
    const id = state.params.replace('send/', '');
    mountTemplateSend(id);
    return;
  }
  mountTemplates();
};

// ══════════════════════════════════════════════════════
// INIT
// ══════════════════════════════════════════════════════
document.addEventListener('DOMContentLoaded', () => {
  const parts = location.hash.replace('#', '').split('/');
  const page = parts[0] || (state.token || state.apiKey ? 'dashboard' : 'login');
  let params = null;
  let tab = '';
  for (let i = 1; i < parts.length; i++) {
    if (parts[i] === 't' && parts[i + 1]) { tab = parts[i + 1]; i++; }
    else if (parts[i] === 'show') { params = parts[i + 1]; i++; }
    else if (parts[i] === 'send') { params = 'send/' + (parts[i + 1] || ''); i++; }
    else { params = parts[i]; }
  }
  state.page = page;
  state.params = params;
  state.tab = tab || getDefaultTab(page);
  render();
});
