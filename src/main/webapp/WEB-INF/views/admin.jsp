<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.iplive.model.Team, com.iplive.model.Player, com.iplive.model.Match" %>
<%@ include file="header.jsp" %>
<%
    List<Team>  teams   = (List<Team>)  request.getAttribute("teams");
    List<Player>players = (List<Player>)request.getAttribute("players");
    List<Match> matches = (List<Match>) request.getAttribute("matches");
    
    if (!"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(ctx + "/login"); return;
    }
%>
<div class="page-wrap">
    <div class="sec-title mb20">Admin Panel</div>
    <div class="admin-grid">

        <!-- Add Team -->
        <div class="card-sec">
            <div class="fw6 text-white mb12">Add New Team</div>
            <div class="text-muted fs12 mb12">Register a team for the season</div>
            <form method="post" action="<%= ctx %>/admin">
                <input type="hidden" name="action" value="addTeam">
                <div class="form-group"><label>Team Name</label><input type="text" name="teamName" placeholder="e.g. Mumbai Indians" required></div>
                <div class="form-group"><label>Short Code</label><input type="text" name="shortCode" placeholder="e.g. MI" maxlength="5" required></div>
                <div class="form-group"><label>Home Ground</label><input type="text" name="homeGround" placeholder="e.g. Wankhede Stadium"></div>
                <button type="submit" class="form-submit">Add Team</button>
            </form>
        </div>

        <!-- Add Player -->
        <div class="card-sec">
            <div class="fw6 text-white mb12">Add Player</div>
            <div class="text-muted fs12 mb12">Register a player to a team</div>
            <form method="post" action="<%= ctx %>/admin">
                <input type="hidden" name="action" value="addPlayer">
                <div class="form-group"><label>Player Name</label><input type="text" name="playerName" placeholder="e.g. Rohit Sharma" required></div>
                <div class="form-group">
                    <label>Team</label>
                    <select name="teamId" required>
                        <option value="">Select Team</option>
                        <% if (teams != null) { for (Team t : teams) { %>
                        <option value="<%= t.getTeamId() %>"><%= t.getTeamName() %> (<%= t.getShortCode() %>)</option>
                        <% } } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Role</label>
                    <select name="role" required>
                        <option value="Batsman">Batsman</option>
                        <option value="Bowler">Bowler</option>
                        <option value="All-Rounder">All-Rounder</option>
                        <option value="Wicket-Keeper">Wicket-Keeper</option>
                    </select>
                </div>
                <button type="submit" class="form-submit">Add Player</button>
            </form>
        </div>

        <!-- Schedule Match -->
        <div class="card-sec">
            <div class="fw6 text-white mb12">Schedule Match</div>
            <div class="text-muted fs12 mb12">Set up a new match simulation</div>
            <form method="post" action="<%= ctx %>/admin">
                <input type="hidden" name="action" value="scheduleMatch">
                <div class="form-group">
                    <label>Team A (Batting First)</label>
                    <select name="teamAId" required>
                        <option value="">Select Team A</option>
                        <% if (teams != null) { for (Team t : teams) { %>
                        <option value="<%= t.getTeamId() %>"><%= t.getTeamName() %></option>
                        <% } } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Team B</label>
                    <select name="teamBId" required>
                        <option value="">Select Team B</option>
                        <% if (teams != null) { for (Team t : teams) { %>
                        <option value="<%= t.getTeamId() %>"><%= t.getTeamName() %></option>
                        <% } } %>
                    </select>
                </div>
                <div class="form-group"><label>Venue</label><input type="text" name="venue" placeholder="e.g. Wankhede Stadium"></div>
                <button type="submit" class="form-submit">Schedule Match</button>
            </form>
        </div>

        <!-- Registered Teams -->
        <div class="card-sec">
            <div class="fw6 text-white mb12">Registered Teams</div>
            <div class="text-muted fs12 mb12">Manage existing teams</div>
            <table class="tbl">
                <tr><th style="text-align:left">Team</th><th style="text-align:left">Code</th><th></th></tr>
                <% if (teams != null) { for (Team t : teams) { %>
                <tr>
                    <td><%= t.getTeamName() %></td>
                    <td><%= t.getShortCode() %></td>
                    <td>
                        <form method="post" action="<%= ctx %>/admin" style="display:inline">
                            <input type="hidden" name="action" value="removeTeam">
                            <input type="hidden" name="teamId" value="<%= t.getTeamId() %>">
                            <button type="submit" class="del-btn" onclick="return confirm('Remove team?')">Remove</button>
                        </form>
                    </td>
                </tr>
                <% } } %>
            </table>
        </div>

    </div>

    <!-- Scheduled Matches -->
    <div class="sec-title mt20 mb12">Scheduled &amp; Live Matches</div>
    <div class="card overflow-x">
        <table class="tbl">
            <tr><th style="text-align:left">#</th><th style="text-align:left">Match</th><th style="text-align:left">Venue</th><th>Date</th><th>Status</th><th>Action</th></tr>
            <% if (matches != null && !matches.isEmpty()) { for (Match m : matches) { %>
            <tr>
                <td><%= m.getMatchId() %></td>
                <td class="fw6"><%= m.getTeamAName() %> vs <%= m.getTeamBName() %></td>
                <td class="text-muted"><%= m.getVenue() != null ? m.getVenue() : "—" %></td>
                <td class="text-muted"><%= m.getMatchDate() != null ? m.getMatchDate() : "—" %></td>
                <td>
                    <span class="mc-status <%= "Live".equals(m.getStatus())?"s-live":"Completed".equals(m.getStatus())?"s-completed":"s-upcoming" %>">
                        <%= m.getStatus() %>
                    </span>
                </td>
                <td>
                    <% if (!"Completed".equals(m.getStatus())) { %>
                    <button class="del-btn" onclick="location.href='<%= ctx %>/match?matchId=<%= m.getMatchId() %>'" style="color:#f5c518;border-color:rgba(245,197,24,0.3)">
                        Simulate ▶
                    </button>
                    <% } else { %>
                    <button class="del-btn" onclick="location.href='<%= ctx %>/scorecard?matchId=<%= m.getMatchId() %>'">
                        Scorecard
                    </button>
                    <% } %>
                </td>
            </tr>
            <% } } else { %>
            <tr><td colspan="6" class="text-muted" style="padding:20px;text-align:center">No matches scheduled yet.</td></tr>
            <% } %>
        </table>
    </div>
</div>
</body></html>
