<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.iplive.model.Match, com.iplive.model.Player" %>
<%@ include file="header.jsp" %>
<%
    Match match    = (Match) request.getAttribute("match");
    List<Player> batters = (List<Player>) request.getAttribute("batters");
    List<Player> bowlers = (List<Player>) request.getAttribute("bowlers");
    
    if (match == null) { response.sendRedirect(ctx + "/home"); return; }
    Player striker    = batters != null && !batters.isEmpty() ? batters.get(0) : null;
    Player nonStriker = batters != null && batters.size() > 1 ? batters.get(1) : null;
    Player bowler     = bowlers != null && !bowlers.isEmpty() ? bowlers.get(0) : null;
    int[] bRuns  = match.getBatterRuns()  != null ? match.getBatterRuns()  : new int[11];
    int[] bBalls = match.getBatterBalls() != null ? match.getBatterBalls() : new int[11];
%>

<!-- Hidden fields for JS -->
<input type="hidden" id="appCtx"        value="<%= ctx %>">
<input type="hidden" id="matchIdField" value="<%= match.getMatchId() %>">
<input type="hidden" id="teamAName"    value="<%= match.getTeamAName() %>">
<input type="hidden" id="teamBName"    value="<%= match.getTeamBName() %>">

<!-- Match Header -->
<div class="match-header">
    <button class="back-btn" onclick="location.href='<%= ctx %>/home'">← Back</button>
    <div>
        <div class="mh-title"><%= match.getTeamAName() %> vs <%= match.getTeamBName() %></div>
        <div class="mh-sub"><%= match.getVenue() != null ? match.getVenue() : "" %> · 20 Overs per side</div>
    </div>
    <% if ("Live".equals(match.getStatus())) { %><span class="live-badge" style="margin-left:auto">LIVE</span><% } %>
</div>

<!-- Result Banner (hidden by default) -->
<div id="resultBanner" style="display:none;margin:10px 20px;padding:12px 16px;border-radius:8px;border:1px solid;font-size:13px;font-weight:600;text-align:center"></div>

<!-- Scoreboard -->
<div class="scoreboard">
    <!-- Prediction -->
    <div class="pred-wrap">
        <div class="pred-label">MATCH PREDICTION</div>
        <div class="pred-teams">
            <span id="predLabelA"><%= match.getTeamAName() %> — 50%</span>
            <span id="predLabelB"><%= match.getTeamBName() %> — 50%</span>
        </div>
        <div class="pred-bar">
            <div class="pred-a" id="predBarA" style="width:50%"></div>
            <div class="pred-b" id="predBarB" style="width:50%"></div>
        </div>
        <div class="pred-note">Based on run rate, wickets &amp; match state</div>
    </div>

    <!-- Teams Score -->
    <div class="score-teams">
        <div class="score-team">
            <div class="stb" style="background:rgba(255,255,255,0.08);color:#ccc"><%= match.getTeamACode() %></div>
            <div class="stn"><%= match.getTeamAName() %></div>
            <div class="str" id="teamAScore"><%= match.getRuns1() %>/<%= match.getWickets1() %></div>
            <div class="sto" id="teamAOver">(<%= match.getOverString(match.getBalls1()) %> ov)</div>
        </div>
        <div class="vs-big">vs</div>
        <div class="score-team">
            <div class="stb" style="background:rgba(255,255,255,0.08);color:#ccc"><%= match.getTeamBCode() %></div>
            <div class="stn"><%= match.getTeamBName() %></div>
            <div class="str" id="teamBScore"><%= match.getCurrentInnings() == 2 ? match.getRuns2() + "/" + match.getWickets2() : "—" %></div>
            <div class="sto" id="teamBOver"><%= match.getCurrentInnings() == 2 ? "(" + match.getOverString(match.getBalls2()) + " ov)" : "Yet to bat" %></div>
        </div>
    </div>

    <!-- CRR Bar -->
    <div class="crr-bar">
        <div class="ci">
            <div class="cl">CRR</div>
            <div class="cv" id="crrVal">
                <%= match.getCurrentBalls() > 0 ? String.format("%.2f", match.getCurrentRuns() * 6.0 / match.getCurrentBalls()) : "0.00" %>
            </div>
        </div>
        <div class="ci">
            <div class="cl">Innings</div>
            <div class="cv"><%= match.getCurrentInnings() == 1 ? "1st" : "2nd" %></div>
        </div>
        <% if (match.getCurrentInnings() == 2) { %>
        <div class="ci">
            <div class="cl">Balls</div>
            <div class="cv" id="ballsVal"><%= match.getCurrentBalls() %>/120</div>
        </div>
        <div class="ci">
            <div class="cl">Status</div>
            <div class="cv" id="statusVal"><%= match.getStatus() %></div>
        </div>
        <div class="ci">
            <div class="cl">Target</div>
            <div class="cv" id="targetVal"><%= match.getRuns1() + 1 %></div>
        </div>
        <div class="ci">
            <div class="cl">Need</div>
            <div class="cv" id="needVal"><%= (match.getRuns1() + 1 - match.getRuns2()) %> in <%= (120 - match.getBalls2()) %> b</div>
        </div>
        <% } else { %>
        <div class="ci">
            <div class="cl">Balls</div>
            <div class="cv" id="ballsVal"><%= match.getCurrentBalls() %>/120</div>
        </div>
        <div class="ci">
            <div class="cl">Status</div>
            <div class="cv" id="statusVal"><%= match.getStatus() %></div>
        </div>
        <div class="ci">
            <div class="cl">Target</div>
            <div class="cv" id="targetVal">—</div>
        </div>
        <div class="ci">
            <div class="cl">Need</div>
            <div class="cv" id="needVal">—</div>
        </div>
        <% } %>
    </div>
</div>

<!-- Match Body -->
<div class="match-body">
    <!-- Commentary Panel -->
    <div class="comm-panel">
        <div class="panel-title">Live Commentary</div>
        <div class="comm-list" id="commList">
            <% for (String c : match.getCommentary()) { %>
            <div class="ball-entry">
                <span class="ball-over">ball</span>
                <span class="ball-result">—</span>
                <span class="ball-text"><%= c %></span>
            </div>
            <% } %>
            <% if (match.getCommentary().isEmpty()) { %>
            <div class="ball-text text-muted" style="padding:8px 0">Press "Bowl Next Ball" to start the simulation!</div>
            <% } %>
        </div>

        <div class="panel-title">This Over</div>
        <div class="over-dots" id="overDots"></div>

        <button class="nbb" id="nextBallBtn"
            onclick="bowlNextBall()"
            <%= "Completed".equals(match.getStatus()) ? "disabled" : "" %>>
            <%= "Completed".equals(match.getStatus()) ? "Match Over" : "Bowl Next Ball ▶" %>
        </button>
        <button class="ab-btn" id="autoPlayBtn" onclick="toggleAutoPlay()">Auto Play ▶▶</button>
    </div>

    <!-- Batters / Bowler Panel -->
    <div class="batt-panel">
        <div class="panel-title">At the Crease</div>
        <table class="tbl mb12">
            <tr><th>Batter</th><th>R</th><th>B</th><th>SR</th></tr>
            <tr>
                <td class="fw6 text-gold">
                    <span style="display:inline-block;width:6px;height:6px;background:#f5c518;border-radius:50%;margin-right:5px"></span>
                    <span id="strikerName"><%= striker != null ? striker.getPlayerName() + "*" : "—" %></span>
                </td>
                <td id="strikerRuns"><%= bRuns.length > 0 ? bRuns[0] : 0 %></td>
                <td id="strikerBalls"><%= bBalls.length > 0 ? bBalls[0] : 0 %></td>
                <td id="strikerSR">0.0</td>
            </tr>
            <tr>
                <td class="fw6"><span id="nonStrikerName"><%= nonStriker != null ? nonStriker.getPlayerName() : "—" %></span></td>
                <td id="nonStrikerRuns"><%= bRuns.length > 1 ? bRuns[1] : 0 %></td>
                <td id="nonStrikerBalls"><%= bBalls.length > 1 ? bBalls[1] : 0 %></td>
                <td id="nonStrikerSR">0.0</td>
            </tr>
        </table>

        <div class="panel-title">Current Bowler</div>
        <table class="tbl mb12">
            <tr><th>Bowler</th><th>Role</th></tr>
            <tr>
                <td class="fw6"><%= bowler != null ? bowler.getPlayerName() : "—" %></td>
                <td class="text-muted"><%= bowler != null ? bowler.getRole() : "" %></td>
            </tr>
        </table>

        <div class="panel-title">Batting Team</div>
        <div style="font-size:12px;color:#888;margin-bottom:8px">
            <%= match.getCurrentInnings() == 1 ? match.getTeamAName() : match.getTeamBName() %>
            &nbsp;|&nbsp;
            Wickets: <span class="text-red"><%= match.getCurrentWickets() %>/10</span>
        </div>

        <% if ("Completed".equals(match.getStatus())) { %>
        <a href="<%= ctx %>/scorecard?matchId=<%= match.getMatchId() %>">
            <button class="form-submit" style="background:#1a1a2e;color:#f5c518;border:1px solid rgba(245,197,24,0.3)">
                View Full Scorecard →
            </button>
        </a>
        <% } %>
    </div>
</div>

<script src="<%= ctx %>/js/match.js"></script>
</body></html>
