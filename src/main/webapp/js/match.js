// ===== IPLive match.js — Member 2 =====

let autoTimer = null;
let overDots   = [];
let currentOver = -1;

function getBasePath() {
    const el = document.getElementById('appCtx');
    return el ? el.value : '';
}

function getMatchId() {
    return document.getElementById('matchIdField').value;
}

function getResultClass(data) {
    if (data.isWicket) return 'br-wk';
    if (data.isSix)    return 'br-six';
    if (data.isFour)   return 'br-four';
    if (data.runs === 0) return 'br-dot';
    return '';
}

function getResultLabel(data) {
    if (data.isWicket) return 'W';
    if (data.isSix)    return '6';
    if (data.isFour)   return '4';
    return data.runs;
}

function getOverDotClass(data) {
    if (data.isWicket) return 'od od-w';
    if (data.isSix)    return 'od od-6';
    if (data.isFour)   return 'od od-4';
    return 'od od-r';
}

function updateOverDots(data, overStr) {
    const overNum = Math.floor(data.totalOver.split('.')[0]);
    if (overNum !== currentOver) {
        currentOver = overNum;
        overDots    = [];
    }
    overDots.push({ data, overStr });
    const container = document.getElementById('overDots');
    if (!container) return;
    container.innerHTML = '';
    overDots.forEach(item => {
        const div = document.createElement('div');
        div.className = getOverDotClass(item.data);
        div.textContent = getResultLabel(item.data);
        container.appendChild(div);
    });
    // Add empty dots for remaining balls
    for (let i = overDots.length; i < 6; i++) {
        const div = document.createElement('div');
        div.className = 'od od-e';
        div.textContent = '.';
        container.appendChild(div);
    }
}

function addCommentaryEntry(data) {
    const list = document.getElementById('commList');
    if (!list) return;
    const entry = document.createElement('div');
    entry.className = 'ball-entry';
    const rc = getResultClass(data);
    const rl = getResultLabel(data);
    entry.innerHTML = `
        <span class="ball-over">${data.over}</span>
        <span class="ball-result ${rc}">${rl}</span>
        <span class="ball-text">${data.commentary}</span>`;
    list.insertBefore(entry, list.firstChild);
    if (list.children.length > 20) list.removeChild(list.lastChild);
}

function formatOver(balls) {
    const overs = Math.floor(balls / 6);
    const ballsInOver = balls % 6;
    return overs + '.' + ballsInOver;
}

function updateScoreboard(data) {
    setEl('teamAScore', data.runs1 + '/' + data.wickets1);
    setEl('teamAOver', '(' + formatOver(data.balls1) + ' ov)');

    if (data.currentInnings === 2 || data.matchOver) {
        setEl('teamBScore', data.runs2 + '/' + data.wickets2);
        setEl('teamBOver', '(' + formatOver(data.balls2) + ' ov)');
        setEl('targetVal', data.target ? data.target : '—');
        setEl('needVal', data.needRuns + ' in ' + data.ballsRemaining + ' b');
    } else {
        setEl('teamBScore', '—');
        setEl('teamBOver', 'Yet to bat');
        setEl('targetVal', '—');
        setEl('needVal', data.ballsRemaining + ' balls left');
    }

    setEl('ballsVal', data.currentBalls + '/120');
    setEl('statusVal', data.status || 'Live');
    setEl('crrVal', data.totalOver && data.totalRuns ? (data.totalRuns * 6 / (parseInt(data.totalOver)*6 + parseInt(data.totalOver.split('.')[1]||0)) || 0).toFixed(2) : '0.00');
    // Batters
    setEl('strikerName',  (data.strikerName || '') + '*');
    setEl('strikerRuns',  data.strikerRuns);
    setEl('strikerBalls', data.strikerBalls);
    setEl('nonStrikerName',  data.nonStrikerName || '');
    setEl('nonStrikerRuns',  data.nonStrikerRuns);
    setEl('nonStrikerBalls', data.nonStrikerBalls);
    // SR
    const sr1 = data.strikerBalls > 0 ? ((data.strikerRuns / data.strikerBalls) * 100).toFixed(1) : '0.0';
    const sr2 = data.nonStrikerBalls > 0 ? ((data.nonStrikerRuns / data.nonStrikerBalls) * 100).toFixed(1) : '0.0';
    setEl('strikerSR', sr1);
    setEl('nonStrikerSR', sr2);
    // Prediction
    updatePrediction(data.teamAWinPct || 50, data.teamBWinPct || 50);
}

function updatePrediction(pctA, pctB) {
    const barA = document.getElementById('predBarA');
    const barB = document.getElementById('predBarB');
    const lblA = document.getElementById('predLabelA');
    const lblB = document.getElementById('predLabelB');
    if (barA) barA.style.width = pctA + '%';
    if (barB) barB.style.width = pctB + '%';
    if (lblA) lblA.textContent = (document.getElementById('teamAName') ? document.getElementById('teamAName').value : 'Team A') + ' — ' + pctA + '%';
    if (lblB) lblB.textContent = (document.getElementById('teamBName') ? document.getElementById('teamBName').value : 'Team B') + ' — ' + pctB + '%';
}

function setEl(id, val) {
    const el = document.getElementById(id);
    if (el) el.textContent = val;
}

async function bowlNextBall() {
    const btn = document.getElementById('nextBallBtn');
    if (btn) btn.disabled = true;

    try {
        const formData = new FormData();
        formData.append('matchId', getMatchId());

        const response = await fetch(getBasePath() + '/nextball', { method: 'POST', body: formData });
        const data     = await response.json();

        if (data.error) {
            console.error(data.error);
            showErrorMessage(data.error);
            if (btn) btn.disabled = false;
            return;
        }

        addCommentaryEntry(data);
        updateOverDots(data, data.over);
        updateScoreboard(data);

        if (data.inningsOver && !data.matchOver) {
            showInningsBreak(data.resultMessage);
            if (btn) { btn.disabled = false; btn.textContent = 'Start Innings 2 ▶'; }
            stopAutoPlay();
            return;
        }

        if (data.matchOver) {
            showMatchResult(data.resultMessage);
            if (btn) { btn.disabled = true; btn.textContent = 'Match Over'; }
            stopAutoPlay();
            return;
        }

        if (btn) { btn.disabled = false; btn.textContent = 'Bowl Next Ball ▶'; }

    } catch (err) {
        console.error(err);
        if (btn) btn.disabled = false;
    }
}

function showInningsBreak(msg) {
    const el = document.getElementById('resultBanner');
    if (!el) return;
    el.style.display = 'block';
    el.style.background = 'rgba(245,197,24,0.12)';
    el.style.borderColor = 'rgba(245,197,24,0.3)';
    el.style.color = '#f5c518';
    el.textContent = '🏏 INNINGS BREAK — ' + msg;
}

function showMatchResult(msg) {
    const el = document.getElementById('resultBanner');
    if (!el) return;
    el.style.display = 'block';
    el.style.background = 'rgba(59,109,17,0.18)';
    el.style.borderColor = 'rgba(59,109,17,0.4)';
    el.style.color = '#7ec850';
    el.textContent = '🏆 MATCH RESULT — ' + msg;
}

function showErrorMessage(msg) {
    const el = document.getElementById('resultBanner');
    if (!el) return;
    el.style.display = 'block';
    el.style.background = 'rgba(255,85,85,0.12)';
    el.style.borderColor = 'rgba(255,85,85,0.3)';
    el.style.color = '#ff5a5a';
    el.textContent = '⚠️ Error — ' + msg;
}

function startAutoPlay() {
    if (autoTimer) return;
    document.getElementById('autoPlayBtn').textContent = 'Pause Auto ⏸';
    autoTimer = setInterval(() => {
        const btn = document.getElementById('nextBallBtn');
        if (btn && btn.disabled && btn.textContent === 'Match Over') { stopAutoPlay(); return; }
        bowlNextBall();
    }, 1300);
}

function stopAutoPlay() {
    if (autoTimer) { clearInterval(autoTimer); autoTimer = null; }
    const ab = document.getElementById('autoPlayBtn');
    if (ab) ab.textContent = 'Auto Play ▶▶';
}

function toggleAutoPlay() {
    if (autoTimer) stopAutoPlay();
    else startAutoPlay();
}

// Init empty over dots on page load
document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('overDots');
    if (!container) return;
    container.innerHTML = '';
    for (let i = 0; i < 6; i++) {
        const d = document.createElement('div');
        d.className = 'od od-e'; d.textContent = '.';
        container.appendChild(d);
    }
});


