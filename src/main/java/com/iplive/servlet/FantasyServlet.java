package com.iplive.servlet;

import com.iplive.util.DBUtil;
import com.iplive.util.FantasyEngine;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;
import java.util.Map;

/**
 * Handles the /fantasy route.
 *
 * GET /fantasy → leaderboard + match toppers
 * GET /fantasy?playerId=X → player detail (badges + match history)
 * POST /fantasy?action=recompute&matchId=X → (admin) recompute points
 */
public class FantasyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pidParam = req.getParameter("playerId");

        try (Connection conn = DBUtil.getConnection()) {

            if (pidParam != null) {
                // ── Player detail view ──────────────────────────────────
                int playerId = Integer.parseInt(pidParam);

                // Basic player info
                List<Map<String, Object>> matchPts = FantasyEngine.getPlayerMatchPoints(conn, playerId);
                List<Map<String, Object>> badges = FantasyEngine.getPlayerBadges(conn, playerId);

                // Season rank
                int rank = 0;
                int totalPts = 0;
                double avgPts = 0;
                int matches = 0;
                try (var ps = conn.prepareStatement(
                        "SELECT rank_pos, total_fantasy_pts, avg_pts, matches_played FROM season_fantasy_rank WHERE player_id=?")) {
                    ps.setInt(1, playerId);
                    try (var rs = ps.executeQuery()) {
                        if (rs.next()) {
                            rank = rs.getInt("rank_pos");
                            totalPts = rs.getInt("total_fantasy_pts");
                            avgPts = rs.getDouble("avg_pts");
                            matches = rs.getInt("matches_played");
                        }
                    }
                }

                // Player name & team
                String playerName = "Unknown";
                String teamName = "";
                String teamCode = "";
                try (var ps = conn.prepareStatement(
                        "SELECT p.player_name, t.team_name, t.short_code FROM player p JOIN team t ON t.team_id=p.team_id WHERE p.player_id=?")) {
                    ps.setInt(1, playerId);
                    try (var rs = ps.executeQuery()) {
                        if (rs.next()) {
                            playerName = rs.getString("player_name");
                            teamName = rs.getString("team_name");
                            teamCode = rs.getString("short_code");
                        }
                    }
                }

                req.setAttribute("playerId", playerId);
                req.setAttribute("playerName", playerName);
                req.setAttribute("teamName", teamName);
                req.setAttribute("teamCode", teamCode);
                req.setAttribute("matchPts", matchPts);
                req.setAttribute("badges", badges);
                req.setAttribute("rank", rank);
                req.setAttribute("totalPts", totalPts);
                req.setAttribute("avgPts", avgPts);
                req.setAttribute("matches", matches);

                req.getRequestDispatcher("/WEB-INF/views/fantasyPlayer.jsp").forward(req, resp);

            } else {
                // ── Main leaderboard view ────────────────────────────────
                List<Map<String, Object>> leaderboard = FantasyEngine.getSeasonLeaderboard(conn, 50);
                List<Map<String, Object>> toppers = FantasyEngine.getMatchFantasyToppers(conn, 10);

                // All achievement defs for the "Achievements" section
                List<Map<String, Object>> allAchs = new java.util.ArrayList<>();
                try (var st = conn.createStatement();
                        var rs = st.executeQuery("SELECT * FROM achievement_def ORDER BY category, ach_id")) {
                    while (rs.next()) {
                        Map<String, Object> m = new java.util.LinkedHashMap<>();
                        m.put("icon", rs.getString("icon"));
                        m.put("title", rs.getString("title"));
                        m.put("desc", rs.getString("description"));
                        m.put("cat", rs.getString("category"));
                        allAchs.add(m);
                    }
                }

                req.setAttribute("leaderboard", leaderboard);
                req.setAttribute("toppers", toppers);
                req.setAttribute("allAchs", allAchs);

                req.getRequestDispatcher("/WEB-INF/views/fantasy.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Fantasy feature error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = (String) req.getSession().getAttribute("role");
        if (!"admin".equals(role)) {
            resp.sendError(403, "Admin only");
            return;
        }

        String action = req.getParameter("action");
        String matchParam = req.getParameter("matchId");

        if ("recompute".equals(action) && matchParam != null) {
            int matchId = Integer.parseInt(matchParam);
            FantasyEngine.computeAndSaveMatchPoints(matchId);
        } else if ("recomputeAll".equals(action)) {
            try (Connection conn = DBUtil.getConnection();
                    var st = conn.createStatement();
                    var rs = st.executeQuery("SELECT match_id FROM match_tbl WHERE status='Completed'")) {
                while (rs.next()) {
                    FantasyEngine.computeAndSaveMatchPoints(rs.getInt(1));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        resp.sendRedirect(req.getContextPath() + "/fantasy");
    }
}