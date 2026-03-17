'use strict';

/* ── Lokalizace ── */
const L10N = {
    en: { online:'ONLINE', id:'ID', name:'PLAYER',  job:'JOB',      ping:'PING', empty:'No players online.', loading:'SEARCHING...' },
    cs: { online:'ONLINE', id:'ID', name:'HRÁČ',    job:'PROFESE',  ping:'PING', empty:'Žádní hráči online.', loading:'NAČÍTÁNÍ...' },
    de: { online:'ONLINE', id:'ID', name:'SPIELER', job:'BERUF',    ping:'PING', empty:'Keine Spieler online.', loading:'LADEN...' },
    pl: { online:'ONLINE', id:'ID', name:'GRACZ',   job:'PRACA',    ping:'PING', empty:'Brak graczy online.', loading:'ŁADOWANIE...' },
    sk: { online:'ONLINE', id:'ID', name:'HRÁČ',    job:'POVOLANIE',ping:'PING', empty:'Žiadni hráči online.', loading:'NAČÍTAVANIE...' },
};

/* ── Stav ── */
let L          = L10N.cs;
let Cfg        = null;
let players    = [];
let page       = 1;
let totalPages = 1;

/* ── DOM ── */
const $ = id => document.getElementById(id);
const overlay      = $('overlay');
const playerList   = $('playerList');
const emptyState   = $('emptyState');
const onlineCount  = $('onlineCount');
const maxCount     = $('maxCount');
const activityEl   = $('activity');
const serverName   = $('serverName');
const serverTag    = $('serverTag');
const lblOnline    = $('lblOnline');
const lblId        = $('lblId');
const lblName      = $('lblName');
const lblJob       = $('lblJob');
const lblPing      = $('lblPing');
const lblSearching = $('lblSearching');
const pagination   = $('pagination');
const pageCurrent  = $('pageCurrent');
const pageTotal    = $('pageTotal');
const btnPrev      = $('btnPrev');
const btnNext      = $('btnNext');


// Šipky pro stránkování v prohlížeči (bez myši)
document.addEventListener('keydown', e => {
    if (overlay.classList.contains('hidden')) return;
    if (e.code === 'ArrowLeft')  { e.preventDefault(); goPage(page - 1, true); }
    if (e.code === 'ArrowRight') { e.preventDefault(); goPage(page + 1, true); }
});

/* ── Locale ── */
function setLocale(locale) {
    L = L10N[locale] || L10N.cs;
    lblOnline.textContent    = L.online;
    lblId.textContent        = L.id;
    lblName.textContent      = L.name;
    lblJob.textContent       = L.job;
    lblPing.textContent      = L.ping;
    lblSearching.textContent = L.loading;
}

/* ── Activity bar ── */
function buildActivity(counts, groups) {
    activityEl.innerHTML = '';
    if (!groups || !groups.length) { activityEl.style.display = 'none'; return; }
    activityEl.style.display = 'flex';
    groups.forEach(grp => {
        const count = counts ? (counts[grp.label] || 0) : 0;
        const el = document.createElement('div');
        el.className = 'act-group';
        el.innerHTML = `
            <i class="fas ${grp.icon} act-icon" style="color:${grp.color}"></i>
            <div class="act-body">
                <div class="act-count" id="cnt-${esc(grp.label)}">${count}</div>
                <div class="act-label">${grp.label}</div>
            </div>`;
        activityEl.appendChild(el);
    });
}

function updateActivityCounts(counts) {
    if (!counts || !Cfg) return;
    Cfg.activityGroups.forEach(grp => {
        const el = document.getElementById(`cnt-${esc(grp.label)}`);
        if (el) el.textContent = counts[grp.label] || 0;
    });
}

/* ── Render stránky ── */
function renderPage(list, animate) {
    playerList.querySelectorAll('.player-row').forEach(r => r.remove());
    if (!list || !list.length) {
        emptyState.querySelector('span').textContent = L.empty;
        emptyState.style.display = 'flex';
        return;
    }
    emptyState.style.display = 'none';
    list.forEach((p, i) => {
        const row = document.createElement('div');
        row.className = `player-row perm-${p.perm}${animate ? ' enter' : ''}`;
        row.dataset.pid = String(p.id);
        if (animate) row.style.animationDelay = `${i * 0.018}s`;

        const badge = p.perm === 'admin'
            ? `<span class="badge badge-admin">ADMIN</span>`
            : p.perm === 'mod'
            ? `<span class="badge badge-mod">MOD</span>` : '';

        const jobCol  = Cfg && Cfg.showJob
            ? `<div class="col-job${p.onDuty ? ' on-duty' : ''}">${esc(p.job)}</div>` : '';
        const pingCol = Cfg && Cfg.showPing
            ? `<div class="col-ping ping-${p.pingClass || 'good'}">
                   <span class="ping-dot"></span>
                   <span class="ping-val">${p.ping}</span>
               </div>` : '';

        row.innerHTML = `
            <div class="col-id">${p.id}</div>
            <div class="col-name"><span class="col-name-text">${esc(p.name)}</span>${badge}</div>
            ${jobCol}${pingCol}`;
        playerList.appendChild(row);
    });

    if (animate) {
        setTimeout(() => {
            playerList.querySelectorAll('.player-row.enter').forEach(r => r.classList.remove('enter'));
        }, 500);
    }
}

/* ── Stránkování ── */
function getPage(n) {
    const pp = (Cfg && Cfg.perPage) || 25;
    return players.slice((n - 1) * pp, n * pp);
}

function syncPagination() {
    const pp = (Cfg && Cfg.perPage) || 25;
    totalPages = Math.max(1, Math.ceil(players.length / pp));
    if (page > totalPages) page = totalPages;
    pageCurrent.textContent = page;
    pageTotal.textContent   = totalPages;
    btnPrev.disabled = page <= 1;
    btnNext.disabled = page >= totalPages;
    pagination.classList.toggle('hidden', totalPages <= 1);
}

function goPage(n, anim) {
    page = Math.max(1, Math.min(n, totalPages));
    syncPagination();
    renderPage(getPage(page), anim);
}

/* ── Smart refresh ── */
function smartUpdate(newPlayers) {
    players = newPlayers || [];
    syncPagination();
    const slice  = getPage(page);
    const curIds = new Set([...playerList.querySelectorAll('.player-row')].map(r => r.dataset.pid));
    const newIds = new Set(slice.map(p => String(p.id)));

    if (curIds.size !== newIds.size || [...curIds].some(id => !newIds.has(id))) {
        renderPage(slice, true);
        return;
    }
    slice.forEach(p => {
        const row = playerList.querySelector(`.player-row[data-pid="${p.id}"]`);
        if (!row) return;
        const pingEl  = row.querySelector('.col-ping');
        const pingVal = row.querySelector('.ping-val');
        if (pingEl && pingVal) {
            pingEl.className    = `col-ping ping-${p.pingClass || 'good'}`;
            pingVal.textContent = p.ping;
        }
        const jobEl = row.querySelector('.col-job');
        if (jobEl) {
            jobEl.textContent = p.job;
            jobEl.className   = `col-job${p.onDuty ? ' on-duty' : ''}`;
        }
    });
}

/* ── Otevření / Update / Zavření ── */
function openScoreboard(msg) {
    Cfg = msg.config || Cfg;
    if (Cfg) {
        setLocale(Cfg.locale);
        serverName.textContent = Cfg.serverName;
        serverTag.textContent  = Cfg.serverTagline;
    }
    page = 1;
    overlay.classList.remove('hidden');
    if (msg.data) {
        onlineCount.textContent = msg.data.total      || 0;
        maxCount.textContent    = msg.data.maxPlayers || 64;
        players = msg.data.players || [];
        if (Cfg && Cfg.showActivity) buildActivity(msg.data.activity, Cfg.activityGroups);
        else activityEl.style.display = 'none';
        syncPagination();
        renderPage(getPage(1), true);
    }
}

function updateScoreboard(data) {
    if (!data) return;
    onlineCount.textContent = data.total      || 0;
    maxCount.textContent    = data.maxPlayers || 64;
    if (Cfg && Cfg.showActivity) updateActivityCounts(data.activity);
    smartUpdate(data.players || []);
}

function closeScoreboard() {
    overlay.classList.add('hidden');
    playerList.querySelectorAll('.player-row').forEach(r => r.remove());
    emptyState.querySelector('span').textContent = L.loading;
    emptyState.style.display = 'flex';
    pagination.classList.add('hidden');
    players = []; page = 1;
}

/* ── NUI message listener (z Lua) ── */
window.addEventListener('message', e => {
    const msg = e.data;
    if (!msg || !msg.action) return;
    if      (msg.action === 'open')     openScoreboard(msg);
    else if (msg.action === 'update')   updateScoreboard(msg.data);
    else if (msg.action === 'close')    closeScoreboard();
    else if (msg.action === 'pageNext') goPage(page + 1, true);
    else if (msg.action === 'pagePrev') goPage(page - 1, true);
});

/* ── Tlačítka stránek ── */
btnPrev.addEventListener('click', () => goPage(page - 1, true));
btnNext.addEventListener('click', () => goPage(page + 1, true));

/* ── Utility ── */
function esc(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
