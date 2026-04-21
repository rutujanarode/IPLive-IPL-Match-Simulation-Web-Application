package com.iplive.util;

import java.sql.*;
import java.util.*;

/**
 * IPLive Fantasy Points Engine
 *
 * Point System:
 * ─────────────────────────────────────────────────
 * BATTING
 *   +1  per run scored
 *   +1  per four hit
 *   +2  per six hit
 *   +8  for 50-run milestone
 *   +16 for 100-run milestone
 *   -2  duck (0 runs, got out)
 *   SR bonus (min 10 balls): >170 SR → +6, >150 → +4, >130 → +2
 *   SR penalty: <50 SR → -6, <70 → -4, <100 → -2
 *
 * BOWLING
 *   +25 per wicket
 *   +8  for 3-wicket haul
 *   +16 for 5-wicket haul
 *   +1  per dot ball (estimated: (overs*6 - hits) *0.4)
 *   Economy bonus (min 2 overs): <5 → +6, <6 → +4, <7 → +2
 *   Economy penalty: >10 → -6, >9 → -4, >8 → -2
 *
 * GENERAL
 *   +4  playing XI (always given)
 * ─────────────────────────────────────────────────
 */
public class FantasyEngine {

    // ─── Compute & persist fantasy points for a completed match ───────────
    public static void computeAndSaveMatchPoints(int matchId) {
        try (Connection conn = DBUtil.getConnection()) {
            computeBattingPoints(conn, matchId);
            computeBowlingPoints(conn, matchId);
            grantPlayingPoints(conn, matchId);
            rebuildSeasonRank(conn);
            grantBadges(conn, matchId);
        } catch (SQLException e) {
            System.err.println("FantasyEngine error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ─── Batting points ────────────────────────────────────────────────────
    private static void computeBattingPoints(Connection conn, int matchId) throws SQLException {
        String sql = "SELECT bs.player_id, bs.innings_id, " +
            "bs.runs, bs.balls_faced, bs.fours, bs.sixes, bs.is_out " +
            "FROM batting_stats bs " +
            "WHERE bs.match_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, matchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int pid       = rs.getInt("player_id");
                    int inningsId = rs.getInt("innings_id");
                    int runs      = rs.getInt("runs");
                    int balls     = rs.getInt("balls_faced");
                    int fours     = rs.getInt("fours");
                    int sixes     = rs.getInt("sixes");
                    boolean isOut = rs.getBoolean("is_out");

                    int runPts  = runs;
                    int bndPts  = fours + (sixes * 2);
                    int milePts = 0;
                    if (runs >= 100)      milePts = 16;
                    else if (runs >= 50)  milePts = 8;
                    else if (runs == 0 && isOut) milePts = -2; // duck

                    int srPts = 0;
                    if (balls >= 10) {
                        double sr = runs * 100.0 / balls;
                        if      (sr > 170) srPts =  6;
                        else if (sr > 150) srPts =  4;
                        else if (sr > 130) srPts =  2;
                        else if (sr < 50)  srPts = -6;
                        else if (sr < 70)  srPts = -4;
                        else if (sr < 100) srPts = -2;
                    }

                    int total = runPts + bndPts + milePts + srPts;
                    upsertFantasyPoints(conn, pid, matchId, inningsId,
                            runPts, bndPts, milePts, srPts, 0, 0, 0, 0, 4, total);
                }
            }
        }
    }

    // ─── Bowling points ────────────────────────────────────────────────────
    private static void computeBowlingPoints(Connection conn, int matchId) throws SQLException {
        String sql = "SELECT bw.player_id, bw.innings_id, " +
            "bw.overs, bw.runs_given, bw.wickets " +
            "FROM bowling_stats bw " +
            "WHERE bw.match_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, matchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int pid       = rs.getInt("player_id");
                    int inningsId = rs.getInt("innings_id");
                    double overs  = rs.getDouble("overs");
                    int runsGiven = rs.getInt("runs_given");
                    int wickets   = rs.getInt("wickets");

                    int wickPts = wickets * 25;
                    int haulPts = 0;
                    if      (wickets >= 5) haulPts = 16;
                    else if (wickets >= 3) haulPts = 8;

                    // Estimate dot balls from overs & runs
                    int ballsBowled = (int)(Math.floor(overs) * 6 + (overs % 1) * 10);
                    int dotPts = (int)(Math.max(0, ballsBowled - runsGiven) * 0.4);

                    int econPts = 0;
                    if (overs >= 2) {
                        double econ = runsGiven / overs;
                        if      (econ < 5)  econPts =  6;
                        else if (econ < 6)  econPts =  4;
                        else if (econ < 7)  econPts =  2;
                        else if (econ > 10) econPts = -6;
                        else if (econ > 9)  econPts = -4;
                        else if (econ > 8)  econPts = -2;
                    }

                    int total = wickPts + haulPts + dotPts + econPts;

                    // Merge with existing batting pts for same player/match
                    mergeFantasyBowling(conn, pid, matchId, inningsId,
                            wickPts, dotPts, haulPts, econPts, total);
                }
            }
        }
    }

    // ─── +4 playing pts for anyone who batted or bowled ───────────────────
    private static void grantPlayingPoints(Connection conn, int matchId) throws SQLException {
        // playing_pts is already set to 4 in upsert; this handles edge case
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE fantasy_points SET total_pts = run_pts+boundary_pts+fifty_pts+sr_pts+" +
                "wicket_pts+dot_pts+haul_pts+economy_pts+playing_pts WHERE match_id=?")) {
            ps.setInt(1, matchId);
            ps.executeUpdate();
        }
    }

    // ─── Rebuild season leaderboard ───────────────────────────────────────
    public static void rebuildSeasonRank(Connection conn) throws SQLException {
        // Truncate & rebuild
        try (Statement st = conn.createStatement()) {
            st.execute("DELETE FROM season_fantasy_rank");
        }
        String insertSql = "INSERT INTO season_fantasy_rank (player_id, total_fantasy_pts, matches_played, avg_pts) " +
            "SELECT fp.player_id, " +
            "SUM(fp.total_pts) AS total_pts, " +
            "COUNT(DISTINCT fp.match_id) AS matches, " +
            "ROUND(SUM(fp.total_pts)*1.0 / COUNT(DISTINCT fp.match_id), 1) AS avg " +
            "FROM fantasy_points fp " +
            "GROUP BY fp.player_id";
        try (Statement st = conn.createStatement()) {
            st.execute(insertSql);
        }
        // Assign rank positions
        try (Statement st = conn.createStatement()) {
            st.execute("SET @r=0; " +
                "UPDATE season_fantasy_rank " +
                "SET rank_pos = (@r := @r + 1) " +
                "ORDER BY total_fantasy_pts DESC");
        } catch (SQLException ignored) {
            // fallback: set ranks in Java
            String sel = "SELECT player_id FROM season_fantasy_rank ORDER BY total_fantasy_pts DESC";
            try (PreparedStatement upd = conn.prepareStatement(
                    "UPDATE season_fantasy_rank SET rank_pos=? WHERE player_id=?");
                 Statement st2 = conn.createStatement();
                 ResultSet rs = st2.executeQuery(sel)) {
                int rank = 1;
                while (rs.next()) {
                    upd.setInt(1, rank++);
                    upd.setInt(2, rs.getInt(1));
                    upd.executeUpdate();
                }
            }
        }
    }

    // ─── Grant achievement badges ─────────────────────────────────────────
    private static void grantBadges(Connection conn, int matchId) throws SQLException {
        // Century Club
        grantBadgeForBatters(conn, matchId, "century_club",
                "SELECT bs.player_id FROM batting_stats bs WHERE bs.match_id=? AND bs.runs>=100");
        // Six Machine (5+ sixes in match)
        grantBadgeForBatters(conn, matchId, "six_machine",
                "SELECT bs.player_id FROM batting_stats bs WHERE bs.match_id=? AND bs.sixes>=5");
        // Hat-trick Hero (3+ wickets)
        grantBadgeForBatters(conn, matchId, "hat_trick_hero",
                "SELECT bw.player_id FROM bowling_stats bw WHERE bw.match_id=? AND bw.wickets>=3");
        // Five-fer
        grantBadgeForBatters(conn, matchId, "five_for",
                "SELECT bw.player_id FROM bowling_stats bw WHERE bw.match_id=? AND bw.wickets>=5");
        // All-Rounder Elite: 30+ runs AND 2+ wickets same match
        grantBadgeForBatters(conn, matchId, "all_rounder",
                "SELECT bs.player_id FROM batting_stats bs " +
                "JOIN bowling_stats bw ON bs.player_id=bw.player_id AND bs.match_id=bw.match_id " +
                "WHERE bs.match_id=? AND bs.runs>=30 AND bw.wickets>=2");
        // Top scorer of match
        grantTopScorer(conn, matchId);
        // Season badges (MVP, Orange Cap, Purple Cap, Iron Man)
        grantSeasonBadges(conn);
    }

    private static void grantBadgeForBatters(Connection conn, int matchId, String achKey, String playerSql) throws SQLException {
        int achId = getAchId(conn, achKey);
        if (achId < 0) return;
        try (PreparedStatement ps = conn.prepareStatement(playerSql)) {
            ps.setInt(1, matchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    insertBadge(conn, rs.getInt(1), achId, matchId);
                }
            }
        }
    }

    private static void grantTopScorer(Connection conn, int matchId) throws SQLException {
        int achId = getAchId(conn, "top_scorer");
        if (achId < 0) return;
        String sql = "SELECT player_id FROM fantasy_points WHERE match_id=? ORDER BY total_pts DESC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, matchId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) insertBadge(conn, rs.getInt(1), achId, matchId);
            }
        }
    }

    private static void grantSeasonBadges(Connection conn) throws SQLException {
        // MVP – highest season pts
        grantTopSeasonBadge(conn, "mvp",
                "SELECT player_id FROM season_fantasy_rank ORDER BY total_fantasy_pts DESC LIMIT 1");
        // Orange Cap – top runs
        grantTopSeasonBadge(conn, "orange_cap",
                "SELECT player_id FROM season_batting_stats ORDER BY runs DESC LIMIT 1");
        // Purple Cap – top wickets
        grantTopSeasonBadge(conn, "purple_cap",
                "SELECT player_id FROM season_bowling_stats ORDER BY wickets DESC LIMIT 1");
        // Iron Man – 14+ matches played in fantasy
        int achId = getAchId(conn, "iron_man");
        if (achId >= 0) {
            String sql = "SELECT player_id FROM season_fantasy_rank WHERE matches_played>=14";
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sql)) {
                while (rs.next()) insertBadge(conn, rs.getInt(1), achId, null);
            }
        }
    }

    private static void grantTopSeasonBadge(Connection conn, String achKey, String playerSql) throws SQLException {
        int achId = getAchId(conn, achKey);
        if (achId < 0) return;
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(playerSql)) {
            if (rs.next()) insertBadge(conn, rs.getInt(1), achId, null);
        }
    }

    private static int getAchId(Connection conn, String key) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT ach_id FROM achievement_def WHERE ach_key=?")) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    private static void insertBadge(Connection conn, int playerId, int achId, Integer matchId) throws SQLException {
        String sql = "INSERT IGNORE INTO player_badge (player_id, ach_id, match_id) VALUES (?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, playerId);
            ps.setInt(2, achId);
            if (matchId != null) ps.setInt(3, matchId); else ps.setNull(3, Types.INTEGER);
            ps.executeUpdate();
        }
    }

    // ─── Upsert helpers ───────────────────────────────────────────────────
    private static void upsertFantasyPoints(Connection conn,
            int pid, int matchId, int inningsId,
            int runPts, int bndPts, int milePts, int srPts,
            int wickPts, int dotPts, int haulPts, int econPts,
            int playPts, int total) throws SQLException {
        String sql = "INSERT INTO fantasy_points " +
            "(player_id,match_id,innings_id,run_pts,boundary_pts,fifty_pts,sr_pts, " +
            "wicket_pts,dot_pts,haul_pts,economy_pts,playing_pts,total_pts) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?) " +
            "ON DUPLICATE KEY UPDATE " +
            "run_pts=VALUES(run_pts), boundary_pts=VALUES(boundary_pts), " +
            "fifty_pts=VALUES(fifty_pts), sr_pts=VALUES(sr_pts), " +
            "playing_pts=VALUES(playing_pts), " +
            "total_pts=total_pts - run_pts - boundary_pts - fifty_pts - sr_pts + VALUES(run_pts)+VALUES(boundary_pts)+VALUES(fifty_pts)+VALUES(sr_pts)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pid);      ps.setInt(2, matchId);   ps.setInt(3, inningsId);
            ps.setInt(4, runPts);   ps.setInt(5, bndPts);    ps.setInt(6, milePts);
            ps.setInt(7, srPts);    ps.setInt(8, wickPts);   ps.setInt(9, dotPts);
            ps.setInt(10, haulPts); ps.setInt(11, econPts);  ps.setInt(12, playPts);
            ps.setInt(13, total);
            ps.executeUpdate();
        }
    }

    private static void mergeFantasyBowling(Connection conn,
            int pid, int matchId, int inningsId,
            int wickPts, int dotPts, int haulPts, int econPts, int addTotal) throws SQLException {
        // Try update existing row first
        String upd = "UPDATE fantasy_points " +
            "SET wicket_pts=wicket_pts+?, dot_pts=dot_pts+?, " +
            "haul_pts=haul_pts+?, economy_pts=economy_pts+?, " +
            "total_pts=total_pts+? " +
            "WHERE player_id=? AND match_id=?";
        try (PreparedStatement ps = conn.prepareStatement(upd)) {
            ps.setInt(1, wickPts); ps.setInt(2, dotPts);
            ps.setInt(3, haulPts); ps.setInt(4, econPts); ps.setInt(5, addTotal);
            ps.setInt(6, pid);     ps.setInt(7, matchId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                // No batting row – insert fresh
                upsertFantasyPoints(conn, pid, matchId, inningsId,
                        0, 0, 0, 0, wickPts, dotPts, haulPts, econPts, 4, addTotal + 4);
            }
        }
    }

    // ─── Public helpers for Servlet ───────────────────────────────────────

    /** Top N players by season fantasy points */
    public static List<Map<String,Object>> getSeasonLeaderboard(Connection conn, int limit) throws SQLException {
        String sql = "SELECT sfr.rank_pos, sfr.total_fantasy_pts, sfr.matches_played, sfr.avg_pts, " +
            "p.player_id, p.player_name, p.role, " +
            "t.team_name, t.short_code, t.color_hex " +
            "FROM season_fantasy_rank sfr " +
            "JOIN player p ON p.player_id = sfr.player_id " +
            "JOIN team t ON t.team_id = p.team_id " +
            "ORDER BY sfr.total_fantasy_pts DESC " +
            "LIMIT ?";
        List<Map<String,Object>> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("rank",      rs.getInt("rank_pos"));
                    row.put("playerId",  rs.getInt("player_id"));
                    row.put("name",      rs.getString("player_name"));
                    row.put("role",      rs.getString("role"));
                    row.put("team",      rs.getString("team_name"));
                    row.put("code",      rs.getString("short_code"));
                    row.put("color",     rs.getString("color_hex"));
                    row.put("pts",       rs.getInt("total_fantasy_pts"));
                    row.put("matches",   rs.getInt("matches_played"));
                    row.put("avg",       rs.getDouble("avg_pts"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    /** Fantasy points breakdown for a player across all matches */
    public static List<Map<String,Object>> getPlayerMatchPoints(Connection conn, int playerId) throws SQLException {
        String sql = "SELECT fp.match_id, fp.total_pts, " +
            "fp.run_pts, fp.boundary_pts, fp.fifty_pts, fp.sr_pts, " +
            "fp.wicket_pts, fp.dot_pts, fp.haul_pts, fp.economy_pts, " +
            "mt.match_date, " +
            "ta.short_code AS teamA, tb.short_code AS teamB " +
            "FROM fantasy_points fp " +
            "JOIN match_tbl mt ON mt.match_id = fp.match_id " +
            "JOIN team ta ON ta.team_id = mt.team_a_id " +
            "JOIN team tb ON tb.team_id = mt.team_b_id " +
            "WHERE fp.player_id=? " +
            "ORDER BY mt.match_date DESC";
        List<Map<String,Object>> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, playerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("matchId",    rs.getInt("match_id"));
                    row.put("totalPts",   rs.getInt("total_pts"));
                    row.put("runPts",     rs.getInt("run_pts"));
                    row.put("bndPts",     rs.getInt("boundary_pts"));
                    row.put("milePts",    rs.getInt("fifty_pts"));
                    row.put("srPts",      rs.getInt("sr_pts"));
                    row.put("wickPts",    rs.getInt("wicket_pts"));
                    row.put("dotPts",     rs.getInt("dot_pts"));
                    row.put("haulPts",    rs.getInt("haul_pts"));
                    row.put("econPts",    rs.getInt("economy_pts"));
                    row.put("date",       rs.getString("match_date"));
                    row.put("vs",         rs.getString("teamA") + " vs " + rs.getString("teamB"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    /** Badges earned by a player */
    public static List<Map<String,Object>> getPlayerBadges(Connection conn, int playerId) throws SQLException {
        String sql = "SELECT ad.title, ad.description, ad.icon, ad.category, pb.earned_at " +
            "FROM player_badge pb " +
            "JOIN achievement_def ad ON ad.ach_id = pb.ach_id " +
            "WHERE pb.player_id=? " +
            "ORDER BY pb.earned_at DESC";
        List<Map<String,Object>> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, playerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("title",    rs.getString("title"));
                    row.put("desc",     rs.getString("description"));
                    row.put("icon",     rs.getString("icon"));
                    row.put("category", rs.getString("category"));
                    row.put("earnedAt", rs.getString("earned_at"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    /** Per-match top fantasy scorer */
    public static List<Map<String,Object>> getMatchFantasyToppers(Connection conn, int limit) throws SQLException {
        String sql = "SELECT fp.match_id, fp.total_pts, " +
            "p.player_name, t.short_code, " +
            "ta.short_code AS teamA, tb.short_code AS teamB, " +
            "mt.match_date " +
            "FROM fantasy_points fp " +
            "JOIN player p ON p.player_id = fp.player_id " +
            "JOIN team t ON t.team_id = p.team_id " +
            "JOIN match_tbl mt ON mt.match_id = fp.match_id " +
            "JOIN team ta ON ta.team_id = mt.team_a_id " +
            "JOIN team tb ON tb.team_id = mt.team_b_id " +
            "WHERE (fp.match_id, fp.total_pts) IN ( " +
            "SELECT match_id, MAX(total_pts) FROM fantasy_points GROUP BY match_id " +
            ") " +
            "ORDER BY mt.match_date DESC " +
            "LIMIT ?";
        List<Map<String,Object>> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("matchId",  rs.getInt("match_id"));
                    row.put("pts",      rs.getInt("total_pts"));
                    row.put("player",   rs.getString("player_name"));
                    row.put("teamCode", rs.getString("short_code"));
                    row.put("vs",       rs.getString("teamA") + " vs " + rs.getString("teamB"));
                    row.put("date",     rs.getString("match_date"));
                    list.add(row);
                }
            }
        }
        return list;
    }
}