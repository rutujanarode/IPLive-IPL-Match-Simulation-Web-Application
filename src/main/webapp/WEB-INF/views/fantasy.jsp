<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ include file="header.jsp" %>
<%
    List<Map<String,Object>> leaderboard = (List<Map<String,Object>>) request.getAttribute("leaderboard");
    List<Map<String,Object>> toppers     = (List<Map<String,Object>>) request.getAttribute("toppers");
    List<Map<String,Object>> allAchs     = (List<Map<String,Object>>) request.getAttribute("allAchs");
%>

<style>
/* ── Fantasy Feature Styles ────────────────────────────── */
.fantasy-hero {
    background: linear-gradient(135deg, #1a0533 0%, #12122a 60%, #0d1f0d 100%);
    border-bottom: 1px solid rgba(180,100,255,0.25);
    padding: 44px 24px 32px;
    text-align: center;
}
.fantasy-hero h1 { color:#fff; font-size:30px; font-weight:700; margin-bottom:6px; }
.fantasy-hero h1 span { color:#b464ff; }
.fantasy-hero p  { color:#999; font-size:14px; }

.ftab-bar {
    display: flex; gap: 4px; margin-bottom: 22px;
    border-bottom: 1px solid rgba(255,255,255,0.07);
    padding-bottom: 0;
}
.ftab {
    padding: 9px 18px; border-radius: 8px 8px 0 0; cursor: pointer;
    font-size: 13px; font-weight: 600; color: #888;
    border: 1px solid transparent; border-bottom: none;
    transition: all .2s;
}
.ftab.active { color:#b464ff; background:rgba(180,100,255,0.1); border-color:rgba(180,100,255,0.25); }
.ftab:hover:not(.active) { color:#ccc; background:rgba(255,255,255,0.04); }

.ftab-content { display:none; }
.ftab-content.active { display:block; }

/* Leaderboard */
.lb-row {
    display: grid;
    grid-template-columns: 36px 1fr 70px 60px 70px;
    gap: 6px;
    align-items: center;
    padding: 10px 12px;
    border-radius: 8px;
    transition: background .15s;
    cursor: pointer;
}
.lb-row:hover { background: rgba(180,100,255,0.07); }
.lb-row.gold   { background: rgba(245,197,24,0.07); }
.lb-row.silver { background: rgba(180,180,180,0.05); }
.lb-row.bronze { background: rgba(205,127,50,0.06); }

.lb-rank { font-size:16px; text-align:center; }
.lb-name { font-weight:600; font-size:13px; color:#eee; }
.lb-team { font-size:11px; color:#888; margin-top:2px; }
.lb-pts  { font-size:16px; font-weight:700; color:#b464ff; text-align:right; }
.lb-avg  { font-size:12px; color:#777; text-align:right; }
.lb-matches { font-size:12px; color:#666; text-align:right; }

.lb-hdr {
    display: grid;
    grid-template-columns: 36px 1fr 70px 60px 70px;
    gap: 6px; padding: 6px 12px;
    font-size:11px; color:#555; letter-spacing:.5px; text-transform:uppercase;
    border-bottom: 1px solid rgba(255,255,255,0.06);
    margin-bottom: 6px;
}

/* Points breakdown card */
.pts-system {
    display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
}
@media(max-width:600px) { .pts-system { grid-template-columns:1fr; } }
.pts-card {
    background: #12122a; border: 1px solid rgba(255,255,255,0.07);
    border-radius: 10px; padding: 16px;
}
.pts-card-title { font-size:13px; font-weight:700; color:#b464ff; margin-bottom:12px; display:flex; align-items:center; gap:6px; }
.pts-row { display:flex; justify-content:space-between; align-items:center; padding:5px 0; border-bottom:1px solid rgba(255,255,255,0.04); font-size:12px; color:#aaa; }
.pts-row:last-child { border-bottom:none; }
.pts-val { font-weight:700; color:#e0e0e0; }
.pts-val.pos { color:#4dff91; }
.pts-val.neg { color:#ff6b6b; }

/* Achievements grid */
.ach-grid {
    display: grid; grid-template-columns: repeat(auto-fill,minmax(180px,1fr)); gap:14px;
}
.ach-tile {
    background: #12122a; border:1px solid rgba(255,255,255,0.07);
    border-radius:10px; padding:16px 14px; text-align:center; transition:border-color .2s;
}
.ach-tile:hover { border-color:rgba(180,100,255,0.35); }
.ach-icon  { font-size:28px; margin-bottom:8px; }
.ach-title { font-size:13px; font-weight:700; color:#e0e0e0; margin-bottom:4px; }
.ach-desc  { font-size:11px; color:#777; }
.ach-cat   { font-size:10px; color:#b464ff; margin-top:6px; text-transform:uppercase; letter-spacing:.8px; }

/* Match toppers */
.topper-row {
    display:flex; align-items:center; justify-content:space-between;
    padding:10px 12px; border-radius:8px; border-bottom:1px solid rgba(255,255,255,0.05);
}
.topper-row:last-child { border-bottom:none; }
.topper-match { font-size:11px; color:#666; }
.topper-name  { font-size:13px; font-weight:600; color:#eee; }
.topper-pts   { font-size:18px; font-weight:700; color:#b464ff; }

/* Team badge pill */
.team-pill {
    display:inline-block; padding:2px 8px; border-radius:10px;
    font-size:10px; font-weight:700; letter-spacing:.6px;
}

/* Stats summary bar */
.summary-bar {
    display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:22px;
}
@media(max-width:600px) { .summary-bar { grid-template-columns:repeat(2,1fr); } }
.summary-cell {
    background:#12122a; border:1px solid rgba(255,255,255,0.07);
    border-radius:10px; padding:14px; text-align:center;
}
.summary-val  { font-size:22px; font-weight:700; color:#b464ff; }
.summary-lbl  { font-size:11px; color:#666; margin-top:4px; }
</style>

<!-- Hero -->
<div class="fantasy-hero">
    <div class="hero-badge" style="border-color:rgba(180,100,255,0.4);color:#b464ff;background:rgba(180,100,255,0.1)">
        FANTASY LEAGUE — IPL 2025
    </div>
    <h1>Fantasy <span>Points Arena</span></h1>
    <p>Auto-computed points, achievement badges & season leaderboard</p>
</div>

<div class="page-wrap">

    <%-- Summary stats bar --%>
    <%
        int totalPlayers = leaderboard != null ? leaderboard.size() : 0;
        int totalMatches = toppers != null ? toppers.size() : 0;
        int totalBadges  = allAchs  != null ? allAchs.size()  : 0;
        int topPts = 0;
        if (leaderboard != null && !leaderboard.isEmpty()) {
            topPts = (Integer) leaderboard.get(0).get("pts");
        }
    %>
    <div class="summary-bar">
        <div class="summary-cell">
            <div class="summary-val"><%= totalPlayers %>+</div>
            <div class="summary-lbl">Players Ranked</div>
        </div>
        <div class="summary-cell">
            <div class="summary-val"><%= totalMatches %></div>
            <div class="summary-lbl">Matches Scored</div>
        </div>
        <div class="summary-cell">
            <div class="summary-val"><%= totalBadges %></div>
            <div class="summary-lbl">Achievement Types</div>
        </div>
        <div class="summary-cell">
            <div class="summary-val"><%= topPts %></div>
            <div class="summary-lbl">Top Season Points</div>
        </div>
    </div>

    <%-- Tab bar --%>
    <div class="ftab-bar">
        <div class="ftab active" onclick="switchTab('leaderboard',this)">🏆 Leaderboard</div>
        <div class="ftab" onclick="switchTab('toppers',this)">⚡ Match MVPs</div>
        <div class="ftab" onclick="switchTab('achievements',this)">🎖 Achievements</div>
        <div class="ftab" onclick="switchTab('points',this)">📋 Points System</div>
        <% if ("admin".equals(role)) { %>
        <div class="ftab" onclick="switchTab('admin',this)">⚙ Admin</div>
        <% } %>
    </div>

    <%-- ── TAB 1: Season Leaderboard ─────────────────────────────────────── --%>
    <div id="tab-leaderboard" class="ftab-content active">
        <div class="sec-title">Season Fantasy Leaderboard</div>
        <div class="card" style="padding:16px">
            <div class="lb-hdr">
                <span>#</span><span>Player</span>
                <span style="text-align:right">Pts</span>
                <span style="text-align:right">Avg</span>
                <span style="text-align:right">Matches</span>
            </div>
            <% if (leaderboard != null && !leaderboard.isEmpty()) {
                for (Map<String,Object> row : leaderboard) {
                    int r = (Integer)row.get("rank");
                    String rowClass = r==1?"gold":r==2?"silver":r==3?"bronze":"";
                    String rankEmoji = r==1?"🥇":r==2?"🥈":r==3?"🥉":String.valueOf(r);
                    String hex = (String)row.get("color");
            %>
            <div class="lb-row <%= rowClass %>" onclick="location.href='<%= ctx %>/fantasy?playerId=<%= row.get("playerId") %>'">
                <div class="lb-rank"><%= rankEmoji %></div>
                <div>
                    <div class="lb-name"><%= row.get("name") %></div>
                    <div class="lb-team">
                        <span class="team-pill" style="background:<%= hex %>22;color:<%= hex %>"><%= row.get("code") %></span>
                        &nbsp;<%= row.get("role") %>
                    </div>
                </div>
                <div class="lb-pts"><%= row.get("pts") %></div>
                <div class="lb-avg"><%= row.get("avg") %></div>
                <div class="lb-matches"><%= row.get("matches") %></div>
            </div>
            <% } } else { %>
            <div style="text-align:center;padding:40px;color:#555">
                No fantasy points yet.<br>
                <% if ("admin".equals(role)) { %>
                <a href="#" onclick="switchTab('admin',document.querySelectorAll('.ftab')[4])" style="color:#b464ff">Go to Admin tab</a> to compute points.
                <% } else { %>
                Complete some matches first!
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <%-- ── TAB 2: Match MVPs ───────────────────────────────────────────────── --%>
    <div id="tab-toppers" class="ftab-content">
        <div class="sec-title">Match Fantasy MVPs</div>
        <div class="card" style="padding:16px">
            <% if (toppers != null && !toppers.isEmpty()) {
                for (Map<String,Object> t : toppers) { %>
            <div class="topper-row">
                <div>
                    <div class="topper-name"><%= t.get("player") %>
                        <span class="team-pill" style="background:rgba(180,100,255,0.15);color:#b464ff;margin-left:6px"><%= t.get("teamCode") %></span>
                    </div>
                    <div class="topper-match"><%= t.get("vs") %> &bull; <%= t.get("date") %></div>
                </div>
                <div class="topper-pts"><%= t.get("pts") %> pts</div>
            </div>
            <% } } else { %>
            <div style="text-align:center;padding:40px;color:#555">No match MVP data yet.</div>
            <% } %>
        </div>
    </div>

    <%-- ── TAB 3: Achievements ─────────────────────────────────────────────── --%>
    <div id="tab-achievements" class="ftab-content">
        <div class="sec-title">All Achievements</div>
        <div class="ach-grid">
            <% if (allAchs != null) { for (Map<String,Object> a : allAchs) { %>
            <div class="ach-tile">
                <div class="ach-icon"><%= a.get("icon") %></div>
                <div class="ach-title"><%= a.get("title") %></div>
                <div class="ach-desc"><%= a.get("desc") %></div>
                <div class="ach-cat"><%= a.get("cat") %></div>
            </div>
            <% } } %>
        </div>
    </div>

    <%-- ── TAB 4: Points System ────────────────────────────────────────────── --%>
    <div id="tab-points" class="ftab-content">
        <div class="sec-title">How Points Are Calculated</div>
        <div class="pts-system">
            <div class="pts-card">
                <div class="pts-card-title">🏏 Batting</div>
                <div class="pts-row"><span>Run scored</span><span class="pts-val pos">+1 / run</span></div>
                <div class="pts-row"><span>Boundary (4)</span><span class="pts-val pos">+1</span></div>
                <div class="pts-row"><span>Six hit</span><span class="pts-val pos">+2</span></div>
                <div class="pts-row"><span>Half-century (50+)</span><span class="pts-val pos">+8</span></div>
                <div class="pts-row"><span>Century (100+)</span><span class="pts-val pos">+16</span></div>
                <div class="pts-row"><span>Duck (out for 0)</span><span class="pts-val neg">-2</span></div>
                <div class="pts-row"><span>SR &gt;170 (min 10b)</span><span class="pts-val pos">+6</span></div>
                <div class="pts-row"><span>SR &gt;150</span><span class="pts-val pos">+4</span></div>
                <div class="pts-row"><span>SR &gt;130</span><span class="pts-val pos">+2</span></div>
                <div class="pts-row"><span>SR &lt;100</span><span class="pts-val neg">-2</span></div>
                <div class="pts-row"><span>SR &lt;70</span><span class="pts-val neg">-4</span></div>
                <div class="pts-row"><span>SR &lt;50</span><span class="pts-val neg">-6</span></div>
            </div>
            <div class="pts-card">
                <div class="pts-card-title">🎯 Bowling</div>
                <div class="pts-row"><span>Wicket taken</span><span class="pts-val pos">+25</span></div>
                <div class="pts-row"><span>3-wicket haul</span><span class="pts-val pos">+8 bonus</span></div>
                <div class="pts-row"><span>5-wicket haul</span><span class="pts-val pos">+16 bonus</span></div>
                <div class="pts-row"><span>Dot ball (est.)</span><span class="pts-val pos">+0.4</span></div>
                <div class="pts-row"><span>Economy &lt;5 (2+ ov)</span><span class="pts-val pos">+6</span></div>
                <div class="pts-row"><span>Economy &lt;6</span><span class="pts-val pos">+4</span></div>
                <div class="pts-row"><span>Economy &lt;7</span><span class="pts-val pos">+2</span></div>
                <div class="pts-row"><span>Economy &gt;8</span><span class="pts-val neg">-2</span></div>
                <div class="pts-row"><span>Economy &gt;9</span><span class="pts-val neg">-4</span></div>
                <div class="pts-row"><span>Economy &gt;10</span><span class="pts-val neg">-6</span></div>
            </div>
            <div class="pts-card">
                <div class="pts-card-title">⭐ Bonus</div>
                <div class="pts-row"><span>Playing XI</span><span class="pts-val pos">+4</span></div>
                <div class="pts-row"><span>30+ runs &amp; 2+ wickets</span><span class="pts-val pos">All-Rounder badge</span></div>
            </div>
            <div class="pts-card">
                <div class="pts-card-title">🏅 Rank Medals</div>
                <div class="pts-row"><span>1st place season</span><span class="pts-val" style="color:#f5c518">🥇 Gold</span></div>
                <div class="pts-row"><span>2nd place season</span><span class="pts-val" style="color:#aaa">🥈 Silver</span></div>
                <div class="pts-row"><span>3rd place season</span><span class="pts-val" style="color:#cd7f32">🥉 Bronze</span></div>
                <div class="pts-row" style="margin-top:10px"><span style="color:#888">Avg = Total pts / Matches</span><span></span></div>
            </div>
        </div>
    </div>

    <%-- ── TAB 5: Admin (recompute) ────────────────────────────────────────── --%>
    <% if ("admin".equals(role)) { %>
    <div id="tab-admin" class="ftab-content">
        <div class="sec-title">Admin — Recompute Fantasy Points</div>
        <div class="card" style="padding:24px">
            <p style="color:#aaa;font-size:13px;margin-bottom:20px">
                Run recompute after every completed match to refresh the leaderboard and badges.
            </p>
            <form method="post" action="<%= ctx %>/fantasy" style="display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end">
                <div>
                    <label style="font-size:12px;color:#888;display:block;margin-bottom:4px">Match ID (optional)</label>
                    <input type="number" name="matchId" placeholder="e.g. 3"
                           style="background:#0d0d1a;border:1px solid rgba(255,255,255,0.12);color:#e0e0e0;padding:8px 12px;border-radius:6px;width:140px">
                </div>
                <button type="submit" name="action" value="recompute"
                        class="btn-primary" style="background:#b464ff;color:#fff">
                    Recompute Match
                </button>
                <button type="submit" name="action" value="recomputeAll"
                        class="btn-outline" style="border-color:rgba(180,100,255,0.4);color:#b464ff"
                        onclick="return confirm('Recompute ALL completed matches?')">
                    Recompute All Matches
                </button>
            </form>
        </div>
    </div>
    <% } %>

</div>

<script>
function switchTab(id, el) {
    document.querySelectorAll('.ftab-content').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.ftab').forEach(t => t.classList.remove('active'));
    document.getElementById('tab-' + id).classList.add('active');
    el.classList.add('active');
}
</script>

</body></html>
