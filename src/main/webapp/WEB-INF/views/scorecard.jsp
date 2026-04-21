<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ include file="header.jsp" %>
<%
    Map<String,Object> info   = (Map<String,Object>) request.getAttribute("matchInfo");
    List<Map<String,Object>> bat1 = (List<Map<String,Object>>) request.getAttribute("batting1");
    List<Map<String,Object>> bow1 = (List<Map<String,Object>>) request.getAttribute("bowling1");
    List<Map<String,Object>> bat2 = (List<Map<String,Object>>) request.getAttribute("batting2");
    List<Map<String,Object>> bow2 = (List<Map<String,Object>>) request.getAttribute("bowling2");
    String ctxPath = request.getContextPath();
    Integer matchIdObj = (Integer) request.getAttribute("matchId");
    int matchId = matchIdObj != null ? matchIdObj : 0;
    if (info == null) { response.sendRedirect(ctxPath + "/history"); return; }

    int balls1 = info.get("b1") != null ? ((Number) info.get("b1")).intValue() : 0;
    int balls2 = info.get("b2") != null ? ((Number) info.get("b2")).intValue() : 0;
    String over1 = balls1 > 0 ? (balls1 / 6) + "." + (balls1 % 6) : "0.0";
    String over2 = balls2 > 0 ? (balls2 / 6) + "." + (balls2 % 6) : "0.0";
%>
<div class="match-header">
    <button class="back-btn" onclick="location.href='<%= ctxPath %>/history'">← Back</button>
    <div>
        <div class="mh-title"><%= info.get("teamA") %> vs <%= info.get("teamB") %></div>
        <div class="mh-sub"><%= info.get("venue") %> &nbsp;·&nbsp; <%= info.get("date") %></div>
    </div>
    <% if (info.get("winner") != null) { %>
    <span style="background:rgba(59,109,17,.2);color:#7ec850;font-size:11px;padding:4px 10px;border-radius:10px;margin-left:auto">
        <%= info.get("winner") %> won
    </span>
    <% } %>
    <% if (info.get("manOfTheMatch") != null) { %>
    <div style="margin-top:10px;color:#fff;font-size:13px;font-weight:600">
        Man of the Match: <span style="color:#f5c518"><%= info.get("manOfTheMatch") %></span>
    </div>
    <% } %>
</div>

<div class="page-wrap">

    <!-- Innings 1 -->
    <div class="scorecard-innings">
        <div class="innings-title">
            <%= info.get("teamA") %> Innings — <%= info.get("r1") %>/<%= info.get("w1") %> (<%= over1 %> Overs)
        </div>
        <div class="card overflow-x mb12">
            <table class="tbl" style="min-width:480px">
                <tr><th style="text-align:left">Batter</th><th style="text-align:left">Dismissal</th><th>R</th><th>B</th><th>4s</th><th>6s</th><th>SR</th></tr>
                <% if (bat1 != null && !bat1.isEmpty()) { for (Map<String,Object> r : bat1) { %>
                <tr>
                    <td class="fw6"><%= r.get("name") %></td>
                    <td class="text-muted fs11"><%= r.get("dismissal") %></td>
                    <td class="text-gold"><%= r.get("runs") %></td>
                    <td><%= r.get("balls") %></td>
                    <td><%= r.get("fours") %></td>
                    <td><%= r.get("sixes") %></td>
                    <td><%= r.get("sr") %></td>
                </tr>
                <% } } else { %>
                <tr><td colspan="7" class="text-muted" style="padding:12px">No batting data recorded.</td></tr>
                <% } %>
                <tr style="border-top:1px solid rgba(255,255,255,0.1)">
                    <td class="fw6" colspan="2">Total</td>
                    <td class="fw6 text-gold" colspan="2"><%= info.get("r1") %>/<%= info.get("w1") %></td>
                    <td colspan="3" class="text-muted fs11">(<%= over1 %> Overs)</td>
                </tr>
            </table>
        </div>
        <div class="card overflow-x">
            <div class="panel-title" style="margin-bottom:10px"><%= info.get("teamB") %> Bowling</div>
            <table class="tbl" style="min-width:380px">
                <tr><th style="text-align:left">Bowler</th><th>O</th><th>M</th><th>R</th><th>W</th><th>Eco</th></tr>
                <% if (bow1 != null && !bow1.isEmpty()) { for (Map<String,Object> r : bow1) { %>
                <tr>
                    <td class="fw6"><%= r.get("name") %></td>
                    <td><%= r.get("overs") %></td>
                    <td><%= r.get("maidens") %></td>
                    <td><%= r.get("runs") %></td>
                    <td class="text-gold"><%= r.get("wickets") %></td>
                    <td><%= r.get("eco") %></td>
                </tr>
                <% } } else { %>
                <tr><td colspan="6" class="text-muted" style="padding:12px">No bowling data recorded.</td></tr>
                <% } %>
            </table>
        </div>
    </div>

    <!-- Innings 2 -->
    <% if (bat2 != null && !bat2.isEmpty()) { %>
    <div class="scorecard-innings">
        <div class="innings-title">
            <%= info.get("teamB") %> Innings — <%= info.get("r2") %>/<%= info.get("w2") %> (<%= over2 %> Overs)
        </div>
        <div class="card overflow-x mb12">
            <table class="tbl" style="min-width:480px">
                <tr><th style="text-align:left">Batter</th><th style="text-align:left">Dismissal</th><th>R</th><th>B</th><th>4s</th><th>6s</th><th>SR</th></tr>
                <% for (Map<String,Object> r : bat2) { %>
                <tr>
                    <td class="fw6"><%= r.get("name") %></td>
                    <td class="text-muted fs11"><%= r.get("dismissal") %></td>
                    <td class="text-gold"><%= r.get("runs") %></td>
                    <td><%= r.get("balls") %></td>
                    <td><%= r.get("fours") %></td>
                    <td><%= r.get("sixes") %></td>
                    <td><%= r.get("sr") %></td>
                </tr>
                <% } %>
                <tr style="border-top:1px solid rgba(255,255,255,0.1)">
                    <td class="fw6" colspan="2">Total</td>
                    <td class="fw6 text-gold" colspan="2"><%= info.get("r2") %>/<%= info.get("w2") %></td>
                    <td colspan="3" class="text-muted fs11">(<%= over2 %> Overs)</td>
                </tr>
            </table>
        </div>
        <% if (bow2 != null && !bow2.isEmpty()) { %>
        <div class="card overflow-x">
            <div class="panel-title" style="margin-bottom:10px"><%= info.get("teamA") %> Bowling</div>
            <table class="tbl" style="min-width:380px">
                <tr><th style="text-align:left">Bowler</th><th>O</th><th>M</th><th>R</th><th>W</th><th>Eco</th></tr>
                <% for (Map<String,Object> r : bow2) { %>
                <tr>
                    <td class="fw6"><%= r.get("name") %></td>
                    <td><%= r.get("overs") %></td>
                    <td><%= r.get("maidens") %></td>
                    <td><%= r.get("runs") %></td>
                    <td class="text-gold"><%= r.get("wickets") %></td>
                    <td><%= r.get("eco") %></td>
                </tr>
                <% } %>
            </table>
        </div>
        <% } %>
    </div>
    <% } %>

</div>
</body></html>
