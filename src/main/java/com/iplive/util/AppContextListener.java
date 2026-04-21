package com.iplive.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Application startup listener to verify database connectivity and other resources
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("=== IPLive Application Starting ===");
        
        try (Connection conn = DBUtil.getConnection()) {
            if (conn != null) {
                System.out.println("✓ Database connection successful");
                boolean needsSeed = false;
                try {
                    needsSeed = DBUtil.isDatabaseIncomplete(conn);
                } catch (SQLException e) {
                    // Tables don't exist yet, seed the database
                    needsSeed = true;
                }
                
                if (needsSeed) {
                    System.out.println("⚠️ Database appears incomplete. Seeding missing data from schema.sql...");
                    DBUtil.seedDatabase(sce.getServletContext(), conn);
                    System.out.println("✓ Database schema seeding completed.");
                }
            }
        } catch (Exception e) {
            System.err.println("✗ Database connection failed: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to connect to database during startup", e);
        }
        
        System.out.println("=== IPLive Application Started Successfully ===");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("=== IPLive Application Stopped ===");
    }
}
