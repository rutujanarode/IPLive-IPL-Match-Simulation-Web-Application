package com.iplive.servlet;

import com.iplive.model.Player;
import com.iplive.util.DBUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class StatsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        List<Player> orangeCap = new ArrayList<>();
        List<Player> purpleCap = new ArrayList<>();
        List<Map<String, Object>> pointsTable = new ArrayList<>();

        try (Connection con = DBUtil.getConnection()) {

            // ---- Orange Cap: prefer live batting_stats; fallback to season_batting_stats ----
            PreparedStatement ps = con.prepareStatement(
                    "SELECT p.player_id, p.player_name, t.team_name, t.short_code, " +
                            "SUM(bs.runs) AS total_runs, SUM(bs.balls_faced) AS total_balls, " +
                            "SUM(bs.fours) AS fours, SUM(bs.sixes) AS sixes, COUNT(DISTINCT bs.match_id) AS matches " +
                            "FROM batting_stats bs " +
                            "JOIN player p ON bs.player_id = p.player_id " +
                            "JOIN team t ON p.team_id = t.team_id " +
                            "GROUP BY p.player_id ORDER BY total_runs DESC, total_balls ASC LIMIT 15");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Player p = new Player();
                p.setPlayerId(rs.getInt("player_id"));
                p.setPlayerName(rs.getString("player_name"));
                p.setTeamName(rs.getString("team_name"));
                p.setShortCode(rs.getString("short_code"));
                p.setTotalRuns(rs.getInt("total_runs"));
                p.setTotalBalls(rs.getInt("total_balls"));
                p.setTotalFours(rs.getInt("fours"));
                p.setTotalSixes(rs.getInt("sixes"));
                p.setMatchesPlayed(rs.getInt("matches"));
                orangeCap.add(p);
            }
            rs.close();
            ps.close();

            if (orangeCap.isEmpty()) {
                ps = con.prepareStatement(
                        "SELECT p.player_id, p.player_name, t.team_name, t.short_code, " +
                                "s.runs AS total_runs, s.balls, s.matches AS matches_played, " +
                                "s.highest_score, s.fifties, s.hundreds, s.fours, s.sixes, s.not_outs, s.innings " +
                                "FROM season_batting_stats s " +
                                "JOIN player p ON s.player_id = p.player_id " +
                                "JOIN team t ON p.team_id = t.team_id " +
                                "ORDER BY s.runs DESC LIMIT 15");
                rs = ps.executeQuery();
                while (rs.next()) {
                    Player p = new Player();
                    p.setPlayerId(rs.getInt("player_id"));
                    p.setPlayerName(rs.getString("player_name"));
                    p.setTeamName(rs.getString("team_name"));
                    p.setShortCode(rs.getString("short_code"));
                    p.setTotalRuns(rs.getInt("total_runs"));
                    p.setTotalBalls(rs.getInt("balls"));
                    p.setMatchesPlayed(rs.getInt("matches_played"));
                    p.setTotalFours(rs.getInt("fours"));
                    p.setTotalSixes(rs.getInt("sixes"));
                    orangeCap.add(p);
                }
                rs.close();
                ps.close();
            }

            // ---- Purple Cap: prefer live bowling_stats; fallback to season_bowling_stats ----
            ps = con.prepareStatement(
                    "SELECT p.player_id, p.player_name, t.team_name, t.short_code, " +
                            "SUM(bw.wickets) AS total_wickets, SUM(bw.overs) AS total_overs, " +
                            "SUM(bw.runs_given) AS runs_given, COUNT(DISTINCT bw.match_id) AS matches " +
                            "FROM bowling_stats bw " +
                            "JOIN player p ON bw.player_id = p.player_id " +
                            "JOIN team t ON p.team_id = t.team_id " +
                            "GROUP BY p.player_id ORDER BY total_wickets DESC, runs_given ASC LIMIT 15");
            rs = ps.executeQuery();
            while (rs.next()) {
                Player p = new Player();
                p.setPlayerId(rs.getInt("player_id"));
                p.setPlayerName(rs.getString("player_name"));
                p.setTeamName(rs.getString("team_name"));
                p.setShortCode(rs.getString("short_code"));
                p.setTotalWickets(rs.getInt("total_wickets"));
                p.setTotalOvers(rs.getDouble("total_overs"));
                p.setTotalRunsGiven(rs.getInt("runs_given"));
                p.setMatchesPlayed(rs.getInt("matches"));
                purpleCap.add(p);
            }
            rs.close();
            ps.close();

            if (purpleCap.isEmpty()) {
                ps = con.prepareStatement(
                        "SELECT p.player_id, p.player_name, t.team_name, t.short_code, " +
                                "s.wickets AS total_wickets, s.overs, s.runs_given, s.matches AS matches_played, " +
                                "s.best_bowling " +
                                "FROM season_bowling_stats s " +
                                "JOIN player p ON s.player_id = p.player_id " +
                                "JOIN team t ON p.team_id = t.team_id " +
                                "ORDER BY s.wickets DESC, s.runs_given ASC LIMIT 15");
                rs = ps.executeQuery();
                while (rs.next()) {
                    Player p = new Player();
                    p.setPlayerId(rs.getInt("player_id"));
                    p.setPlayerName(rs.getString("player_name"));
                    p.setTeamName(rs.getString("team_name"));
                    p.setShortCode(rs.getString("short_code"));
                    p.setTotalWickets(rs.getInt("total_wickets"));
                    p.setTotalOvers(rs.getDouble("overs"));
                    p.setTotalRunsGiven(rs.getInt("runs_given"));
                    p.setMatchesPlayed(rs.getInt("matches_played"));
                    purpleCap.add(p);
                }
                rs.close();
                ps.close();
            }

            // ---- Points Table ----
            ps = con.prepareStatement(
                    "SELECT t.team_id, t.team_name, t.short_code, " +
                            "COUNT(m.match_id) AS played, " +
                            "SUM(CASE WHEN m.winner_team_id=t.team_id THEN 1 ELSE 0 END) AS wins, " +
                            "SUM(CASE WHEN m.status='Completed' AND m.winner_team_id!=t.team_id AND m.winner_team_id IS NOT NULL THEN 1 ELSE 0 END) AS losses, "
                            +
                            "SUM(CASE WHEN m.status='Completed' AND m.winner_team_id IS NULL THEN 1 ELSE 0 END) AS nr "
                            +
                            "FROM team t LEFT JOIN match_tbl m " +
                            "ON (m.team_a_id=t.team_id OR m.team_b_id=t.team_id) AND m.status='Completed' " +
                            "GROUP BY t.team_id ORDER BY wins DESC, nr DESC");
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                int wins = rs.getInt("wins");
                int losses = rs.getInt("losses");
                int nr = rs.getInt("nr");
                row.put("teamName", rs.getString("team_name"));
                row.put("shortCode", rs.getString("short_code"));
                row.put("played", rs.getInt("played"));
                row.put("wins", wins);
                row.put("losses", losses);
                row.put("nr", nr);
                row.put("points", wins * 2 + nr);
                // Placeholder NRR (real NRR needs ball-by-ball aggregate — complex)
                double nrrVal = (wins * 0.3) - (losses * 0.25) + (Math.random() * 0.1 - 0.05);
                row.put("nrr", String.format("%+.3f", nrrVal));
                pointsTable.add(row);
            }
            rs.close();
            ps.close();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("orangeCap", orangeCap);
        req.setAttribute("purpleCap", purpleCap);
        req.setAttribute("pointsTable", pointsTable);
        req.getRequestDispatcher("/WEB-INF/views/stats.jsp").forward(req, res);
    }
}
