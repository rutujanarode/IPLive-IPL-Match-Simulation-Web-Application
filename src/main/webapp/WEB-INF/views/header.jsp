<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <% String ctx=request.getContextPath(); String uri=request.getRequestURI(); String role=(String)
        session.getAttribute("role"); String user=(String) session.getAttribute("username"); %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>IPLive — Real-Time IPL Simulation</title>
            <link rel="stylesheet" href="<%= ctx %>/css/style.css">
        </head>

        <body>

            <nav class="navbar">
                <span class="nav-logo" onclick="location.href='<%= ctx %>/home'">IPLive</span>
                <div class="nav-links">
                    <a href="<%= ctx %>/home" class="<%= uri.contains("/home") ? "active" : "" %>">Home</a>
                    <a href="<%= ctx %>/match" class="<%= uri.contains("/match") ? "active" : "" %>">Live Match</a>
                    <a href="<%= ctx %>/stats" class="<%= uri.contains("/stats") ? "active" : "" %>">Caps &amp;
                        Points</a>
                    <a href="<%= ctx %>/squads" class="<%= uri.contains("/squads") ? "active" : "" %>">Squads</a>
                    <a href="<%= ctx %>/history" class="<%= uri.contains("/history") ? "active" : "" %>">History</a>
                    <a href="<%= ctx %>/fantasy" class="<%= uri.contains("/fantasy") ? "active" : "" %>"
                        style="<%= uri.contains("/fantasy") ? "" : "color:#b464ff;" %>">🎮 Fantasy</a>
                    <% if ("admin".equals(role)) { %>
                        <a href="<%= ctx %>/admin" class="<%= uri.contains("/admin") ? "active" : "" %>">Admin</a>
                        <% } %>
                </div>
                <% if (user !=null) { %>
                    <span style="font-size:12px;color:#888;margin-right:10px">Hi, <%= user %></span>
                    <a href="<%= ctx %>/logout" style="font-size:12px;color:#f08080;">Logout</a>
                    <% } else { %>
                        <button class="nav-btn" onclick="location.href='<%= ctx %>/login'">Login</button>
                        <% } %>
            </nav>