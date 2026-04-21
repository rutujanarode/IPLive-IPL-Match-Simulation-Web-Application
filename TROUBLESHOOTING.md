# IPLive Tomcat Startup Error - Troubleshooting Guide

## Error Message
```
java.lang.IllegalArgumentException: The servlets named [MatchServlet] and
[com.iplive.servlet.MatchServlet] are both mapped to the url-pattern [/match]
```

## Root Cause Analysis

This error occurs when Tomcat finds duplicate servlet mappings. The issue was:
- **MatchServlet** had `@WebServlet({ "/match", "/nextBall" })` annotation
- **web.xml** also mapped MatchServlet to `/match`
- **BallServlet** was mapped to `/nextball` in web.xml

## Fixes Applied

### 1. **Removed Duplicate Servlet Mapping**
   - ✅ Removed `@WebServlet` annotation from MatchServlet.java
   - ✅ Kept web.xml mappings: MatchServlet → `/match`, BallServlet → `/nextball`

### 2. **Fixed Match Initialization**
   - ✅ Added innings creation in `initInnings()` method
   - ✅ Now creates innings record in database when match starts

### 3. **Fixed Player Data Loading**
   - ✅ Updated `getPlayers()` to load `batting_avg` and `bowling_avg` from database
   - ✅ These values are required for ball simulation logic

### 4. **Added Test Endpoint**
   - ✅ Created `/test` endpoint to verify database connectivity
   - ✅ Visit `http://localhost:8081/IPLive/test` to check if app is working

---

## Current Servlet Mappings

| Servlet | URL Pattern | Method | Purpose |
|---------|-------------|--------|---------|
| MatchServlet | `/match` | GET | Load match page |
| BallServlet | `/nextball` | POST | Simulate next ball (AJAX) |
| TestServlet | `/test` | GET | Test database connection |

---

## Testing the Fix

1. **Start the application:**
   ```bash
   mvn clean install
   mvn tomcat7:run
   ```

2. **Test database connection:**
   - Visit: `http://localhost:8081/IPLive/test`
   - Should show: "Database connection: SUCCESS"

3. **Test match simulation:**
   - Go to home page and select a match
   - Click "Bowl Next Ball" button
   - Should update scores, commentary, and batter stats

---

## If Still Not Working

### Check Browser Console (F12)
- Look for JavaScript errors
- Check Network tab for failed AJAX requests

### Check Tomcat Logs
```bash
# Look in target/tomcat7x/logs/
tail -f target/tomcat7x/logs/catalina.out
```

### Common Issues
1. **Database not running** → Start MySQL service
2. **No data in database** → Run schema.sql
3. **Port conflict** → Change port in pom.xml
4. **Session timeout** → Refresh match page

---

## Debug Steps

1. **Verify MySQL is running:**
   ```sql
   mysql -u root -p -e "SHOW DATABASES;"
   ```

2. **Check if iplive database exists:**
   ```sql
   USE iplive; SHOW TABLES;
   ```

3. **Test player loading:**
   ```sql
   SELECT COUNT(*) FROM player;
   ```

4. **Check match status:**
   ```sql
   SELECT match_id, status FROM match_tbl;
   ```
