package com.iplive.servlet;

import com.iplive.model.Player;
import com.iplive.model.Team;
import com.iplive.util.DBUtil;
import com.iplive.util.PlayerImageUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

public class SquadsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Map<Team, List<Player>> squads = new LinkedHashMap<>();
        try (Connection con = DBUtil.getConnection()) {
            if (isSquadDataIncomplete(con)) {
                seedSquadData(req, con);
            }

            ResultSet rs = con.createStatement().executeQuery("SELECT * FROM team ORDER BY team_name");
            List<Team> teams = new ArrayList<>();
            while (rs.next()) {
                teams.add(new Team(rs.getInt("team_id"), rs.getString("team_name"),
                        rs.getString("short_code"), rs.getString("home_ground"), rs.getString("color_hex")));
            }
            rs.close();

            Map<Integer, List<Player>> playersByTeam = new HashMap<>();
            rs = con.createStatement().executeQuery("SELECT * FROM player ORDER BY role, player_name");
            while (rs.next()) {
                Player p = new Player();
                p.setPlayerId(rs.getInt("player_id"));
                p.setPlayerName(rs.getString("player_name"));
                p.setRole(rs.getString("role"));
                String imageUrl = rs.getString("image_url");
                p.setImageUrl(PlayerImageUtil.resolvePlayerImage(imageUrl, p.getPlayerName()));
                p.setTeamId(rs.getInt("team_id"));
                playersByTeam.computeIfAbsent(p.getTeamId(), k -> new ArrayList<>()).add(p);
            }
            rs.close();

            for (Team t : teams) {
                squads.put(t, playersByTeam.getOrDefault(t.getTeamId(), new ArrayList<>()));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        req.setAttribute("squads", squads);
        req.getRequestDispatcher("/WEB-INF/views/squads.jsp").forward(req, res);
    }

    /**
     * Returns true if ANY team has fewer than 10 players — indicating incomplete
     * seeding.
     * This is more reliable than a global count, because partial seeding can leave
     * some teams empty while others are fully populated.
     */
    private boolean isSquadDataIncomplete(Connection con) throws SQLException {
        try (Statement stmt = con.createStatement()) {
            // Check total player count first (fast path)
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM player");
            int playerCount = 0;
            if (rs.next())
                playerCount = rs.getInt(1);
            rs.close();

            if (playerCount < 100)
                return true; // clearly incomplete

            // Also check if any team has zero players (per-team check)
            rs = stmt.executeQuery(
                    "SELECT t.team_id FROM team t " +
                            "LEFT JOIN player p ON t.team_id = p.team_id " +
                            "GROUP BY t.team_id " +
                            "HAVING COUNT(p.player_id) = 0");
            boolean hasEmptyTeam = rs.next();
            rs.close();
            return hasEmptyTeam;
        }
    }

    private void seedSquadData(HttpServletRequest req, Connection con) {
        try (InputStream in = req.getServletContext().getResourceAsStream("/WEB-INF/schema.sql")) {
            if (in == null) {
                System.err.println("⚠️ squads servlet: schema.sql not found in WEB-INF");
                return;
            }
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
                StringBuilder sqlBuilder = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    String trimmed = line.trim();
                    // Skip empty lines and full-line comments
                    if (trimmed.isEmpty() || trimmed.startsWith("--") || trimmed.startsWith("#")) {
                        continue;
                    }
                    // Strip inline comments from the end of the line
                    int inlineComment = findInlineCommentStart(trimmed);
                    if (inlineComment >= 0) {
                        trimmed = trimmed.substring(0, inlineComment).trim();
                    }
                    if (trimmed.isEmpty())
                        continue;

                    sqlBuilder.append(trimmed).append(' ');

                    if (trimmed.endsWith(";")) {
                        String sql = sqlBuilder.toString().trim();
                        // Remove trailing semicolon
                        sql = sql.substring(0, sql.length() - 1).trim();
                        sqlBuilder.setLength(0);
                        if (!sql.isEmpty()) {
                            executeSchemaStatement(con, sql);
                        }
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("⚠️ squads servlet: failed to read schema.sql: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Finds the start of an inline SQL comment (--) that is NOT inside a string
     * literal.
     * Returns -1 if no inline comment is found.
     */
    private int findInlineCommentStart(String line) {
        boolean inString = false;
        for (int i = 0; i < line.length() - 1; i++) {
            char c = line.charAt(i);
            if (c == '\'' && (i == 0 || line.charAt(i - 1) != '\\')) {
                inString = !inString;
            }
            if (!inString && c == '-' && line.charAt(i + 1) == '-') {
                return i;
            }
        }
        return -1;
    }

    private void executeSchemaStatement(Connection con, String sql) {
        String normalized = sql.trim();
        String upper = normalized.toUpperCase(Locale.ROOT);

        // Only process INSERT and CREATE statements; skip USE, CREATE DATABASE etc.
        if (upper.startsWith("USE ") || upper.startsWith("CREATE DATABASE")) {
            return;
        }

        // Convert INSERT INTO → INSERT IGNORE INTO to skip duplicate-key errors
        if (upper.startsWith("INSERT INTO ")) {
            normalized = "INSERT IGNORE INTO " + normalized.substring("INSERT INTO ".length());
        }

        try (Statement stmt = con.createStatement()) {
            stmt.execute(normalized);
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                return; // duplicate entry — safe to ignore
            }
            System.err.println("⚠️ squads servlet: failed SQL ["
                    + normalized.substring(0, Math.min(80, normalized.length())) + "...]: " + e.getMessage());
        }
    }
}