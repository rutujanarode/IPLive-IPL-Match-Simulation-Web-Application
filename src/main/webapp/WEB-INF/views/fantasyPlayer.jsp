<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List, java.util.Map" %>
        <%@ include file="header.jsp" %>
            <% int playerId=(Integer) request.getAttribute("playerId"); String playerName=(String)
                request.getAttribute("playerName"); String teamName=(String) request.getAttribute("teamName"); String
                teamCode=(String) request.getAttribute("teamCode"); int rank=(Integer) request.getAttribute("rank"); int
                totalPts=(Integer) request.getAttribute("totalPts"); double avgPts=(Double)
                request.getAttribute("avgPts"); int matches=(Integer) request.getAttribute("matches");
                List<Map<String,Object>> matchPts = (List<Map<String,Object>>) request.getAttribute("matchPts");
                    List<Map<String,Object>> badges = (List<Map<String,Object>>) request.getAttribute("badges");
                            %>

                            <style>
                                .fp-hero {
                                    background: linear-gradient(135deg, #1a0533, #12122a 70%);
                                    border-bottom: 1px solid rgba(180, 100, 255, 0.2);
                                    padding: 36px 24px;
                                    text-align: center;
                                }

                                .fp-name {
                                    font-size: 26px;
                                    font-weight: 700;
                                    color: #fff;
                                }

                                .fp-team {
                                    font-size: 13px;
                                    color: #888;
                                    margin-top: 4px;
                                }

                                .fp-stats-bar {
                                    display: grid;
                                    grid-template-columns: repeat(4, 1fr);
                                    gap: 12px;
                                    margin: 24px 0 0;
                                    max-width: 600px;
                                    margin-left: auto;
                                    margin-right: auto;
                                }

                                .fp-stat {
                                    background: rgba(180, 100, 255, 0.1);
                                    border: 1px solid rgba(180, 100, 255, 0.2);
                                    border-radius: 10px;
                                    padding: 12px;
                                }

                                .fp-stat-val {
                                    font-size: 22px;
                                    font-weight: 700;
                                    color: #b464ff;
                                }

                                .fp-stat-lbl {
                                    font-size: 10px;
                                    color: #777;
                                    margin-top: 3px;
                                    text-transform: uppercase;
                                    letter-spacing: .6px;
                                }

                                .badge-grid {
                                    display: flex;
                                    flex-wrap: wrap;
                                    gap: 10px;
                                }

                                .badge-chip {
                                    display: flex;
                                    align-items: center;
                                    gap: 8px;
                                    background: #12122a;
                                    border: 1px solid rgba(180, 100, 255, 0.25);
                                    border-radius: 20px;
                                    padding: 6px 14px;
                                }

                                .badge-chip .bi {
                                    font-size: 18px;
                                }

                                .badge-chip .bt {
                                    font-size: 12px;
                                    font-weight: 600;
                                    color: #e0e0e0;
                                }

                                /* Match pts chart */
                                .mp-bar-wrap {
                                    margin-top: 4px;
                                }

                                .mp-bar {
                                    height: 6px;
                                    border-radius: 3px;
                                    background: linear-gradient(90deg, #b464ff, #4daaff);
                                    transition: width .4s;
                                }

                                .mp-row {
                                    display: grid;
                                    grid-template-columns: 100px 1fr 60px;
                                    gap: 12px;
                                    align-items: center;
                                    padding: 8px 0;
                                    border-bottom: 1px solid rgba(255, 255, 255, 0.04);
                                    font-size: 12px;
                                }

                                .mp-row:last-child {
                                    border-bottom: none;
                                }

                                .pts-breakdown {
                                    display: flex;
                                    flex-wrap: wrap;
                                    gap: 6px;
                                    margin-top: 6px;
                                }

                                .pb-chip {
                                    font-size: 10px;
                                    padding: 2px 8px;
                                    border-radius: 8px;
                                    background: rgba(255, 255, 255, 0.06);
                                    color: #aaa;
                                }

                                .pb-chip.pos {
                                    background: rgba(77, 255, 145, 0.1);
                                    color: #4dff91;
                                }

                                .pb-chip.neg {
                                    background: rgba(255, 107, 107, 0.1);
                                    color: #ff6b6b;
                                }
                            </style>

                            <div class="fp-hero">
                                <div style="font-size:48px;margin-bottom:8px">🎮</div>
                                <div class="fp-name">
                                    <%= playerName %>
                                </div>
                                <div class="fp-team">
                                    <%= teamCode %> &bull; <%= teamName %>
                                </div>
                                <div class="fp-stats-bar">
                                    <div class="fp-stat">
                                        <div class="fp-stat-val">
                                            <%= rank> 0 ? "#"+rank : "—" %>
                                        </div>
                                        <div class="fp-stat-lbl">Season Rank</div>
                                    </div>
                                    <div class="fp-stat">
                                        <div class="fp-stat-val">
                                            <%= totalPts %>
                                        </div>
                                        <div class="fp-stat-lbl">Total Pts</div>
                                    </div>
                                    <div class="fp-stat">
                                        <div class="fp-stat-val">
                                            <%= avgPts %>
                                        </div>
                                        <div class="fp-stat-lbl">Avg / Match</div>
                                    </div>
                                    <div class="fp-stat">
                                        <div class="fp-stat-val">
                                            <%= badges !=null ? badges.size() : 0 %>
                                        </div>
                                        <div class="fp-stat-lbl">Badges</div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-wrap">

                                <!-- Back link -->
                                <a href="<%= ctx %>/fantasy"
                                    style="color:#b464ff;font-size:13px;display:inline-flex;align-items:center;gap:4px;margin-bottom:20px">
                                    ← Back to Leaderboard
                                </a>

                                <!-- Badges -->
                                <div class="sec-title">Achievements Unlocked</div>
                                <div class="card" style="padding:20px;margin-bottom:22px">
                                    <% if (badges !=null && !badges.isEmpty()) { %>
                                        <div class="badge-grid">
                                            <% for (Map<String,Object> b : badges) { %>
                                                <div class="badge-chip" title="<%= b.get(" desc") %>">
                                                    <span class="bi">
                                                        <%= b.get("icon") %>
                                                    </span>
                                                    <span class="bt">
                                                        <%= b.get("title") %>
                                                    </span>
                                                </div>
                                                <% } %>
                                        </div>
                                        <% } else { %>
                                            <div style="color:#555;font-size:13px;text-align:center;padding:20px">No
                                                badges earned yet.</div>
                                            <% } %>
                                </div>

                                <!-- Match-by-match points -->
                                <div class="sec-title">Match Fantasy Scorecard</div>
                                <div class="card" style="padding:16px 20px">
                                    <% int maxPts=1; if (matchPts !=null) { for (Map<String,Object> mp : matchPts) {
                                        int tp = (Integer) mp.get("totalPts");
                                        if (tp > maxPts) maxPts = tp;
                                        }
                                        }
                                        %>
                                        <% if (matchPts !=null && !matchPts.isEmpty()) { for (Map<String,Object> mp :
                                            matchPts) {
                                            int tp = (Integer) mp.get("totalPts");
                                            int rp = (Integer) mp.get("runPts");
                                            int bp = (Integer) mp.get("bndPts");
                                            int mp2 = (Integer) mp.get("milePts");
                                            int srp = (Integer) mp.get("srPts");
                                            int wp = (Integer) mp.get("wickPts");
                                            int dp = (Integer) mp.get("dotPts");
                                            int hp = (Integer) mp.get("haulPts");
                                            int ep = (Integer) mp.get("econPts");
                                            int barW = (int)((tp * 100.0) / maxPts);
                                            %>
                                            <div class="mp-row">
                                                <div>
                                                    <div style="font-weight:600;color:#e0e0e0">
                                                        <%= mp.get("vs") %>
                                                    </div>
                                                    <div style="color:#555;font-size:10px;margin-top:2px">
                                                        <%= mp.get("date") %>
                                                    </div>
                                                </div>
                                                <div>
                                                    <div class="mp-bar-wrap">
                                                        <div class="mp-bar" style="width:<%= barW %>%"></div>
                                                    </div>
                                                    <div class="pts-breakdown">
                                                        <% if (rp> 0) { %><span class="pb-chip pos">Bat +<%= rp %>
                                                                    </span>
                                                            <% } %>
                                                                <% if (bp> 0) { %><span class="pb-chip pos">Boundary +
                                                                        <%= bp %></span>
                                                                    <% } %>
                                                                        <% if (mp2> 0) { %><span
                                                                                class="pb-chip pos">Milestone +<%= mp2
                                                                                    %></span>
                                                                            <% } %>
                                                                                <% if (mp2 < 0) { %><span
                                                                                        class="pb-chip neg">Duck <%= mp2
                                                                                            %></span>
                                                                                    <% } %>
                                                                                        <% if (srp> 0) { %><span
                                                                                                class="pb-chip pos">SR +
                                                                                                <%= srp %></span>
                                                                                            <% } %>
                                                                                                <% if (srp < 0) { %>
                                                                                                    <span
                                                                                                        class="pb-chip neg">SR
                                                                                                        <%= srp %>
                                                                                                            </span>
                                                                                                    <% } %>
                                                                                                        <% if (wp> 0) {
                                                                                                            %><span
                                                                                                                class="pb-chip pos">Wkt
                                                                                                                +<%= wp
                                                                                                                    %>
                                                                                                                    </span>
                                                                                                            <% } %>
                                                                                                                <% if
                                                                                                                    (dp>
                                                                                                                    0) {
                                                                                                                    %><span
                                                                                                                        class="pb-chip pos">Dot
                                                                                                                        +
                                                                                                                        <%= dp
                                                                                                                            %>
                                                                                                                            </span>
                                                                                                                    <% }
                                                                                                                        %>
                                                                                                                        <% if
                                                                                                                            (hp>
                                                                                                                            0)
                                                                                                                            {
                                                                                                                            %><span
                                                                                                                                class="pb-chip pos">Haul
                                                                                                                                +
                                                                                                                                <%= hp
                                                                                                                                    %>
                                                                                                                                    </span>
                                                                                                                            <% }
                                                                                                                                %>
                                                                                                                                <% if (ep != 0) { %>
                                                                                                                                    <span class='<%= "pb-chip " + (ep > 0 ? "pos" : "neg") %>'>
                                                                                                                                        Econ <%= ep > 0 ? "+" : "" %><%= ep %>
                                                                                                                                    </span>
                                                                                                                                <% } %>
                                                    </div>
                                                </div>
                                                <div
                                                    style="font-size:18px;font-weight:700;color:#b464ff;text-align:right">
                                                    <%= tp %>
                                                </div>
                                            </div>
                                            <% } } else { %>
                                                <div style="text-align:center;padding:40px;color:#555">No match data
                                                    yet.</div>
                                                <% } %>
                                </div>

                            </div>
                            </body>

                            </html>