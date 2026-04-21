package com.iplive.util;

import javax.servlet.ServletContext;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Locale;

public class DBUtil {

    private static final String URL = "jdbc:mysql://localhost:3306/iplive?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASSWORD = "R@98r#abc"; // Change to your MySQL password

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public static boolean isDatabaseIncomplete(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            // Check if essential tables exist
            String[] requiredTables = {"team", "player", "match_tbl", "batting_stats", "bowling_stats", 
                                       "fantasy_points", "season_fantasy_rank", "achievement_def", "player_badge"};
            
            for (String table : requiredTables) {
                try {
                    stmt.executeQuery("SELECT 1 FROM " + table + " LIMIT 1");
                } catch (SQLException e) {
                    // Table doesn't exist, database is incomplete
                    return true;
                }
            }
            
            // Check data completeness
            int teamCount = 0;
            int playerCount = 0;
            int matchCount = 0;

            var rs = stmt.executeQuery("SELECT COUNT(*) FROM team");
            if (rs.next())
                teamCount = rs.getInt(1);
            rs.close();

            rs = stmt.executeQuery("SELECT COUNT(*) FROM player");
            if (rs.next())
                playerCount = rs.getInt(1);
            rs.close();

            rs = stmt.executeQuery("SELECT COUNT(*) FROM match_tbl");
            if (rs.next())
                matchCount = rs.getInt(1);
            rs.close();

            return teamCount < 10 || playerCount < 150 || matchCount < 5;
        }
    }

    public static void seedDatabase(ServletContext context, Connection conn) {
        try (InputStream in = context.getResourceAsStream("/WEB-INF/schema.sql")) {
            if (in == null) {
                System.err.println("✗ schema.sql not found in WEB-INF");
                return;
            }
            
            // Read entire file as string
            StringBuilder fileContent = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    String trimmed = line.trim();
                    // Skip whole-line comments and empty lines
                    if (trimmed.isEmpty() || trimmed.startsWith("--") || trimmed.startsWith("#")) {
                        continue;
                    }
                    // Remove inline comments starting with --
                    int commentIndex = trimmed.indexOf("--");
                    if (commentIndex >= 0) {
                        trimmed = trimmed.substring(0, commentIndex).trim();
                    }
                    if (!trimmed.isEmpty()) {
                        fileContent.append(" ").append(trimmed);
                    }
                }
            }
            
            // Split by semicolon and execute each statement
            String[] statements = fileContent.toString().split(";");
            for (String statement : statements) {
                String sql = statement.trim();
                
                // Skip empty statements and whitespace-only statements
                if (sql.isEmpty() || sql.length() < 5) {
                    continue;
                }
                
                // Skip USE database statements (we're already connected to the right DB)
                if (sql.toUpperCase(Locale.ROOT).startsWith("USE ")) {
                    continue;
                }
                
                executeSchemaStatement(conn, sql);
            }
        } catch (IOException e) {
            System.err.println("✗ Failed to read schema.sql: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void executeSchemaStatement(Connection conn, String sql) {
        String normalized = sql.trim();
        
        // Skip empty statements
        if (normalized.isEmpty()) {
            return;
        }
        
        String upper = normalized.toUpperCase(Locale.ROOT);
        
        // Convert INSERT INTO to INSERT IGNORE
        if (upper.startsWith("INSERT INTO ")) {
            normalized = "INSERT IGNORE " + normalized.substring("INSERT INTO ".length());
        }
        
        try (Statement stmt = conn.createStatement()) {
            stmt.execute(normalized);
            
            // Log successful CREATE TABLE statements
            if (upper.startsWith("CREATE TABLE")) {
                String tableName = extractTableName(normalized);
                if (tableName != null) {
                    System.out.println("✓ Created table: " + tableName);
                }
            }
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                // Duplicate key error - ignore silently (already exists)
                return;
            }
            
            // Check for table already exists error (error code 1050)
            if (e.getErrorCode() == 1050) {
                // Table already exists - this is fine
                return;
            }
            
            // For syntax errors on CREATE TABLE, log them but continue
            if (upper.startsWith("CREATE TABLE")) {
                String tableName = extractTableName(normalized);
                System.err.println("✗ Failed to create table " + tableName + ": " + e.getMessage());
            }
            // Silently ignore other errors
        }
    }
    
    private static String extractTableName(String sql) {
        String upper = sql.toUpperCase(Locale.ROOT);
        int createIdx = upper.indexOf("CREATE TABLE");
        if (createIdx == -1) return null;
        
        int start = createIdx + 12; // "CREATE TABLE".length()
        String rest = sql.substring(start).trim();
        
        // Handle "IF NOT EXISTS"
        if (rest.toUpperCase(Locale.ROOT).startsWith("IF NOT EXISTS")) {
            rest = rest.substring(13).trim();
        }
        
        // Get table name (first word)
        int spaceIdx = rest.indexOf(' ');
        int parenIdx = rest.indexOf('(');
        int endIdx = Math.min(
            spaceIdx == -1 ? Integer.MAX_VALUE : spaceIdx,
            parenIdx == -1 ? Integer.MAX_VALUE : parenIdx
        );
        
        if (endIdx == Integer.MAX_VALUE) return null;
        return rest.substring(0, endIdx).trim().replaceAll("`", "");
    }

    public static void close(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try {
                    r.close();
                } catch (Exception ignored) {
                }
            }
        }
    }
}