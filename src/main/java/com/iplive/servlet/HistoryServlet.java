package com.iplive.servlet;

import com.iplive.model.Match;
import com.iplive.util.DBUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class HistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        List<Match> history = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT m.match_id, m.venue, m.match_date, m.status, " +
                "ta.team_name AS a_name, ta.short_code AS a_code, " +
                "tb.team_name AS b_name, tb.short_code AS b_code, " +
                "tw.team_name AS winner_name, " +
                "i1.total_runs AS r1, i1.total_wickets AS w1, i1.total_balls AS b1, " +
                "i2.total_runs AS r2, i2.total_wickets AS w2, i2.total_balls AS b2 " +
                "FROM match_tbl m " +
                "JOIN team ta ON m.team_a_id=ta.team_id JOIN team tb ON m.team_b_id=tb.team_id " +
                "LEFT JOIN team tw ON m.winner_team_id=tw.team_id " +
                "LEFT JOIN innings i1 ON i1.match_id=m.match_id AND i1.innings_number=1 " +
                "LEFT JOIN innings i2 ON i2.match_id=m.match_id AND i2.innings_number=2 " +
                "WHERE m.status='Completed' ORDER BY m.match_date DESC")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Match m = new Match();
                m.setMatchId(rs.getInt("match_id")); m.setVenue(rs.getString("venue"));
                m.setMatchDate(rs.getString("match_date")); m.setStatus(rs.getString("status"));
                m.setTeamAName(rs.getString("a_name")); m.setTeamACode(rs.getString("a_code"));
                m.setTeamBName(rs.getString("b_name")); m.setTeamBCode(rs.getString("b_code"));
                m.setWinnerName(rs.getString("winner_name"));
                m.setRuns1(rs.getInt("r1")); m.setWickets1(rs.getInt("w1")); m.setBalls1(rs.getInt("b1"));
                m.setRuns2(rs.getInt("r2")); m.setWickets2(rs.getInt("w2")); m.setBalls2(rs.getInt("b2"));
                history.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        req.setAttribute("history", history);
        req.getRequestDispatcher("/WEB-INF/views/history.jsp").forward(req, res);
    }
}
