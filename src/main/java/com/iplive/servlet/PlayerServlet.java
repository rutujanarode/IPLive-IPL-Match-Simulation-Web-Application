
package com.iplive.servlet;

import com.iplive.model.Player;
import com.iplive.util.DBUtil;
import com.iplive.util.PlayerImageUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class PlayerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String pidStr = req.getParameter("playerId");
        if (pidStr == null) { res.sendRedirect(req.getContextPath() + "/stats"); return; }
        int playerId = Integer.parseInt(pidStr);

        Player player = null;
        Map<String,Object> battingStats  = new LinkedHashMap<>();
        Map<String,Object> bowlingStats  = new LinkedHashMap<>();
        List<Map<String,Object>> recentMatches = new ArrayList<>();

        try (Connection con = DBUtil.getConnection()) {

            // ---- Basic player info ----
            PreparedStatement ps = con.prepareStatement(
                "SELECT p.*, t.team_name, t.short_code, t.color_hex " +
                "FROM player p JOIN team t ON p.team_id = t.team_id " +
                "WHERE p.player_id = ?");
            ps.setInt(1, playerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                player = new Player();
                player.setPlayerId(rs.getInt("player_id"));
                player.setPlayerName(rs.getString("player_name"));
                player.setTeamId(rs.getInt("team_id"));
                player.setTeamName(rs.getString("team_name"));
                player.setShortCode(rs.getString("short_code"));
                player.setRole(rs.getString("role"));
                player.setBattingAvg(rs.getDouble("batting_avg"));
                player.setBowlingAvg(rs.getDouble("bowling_avg"));
                player.setImageUrl(PlayerImageUtil.resolvePlayerImage(rs.getString("image_url"), rs.getString("player_name")));
                req.setAttribute("nationality",   rs.getString("nationality"));
                req.setAttribute("dob",           rs.getString("date_of_birth"));
                req.setAttribute("battingStyle",  rs.getString("batting_style"));
                req.setAttribute("bowlingStyle",  rs.getString("bowling_style"));
                req.setAttribute("bio",           rs.getString("bio"));
                req.setAttribute("colorHex",      rs.getString("color_hex"));
            }
            rs.close(); ps.close();

            if (player == null) { res.sendRedirect(req.getContextPath() + "/stats"); return; }

            // ---- Season Batting Stats ----
            ps = con.prepareStatement(
                "SELECT * FROM season_batting_stats WHERE player_id = ?");
            ps.setInt(1, playerId);
            rs = ps.executeQuery();
            if (rs.next()) {
                battingStats.put("matches",       rs.getInt("matches"));
                battingStats.put("innings",       rs.getInt("innings"));
                battingStats.put("runs",          rs.getInt("runs"));
                battingStats.put("balls",         rs.getInt("balls"));
                battingStats.put("highestScore",  rs.getInt("highest_score"));
                battingStats.put("fifties",       rs.getInt("fifties"));
                battingStats.put("hundreds",      rs.getInt("hundreds"));
                battingStats.put("fours",         rs.getInt("fours"));
                battingStats.put("sixes",         rs.getInt("sixes"));
                battingStats.put("notOuts",       rs.getInt("not_outs"));
                int runs = rs.getInt("runs");
                int balls = rs.getInt("balls");
                int inns  = rs.getInt("innings");
                int no    = rs.getInt("not_outs");
                double avg = (inns - no) > 0 ? (double) runs / (inns - no) : runs;
                double sr  = balls > 0 ? runs * 100.0 / balls : 0;
                battingStats.put("average",  String.format("%.2f", avg));
                battingStats.put("strikeRate", String.format("%.2f", sr));
            }
            rs.close(); ps.close();

            // ---- Season Bowling Stats ----
            ps = con.prepareStatement(
                "SELECT * FROM season_bowling_stats WHERE player_id = ?");
            ps.setInt(1, playerId);
            rs = ps.executeQuery();
            if (rs.next()) {
                double overs = rs.getDouble("overs");
                int runsGiven = rs.getInt("runs_given");
                int wkts = rs.getInt("wickets");
                bowlingStats.put("matches",      rs.getInt("matches"));
                bowlingStats.put("overs",        overs);
                bowlingStats.put("runsGiven",    runsGiven);
                bowlingStats.put("wickets",      wkts);
                bowlingStats.put("bestBowling",  rs.getString("best_bowling"));
                bowlingStats.put("maidens",      rs.getInt("maidens"));
                bowlingStats.put("fourWickets",  rs.getInt("four_wickets"));
                bowlingStats.put("fiveWickets",  rs.getInt("five_wickets"));
                double eco  = overs > 0 ? runsGiven / overs : 0;
                double bavg = wkts   > 0 ? (double) runsGiven / wkts : 0;
                bowlingStats.put("economy",  String.format("%.2f", eco));
                bowlingStats.put("average",  String.format("%.2f", bavg));
            }
            rs.close(); ps.close();

            // ---- Recent match performances (batting) ----
            ps = con.prepareStatement(
                "SELECT bs.runs, bs.balls_faced, bs.fours, bs.sixes, bs.is_out, " +
                "m.match_date, ta.short_code AS opp_a, tb.short_code AS opp_b, " +
                "p.team_id AS pid_team " +
                "FROM batting_stats bs " +
                "JOIN match_tbl m ON bs.match_id = m.match_id " +
                "JOIN team ta ON m.team_a_id = ta.team_id " +
                "JOIN team tb ON m.team_b_id = tb.team_id " +
                "JOIN player p ON bs.player_id = p.player_id " +
                "WHERE bs.player_id = ? " +
                "ORDER BY m.match_date DESC LIMIT 5");
            ps.setInt(1, playerId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                String oppA = rs.getString("opp_a");
                String oppB = rs.getString("opp_b");
                // figure out opponent
                String opp  = (oppA != null && !player.getShortCode().equals(oppA)) ? oppA : oppB;
                row.put("opponent",  "vs " + opp);
                row.put("runs",      rs.getInt("runs"));
                row.put("balls",     rs.getInt("balls_faced"));
                row.put("fours",     rs.getInt("fours"));
                row.put("sixes",     rs.getInt("sixes"));
                row.put("isOut",     rs.getBoolean("is_out"));
                row.put("date",      rs.getString("match_date"));
                int r = rs.getInt("runs"), b = rs.getInt("balls_faced");
                row.put("sr", b > 0 ? String.format("%.1f", r * 100.0 / b) : "—");
                recentMatches.add(row);
            }
            rs.close(); ps.close();

        } catch (SQLException e) { e.printStackTrace(); }

        req.setAttribute("player",       player);
        req.setAttribute("battingStats", battingStats);
        req.setAttribute("bowlingStats", bowlingStats);
        req.setAttribute("recentMatches", recentMatches);
        req.getRequestDispatcher("/WEB-INF/views/playerProfile.jsp").forward(req, res);
    }
}
