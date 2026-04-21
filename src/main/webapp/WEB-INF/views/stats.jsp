<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List, java.util.Map, com.iplive.model.Player" %>
        <%@ include file="header.jsp" %>
            <% List<Player> orangeCap = (List<Player>) request.getAttribute("orangeCap");
                    List<Player> purpleCap = (List<Player>) request.getAttribute("purpleCap");
                            List<Map<String,Object>> pointsTable = (List<Map<String,Object>>)
                                    request.getAttribute("pointsTable");
                                    %>

                                    <style>
                                        .player-link {
                                            color: inherit;
                                            text-decoration: none;
                                            cursor: pointer;
                                        }

                                        .player-link:hover .cap-pname {
                                            color: #f5c518;
                                            text-decoration: underline;
                                        }

                                        .cap-row-wrap {
                                            display: grid;
                                            grid-template-columns: 22px 1fr 55px 55px 55px;
                                            gap: 4px;
                                            align-items: center;
                                            padding: 8px 0;
                                            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
                                        }

                                        .cap-row-wrap:last-child {
                                            border-bottom: none;
                                        }

                                        .medal-1 {
                                            color: #f5c518;
                                            font-size: 14px;
                                        }

                                        .medal-2 {
                                            color: #aaa;
                                            font-size: 14px;
                                        }

                                        .medal-3 {
                                            color: #cd7f32;
                                            font-size: 14px;
                                        }
                                    </style>

                                    <div class="page-wrap">

                                        <!-- ===== CAPS ===== -->
                                        <div class="sec-title mb20">IPL 2025 — Season Awards</div>
                                        <div class="caps-grid mb20">

                                            <!-- ORANGE CAP -->
                                            <div class="cap-card">
                                                <div class="cap-header">
                                                    <div class="cap-icon"
                                                        style="background:rgba(245,130,0,.2);color:#f5a000;font-weight:700;font-size:20px">
                                                        &#127280;</div>
                                                    <div>
                                                        <div class="cap-title" style="color:#f5a000">Orange Cap</div>
                                                        <div class="cap-sub">Top run scorers &mdash; IPL 2025</div>
                                                    </div>
                                                </div>

                                                <!-- Header row -->
                                                <div
                                                    style="display:grid;grid-template-columns:22px 1fr 55px 55px 55px;gap:4px;padding:4px 0;border-bottom:1px solid rgba(255,255,255,0.06)">
                                                    <span class="fs11 text-muted">#</span>
                                                    <span class="fs11 text-muted">Player</span>
                                                    <span class="fs11 text-muted" style="text-align:right">Runs</span>
                                                    <span class="fs11 text-muted" style="text-align:right">Balls</span>
                                                    <span class="fs11 text-muted" style="text-align:right">SR</span>
                                                </div>

                                                <% if (orangeCap !=null && !orangeCap.isEmpty()) { int rank=1; for
                                                    (Player p : orangeCap) { String medalClass=(rank==1) ? "medal-1" :
                                                    (rank==2) ? "medal-2" : (rank==3) ? "medal-3" : "cap-rank" ; %>
                                                    <div class="cap-row-wrap">
                                                        <span class="<%= medalClass %>">
                                                            <%= rank %>
                                                        </span>
                                                        <div>
                                                            <div class="cap-pname">
                                                                <%= p.getPlayerName() %>
                                                            </div>
                                                            <span class="pill pill-default">
                                                                <%= p.getShortCode() !=null ? p.getShortCode() :
                                                                    p.getTeamName() %>
                                                            </span>
                                                        </div>
                                                        <span class="cap-stat text-gold" style="text-align:right">
                                                            <%= p.getTotalRuns() %>
                                                        </span>
                                                        <span class="cap-sr" style="text-align:right">
                                                            <%= p.getTotalBalls() %>
                                                        </span>
                                                        <span class="cap-sr" style="text-align:right">
                                                            <%= p.getStrikeRate() %>
                                                        </span>
                                                    </div>
                                                    <% rank++; } } else { %>
                                                        <div class="text-muted fs12" style="padding:16px 0">No batting
                                                            data yet. Play some matches!</div>
                                                        <% } %>
                                            </div>

                                            <!-- PURPLE CAP -->
                                            <div class="cap-card">
                                                <div class="cap-header">
                                                    <div class="cap-icon"
                                                        style="background:rgba(83,74,183,.2);color:#a090f0;font-weight:700;font-size:20px">
                                                        &#127280;</div>
                                                    <div>
                                                        <div class="cap-title" style="color:#a090f0">Purple Cap</div>
                                                        <div class="cap-sub">Top wicket takers &mdash; IPL 2025</div>
                                                    </div>
                                                </div>

                                                <!-- Header row -->
                                                <div
                                                    style="display:grid;grid-template-columns:22px 1fr 55px 55px 55px;gap:4px;padding:4px 0;border-bottom:1px solid rgba(255,255,255,0.06)">
                                                    <span class="fs11 text-muted">#</span>
                                                    <span class="fs11 text-muted">Player</span>
                                                    <span class="fs11 text-muted" style="text-align:right">Wkts</span>
                                                    <span class="fs11 text-muted" style="text-align:right">Overs</span>
                                                    <span class="fs11 text-muted" style="text-align:right">Eco</span>
                                                </div>

                                                <% if (purpleCap !=null && !purpleCap.isEmpty()) { int rank=1; for
                                                    (Player p : purpleCap) { String medalClass=(rank==1) ? "medal-1" :
                                                    (rank==2) ? "medal-2" : (rank==3) ? "medal-3" : "cap-rank" ; %>
                                                    <div class="cap-row-wrap">
                                                        <span class="<%= medalClass %>">
                                                            <%= rank %>
                                                        </span>
                                                        <div>
                                                            <div class="cap-pname">
                                                                <%= p.getPlayerName() %>
                                                            </div>
                                                            <span class="pill pill-default">
                                                                <%= p.getShortCode() !=null ? p.getShortCode() :
                                                                    p.getTeamName() %>
                                                            </span>
                                                        </div>
                                                        <span class="cap-stat" style="text-align:right;color:#a090f0">
                                                            <%= p.getTotalWickets() %>
                                                        </span>
                                                        <span class="cap-sr" style="text-align:right">
                                                            <%= p.getTotalOvers() %>
                                                        </span>
                                                        <span class="cap-sr" style="text-align:right">
                                                            <%= p.getEconomy() %>
                                                        </span>
                                                    </div>
                                                    <% rank++; } } else { %>
                                                        <div class="text-muted fs12" style="padding:16px 0">No bowling
                                                            data yet. Play some matches!</div>
                                                        <% } %>
                                            </div>

                                        </div><!-- /caps-grid -->

                                        <!-- ===== POINTS TABLE ===== -->
                                        <div class="sec-title mb12">IPL 2025 &mdash; Points Table</div>
                                        <div class="card overflow-x">
                                            <table class="tbl">
                                                <tr>
                                                    <th>#</th>
                                                    <th style="text-align:left">Team</th>
                                                    <th>M</th>
                                                    <th>W</th>
                                                    <th>L</th>
                                                    <th>NR</th>
                                                    <th>Pts</th>
                                                    <th>NRR</th>
                                                    <th>Form</th>
                                                </tr>
                                                <% if (pointsTable !=null && !pointsTable.isEmpty()) { int rank=1; for
                                                    (Map<String,Object> row : pointsTable) {
                                                    int wins = ((Integer) row.get("wins")).intValue();
                                                    int losses = ((Integer) row.get("losses")).intValue();
                                                    String nrr = (String) row.get("nrr");
                                                    boolean isPos = nrr != null && nrr.startsWith("+");
                                                    String rankClass = (rank <= 4) ? "rbadge gold" : "rbadge" ; String
                                                        nrrClass=isPos ? "nrr-pos" : "nrr-neg" ; %>
                                                        <tr>
                                                            <td><span class="<%= rankClass %>">
                                                                    <%= rank %>
                                                                </span></td>
                                                            <td class="fw6">
                                                                <%= row.get("teamName") %>
                                                            </td>
                                                            <td>
                                                                <%= row.get("played") %>
                                                            </td>
                                                            <td>
                                                                <%= wins %>
                                                            </td>
                                                            <td>
                                                                <%= losses %>
                                                            </td>
                                                            <td>
                                                                <%= row.get("nr") %>
                                                            </td>
                                                            <td class="text-gold fw6">
                                                                <%= row.get("points") %>
                                                            </td>
                                                            <td class="<%= nrrClass %>">
                                                                <%= nrr %>
                                                            </td>
                                                            <td>
                                                                <% for (int i=0; i < wins && i < 3; i++) { %>
                                                                    <span style="color:#7ec850;font-size:11px">W </span>
                                                                    <% } for (int i=0; i < losses && i < 3; i++) { %>
                                                                        <span style="color:#f08080;font-size:11px">L
                                                                        </span>
                                                                        <% } %>
                                                            </td>
                                                        </tr>
                                                        <% rank++; } } else { %>
                                                            <tr>
                                                                <td colspan="9"
                                                                    style="text-align:center;color:#666;padding:20px">No
                                                                    completed matches yet.</td>
                                                            </tr>
                                                            <% } %>
                                            </table>
                                            <div class="text-muted fs11 mt12">Top 4 teams qualify for playoffs
                                                &nbsp;&middot;&nbsp; W = Win &nbsp;&middot;&nbsp; L = Loss
                                                &nbsp;&middot;&nbsp; NR = No Result</div>
                                        </div>

                                    </div><!-- /page-wrap -->
                                    </body>

                                    </html>