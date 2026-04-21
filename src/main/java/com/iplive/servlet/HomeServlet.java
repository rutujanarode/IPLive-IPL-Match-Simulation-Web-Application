package com.iplive.servlet;

import com.iplive.model.Match;
import com.iplive.util.DBUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        List<Match> matches = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT m.match_id, m.venue, m.match_date, m.status, " +
                "ta.team_name AS team_a_name, ta.short_code AS a_code, " +
                "tb.team_name AS team_b_name, tb.short_code AS b_code, " +
                "tw.team_name AS winner_name, " +
                "i1.total_runs AS runs1, i1.total_wickets AS wkts1, i1.total_balls AS balls1, " +
                "i2.total_runs AS runs2, i2.total_wickets AS wkts2, i2.total_balls AS balls2 " +
                "FROM match_tbl m " +
                "JOIN team ta ON m.team_a_id = ta.team_id " +
                "JOIN team tb ON m.team_b_id = tb.team_id " +
                "LEFT JOIN team tw ON m.winner_team_id = tw.team_id " +
                "LEFT JOIN innings i1 ON i1.match_id=m.match_id AND i1.innings_number=1 " +
                "LEFT JOIN innings i2 ON i2.match_id=m.match_id AND i2.innings_number=2 " +
                "ORDER BY m.match_date DESC LIMIT 10")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Match m = new Match();
                m.setMatchId(rs.getInt("match_id"));
                m.setVenue(rs.getString("venue"));
                m.setMatchDate(rs.getString("match_date"));
                m.setStatus(rs.getString("status"));
                m.setTeamAName(rs.getString("team_a_name"));
                m.setTeamACode(rs.getString("a_code"));
                m.setTeamBName(rs.getString("team_b_name"));
                m.setTeamBCode(rs.getString("b_code"));
                m.setWinnerName(rs.getString("winner_name"));
                m.setRuns1(rs.getInt("runs1"));
                m.setWickets1(rs.getInt("wkts1"));
                m.setBalls1(rs.getInt("balls1"));
                m.setRuns2(rs.getInt("runs2"));
                m.setWickets2(rs.getInt("wkts2"));
                m.setBalls2(rs.getInt("balls2"));
                matches.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }

        req.setAttribute("matches", matches);
        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, res);
    }
}
