package com.iplive.servlet;

import com.iplive.model.BallResult;
import com.iplive.model.Match;
import com.iplive.model.Player;
import com.iplive.util.SimulationEngine;
import org.json.JSONObject;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.List;

import com.iplive.util.DBUtil;

@MultipartConfig
public class BallServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();

        String matchIdParam = req.getParameter("matchId");
        if (matchIdParam == null || matchIdParam.trim().isEmpty()) {
            out.print(new JSONObject().put("error", "Missing matchId parameter").toString());
            return;
        }

        int matchId;
        try {
            matchId = Integer.parseInt(matchIdParam.trim());
        } catch (NumberFormatException e) {
            out.print(new JSONObject().put("error", "Invalid matchId: " + matchIdParam).toString());
            return;
        }

        HttpSession session = req.getSession();
        Match match = (Match) session.getAttribute("match_" + matchId);

        if (match == null || "Completed".equals(match.getStatus())) {
            out.print(new JSONObject().put("error", "Match not found or already completed").toString());
            return;
        }

        // Handle innings transition — create innings 2
        if (match.getCurrentInnings() == 2 && match.getInningsId2() == 0) {
            try (Connection con = DBUtil.getConnection();
                    PreparedStatement ps = con.prepareStatement(
                            "INSERT INTO innings(match_id,batting_team_id,bowling_team_id,innings_number) VALUES(?,?,?,2)",
                            Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, match.getMatchId());
                ps.setInt(2, match.getTeamBId());
                ps.setInt(3, match.getTeamAId());
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next())
                    match.setInningsId2(rs.getInt(1));
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        int battingTeamId = match.getCurrentInnings() == 1 ? match.getTeamAId() : match.getTeamBId();
        int bowlingTeamId = match.getCurrentInnings() == 1 ? match.getTeamBId() : match.getTeamAId();

        List<Player> batters = MatchServlet.getPlayers(battingTeamId);
        List<Player> bowlers = MatchServlet.getPlayers(bowlingTeamId);

        // Only keep bowlers
        bowlers.removeIf(p -> "Batsman".equals(p.getRole()) || "Wicket-Keeper".equals(p.getRole()));
        if (bowlers.isEmpty())
            bowlers = MatchServlet.getPlayers(bowlingTeamId);

        try {
            BallResult result = SimulationEngine.simulateBall(match, batters, bowlers);
            session.setAttribute("match_" + matchId, match);

            JSONObject json = new JSONObject();
            json.put("over", result.getOver());
            json.put("runs", result.getRuns());
            json.put("isWicket", result.isWicket());
            json.put("isFour", result.isFour());
            json.put("isSix", result.isSix());
            json.put("commentary", result.getCommentary());
            json.put("totalRuns", result.getTotalRuns());
            json.put("totalWickets", result.getTotalWickets());
            json.put("totalOver", result.getTotalOver());
            json.put("inningsOver", result.isInningsOver());
            json.put("matchOver", result.isMatchOver());
            json.put("resultMessage", result.getResultMessage() == null ? "" : result.getResultMessage());
            json.put("strikerName", result.getStrikerName() == null ? "" : result.getStrikerName());
            json.put("nonStrikerName", result.getNonStrikerName() == null ? "" : result.getNonStrikerName());
            json.put("strikerRuns", result.getStrikerRuns());
            json.put("strikerBalls", result.getStrikerBalls());
            json.put("nonStrikerRuns", result.getNonStrikerRuns());
            json.put("nonStrikerBalls", result.getNonStrikerBalls());
            json.put("currentInnings", match.getCurrentInnings());
            json.put("runs1", match.getRuns1());
            json.put("wickets1", match.getWickets1());
            json.put("balls1", match.getBalls1());
            json.put("runs2", match.getRuns2());
            json.put("wickets2", match.getWickets2());
            json.put("balls2", match.getBalls2());
            json.put("currentBalls", match.getCurrentBalls());
            json.put("ballsRemaining", match.getCurrentInnings() == 2 ? Math.max(0, 120 - match.getBalls2()) : Math.max(0, 120 - match.getBalls1()));
            json.put("status", match.getStatus());
            if (match.getCurrentInnings() == 2) {
                json.put("target", match.getRuns1() + 1);
                json.put("needRuns", Math.max(0, match.getRuns1() + 1 - match.getRuns2()));
            } else {
                json.put("target", 0);
                json.put("needRuns", 0);
            }

            // Win prediction (simple: based on run rate comparison)
            double crr = match.getCurrentBalls() > 0 ? (match.getCurrentRuns() * 6.0) / match.getCurrentBalls() : 0;
            int teamAWinPct = (int) Math.min(90, Math.max(10, 50 + (crr - 8.0) * 3));
            json.put("teamAWinPct", teamAWinPct);
            json.put("teamBWinPct", 100 - teamAWinPct);

            out.print(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            out.print(new JSONObject().put("error", e.getMessage()).toString());
        }
    }
}