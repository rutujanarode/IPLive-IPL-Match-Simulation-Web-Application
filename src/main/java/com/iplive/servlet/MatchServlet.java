package com.iplive.servlet;

import com.iplive.model.Match;
import com.iplive.model.Player;
import com.iplive.util.DBUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MatchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // ==============================
        // 🔥 NORMAL MATCH LOADING
        // ==============================

        String matchIdStr = req.getParameter("matchId");

        // Show match list
        if (matchIdStr == null) {

            List<Match> upcoming = new ArrayList<>();

            try (Connection con = DBUtil.getConnection();
                    PreparedStatement ps = con.prepareStatement(
                            "SELECT m.match_id, m.venue, m.status, " +
                                    "ta.team_name AS a_name, ta.short_code AS a_code, " +
                                    "tb.team_name AS b_name, tb.short_code AS b_code " +
                                    "FROM match_tbl m " +
                                    "JOIN team ta ON m.team_a_id=ta.team_id " +
                                    "JOIN team tb ON m.team_b_id=tb.team_id " +
                                    "WHERE m.status='Upcoming' OR m.status='Live'")) {

                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    Match m = new Match();
                    m.setMatchId(rs.getInt("match_id"));
                    m.setVenue(rs.getString("venue"));
                    m.setStatus(rs.getString("status"));

                    m.setTeamAName(rs.getString("a_name"));
                    m.setTeamACode(rs.getString("a_code"));

                    m.setTeamBName(rs.getString("b_name"));
                    m.setTeamBCode(rs.getString("b_code"));

                    upcoming.add(m);
                }

            } catch (SQLException e) {
                e.printStackTrace();
            }

            req.setAttribute("upcoming", upcoming);
            req.getRequestDispatcher("/WEB-INF/views/selectMatch.jsp")
                    .forward(req, res);
            return;
        }

        int matchId = Integer.parseInt(matchIdStr);
        HttpSession session = req.getSession();

        // Load match from session
        Match match = (Match) session.getAttribute("match_" + matchId);

        if (match == null) {
            match = loadMatch(matchId);

            if (match == null) {
                res.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            // Only initialize innings for a fresh Upcoming match.
            // A Live match that lost its session is re-attached without re-inserting
            // innings.
            if ("Upcoming".equals(match.getStatus())) {
                initInnings(match);
            } else {
                // Match is already Live — restore minimal state so simulation can continue
                match.setStatus("Live");
                match.setBatterRuns(new int[11]);
                match.setBatterBalls(new int[11]);
                match.setCommentary(new java.util.ArrayList<>());
                // Reload inningsId from DB so persistBallToDB works
                reloadInningsIds(match);
            }
            session.setAttribute("match_" + matchId, match);
        }

        // Load players
        List<Player> batters = getPlayers(
                match.getCurrentInnings() == 1 ? match.getTeamAId() : match.getTeamBId());

        List<Player> bowlers = getPlayers(
                match.getCurrentInnings() == 1 ? match.getTeamBId() : match.getTeamAId());

        req.setAttribute("match", match);
        req.setAttribute("batters", batters);
        req.setAttribute("bowlers", bowlers);

        req.getRequestDispatcher("/WEB-INF/views/liveMatch.jsp")
                .forward(req, res);
    }

    // ==============================
    // 🔧 RELOAD INNINGS IDS (when session lost for a Live match)
    // ==============================
    private void reloadInningsIds(Match match) {
        try (Connection con = DBUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "SELECT innings_id, innings_number FROM innings WHERE match_id=? ORDER BY innings_number")) {
            ps.setInt(1, match.getMatchId());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int num = rs.getInt("innings_number");
                int id = rs.getInt("innings_id");
                if (num == 1)
                    match.setInningsId1(id);
                else if (num == 2)
                    match.setInningsId2(id);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // 🔧 LOAD MATCH FROM DB
    // ==============================
    private Match loadMatch(int matchId) {

        try (Connection con = DBUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "SELECT m.*, " +
                                "ta.team_name AS a_name, ta.short_code AS a_code, ta.team_id AS a_id, " +
                                "tb.team_name AS b_name, tb.short_code AS b_code, tb.team_id AS b_id " +
                                "FROM match_tbl m " +
                                "JOIN team ta ON m.team_a_id=ta.team_id " +
                                "JOIN team tb ON m.team_b_id=tb.team_id " +
                                "WHERE m.match_id=?")) {

            ps.setInt(1, matchId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Match m = new Match();

                m.setMatchId(rs.getInt("match_id"));

                m.setTeamAId(rs.getInt("a_id"));
                m.setTeamAName(rs.getString("a_name"));
                m.setTeamACode(rs.getString("a_code"));

                m.setTeamBId(rs.getInt("b_id"));
                m.setTeamBName(rs.getString("b_name"));
                m.setTeamBCode(rs.getString("b_code"));

                m.setVenue(rs.getString("venue"));
                m.setStatus(rs.getString("status"));

                return m;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // ==============================
    // 🔧 INIT MATCH
    // ==============================
    private void initInnings(Match match) {

        try (Connection con = DBUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "UPDATE match_tbl SET status='Live' WHERE match_id=?")) {

            ps.setInt(1, match.getMatchId());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Create first innings
        try (Connection con = DBUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO innings(match_id,batting_team_id,bowling_team_id,innings_number) VALUES(?,?,?,1)",
                        Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, match.getMatchId());
            ps.setInt(2, match.getTeamAId());
            ps.setInt(3, match.getTeamBId());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next())
                match.setInningsId1(rs.getInt(1));
        } catch (SQLException e) {
            e.printStackTrace();
        }

        match.setStatus("Live");
        match.setRuns1(0);
        match.setWickets1(0);
        match.setBalls1(0);
        match.setRuns2(0);
        match.setWickets2(0);
        match.setBalls2(0);

        match.setCommentary(new ArrayList<>());
        match.setBatterRuns(new int[11]);
        match.setBatterBalls(new int[11]);
    }

    // ==============================
    // 🔧 LOAD PLAYERS
    // ==============================
    public static List<Player> getPlayers(int teamId) {

        List<Player> list = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "SELECT * FROM player WHERE team_id=?")) {

            ps.setInt(1, teamId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Player p = new Player();

                p.setPlayerId(rs.getInt("player_id"));
                p.setPlayerName(rs.getString("player_name"));
                p.setTeamId(rs.getInt("team_id"));
                p.setRole(rs.getString("role"));
                p.setBattingAvg(rs.getDouble("batting_avg"));
                p.setBowlingAvg(rs.getDouble("bowling_avg"));

                list.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
}