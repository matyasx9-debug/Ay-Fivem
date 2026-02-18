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

function renderSelectOptions(selectId, options, valueSelector = (x) => x, labelSelector = (x) => x) {
  const select = document.getElementById(selectId);
  if (!select) return;
  select.innerHTML = '';
  options.forEach((entry, index) => {
    const opt = document.createElement('option');
    opt.value = String(index);
    opt.textContent = labelSelector(entry);
    opt.dataset.value = JSON.stringify(valueSelector(entry));
    select.appendChild(opt);
  });
}

function renderAdminInfo() {
  const rankLabel = adminState.localeUi?.rank || 'Rank';
  const dutyLabel = adminState.localeUi?.duty || 'Duty';
  adminInfo.textContent = `${rankLabel}: ${adminState.rankName} (${adminState.rank}) | ${dutyLabel}: ${adminState.duty ? 'ON' : 'OFF'}`;

  panelTitle.textContent = adminState.branding?.panelName || adminState.localeUi?.panelName || 'AY Panel';
  panelLogo.textContent = adminState.branding?.panelLogo || 'AY';

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

    if (Array.isArray(data.weatherTypes)) {
      renderSelectOptions('weather', data.weatherTypes);
      if (data.defaults?.weather) {
        const weatherSelect = document.getElementById('weather');
        const index = data.weatherTypes.findIndex((x) => String(x) === String(data.defaults.weather));
        if (index >= 0) weatherSelect.value = String(index);
      }
    }
    if (Array.isArray(data.teleportPresets)) {
      renderSelectOptions('tpPreset', data.teleportPresets, (x) => x, (x) => x.label || 'Preset');
    }

    if (data.defaults) {
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
    if (action === 'setWeather') {
      const weatherSelect = document.getElementById('weather');
      const selected = weatherSelect.options[weatherSelect.selectedIndex];
      payload.weather = selected ? selected.textContent : '';
    }
    if (action === 'setTime') {
      payload.hour = Number(document.getElementById('hour').value || 12);
      payload.minute = Number(document.getElementById('minute').value || 0);
    }
    if (action === 'announce') payload.message = document.getElementById('announce').value.trim();
    if (action === 'tpToPlayer') payload.targetId = Number(document.getElementById('targetId').value || 0);
    if (action === 'bringPlayer') payload.targetId = Number(document.getElementById('bringTargetId').value || 0);
    if (action === 'kickPlayer') {
      payload.targetId = Number(document.getElementById('kickTargetId').value || 0);
      payload.reason = document.getElementById('kickReason').value.trim();
    }
    if (action === 'setNoclipSpeed') payload.value = Number(document.getElementById('noclipSpeed').value || 1.5);
    if (action === 'tpPreset') {
      const presetSelect = document.getElementById('tpPreset');
      const selected = presetSelect.options[presetSelect.selectedIndex];
      payload.preset = selected ? JSON.parse(selected.dataset.value || '{}') : null;
    }
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
  { id: 'freezePosition', action: 'freezePosition' },
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
  el.addEventListener('change', () => post('action', { action, state: el.checked }));
});

document.querySelectorAll('[data-nav-target]').forEach((btn) => {
  btn.addEventListener('click', () => {
    const target = document.getElementById(btn.dataset.navTarget);
    if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
  });
});

renderAdminInfo();
