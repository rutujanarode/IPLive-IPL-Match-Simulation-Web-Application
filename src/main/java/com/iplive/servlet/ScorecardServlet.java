package com.iplive.servlet;

import com.iplive.util.DBUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class ScorecardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        int matchId = Integer.parseInt(req.getParameter("matchId"));

        Map<String,Object> matchInfo = new LinkedHashMap<>();
        List<Map<String,Object>> batting1 = new ArrayList<>();
        List<Map<String,Object>> bowling1 = new ArrayList<>();
        List<Map<String,Object>> batting2 = new ArrayList<>();
        List<Map<String,Object>> bowling2 = new ArrayList<>();

        try (Connection con = DBUtil.getConnection()) {
            if (DBUtil.isDatabaseIncomplete(con)) {
                DBUtil.seedDatabase(req.getServletContext(), con);
            }
            // Match info
            PreparedStatement ps = con.prepareStatement(
                "SELECT m.match_id, m.venue, m.match_date, m.status, " +
                "ta.team_name AS a_name, ta.short_code AS a_code, " +
                "tb.team_name AS b_name, tb.short_code AS b_code, " +
                "tw.team_name AS winner, " +
                "i1.total_runs AS r1, i1.total_wickets AS w1, i1.total_balls AS b1, i1.innings_id AS iid1, " +
                "i2.total_runs AS r2, i2.total_wickets AS w2, i2.total_balls AS b2, i2.innings_id AS iid2 " +
                "FROM match_tbl m " +
                "JOIN team ta ON m.team_a_id=ta.team_id JOIN team tb ON m.team_b_id=tb.team_id " +
                "LEFT JOIN team tw ON m.winner_team_id=tw.team_id " +
                "LEFT JOIN innings i1 ON i1.match_id=m.match_id AND i1.innings_number=1 " +
                "LEFT JOIN innings i2 ON i2.match_id=m.match_id AND i2.innings_number=2 " +
                "WHERE m.match_id=?");
            ps.setInt(1, matchId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                matchInfo.put("venue", rs.getString("venue"));
                matchInfo.put("date", rs.getString("match_date"));
                matchInfo.put("teamA", rs.getString("a_name"));
                matchInfo.put("teamACode", rs.getString("a_code"));
                matchInfo.put("teamB", rs.getString("b_name"));
                matchInfo.put("teamBCode", rs.getString("b_code"));
                matchInfo.put("winner", rs.getString("winner"));
                matchInfo.put("r1", rs.getInt("r1")); matchInfo.put("w1", rs.getInt("w1")); matchInfo.put("b1", rs.getInt("b1"));
                matchInfo.put("r2", rs.getInt("r2")); matchInfo.put("w2", rs.getInt("w2")); matchInfo.put("b2", rs.getInt("b2"));
                int iid1 = rs.getInt("iid1"), iid2 = rs.getInt("iid2");
                if (iid1 > 0) {
                    batting1 = getBattingCard(con, iid1, matchId);
                    bowling1 = getBowlingCard(con, iid1, matchId);
                }
                if (iid2 > 0) {
                    batting2 = getBattingCard(con, iid2, matchId);
                    bowling2 = getBowlingCard(con, iid2, matchId);
                }
                String mom = computeManOfTheMatch(con, matchId);
                if (mom != null) {
                    matchInfo.put("manOfTheMatch", mom);
                }
            }
            rs.close(); ps.close();
        } catch (SQLException e) { e.printStackTrace(); }

        req.setAttribute("matchInfo", matchInfo);
        req.setAttribute("batting1", batting1); req.setAttribute("bowling1", bowling1);
        req.setAttribute("batting2", batting2); req.setAttribute("bowling2", bowling2);
        req.setAttribute("matchId", matchId);
        req.getRequestDispatcher("/WEB-INF/views/scorecard.jsp").forward(req, res);
    }

    private List<Map<String,Object>> getBattingCard(Connection con, int inningsId, int matchId) throws SQLException {
        List<Map<String,Object>> list = new ArrayList<>();
        PreparedStatement ps = con.prepareStatement(
            "SELECT p.player_name, bs.runs, bs.balls_faced, bs.fours, bs.sixes, bs.is_out, bs.dismissal_type " +
            "FROM batting_stats bs JOIN player p ON bs.player_id=p.player_id " +
            "WHERE bs.innings_id=? ORDER BY bs.stat_id");
        ps.setInt(1, inningsId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String,Object> row = new LinkedHashMap<>();
            int runs = rs.getInt("runs"), balls = rs.getInt("balls_faced");
            row.put("name", rs.getString("player_name"));
            row.put("dismissal", rs.getBoolean("is_out") ? rs.getString("dismissal_type") : "not out");
            row.put("runs", runs); row.put("balls", balls);
            row.put("fours", rs.getInt("fours")); row.put("sixes", rs.getInt("sixes"));
            row.put("sr", balls > 0 ? String.format("%.1f", runs * 100.0 / balls) : "0.0");
            list.add(row);
        }
        rs.close(); ps.close();
        return list;
    }

    private List<Map<String,Object>> getBowlingCard(Connection con, int inningsId, int matchId) throws SQLException {
        List<Map<String,Object>> list = new ArrayList<>();
        PreparedStatement ps = con.prepareStatement(
            "SELECT p.player_name, bw.overs, bw.maidens, bw.runs_given, bw.wickets " +
            "FROM bowling_stats bw JOIN player p ON bw.player_id=p.player_id " +
            "WHERE bw.innings_id=? ORDER BY bw.wickets DESC");
        ps.setInt(1, inningsId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String,Object> row = new LinkedHashMap<>();
            double overs = rs.getDouble("overs");
            int runsGiven = rs.getInt("runs_given");
            row.put("name", rs.getString("player_name"));
            row.put("overs", overs); row.put("maidens", rs.getInt("maidens"));
            row.put("runs", runsGiven); row.put("wickets", rs.getInt("wickets"));
            row.put("eco", overs > 0 ? String.format("%.2f", runsGiven / overs) : "0.00");
            list.add(row);
        }
        rs.close(); ps.close();
        return list;
    }

    private String computeManOfTheMatch(Connection con, int matchId) throws SQLException {
        String sql = "SELECT p.player_name, " +
                "COALESCE(SUM(bs.runs),0) AS runs, " +
                "COALESCE(SUM(bs.fours),0) AS fours, " +
                "COALESCE(SUM(bs.sixes),0) AS sixes, " +
                "COALESCE(SUM(bw.wickets),0) AS wickets, " +
                "COALESCE(SUM(bw.runs_given),0) AS runs_given " +
                "FROM player p " +
                "LEFT JOIN batting_stats bs ON p.player_id=bs.player_id AND bs.match_id=? " +
                "LEFT JOIN bowling_stats bw ON p.player_id=bw.player_id AND bw.match_id=? " +
                "WHERE bs.match_id=? OR bw.match_id=? " +
                "GROUP BY p.player_id";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, matchId);
        ps.setInt(2, matchId);
        ps.setInt(3, matchId);
        ps.setInt(4, matchId);
        ResultSet rs = ps.executeQuery();

        String bestName = null;
        double bestScore = -Double.MAX_VALUE;

        while (rs.next()) {
            String name = rs.getString("player_name");
            int runs = rs.getInt("runs");
            int fours = rs.getInt("fours");
            int sixes = rs.getInt("sixes");
            int wickets = rs.getInt("wickets");
            int runsGiven = rs.getInt("runs_given");
            double score = runs + fours * 2 + sixes * 3 + wickets * 20 - runsGiven * 0.1;
            if (score > bestScore) {
                bestScore = score;
                bestName = name;
            }
        }

        rs.close(); ps.close();
        return bestName;
    }
}
