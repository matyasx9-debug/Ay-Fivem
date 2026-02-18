const resourceName = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'ay_devpanel';

const panel = document.getElementById('panel');
const closeBtn = document.getElementById('closeBtn');
const adminInfo = document.getElementById('adminInfo');
const developerSection = document.getElementById('developerSection');
const panelTitle = document.getElementById('panelTitle');
const panelLogo = document.getElementById('panelLogo');

let adminState = {
  rank: 0,
  rankName: 'N/A',
  duty: false,
  isDeveloper: false,
  actionRanks: {},
  ranks: {},
  localeUi: {},
  branding: {}
};

function post(endpoint, payload = {}) {
  return fetch(`https://${resourceName}/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
}

function rankNameByLevel(level) {
  return adminState.ranks?.[String(level)]?.name || adminState.ranks?.[level]?.name || `R${level}`;
}

function updateRankBadges() {
  document.querySelectorAll('[data-rank-action]').forEach((el) => {
    const action = el.dataset.rankAction;
    const required = Number(adminState.actionRanks?.[action] ?? 0);
    el.textContent = required > 0 ? `${rankNameByLevel(required)}+` : '';
  });
}

function renderAdminInfo() {
  const rankLabel = adminState.localeUi?.rank || 'Rank';
  const dutyLabel = adminState.localeUi?.duty || 'Duty';
  adminInfo.textContent = `${rankLabel}: ${adminState.rankName} (${adminState.rank}) | ${dutyLabel}: ${adminState.duty ? 'ON' : 'OFF'}`;

  const brandedName = adminState.branding?.panelName || adminState.localeUi?.panelName || 'AY Panel';
  const brandedLogo = adminState.branding?.panelLogo || 'AY';
  panelTitle.textContent = brandedName;
  panelLogo.textContent = brandedLogo;

  developerSection.classList.toggle('hidden', !adminState.isDeveloper);

  if (adminState.localeUi?.dutyInfo) document.getElementById('dutyInfo').textContent = adminState.localeUi.dutyInfo;
  if (adminState.localeUi?.sectionDeveloper) document.getElementById('developerTitle').textContent = adminState.localeUi.sectionDeveloper;
  if (adminState.localeUi?.developerHint) document.getElementById('developerHint').textContent = adminState.localeUi.developerHint;
  if (adminState.localeUi?.announcePlaceholder) document.getElementById('announce').placeholder = adminState.localeUi.announcePlaceholder;

  updateRankBadges();
}

window.addEventListener('message', (event) => {
  const data = event.data;
  if (data.action === 'toggle') {
    panel.classList.toggle('hidden', !data.state);
    if (data.defaults) {
      document.getElementById('weather').value = data.defaults.weather;
      document.getElementById('hour').value = data.defaults.hour;
      document.getElementById('minute').value = data.defaults.minute;
      document.getElementById('noclipSpeed').value = data.defaults.noclipSpeed;
    }
    if (data.admin) {
      adminState = { ...adminState, ...data.admin };
      renderAdminInfo();
    }
  }

  if (data.action === 'adminState' && data.admin) {
    adminState = { ...adminState, ...data.admin };
    renderAdminInfo();
  }
});

closeBtn.addEventListener('click', () => post('close'));
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') post('close');
});

document.querySelectorAll('[data-action]').forEach((btn) => {
  btn.addEventListener('click', () => {
    const action = btn.dataset.action;
    const payload = { action };

    if (action === 'spawnVehicle') payload.model = document.getElementById('vehicleModel').value.trim();
    if (action === 'setWeather') payload.weather = document.getElementById('weather').value;
    if (action === 'setTime') {
      payload.hour = Number(document.getElementById('hour').value || 12);
      payload.minute = Number(document.getElementById('minute').value || 0);
    }
    if (action === 'announce') payload.message = document.getElementById('announce').value.trim();
    if (action === 'setNoclipSpeed') payload.value = Number(document.getElementById('noclipSpeed').value || 1.5);
    if (action === 'tpCoords') {
      payload.x = Number(document.getElementById('tpX').value);
      payload.y = Number(document.getElementById('tpY').value);
      payload.z = Number(document.getElementById('tpZ').value);
    }
    if (action === 'giveWeapon') payload.weapon = document.getElementById('weaponName').value.trim();
    if (action === 'clearArea') payload.radius = Number(document.getElementById('clearRadius').value || 50);
    if (action === 'setPedModel') payload.model = document.getElementById('pedModel').value.trim();
    if (action === 'spawnObject') payload.object = document.getElementById('objectModel').value.trim();

    post('action', payload);
  });
});

const toggles = [
  { id: 'godmode', action: 'godmode' },
  { id: 'invisible', action: 'invisible' },
  { id: 'noclip', action: 'noclip' },
  { id: 'coords', action: 'coords' },
  { id: 'superJump', action: 'superJump' },
  { id: 'fastRun', action: 'fastRun' },
  { id: 'freezeTime', action: 'freezeTime' },
  { id: 'blackout', action: 'blackout' },
  { id: 'forceEngine', action: 'forceEngine' },
  { id: 'noRagdoll', action: 'noRagdoll' },
  { id: 'devEntityDebug', action: 'devEntityDebug' }
];

toggles.forEach(({ id, action }) => {
  const el = document.getElementById(id);
  if (!el) return;
  el.addEventListener('change', () => {
    post('action', { action, state: el.checked });
  });
});

renderAdminInfo();
