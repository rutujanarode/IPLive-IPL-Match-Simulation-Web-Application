package com.iplive.util;

import com.iplive.model.BallResult;
import com.iplive.model.Match;
import com.iplive.model.Player;

import java.sql.*;
import java.util.List;
import java.util.Random;

/**
 * Core simulation engine — handles ball-by-ball logic.
 * Member 1 owns this file.
 */

public class SimulationEngine {

    private static final Random rand = new Random();

    // Commentary templates
    private static final String[] DOT_COMM = { "Defended solidly back to the bowler.", "Good length ball, no run.",
            "Tight line, batter blocked it.", "Beaten outside off stump.", "Kept out on the back foot." };
    private static final String[] ONE_COMM = { "Pushed to mid-on, quick single taken.", "Dabbed to third man for one.",
            "Worked off the pads for a single.", "Driven to long-off — one run." };
    private static final String[] TWO_COMM = { "Driven to long-off, they ran two!",
            "Pushed to deep mid-wicket, back for two.", "Well-timed drive, easy couple." };
    private static final String[] THREE_COMM = { "Deep fielder made a mess of it — three runs!",
            "Hit hard to the corner, three all the way." };
    private static final String[] FOUR_COMM = { "FOUR! Cracked through the covers!",
            "FOUR! Pulled ferociously over square leg!", "FOUR! Beautiful drive — all along the ground!",
            "FOUR! Cuts behind point, no stopping that!", "FOUR! Flicked off the pads — exquisite!" };
    private static final String[] SIX_COMM = { "SIX! Launched over long-on — massive!",
            "SIX! Pulled flat over mid-wicket!", "SIX! That's gone into the second tier!",
            "SIX! Swept effortlessly over deep square!", "SIX! Maximum! What a clean strike!" };
    private static final String[] WKT_COMM = { "WICKET! Caught at mid-off — gone!",
            "WICKET! Bowled through the gate — timber!", "WICKET! Caught behind — given!",
            "WICKET! LBW — plumb in front!", "WICKET! Stumped! Miles out of the crease!",
            "WICKET! Caught at the boundary — superb take!" };

    /**
     * Simulate one ball. Updates Match state and persists to DB.
     */
    public static BallResult simulateBall(Match match, List<Player> batters, List<Player> bowlers) throws SQLException {
        BallResult result = new BallResult();

        int innings = match.getCurrentInnings();
        int balls = match.getCurrentBalls();
        int wickets = match.getCurrentWickets();
        int striker = match.getStriker();
        int nonStriker = match.getNonStriker();

        Player batsman = batters.get(striker);
        Player bowler = bowlers.get(match.getCurrentBowlerIdx() % bowlers.size());

        // Probability weights
        double battingSkill = batsman.getBattingAvg() / 50.0;
        double bowlingSkill = 1.0 - (bowler.getBowlingAvg() / 50.0);

        int[] weights = computeWeights(battingSkill, bowlingSkill, wickets, balls);
        int outcome = weightedRandom(weights); // 0=dot,1,2,3,4,6,W

        boolean isWicket = (outcome == 6);
        int runs = isWicket ? 0 : (outcome == 5 ? 6 : outcome);
        boolean isFour = (outcome == 4);
        boolean isSix = (outcome == 5);

        // Set result fields
        result.setRuns(runs);
        result.setWicket(isWicket);
        result.setFour(isFour);
        result.setSix(isSix);

        // Commentary
        String comm = buildCommentary(outcome, batsman.getPlayerName(), bowler.getPlayerName());
        result.setCommentary(comm);
        match.addCommentary(comm);

        // Update batter stats
        int[] bRuns = match.getBatterRuns();
        int[] bBalls = match.getBatterBalls();
        if (bRuns != null && striker < bRuns.length) {
            bRuns[striker] += runs;
            bBalls[striker] += 1;
        }

        // Update match state
        if (innings == 1) {
            match.setRuns1(match.getRuns1() + runs);
            match.setBalls1(match.getBalls1() + 1);
            if (isWicket)
                match.setWickets1(match.getWickets1() + 1);
        } else {
            match.setRuns2(match.getRuns2() + runs);
            match.setBalls2(match.getBalls2() + 1);
            if (isWicket)
                match.setWickets2(match.getWickets2() + 1);
        }

        // Rotate strike on odd runs
        if (!isWicket && runs % 2 == 1) {
            match.setStriker(nonStriker);
            match.setNonStriker(striker);
        }

        // Change bowler every over
        int newBalls = match.getCurrentBalls();
        if (newBalls % 6 == 0 && newBalls > 0) {
            match.setCurrentBowlerIdx(match.getCurrentBowlerIdx() + 1);
            // Rotate strike at end of over
            int tmp = match.getStriker();
            match.setStriker(match.getNonStriker());
            match.setNonStriker(tmp);
        }

        // Wicket: bring new batsman
        if (isWicket && match.getCurrentWickets() < 10) {
            int nextBatter = wickets + 2;
            if (nextBatter < batters.size()) {
                match.setStriker(nextBatter);
                if (bRuns != null && nextBatter < bRuns.length) {
                    bRuns[nextBatter] = 0;
                    bBalls[nextBatter] = 0;
                }
            }
        }

        // Persist to DB — pass ball count BEFORE this ball was added so overNo/ballNo
        // are correct
        persistBallToDB(match, result, batsman, bowler, balls);

        // Check innings/match over
        int totalBalls = match.getCurrentBalls();
        int totalWickets = match.getCurrentWickets();

        boolean inningsOver = totalBalls >= 120 || totalWickets >= 10;
        boolean matchOver = false;
        String resultMsg = "";

        if (innings == 2 && !isWicket) {
            // Check if target chased
            if (match.getRuns2() > match.getRuns1()) {
                inningsOver = true;
                matchOver = true;
                int wktsLeft = 10 - match.getWickets2();
                resultMsg = match.getTeamBName() + " won by " + wktsLeft + " wickets!";
                finishMatch(match, match.getTeamBId(), resultMsg);
            }
        }
        if (inningsOver && innings == 1) {
            match.setCurrentInnings(2);
            match.setStriker(0);
            match.setNonStriker(1);
            match.setCurrentBowlerIdx(0);
            match.setBatterRuns(new int[11]);
            match.setBatterBalls(new int[11]);
            resultMsg = "Innings break! " + match.getTeamBName() + " need " + (match.getRuns1() + 1) + " runs to win.";
        }
        if (inningsOver && innings == 2 && !matchOver) {
            matchOver = true;
            if (match.getRuns2() > match.getRuns1()) {
                int wktsLeft = 10 - match.getWickets2();
                resultMsg = match.getTeamBName() + " won by " + wktsLeft + " wickets!";
                finishMatch(match, match.getTeamBId(), resultMsg);
            } else if (match.getRuns1() > match.getRuns2()) {
                int diff = match.getRuns1() - match.getRuns2();
                resultMsg = match.getTeamAName() + " won by " + diff + " runs!";
                finishMatch(match, match.getTeamAId(), resultMsg);
            } else {
                resultMsg = "Match tied!";
                finishMatch(match, null, resultMsg);
            }
        }

        result.setInningsOver(inningsOver);
        result.setMatchOver(matchOver);
        result.setResultMessage(resultMsg);
        result.setTotalRuns(match.getCurrentRuns());
        result.setTotalWickets(match.getCurrentWickets());
        result.setTotalOver(match.getCurrentOver());
        result.setOver(match.getOverString(balls));

        // Batter display
        int[] br = match.getBatterRuns();
        int[] bb = match.getBatterBalls();
        result.setStriker(match.getStriker());
        result.setNonStriker(match.getNonStriker());
        if (br != null) {
            int s = match.getStriker(), ns = match.getNonStriker();
            result.setStrikerRuns(s < br.length ? br[s] : 0);
            result.setStrikerBalls(s < bb.length ? bb[s] : 0);
            result.setNonStrikerRuns(ns < br.length ? br[ns] : 0);
            result.setNonStrikerBalls(ns < bb.length ? bb[ns] : 0);
        }
        if (batters.size() > match.getStriker())
            result.setStrikerName(batters.get(match.getStriker()).getPlayerName());
        if (batters.size() > match.getNonStriker())
            result.setNonStrikerName(batters.get(match.getNonStriker()).getPlayerName());

        return result;
    }

    private static int[] computeWeights(double bat, double bowl, int wkts, int balls) {
        double pressure = 1.0 + (wkts * 0.08) + ((120 - balls) < 30 ? 0.1 : 0);
        int wDot = (int) (20 * bowl * pressure);
        int w1 = (int) (35 * (1 - bowl + bat) / 2);
        int w2 = (int) (15 * bat);
        int w3 = (int) (5 * bat);
        int w4 = (int) (12 * bat);
        int w6 = (int) (8 * bat);
        int wWkt = (int) (Math.max(3, 15 * bowl * pressure));
        return new int[] { Math.max(wDot, 1), Math.max(w1, 1), Math.max(w2, 1), Math.max(w3, 1), Math.max(w4, 1),
                Math.max(w6, 1), Math.max(wWkt, 1) };
    }

    private static int weightedRandom(int[] weights) {
        int total = 0;
        for (int w : weights)
            total += w;
        int r = rand.nextInt(total);
        int sum = 0;
        for (int i = 0; i < weights.length; i++) {
            sum += weights[i];
            if (r < sum)
                return i;
        }
        return 0;
    }

    private static String buildCommentary(int outcome, String batter, String bowler) {
        String[] pool;
        switch (outcome) {
            case 0:
                pool = DOT_COMM;
                break;
            case 1:
                pool = ONE_COMM;
                break;
            case 2:
                pool = TWO_COMM;
                break;
            case 3:
                pool = THREE_COMM;
                break;
            case 4:
                pool = FOUR_COMM;
                break;
            case 5:
                pool = SIX_COMM;
                break;
            default:
                pool = WKT_COMM;
                break;
        }
        String base = pool[rand.nextInt(pool.length)];
        return batter + ": " + base + " (Bowler: " + bowler + ")";
    }

    private static void persistBallToDB(Match match, BallResult res, Player batsman, Player bowler, int ballsBefore) {
        int inningsId = match.getCurrentInnings() == 1 ? match.getInningsId1() : match.getInningsId2();
        if (inningsId == 0)
            return;
        int overNo = ballsBefore / 6;
        int ballNo = (ballsBefore % 6) + 1;
        try (Connection con = DBUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO ball_event(innings_id,over_number,ball_number,batsman_id,bowler_id,runs_scored,is_wicket,commentary) VALUES(?,?,?,?,?,?,?,?)")) {
            ps.setInt(1, inningsId);
            ps.setInt(2, overNo);
            ps.setInt(3, ballNo);
            ps.setInt(4, batsman.getPlayerId());
            ps.setInt(5, bowler.getPlayerId());
            ps.setInt(6, res.getRuns());
            ps.setBoolean(7, res.isWicket());
            ps.setString(8, res.getCommentary());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Persist batting and bowling figures for the current match/innings.
        try (Connection con = DBUtil.getConnection()) {
            upsertBattingStats(con, match.getMatchId(), inningsId, batsman, res.getRuns(), res.isWicket(), res.isFour(), res.isSix());
            upsertBowlingStats(con, match.getMatchId(), inningsId, bowler, res.getRuns(), res.isWicket());
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Update innings totals
        try (Connection con = DBUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "UPDATE innings SET total_runs=?,total_wickets=?,total_balls=? WHERE innings_id=?")) {
            ps.setInt(1, match.getCurrentRuns());
            ps.setInt(2, match.getCurrentWickets());
            ps.setInt(3, match.getCurrentBalls());
            ps.setInt(4, inningsId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void upsertBattingStats(Connection con, int matchId, int inningsId, Player batsman, int runs, boolean isWicket, boolean isFour, boolean isSix) throws SQLException {
        PreparedStatement ps = con.prepareStatement(
                "SELECT stat_id, runs, balls_faced, fours, sixes, is_out, dismissal_type " +
                "FROM batting_stats WHERE match_id=? AND innings_id=? AND player_id=?");
        ps.setInt(1, matchId);
        ps.setInt(2, inningsId);
        ps.setInt(3, batsman.getPlayerId());
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            int statId = rs.getInt("stat_id");
            int existingRuns = rs.getInt("runs");
            int existingBalls = rs.getInt("balls_faced");
            int existingFours = rs.getInt("fours");
            int existingSixes = rs.getInt("sixes");
            boolean wasOut = rs.getBoolean("is_out");
            String dismissal = rs.getString("dismissal_type");
            rs.close(); ps.close();

            String nextDismissal = wasOut ? dismissal : (isWicket ? "Caught" : "not out");
            PreparedStatement update = con.prepareStatement(
                    "UPDATE batting_stats SET runs=?, balls_faced=?, fours=?, sixes=?, is_out=?, dismissal_type=? WHERE stat_id=?");
            update.setInt(1, existingRuns + runs);
            update.setInt(2, existingBalls + 1);
            update.setInt(3, existingFours + (isFour ? 1 : 0));
            update.setInt(4, existingSixes + (isSix ? 1 : 0));
            update.setBoolean(5, wasOut || isWicket);
            update.setString(6, nextDismissal);
            update.setInt(7, statId);
            update.executeUpdate();
            update.close();
        } else {
            rs.close(); ps.close();
            PreparedStatement insert = con.prepareStatement(
                    "INSERT INTO batting_stats(player_id,match_id,innings_id,runs,balls_faced,fours,sixes,is_out,dismissal_type) VALUES(?,?,?,?,?,?,?,?,?)");
            insert.setInt(1, batsman.getPlayerId());
            insert.setInt(2, matchId);
            insert.setInt(3, inningsId);
            insert.setInt(4, runs);
            insert.setInt(5, 1);
            insert.setInt(6, isFour ? 1 : 0);
            insert.setInt(7, isSix ? 1 : 0);
            insert.setBoolean(8, isWicket);
            insert.setString(9, isWicket ? "Caught" : "not out");
            insert.executeUpdate();
            insert.close();
        }
    }

    private static void upsertBowlingStats(Connection con, int matchId, int inningsId, Player bowler, int runs, boolean isWicket) throws SQLException {
        PreparedStatement ps = con.prepareStatement(
                "SELECT stat_id, overs, runs_given, wickets, maidens FROM bowling_stats " +
                "WHERE match_id=? AND innings_id=? AND player_id=?");
        ps.setInt(1, matchId);
        ps.setInt(2, inningsId);
        ps.setInt(3, bowler.getPlayerId());
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            int statId = rs.getInt("stat_id");
            double currentOvers = rs.getDouble("overs");
            int existingRuns = rs.getInt("runs_given");
            int existingWickets = rs.getInt("wickets");
            int existingMaidens = rs.getInt("maidens");
            rs.close(); ps.close();

            double nextOvers = addDeliveryToOvers(currentOvers);
            PreparedStatement update = con.prepareStatement(
                    "UPDATE bowling_stats SET overs=?, runs_given=?, wickets=?, maidens=? WHERE stat_id=?");
            update.setDouble(1, nextOvers);
            update.setInt(2, existingRuns + runs);
            update.setInt(3, existingWickets + (isWicket ? 1 : 0));
            update.setInt(4, existingMaidens); // maidens not computed per delivery currently
            update.setInt(5, statId);
            update.executeUpdate();
            update.close();
        } else {
            rs.close(); ps.close();
            PreparedStatement insert = con.prepareStatement(
                    "INSERT INTO bowling_stats(player_id,match_id,innings_id,overs,runs_given,wickets,maidens) VALUES(?,?,?,?,?,?,?)");
            insert.setInt(1, bowler.getPlayerId());
            insert.setInt(2, matchId);
            insert.setInt(3, inningsId);
            insert.setDouble(4, 0.1);
            insert.setInt(5, runs);
            insert.setInt(6, isWicket ? 1 : 0);
            insert.setInt(7, 0);
            insert.executeUpdate();
            insert.close();
        }
    }

    private static int oversToBalls(double overs) {
        int whole = (int) overs;
        int part = (int) Math.round((overs - whole) * 10);
        return whole * 6 + part;
    }

    private static double ballsToOvers(int balls) {
        int whole = balls / 6;
        int part = balls % 6;
        return Double.parseDouble(whole + "." + part);
    }

    private static double addDeliveryToOvers(double currentOvers) {
        int balls = oversToBalls(currentOvers) + 1;
        return ballsToOvers(balls);
    }

    private static void finishMatch(Match match, Integer winnerTeamId, String msg) {
        match.setStatus("Completed");
        match.setWinnerTeamId(winnerTeamId);
        try (Connection con = DBUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "UPDATE match_tbl SET status='Completed', winner_team_id=? WHERE match_id=?")) {
            if (winnerTeamId != null)
                ps.setInt(1, winnerTeamId);
            else
                ps.setNull(1, Types.INTEGER);
            ps.setInt(2, match.getMatchId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}