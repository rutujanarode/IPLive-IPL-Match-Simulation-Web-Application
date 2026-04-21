package com.iplive.servlet;

import com.iplive.util.DBUtil;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;

@WebServlet("/test")
public class TestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/plain");

        try {
            Connection conn = DBUtil.getConnection();
            if (conn != null) {
                res.getWriter().write("Database connection: SUCCESS\n");
                conn.close();
            } else {
                res.getWriter().write("Database connection: FAILED\n");
            }
        } catch (Exception e) {
            res.getWriter().write("Database connection: ERROR - " + e.getMessage() + "\n");
        }

        res.getWriter().write("Application is running!\n");
    }
}