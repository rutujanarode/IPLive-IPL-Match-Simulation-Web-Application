# 🏏 IPLive — IPL Match Simulation Web Application

> A Java Full Stack Mini Project built with Servlets, JSP, MySQL, and AJAX — simulating IPL cricket matches ball-by-ball in real time.

---

##  Team
Rutuja Narode
Tejal Kunde
Aarya Patil

---

##  About the Project

**IPLive** is a web-based IPL match simulation system that provides an interactive, ball-by-ball cricket experience. Unlike traditional platforms that only display static scores or live streaming, IPLive enables users to simulate matches with real-time updates, dynamic commentary, and detailed player statistics.

The system uses a custom-built simulation engine to generate match events and provides a highly engaging and dynamic user experience.

---

##  Features

*  Ball-by-ball live match simulation (with auto-play)
*  Real-time score updates using AJAX
*  Dynamic commentary generation
*  Player profiles with detailed statistics
*  Orange Cap & Purple Cap leaderboards
*  Complete match scorecards
*  Admin panel (manage teams, players, matches)
*  Fantasy Point Arena
*  Match history tracking

---

##  Tech Stack

| Layer      | Technology                   |
| ---------- | ---------------------------- |
| Frontend   | HTML, CSS, JavaScript (AJAX) |
| Backend    | Java Servlets, JSP           |
| Server     | Apache Tomcat                |
| Database   | MySQL (JDBC)                 |
| Build Tool | Maven                        |
| Language   | Java                         |

---

##  Project Structure

```
IPLive/
├── pom.xml                          # Maven build configuration
├── build.bat / build.ps1            # Quick-start scripts (Windows)
├── src/
│   └── main/
│       ├── java/com/iplive/
│       │   ├── model/               # Data models
│       │   │   ├── BallResult.java
│       │   │   ├── Match.java
│       │   │   ├── Player.java
│       │   │   └── Team.java
│       │   ├── servlet/             # Java Servlets (controllers)
│       │   │   ├── HomeServlet.java
│       │   │   ├── MatchServlet.java
│       │   │   ├── BallServlet.java
│       │   │   ├── ScorecardServlet.java
│       │   │   ├── PlayerServlet.java
│       │   │   ├── StatsServlet.java
│       │   │   ├── SquadsServlet.java
│       │   │   ├── FantasyServlet.java
│       │   │   ├── HistoryServlet.java
│       │   │   ├── AdminServlet.java
│       │   │   ├── LoginServlet.java
│       │   │   └── LogoutServlet.java
│       │   └── util/                # Utility classes
│       │       ├── DBUtil.java      # JDBC connection helper
│       │       ├── SimulationEngine.java  # Core ball simulation logic
│       │       ├── FantasyEngine.java     # Fantasy points calculator
│       │       ├── PlayerImageUtil.java
│       │       └── AppContextListener.java
│       └── webapp/
│           ├── index.jsp            # Entry point (redirects to /home)
│           ├── css/style.css        # Global styles
│           ├── js/match.js          # AJAX match simulation logic
│           └── WEB-INF/
│               ├── schema.sql       # Full database schema + seed data
│               └── views/           # JSP view templates
│                   ├── home.jsp
│                   ├── liveMatch.jsp
│                   ├── selectMatch.jsp
│                   ├── scorecard.jsp
│                   ├── playerProfile.jsp
│                   ├── fantasy.jsp
│                   ├── fantasyPlayer.jsp
│                   ├── squads.jsp (via SquadsServlet)
│                   ├── history.jsp
│                   ├── admin.jsp
│                   ├── login.jsp
│                   └── header.jsp
```

---

##  Database Setup

1. Open MySQL
2. Run:

```
src/main/webapp/WEB-INF/schema.sql
```

3. Update credentials in:

```
DBUtil.java
```

---

##  How to Run

```bash
git clone https://github.com/rutujanarode/IPLive-IPL-Match-Simulation-Web-Application.git
cd IPLive
mvn clean package tomcat7:run
```

Then open:

```
http://localhost:8081/IPLive
```

---

##  Admin Login

| Username | Password |
| -------- | -------- |
| admin    | admin123 |

---

##  Architecture

* Presentation Layer → JSP, HTML, CSS, JS
* Application Layer → Servlets + Simulation Engine
* Data Layer → MySQL

**Workflow:**

1. User selects match
2. Clicks “Next Ball”
3. Servlet processes request
4. Simulation engine generates result
5. Database updated
6. UI updates using AJAX

---

---

##  Future Scope

* AI-based match prediction
* Advanced analytics
* Fantasy platform integration
* Mobile UI improvements
* Enhanced security

---

##  Conclusion

This project demonstrates full-stack development using core Java technologies without relying on modern frameworks, focusing on backend logic, database integration, and real-time UI updates.

---

If you like this project, consider giving it a star!
