package com.iplive.servlet;

import com.iplive.model.Match;
import com.iplive.model.Player;
import com.iplive.model.Team;
import com.iplive.util.DBUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminServlet extends HttpServlet {
//Show Admin Dashboard
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        loadAdminData(req);
        req.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "";
        switch (action) {
            case "addTeam":    addTeam(req); break;
            case "addPlayer":  addPlayer(req); break;
            case "scheduleMatch": scheduleMatch(req); break;
            case "removeTeam": removeTeam(req); break;
            default: break;
        }
        res.sendRedirect(req.getContextPath() + "/admin");
    }

    //loads teams, players and matches to display on admin dashboard
    private void loadAdminData(HttpServletRequest req) {
        List<Team> teams = new ArrayList<>();
        List<Player> players = new ArrayList<>();
        List<Match> matches = new ArrayList<>();
        try (Connection con = DBUtil.getConnection()) {
            // Teams
            ResultSet rs = con.createStatement().executeQuery("SELECT t.*, COUNT(p.player_id) AS cnt FROM team t LEFT JOIN player p ON t.team_id=p.team_id GROUP BY t.team_id");
            while (rs.next()) {
                Team t = new Team(rs.getInt("team_id"), rs.getString("team_name"), rs.getString("short_code"), rs.getString("home_ground"), rs.getString("color_hex"));
                teams.add(t);
            }
            rs.close();
            // Players
            rs = con.createStatement().executeQuery("SELECT p.*, t.team_name, t.short_code FROM player p JOIN team t ON p.team_id=t.team_id ORDER BY t.team_name, p.player_name");
            while (rs.next()) {
                Player p = new Player();
                p.setPlayerId(rs.getInt("player_id")); p.setPlayerName(rs.getString("player_name"));
                p.setTeamId(rs.getInt("team_id")); p.setTeamName(rs.getString("team_name"));
                p.setShortCode(rs.getString("short_code")); p.setRole(rs.getString("role"));
                players.add(p);
            }
            rs.close();
            // Matches
            rs = con.createStatement().executeQuery(
                "SELECT m.match_id, m.venue, m.match_date, m.status, ta.team_name AS a, tb.team_name AS b " +
                "FROM match_tbl m JOIN team ta ON m.team_a_id=ta.team_id JOIN team tb ON m.team_b_id=tb.team_id ORDER BY m.match_date DESC LIMIT 10");
            while (rs.next()) {
                Match m = new Match();
                m.setMatchId(rs.getInt("match_id")); m.setTeamAName(rs.getString("a")); m.setTeamBName(rs.getString("b"));
                m.setVenue(rs.getString("venue")); m.setMatchDate(rs.getString("match_date")); m.setStatus(rs.getString("status"));
                matches.add(m);
            }
            rs.close();
        } catch (SQLException e) { e.printStackTrace(); }
        req.setAttribute("teams", teams);
        req.setAttribute("players", players);
        req.setAttribute("matches", matches);
    }

    private void addTeam(HttpServletRequest req) {
        String name = req.getParameter("teamName");
        String code = req.getParameter("shortCode");
        String ground = req.getParameter("homeGround");
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("INSERT INTO team(team_name,short_code,home_ground) VALUES(?,?,?)")) {
            ps.setString(1, name); ps.setString(2, code); ps.setString(3, ground);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    private void addPlayer(HttpServletRequest req) {
        String name = req.getParameter("playerName");
        int teamId   = Integer.parseInt(req.getParameter("teamId"));
        String role  = req.getParameter("role");
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("INSERT INTO player(player_name,team_id,role) VALUES(?,?,?)")) {
            ps.setString(1, name); ps.setInt(2, teamId); ps.setString(3, role);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    private void scheduleMatch(HttpServletRequest req) {
        int teamA = Integer.parseInt(req.getParameter("teamAId"));
        int teamB = Integer.parseInt(req.getParameter("teamBId"));
        String venue = req.getParameter("venue");
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("INSERT INTO match_tbl(team_a_id,team_b_id,venue,status) VALUES(?,?,?,'Upcoming')")) {
            ps.setInt(1, teamA); ps.setInt(2, teamB); ps.setString(3, venue);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    private void removeTeam(HttpServletRequest req) {
        int id = Integer.parseInt(req.getParameter("teamId"));
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM team WHERE team_id=?")) {
            ps.setInt(1, id); ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
}
