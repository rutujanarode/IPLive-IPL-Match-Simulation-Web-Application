<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.iplive.model.Match" %>
<%@ include file="header.jsp" %>
<%
    List<Match> upcoming = (List<Match>) request.getAttribute("upcoming");
    
%>
<div class="page-wrap">
    <div class="sec-title">Select a Match to Simulate</div>
    <% if (upcoming == null || upcoming.isEmpty()) { %>
    <div class="card" style="text-align:center;padding:40px;color:#666">
        No upcoming or live matches. <a href="<%= ctx %>/admin" style="color:#f5c518">Schedule one in Admin panel.</a>
    </div>
    <% } else { %>
    <div class="match-cards">
        <% for (Match m : upcoming) { %>
        <div class="match-card" onclick="location.href='<%= ctx %>/match?matchId=<%= m.getMatchId() %>'">
            <div class="mc-header">
                <span class="mc-status <%= "Live".equals(m.getStatus()) ? "s-live" : "s-upcoming" %>"><%= m.getStatus() %></span>
                <span class="mc-venue"><%= m.getVenue() != null ? m.getVenue() : "" %></span>
            </div>
            <div class="teams-row">
                <div class="team-block">
                    <div class="team-badge" style="background:rgba(255,255,255,0.06);color:#ccc"><%= m.getTeamACode() %></div>
                    <div class="team-name"><%= m.getTeamAName() %></div>
                </div>
                <div class="vs-text">vs</div>
                <div class="team-block">
                    <div class="team-badge" style="background:rgba(255,255,255,0.06);color:#ccc"><%= m.getTeamBCode() %></div>
                    <div class="team-name"><%= m.getTeamBName() %></div>
                </div>
            </div>
            <div class="mc-footer">Click to start ball-by-ball simulation</div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>
</body></html>
