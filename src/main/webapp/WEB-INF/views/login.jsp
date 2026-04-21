<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%  
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IPLive — Login</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<div class="login-wrap">
    <div class="login-card">
        <div class="login-logo">
            <div class="logo-text">IPLive</div>
            <div class="logo-sub">Real-Time IPL Simulation Platform</div>
        </div>

        <% if (error != null) { %>
        <div class="error-msg"><%= error %></div>
        <% } %>

        <form method="post" action="<%= ctx %>/login">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" placeholder="Enter username" required autofocus>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" placeholder="Enter password" required>
            </div>
            <button type="submit" class="form-submit">Login</button>
        </form>

        <p style="text-align:center;font-size:12px;color:#666;margin-top:16px">
            Default admin: <span style="color:#f5c518">admin / admin123</span>
        </p>
        <p style="text-align:center;font-size:12px;margin-top:8px">
            <a href="<%= ctx %>/home" style="color:#5ab4ff">Continue without login →</a>
        </p>
    </div>
</div>
</body></html>
