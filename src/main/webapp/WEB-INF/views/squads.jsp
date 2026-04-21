<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.iplive.model.Team, com.iplive.model.Player" %>
<%@ include file="header.jsp" %>
<%
    Map<Team, List<Player>> squads = (Map<Team, List<Player>>) request.getAttribute("squads");
    List<Team> teamList;
    
        if (squads != null) {
        teamList = new ArrayList<Team>(squads.keySet());
            } else {
            teamList = new ArrayList<Team>();
                }
%>
<div class="page-wrap">
    <div class="sec-title mb20">Team Squads</div>

    <% if (teamList.isEmpty()) { %>
    <div class="card" style="text-align:center;padding:40px;color:#666">No teams found.</div>
    <% } else { %>

    <!-- Tab Buttons -->
    <div class="squad-tabs" id="squadTabs">
        <% for (int i = 0; i < teamList.size(); i++) {
            Team t = teamList.get(i); %>
        <button class='<%= "squad-tab" + (i == 0 ? " active" : "") %>'
                onclick="showSquad('<%= t.getTeamId() %>', this)">
            <%= t.getShortCode() %>
        </button>
        <% } %>
    </div>

    <!-- Squad Panels -->
    <% for (int i = 0; i < teamList.size(); i++) {
        Team t = teamList.get(i);
        List<Player> players = squads.get(t);
        String displayStyle = i == 0 ? "block" : "none";
        out.print("<div id='squad-" + t.getTeamId() + "' style='display:" + displayStyle + "'>");
    %>
        <div style="display:flex;align-items:center;gap:14px;margin-bottom:18px">
            <div style="width:48px;height:48px;border-radius:50%;background:rgba(255,255,255,0.07);display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;color:#ccc">
                <%= t.getShortCode() %>
            </div>
            <div>
                <div class="fw6 text-white" style="font-size:15px"><%= t.getTeamName() %></div>
                <div class="text-muted fs12"><%= t.getHomeGround() != null ? t.getHomeGround() : "Home Ground TBD" %> &nbsp;·&nbsp; <%= players != null ? players.size() : 0 %> Players</div>
            </div>
        </div>

        <% if (players != null && !players.isEmpty()) { %>
        <div class="squad-grid">
            <% for (Player p : players) {
                String roleClass = "pc-bat";
                if ("Bowler".equals(p.getRole()))       roleClass = "pc-bowl";
                if ("All-Rounder".equals(p.getRole()))  roleClass = "pc-ar";
                if ("Wicket-Keeper".equals(p.getRole()))roleClass = "pc-wk";
                String avatarUrl = p.getImageUrl();
                String initials = "";
                if (p.getPlayerName() != null && !p.getPlayerName().trim().isEmpty()) {
                    String[] parts = p.getPlayerName().trim().split("\\s+");
                    if (parts.length > 0) initials += parts[0].substring(0, 1).toUpperCase();
                    if (parts.length > 1) initials += parts[parts.length - 1].substring(0, 1).toUpperCase();
                }
                String avatarSrc = null;
                if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
                    avatarSrc = avatarUrl.startsWith("http") || avatarUrl.startsWith("/") ? avatarUrl : ctx + "/" + avatarUrl;
                }
            %>
            <div class="player-chip">
                <div class="player-avatar">
                    <% if (avatarSrc != null) { %>
                        <img src="<%= avatarSrc %>" alt="<%= p.getPlayerName() %>" width="120" height="160">
                    <% } else { %>
                        <div class="player-avatar-empty"><%= initials %></div>
                    <% } %>
                </div>
                <span class="pc-role <%= roleClass %>"><%= p.getRole() %></span>
                <a href="<%= ctx %>/player?playerId=<%= p.getPlayerId() %>" class="pc-name" style="text-decoration:none;color:inherit;display:block">
                    <%= p.getPlayerName() %>
                </a>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="text-muted fs12">No players added yet.</div>
        <% } %>
    </div>
    <% } %>
    <% } %>
</div>

<script>
function showSquad(teamId, btn) {
    document.querySelectorAll('[id^="squad-"]').forEach(d => d.style.display = 'none');
    document.querySelectorAll('.squad-tab').forEach(b => b.classList.remove('active'));
    document.getElementById('squad-' + teamId).style.display = 'block';
    btn.classList.add('active');
}
</script>
</body></html>
