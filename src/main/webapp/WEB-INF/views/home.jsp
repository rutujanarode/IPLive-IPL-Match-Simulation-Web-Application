<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.iplive.model.Match" %>
<%@ include file="header.jsp" %>
<%
    List<Match> matches = (List<Match>) request.getAttribute("matches");
%>

<!-- Hero -->
<div class="hero">
    <div class="hero-badge">TATA IPL 2025 SEASON</div>
    <h1>Feel every ball. <span>Live.</span></h1>
    <p>Simulate IPL matches ball-by-ball with live commentary, stats &amp; analytics</p>
    <div class="hero-btns">
        <button class="btn-primary" onclick="location.href='<%= ctx %>/match'">Start Match ▶</button>
        <button class="btn-outline" onclick="location.href='<%= ctx %>/stats'">View Caps &amp; Points</button>
        <button class="btn-outline" onclick="location.href='<%= ctx %>/squads'">Team Squads</button>
    </div>
</div>

<div class="page-wrap">
    <div class="sec-title">
        Matches
        <span class="live-badge">LIVE</span>
    </div>

    <% if (matches != null && !matches.isEmpty()) { %>
    <div class="match-cards">
        <% for (Match m : matches) {
            String statusClass = "s-upcoming";
            if ("Live".equals(m.getStatus()))      statusClass = "s-live";
            if ("Completed".equals(m.getStatus())) statusClass = "s-completed";
            String href = "Live".equals(m.getStatus()) || "Upcoming".equals(m.getStatus())
                ? ctx + "/match?matchId=" + m.getMatchId()
                : ctx + "/scorecard?matchId=" + m.getMatchId();
        %>
        <div class="match-card" onclick="location.href='<%= href %>'">
            <div class="mc-header">
                <span class="mc-status <%= statusClass %>"><%= m.getStatus() %></span>
                <span class="mc-venue"><%= m.getVenue() != null ? m.getVenue() : "" %></span>
            </div>
            <div class="teams-row">
                <div class="team-block">
                    <div class="team-badge" style="background:rgba(255,255,255,0.06);color:#ccc"><%= m.getTeamACode() %></div>
                    <div class="team-name"><%= m.getTeamAName() %></div>
                    <% if (m.getBalls1() > 0) { %>
                    <div class="team-score"><%= m.getRuns1() %>/<%= m.getWickets1() %></div>
                    <% } else { %><div class="team-score text-muted">—</div><% } %>
                </div>
                <div class="vs-text">vs</div>
                <div class="team-block">
                    <div class="team-badge" style="background:rgba(255,255,255,0.06);color:#ccc"><%= m.getTeamBCode() %></div>
                    <div class="team-name"><%= m.getTeamBName() %></div>
                    <% if (m.getBalls2() > 0) { %>
                    <div class="team-score text-green"><%= m.getRuns2() %>/<%= m.getWickets2() %></div>
                    <% } else { %><div class="team-score text-muted">—</div><% } %>
                </div>
            </div>
            <div class="mc-footer">
                <% if ("Completed".equals(m.getStatus()) && m.getWinnerName() != null) { %>
                    <span class="text-green"><%= m.getWinnerName() %> won</span>
                <% } else if ("Live".equals(m.getStatus())) { %>
                    Click to watch live simulation
                <% } else { %>
                    Click to start simulation
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <div class="card" style="text-align:center;padding:40px;color:#666">
        No matches found. <a href="<%= ctx %>/admin" style="color:#f5c518">Go to Admin</a> to schedule one.
    </div>
    <% } %>

    <!-- Quick nav cards -->
    <div class="g3 mt20">
        <div class="card" style="cursor:pointer;text-align:center;padding:24px" onclick="location.href='<%= ctx %>/stats'">
            <div style="font-size:28px;margin-bottom:8px">🟠</div>
            <div class="fw6 text-white">Orange &amp; Purple Cap</div>
            <div class="text-muted fs12 mt12">Top run scorers &amp; wicket takers</div>
        </div>
        <div class="card" style="cursor:pointer;text-align:center;padding:24px" onclick="location.href='<%= ctx %>/squads'">
            <div style="font-size:28px;margin-bottom:8px">👥</div>
            <div class="fw6 text-white">Team Squads</div>
            <div class="text-muted fs12 mt12">Players, roles &amp; team info</div>
        </div>
        <div class="card" style="cursor:pointer;text-align:center;padding:24px" onclick="location.href='<%= ctx %>/history'">
            <div style="font-size:28px;margin-bottom:8px">📜</div>
            <div class="fw6 text-white">Match History</div>
            <div class="text-muted fs12 mt12">Past results &amp; scorecards</div>
        </div>
    </div>
</div>
</body></html>
