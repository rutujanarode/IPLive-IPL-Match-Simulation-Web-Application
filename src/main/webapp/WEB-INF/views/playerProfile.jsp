<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.*, com.iplive.model.Player" %>
        <%@ include file="header.jsp" %>
            <% Player player=(Player) request.getAttribute("player"); Map<String,Object> batting = (Map<String,Object>)
                    request.getAttribute("battingStats");
                    Map<String,Object> bowling = (Map<String,Object>) request.getAttribute("bowlingStats");
                            List<Map<String,Object>> recent = (List<Map<String,Object>>)
                                    request.getAttribute("recentMatches");
                                    String bio = (String) request.getAttribute("bio");
                                    String nationality = (String) request.getAttribute("nationality");
                                    String dob = (String) request.getAttribute("dob");
                                    String battingStyle = (String) request.getAttribute("battingStyle");
                                    String bowlingStyle = (String) request.getAttribute("bowlingStyle");
                                    String colorHex = (String) request.getAttribute("colorHex");
                                    if (player == null) { response.sendRedirect(ctx + "/stats"); return; }
                                    if (colorHex == null) colorHex = "#1a1a2e";

                                    String roleClass = "pc-bat";
                                    if ("Bowler".equals(player.getRole())) roleClass = "pc-bowl";
                                    if ("All-Rounder".equals(player.getRole())) roleClass = "pc-ar";
                                    if ("Wicket-Keeper".equals(player.getRole())) roleClass = "pc-wk";

                                    String profileImgSrc = player.getImageUrl();
                                    String initials = "";
                                    if (player.getPlayerName() != null && !player.getPlayerName().trim().isEmpty()) {
                                        String[] parts = player.getPlayerName().trim().split("\\s+");
                                        if (parts.length > 0) initials += parts[0].substring(0, 1).toUpperCase();
                                        if (parts.length > 1) initials += parts[parts.length - 1].substring(0, 1).toUpperCase();
                                    }
                                    if (profileImgSrc != null && !profileImgSrc.trim().isEmpty()) {
                                        if (!(profileImgSrc.startsWith("http") || profileImgSrc.startsWith("/"))) {
                                            profileImgSrc = ctx + "/" + profileImgSrc;
                                        }
                                    }
                                    %>
                                    <style>
                                        .profile-hero {
                                            background: linear-gradient(135deg, #0d0d1a 0%, <%=colorHex %>22 100%);
                                            border-bottom: 1px solid rgba(255, 255, 255, 0.07);
                                            padding: 36px 24px 28px;
                                        }

                                        .stat-pill {
                                            background: rgba(255, 255, 255, 0.06);
                                            border: 1px solid rgba(255, 255, 255, 0.08);
                                            border-radius: 10px;
                                            padding: 14px 18px;
                                            text-align: center;
                                            flex: 1;
                                            min-width: 100px;
                                        }

                                        .stat-pill .sp-val {
                                            font-size: 22px;
                                            font-weight: 700;
                                            color: #f5c518;
                                            margin-bottom: 4px;
                                        }

                                        .stat-pill .sp-lbl {
                                            font-size: 10px;
                                            color: #666;
                                            text-transform: uppercase;
                                            letter-spacing: .5px;
                                        }

                                        .stat-grid {
                                            display: flex;
                                            gap: 10px;
                                            flex-wrap: wrap;
                                            margin-bottom: 16px;
                                        }

                                        .info-row {
                                            display: flex;
                                            gap: 8px;
                                            margin-bottom: 6px;
                                            align-items: center;
                                        }

                                        .info-label {
                                            font-size: 11px;
                                            color: #666;
                                            min-width: 110px;
                                            text-transform: uppercase;
                                            letter-spacing: .3px;
                                        }

                                        .info-value {
                                            font-size: 13px;
                                            color: #ccc;
                                        }

                                        .bio-text {
                                            font-size: 13px;
                                            color: #aaa;
                                            line-height: 1.8;
                                            padding: 14px;
                                            background: rgba(255, 255, 255, 0.03);
                                            border-radius: 8px;
                                            border-left: 3px solid <%=colorHex %>;
                                            margin-top: 12px;
                                        }

                                        .section-divider {
                                            border: none;
                                            border-top: 1px solid rgba(255, 255, 255, 0.06);
                                            margin: 20px 0;
                                        }
                                    </style>

                                    <!-- Profile Hero -->
                                    <div class="profile-hero">
                                        <div
                                            style="max-width:1100px;margin:0 auto;display:flex;align-items:center;gap:20px;flex-wrap:wrap">
                                            <!-- Avatar -->
                                            <div
                                                style="width:80px;height:80px;border-radius:50%;background:<%= colorHex %>33;border:2px solid <%= colorHex %>66;display:flex;align-items:center;justify-content:center;font-size:26px;font-weight:700;color:#fff;flex-shrink:0;overflow:hidden">
                                                <% if (profileImgSrc != null && !profileImgSrc.trim().isEmpty()) { %>
                                                    <img src="<%= profileImgSrc %>" alt="<%= player.getPlayerName() %>" style="width:100%;height:100%;object-fit:cover;display:block">
                                                <% } else { %>
                                                    <div class="player-avatar-empty" style="width:100%;height:100%;font-size:30px;line-height:80px;">
                                                        <%= initials %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div style="flex:1;min-width:200px">
                                                <div
                                                    style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:6px">
                                                    <h1 style="font-size:26px;font-weight:700;color:#fff">
                                                        <%= player.getPlayerName() %>
                                                    </h1>
                                                    <span class="pc-role <%= roleClass %>">
                                                        <%= player.getRole() %>
                                                    </span>
                                                </div>
                                                <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
                                                    <span style="font-size:13px;color:#aaa">
                                                        <%= player.getTeamName() %>
                                                    </span>
                                                    <span style="color:#444">·</span>
                                                    <span style="font-size:12px;color:#666">
                                                        <%= nationality !=null ? nationality : "Indian" %>
                                                    </span>
                                                    <% if (dob !=null && !dob.isEmpty()) { %>
                                                        <span style="color:#444">·</span>
                                                        <span style="font-size:12px;color:#666">Born: <%= dob %></span>
                                                        <% } %>
                                                </div>
                                            </div>
                                            <button class="btn-outline" onclick="history.back()"
                                                style="padding:8px 16px;font-size:12px">← Back</button>
                                        </div>
                                    </div>

                                    <div class="page-wrap">

                                        <div class="g2">
                                            <!-- Left Column -->
                                            <div>
                                                <!-- Bio -->
                                                <% if (bio !=null && !bio.isEmpty()) { %>
                                                    <div class="card mb20">
                                                        <div class="panel-title mb12">About</div>
                                                        <div class="bio-text">
                                                            <%= bio %>
                                                        </div>
                                                    </div>
                                                    <% } %>

                                                        <!-- Personal Info -->
                                                        <div class="card mb20">
                                                            <div class="panel-title mb12">Player Info</div>
                                                            <div class="info-row"><span class="info-label">Full
                                                                    Name</span><span class="info-value fw6">
                                                                    <%= player.getPlayerName() %>
                                                                </span></div>
                                                            <div class="info-row"><span
                                                                    class="info-label">Team</span><span
                                                                    class="info-value">
                                                                    <%= player.getTeamName() %> (<%=
                                                                            player.getShortCode() %>)
                                                                </span></div>
                                                            <div class="info-row"><span
                                                                    class="info-label">Nationality</span><span
                                                                    class="info-value">
                                                                    <%= nationality !=null ? nationality : "Indian" %>
                                                                </span></div>
                                                            <% if (dob !=null && !dob.isEmpty()) { %>
                                                                <div class="info-row"><span class="info-label">Date of
                                                                        Birth</span><span class="info-value">
                                                                        <%= dob %>
                                                                    </span></div>
                                                                <% } %>
                                                                    <div class="info-row"><span
                                                                            class="info-label">Role</span><span
                                                                            class="info-value">
                                                                            <%= player.getRole() %>
                                                                        </span></div>
                                                                    <% if (battingStyle !=null &&
                                                                        !battingStyle.isEmpty()) { %>
                                                                        <div class="info-row"><span
                                                                                class="info-label">Batting
                                                                                Style</span><span class="info-value">
                                                                                <%= battingStyle %>
                                                                            </span></div>
                                                                        <% } %>
                                                                            <% if (bowlingStyle !=null &&
                                                                                !bowlingStyle.isEmpty() &&
                                                                                !"None".equals(bowlingStyle)) { %>
                                                                                <div class="info-row"><span
                                                                                        class="info-label">Bowling
                                                                                        Style</span><span
                                                                                        class="info-value">
                                                                                        <%= bowlingStyle %>
                                                                                    </span></div>
                                                                                <% } %>
                                                        </div>

                                                        <!-- Recent Performances -->
                                                        <% if (recent !=null && !recent.isEmpty()) { %>
                                                            <div class="card">
                                                                <div class="panel-title mb12">Recent Batting
                                                                    Performances</div>
                                                                <table class="tbl">
                                                                    <tr>
                                                                        <th style="text-align:left">Match</th>
                                                                        <th>Runs</th>
                                                                        <th>Balls</th>
                                                                        <th>4s</th>
                                                                        <th>6s</th>
                                                                        <th>SR</th>
                                                                        <th>Result</th>
                                                                    </tr>
                                                                    <% for (Map<String,Object> r : recent) { %>
                                                                        <tr>
                                                                            <td class="text-muted fs12">
                                                                                <%= r.get("opponent") %>
                                                                            </td>
                                                                            <td class="text-gold fw6">
                                                                                <%= r.get("runs") %>
                                                                            </td>
                                                                            <td>
                                                                                <%= r.get("balls") %>
                                                                            </td>
                                                                            <td>
                                                                                <%= r.get("fours") %>
                                                                            </td>
                                                                            <td>
                                                                                <%= r.get("sixes") %>
                                                                            </td>
                                                                            <td>
                                                                                <%= r.get("sr") %>
                                                                            </td>
                                                                            <td><span
                                                                                    style="font-size:10px;padding:2px 7px;border-radius:8px;background:<%= (Boolean) r.get("isOut") ? "rgba(226,75,74,.15)" : "rgba(59,109,17,.15)" %>;color:<%= (Boolean) r.get("isOut") ? "#f08080" : "#7ec850" %>"><%= (Boolean) r.get("isOut") ? "Out" : "Not Out" %></span></td>
                                                                        </tr>
                                                                        <% } %>
                                                                </table>
                                                            </div>
                                                            <% } %>
                                            </div>

                                            <!-- Right Column: Stats -->
                                            <div>
                                                <!-- Batting Stats -->
                                                <% if (!batting.isEmpty()) { %>
                                                    <div class="card mb20">
                                                        <div class="panel-title mb12" style="color:#f5a000">IPL 2025 —
                                                            Batting Stats</div>
                                                        <div class="stat-grid">
                                                            <div class="stat-pill">
                                                                <div class="sp-val">
                                                                    <%= batting.get("runs") %>
                                                                </div>
                                                                <div class="sp-lbl">Runs</div>
                                                            </div>
                                                            <div class="stat-pill">
                                                                <div class="sp-val">
                                                                    <%= batting.get("average") %>
                                                                </div>
                                                                <div class="sp-lbl">Average</div>
                                                            </div>
                                                            <div class="stat-pill">
                                                                <div class="sp-val">
                                                                    <%= batting.get("strikeRate") %>
                                                                </div>
                                                                <div class="sp-lbl">Strike Rate</div>
                                                            </div>
                                                        </div>
                                                        <div class="stat-grid">
                                                            <div class="stat-pill">
                                                                <div class="sp-val" style="color:#ccc">
                                                                    <%= batting.get("matches") %>
                                                                </div>
                                                                <div class="sp-lbl">Matches</div>
                                                            </div>
                                                            <div class="stat-pill">
                                                                <div class="sp-val" style="color:#ccc">
                                                                    <%= batting.get("highestScore") %>
                                                                </div>
                                                                <div class="sp-lbl">Highest</div>
                                                            </div>
                                                            <div class="stat-pill">
                                                                <div class="sp-val" style="color:#ccc">
                                                                    <%= batting.get("fifties") %>
                                                                </div>
                                                                <div class="sp-lbl">50s</div>
                                                            </div>
                                                            <div class="stat-pill">
                                                                <div class="sp-val" style="color:#f5c518">
                                                                    <%= batting.get("hundreds") %>
                                                                </div>
                                                                <div class="sp-lbl">100s</div>
                                                            </div>
                                                        </div>
                                                        <div class="stat-grid">
                                                            <div class="stat-pill">
                                                                <div class="sp-val" style="color:#7ec850">
                                                                    <%= batting.get("fours") %>
                                                                </div>
                                                                <div class="sp-lbl">Fours</div>
                                                            </div>
                                                            <div class="stat-pill">
                                                                <div class="sp-val" style="color:#5ab4ff">
                                                                    <%= batting.get("sixes") %>
                                                                </div>
                                                                <div class="sp-lbl">Sixes</div>
                                                            </div>
                                                            <div class="stat-pill">
                                                                <div class="sp-val" style="color:#ccc">
                                                                    <%= batting.get("notOuts") %>
                                                                </div>
                                                                <div class="sp-lbl">Not Outs</div>
                                                            </div>
                                                            <div class="stat-pill">
                                                                <div class="sp-val" style="color:#ccc">
                                                                    <%= batting.get("balls") %>
                                                                </div>
                                                                <div class="sp-lbl">Balls</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <% } else { %>
                                                        <div class="card mb20"
                                                            style="text-align:center;padding:28px;color:#555">
                                                            No batting stats recorded this season yet.
                                                        </div>
                                                        <% } %>

                                                            <!-- Bowling Stats -->
                                                            <% if (!bowling.isEmpty()) { %>
                                                                <div class="card">
                                                                    <div class="panel-title mb12" style="color:#a090f0">
                                                                        IPL 2025 — Bowling Stats</div>
                                                                    <div class="stat-grid">
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val" style="color:#a090f0">
                                                                                <%= bowling.get("wickets") %>
                                                                            </div>
                                                                            <div class="sp-lbl">Wickets</div>
                                                                        </div>
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val">
                                                                                <%= bowling.get("economy") %>
                                                                            </div>
                                                                            <div class="sp-lbl">Economy</div>
                                                                        </div>
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val">
                                                                                <%= bowling.get("average") %>
                                                                            </div>
                                                                            <div class="sp-lbl">Average</div>
                                                                        </div>
                                                                    </div>
                                                                    <div class="stat-grid">
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val" style="color:#ccc">
                                                                                <%= bowling.get("matches") %>
                                                                            </div>
                                                                            <div class="sp-lbl">Matches</div>
                                                                        </div>
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val" style="color:#ccc">
                                                                                <%= bowling.get("overs") %>
                                                                            </div>
                                                                            <div class="sp-lbl">Overs</div>
                                                                        </div>
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val" style="color:#ccc">
                                                                                <%= bowling.get("runsGiven") %>
                                                                            </div>
                                                                            <div class="sp-lbl">Runs</div>
                                                                        </div>
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val" style="color:#f5c518">
                                                                                <%= bowling.get("bestBowling") %>
                                                                            </div>
                                                                            <div class="sp-lbl">Best</div>
                                                                        </div>
                                                                    </div>
                                                                    <div class="stat-grid">
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val" style="color:#ccc">
                                                                                <%= bowling.get("maidens") %>
                                                                            </div>
                                                                            <div class="sp-lbl">Maidens</div>
                                                                        </div>
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val" style="color:#ccc">
                                                                                <%= bowling.get("fourWickets") %>
                                                                            </div>
                                                                            <div class="sp-lbl">4W Hauls</div>
                                                                        </div>
                                                                        <div class="stat-pill">
                                                                            <div class="sp-val" style="color:#ccc">
                                                                                <%= bowling.get("fiveWickets") %>
                                                                            </div>
                                                                            <div class="sp-lbl">5W Hauls</div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <% } else if ("Bowler".equals(player.getRole())
                                                                    || "All-Rounder" .equals(player.getRole())) { %>
                                                                    <div class="card"
                                                                        style="text-align:center;padding:28px;color:#555">
                                                                        No bowling stats recorded this season yet.
                                                                    </div>
                                                                    <% } %>
                                            </div>
                                        </div>
                                    </div>
                                    </body>

                                    </html>