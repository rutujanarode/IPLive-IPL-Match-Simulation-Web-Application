<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.iplive.model.Match" %>
<%@ include file="header.jsp" %>
<%
    List<Match> history = (List<Match>) request.getAttribute("history");
    
%>
<div class="page-wrap">
    <div class="sec-title mb20">Match History</div>
    <% if (history == null || history.isEmpty()) { %>
    <div class="card" style="text-align:center;padding:40px;color:#666">
        No completed matches yet. <a href="<%= ctx %>/match" style="color:#f5c518">Start a simulation!</a>
    </div>
    <% } else { %>
    <div class="card">
        <% for (Match m : history) { %>
        <div class="hist-item">
            <div>
                <div class="hist-teams"><%= m.getTeamAName() %> vs <%= m.getTeamBName() %></div>
                <div class="hist-result">
                    <%= m.getVenue() != null ? m.getVenue() : "" %>
                    <% if (m.getMatchDate() != null) { %>&nbsp;·&nbsp;<%= m.getMatchDate() %><% } %>
                </div>
                <div class="hist-result mt12">
                    <% if (m.getBalls1() > 0) { %>
                    <%= m.getTeamACode() %>: <%= m.getRuns1() %>/<%= m.getWickets1() %>
                    (<%= m.getOverString(m.getBalls1()) %> ov)
                    <% } %>
                    <% if (m.getBalls2() > 0) { %>
                    &nbsp;|&nbsp;
                    <%= m.getTeamBCode() %>: <%= m.getRuns2() %>/<%= m.getWickets2() %>
                    (<%= m.getOverString(m.getBalls2()) %> ov)
                    <% } %>
                </div>
            </div>
            <div style="text-align:right">
                <% if (m.getWinnerName() != null) { %>
                <span class="hist-winner"><%= m.getWinnerName() %> won</span>
                <% } %>
                <div class="hist-link" onclick="location.href='<%= ctx %>/scorecard?matchId=<%= m.getMatchId() %>'">
                    View scorecard →
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>
</body></html>
