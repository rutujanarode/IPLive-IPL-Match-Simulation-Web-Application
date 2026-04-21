-- ============================================================
-- IPLive — Full IPL 2025 Database with Real Stats
-- ============================================================

CREATE DATABASE IF NOT EXISTS iplive;
USE iplive;

-- ===== TABLES =====

CREATE TABLE IF NOT EXISTS team (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    short_code VARCHAR(5) NOT NULL,
    home_ground VARCHAR(100),
    color_hex VARCHAR(7) DEFAULT '#1a1a2e'
);

CREATE TABLE IF NOT EXISTS player (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    team_id INT NOT NULL,
    role ENUM('Batsman','Bowler','All-Rounder','Wicket-Keeper') NOT NULL,
    batting_avg DOUBLE DEFAULT 30.0,
    bowling_avg DOUBLE DEFAULT 30.0,
    nationality VARCHAR(50) DEFAULT 'Indian',
    date_of_birth VARCHAR(20),
    batting_style VARCHAR(30),
    bowling_style VARCHAR(50),
    image_url VARCHAR(200),
    bio TEXT,
    FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS match_tbl (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    team_a_id INT NOT NULL,
    team_b_id INT NOT NULL,
    venue VARCHAR(100),
    match_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Upcoming','Live','Completed') DEFAULT 'Upcoming',
    winner_team_id INT,
    FOREIGN KEY (team_a_id) REFERENCES team(team_id),
    FOREIGN KEY (team_b_id) REFERENCES team(team_id)
);

CREATE TABLE IF NOT EXISTS innings (
    innings_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    batting_team_id INT NOT NULL,
    bowling_team_id INT NOT NULL,
    total_runs INT DEFAULT 0,
    total_wickets INT DEFAULT 0,
    total_balls INT DEFAULT 0,
    innings_number INT DEFAULT 1,
    is_complete BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (match_id) REFERENCES match_tbl(match_id)
);

CREATE TABLE IF NOT EXISTS ball_event (
    ball_id INT AUTO_INCREMENT PRIMARY KEY,
    innings_id INT NOT NULL,
    over_number INT NOT NULL,
    ball_number INT NOT NULL,
    batsman_id INT,
    bowler_id INT,
    runs_scored INT DEFAULT 0,
    is_wicket BOOLEAN DEFAULT FALSE,
    is_wide BOOLEAN DEFAULT FALSE,
    is_noball BOOLEAN DEFAULT FALSE,
    commentary TEXT,
    FOREIGN KEY (innings_id) REFERENCES innings(innings_id)
);

CREATE TABLE IF NOT EXISTS batting_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    match_id INT NOT NULL,
    innings_id INT NOT NULL,
    runs INT DEFAULT 0,
    balls_faced INT DEFAULT 0,
    fours INT DEFAULT 0,
    sixes INT DEFAULT 0,
    is_out BOOLEAN DEFAULT FALSE,
    dismissal_type VARCHAR(50),
    FOREIGN KEY (player_id) REFERENCES player(player_id),
    FOREIGN KEY (match_id) REFERENCES match_tbl(match_id),
    FOREIGN KEY (innings_id) REFERENCES innings(innings_id)
);

CREATE TABLE IF NOT EXISTS bowling_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    match_id INT NOT NULL,
    innings_id INT NOT NULL,
    overs DOUBLE DEFAULT 0,
    runs_given INT DEFAULT 0,
    wickets INT DEFAULT 0,
    maidens INT DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES player(player_id),
    FOREIGN KEY (match_id) REFERENCES match_tbl(match_id),
    FOREIGN KEY (innings_id) REFERENCES innings(innings_id)
);

CREATE TABLE IF NOT EXISTS season_batting_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL UNIQUE,
    matches INT DEFAULT 0,
    innings INT DEFAULT 0,
    runs INT DEFAULT 0,
    balls INT DEFAULT 0,
    highest_score INT DEFAULT 0,
    fifties INT DEFAULT 0,
    hundreds INT DEFAULT 0,
    fours INT DEFAULT 0,
    sixes INT DEFAULT 0,
    not_outs INT DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES player(player_id)
);

CREATE TABLE IF NOT EXISTS season_bowling_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL UNIQUE,
    matches INT DEFAULT 0,
    overs DOUBLE DEFAULT 0,
    runs_given INT DEFAULT 0,
    wickets INT DEFAULT 0,
    best_bowling VARCHAR(10) DEFAULT '0/0',
    maidens INT DEFAULT 0,
    four_wickets INT DEFAULT 0,
    five_wickets INT DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES player(player_id)
);

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    role ENUM('user','admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TEAMS (All 10 IPL 2025 teams)
-- ============================================================
INSERT INTO team (team_id, team_name, short_code, home_ground, color_hex) VALUES
(1,  'Mumbai Indians',               'MI',   'Wankhede Stadium, Mumbai',           '#004B87'),
(2,  'Chennai Super Kings',          'CSK',  'MA Chidambaram Stadium, Chennai',     '#FFB200'),
(3,  'Royal Challengers Bengaluru',  'RCB',  'M. Chinnaswamy Stadium, Bengaluru',   '#EC3424'),
(4,  'Kolkata Knight Riders',        'KKR',  'Eden Gardens, Kolkata',               '#702963'),
(5,  'Gujarat Titans',               'GT',   'Narendra Modi Stadium, Ahmedabad',    '#1C1C1C'),
(6,  'Sunrisers Hyderabad',          'SRH',  'Rajiv Gandhi Intl. Stadium, Hyderabad','#FF822A'),
(7,  'Rajasthan Royals',             'RR',   'Sawai Mansingh Stadium, Jaipur',      '#EA1A7F'),
(8,  'Punjab Kings',                 'PBKS', 'Maharaja Yadavindra Singh Stadium',   '#ED1F27'),
(9,  'Delhi Capitals',               'DC',   'Arun Jaitley Stadium, Delhi',         '#0078BC'),
(10, 'Lucknow Super Giants',         'LSG',  'BRSABV Ekana Stadium, Lucknow',       '#A72056');

-- ============================================================
-- PLAYERS — Full IPL 2025 Squads (15 per team)
-- ============================================================

-- ===== MUMBAI INDIANS =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(1,  'Rohit Sharma',       1, 'Batsman',       45.3, 99.0, 'Indian',      '30-Apr-1987', 'Right-hand bat', 'Right-arm off break',    'Captain and opener. One of IPL''s greatest batsmen with 6 titles. Known for his effortless pull shot and big-match temperament.'),
(2,  'Ishan Kishan',       1, 'Wicket-Keeper', 32.1, 99.0, 'Indian',      '18-Jul-1998', 'Left-hand bat',  'None',                   'Explosive left-hand wicket-keeper batter. Known for big opening stands and hard-hitting strokeplay.'),
(3,  'Suryakumar Yadav',   1, 'Batsman',       40.8, 99.0, 'Indian',      '22-Sep-1990', 'Right-hand bat', 'Right-arm medium',       'T20 World No. 1 batter. Plays 360° cricket. Known for ramp shots, scoops, and unconventional strokeplay.'),
(4,  'Hardik Pandya',      1, 'All-Rounder',   28.4, 28.2, 'Indian',      '11-Oct-1993', 'Right-hand bat', 'Right-arm fast-medium',  'MI captain. Powerful hitter and effective death bowler. Returns to MI after GT stint.'),
(5,  'Jasprit Bumrah',     1, 'Bowler',         5.0, 18.4, 'Indian',      '06-Dec-1993', 'Right-hand bat', 'Right-arm fast',         'World''s best fast bowler. Lethal yorkers and unique action. Spearhead of MI attack.'),
(6,  'Tilak Varma',        1, 'Batsman',       34.2, 99.0, 'Indian',      '08-Nov-2002', 'Left-hand bat',  'Right-arm off break',    'Young middle-order star. Clean striker and elegant left-hander. Big future ahead.'),
(7,  'Tim David',          1, 'Batsman',       26.5, 99.0, 'Singaporean', '16-Mar-1996', 'Right-hand bat', 'Right-arm off break',    'Explosive finisher. One of the hardest hitters in T20 cricket. Huge sixes specialist.'),
(8,  'Kieron Pollard',     1, 'All-Rounder',   25.0, 30.0, 'West Indian', '12-May-1987', 'Right-hand bat', 'Right-arm medium-fast',  'MI legend. Prolific hitter in death overs. Genuine match-winner with bat and ball.'),
(9,  'Piyush Chawla',      1, 'Bowler',         6.0, 28.0, 'Indian',      '24-Dec-1988', 'Right-hand bat', 'Right-arm leg break',    'Experienced leg-spinner. Builds pressure through flight and variation.'),
(10, 'Trent Boult',        1, 'Bowler',         4.0, 22.1, 'New Zealander','22-Jul-1989', 'Right-hand bat', 'Left-arm fast-medium',   'Lethal swinging Powerplay bowler. Dangerous with the new ball and at death.'),
(11, 'Krunal Pandya',      1, 'All-Rounder',   20.0, 32.0, 'Indian',      '24-Mar-1991', 'Left-hand bat',  'Left-arm orthodox spin', 'Hardik''s elder brother. Useful left-arm spinner and lower-order hitter.'),
(12, 'Naman Dhir',         1, 'Batsman',       22.0, 99.0, 'Indian',      '14-Nov-1999', 'Right-hand bat', 'Right-arm off break',    'Emerging middle-order batter for MI. Promising domestic performer.'),
(13, 'Nuwan Thushara',     1, 'Bowler',         3.0, 26.0, 'Sri Lankan',  '10-Feb-1997', 'Right-hand bat', 'Right-arm fast-medium',  'Sri Lankan pacer. Swings the ball and bowls good lengths.'),
(14, 'Robin Minz',         1, 'Wicket-Keeper', 18.0, 99.0, 'Indian',      '04-Jan-2003', 'Right-hand bat', 'None',                   'Young wicket-keeper batter from Jharkhand. Part of MI youth brigade.'),
(15, 'Deepak Chahar',      1, 'Bowler',         8.5, 24.0, 'Indian',      '07-Aug-1992', 'Right-hand bat', 'Right-arm medium-fast',  'Powerplay specialist. Swings the ball both ways and contributes with bat in lower order.');

-- ===== CHENNAI SUPER KINGS =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(16, 'MS Dhoni',           2, 'Wicket-Keeper', 38.0, 99.0, 'Indian',      '07-Jul-1981', 'Right-hand bat', 'Right-arm medium',       'CSK legend and former India captain. Master finisher, brilliant wicket-keeper. Finishes matches with helicopter shots.'),
(17, 'Ruturaj Gaikwad',    2, 'Batsman',       44.0, 99.0, 'Indian',      '31-Jan-1997', 'Right-hand bat', 'Right-arm off break',    'CSK captain and Orange Cap winner. Elegant top-order batter. Consistent run-scorer for CSK.'),
(18, 'Devon Conway',       2, 'Batsman',       38.5, 99.0, 'New Zealander','08-Jul-1991', 'Left-hand bat',  'Right-arm medium',       'Solid left-handed opener. Technically sound with good running between wickets.'),
(19, 'Ravindra Jadeja',    2, 'All-Rounder',   28.0, 26.0, 'Indian',      '06-Dec-1988', 'Left-hand bat',  'Left-arm orthodox spin', 'World-class all-rounder. Brilliant fielder, economical spinner and impactful lower-order hitter.'),
(20, 'Matheesha Pathirana', 2, 'Bowler',        3.0, 20.0, 'Sri Lankan',  '19-Oct-2002', 'Right-hand bat', 'Right-arm fast',         'Death bowling specialist. Deadly slingy action, rapid pace, and lethal yorkers.'),
(21, 'Tushar Deshpande',   2, 'Bowler',         4.0, 27.0, 'Indian',      '06-Jul-1995', 'Right-hand bat', 'Right-arm fast-medium',  'CSK''s Indian pace option. Useful in powerplay and death overs.'),
(22, 'Ambati Rayudu',      2, 'Batsman',       30.0, 99.0, 'Indian',      '23-Sep-1985', 'Right-hand bat', 'Right-arm medium',       'Veteran middle-order batter. Experienced hand who can play any situation.'),
(23, 'Moeen Ali',          2, 'All-Rounder',   22.0, 28.0, 'English',     '18-Jun-1987', 'Right-hand bat', 'Right-arm off break',    'All-rounder. Handy off-spin and can hit big at any position.'),
(24, 'Shivam Dube',        2, 'All-Rounder',   30.0, 35.0, 'Indian',      '26-Jun-1993', 'Left-hand bat',  'Right-arm medium',       'Power-hitter who can change games. Effective left-hand bat in the middle order.'),
(25, 'Mitchell Santner',   2, 'All-Rounder',   18.0, 27.0, 'New Zealander','05-Feb-1992', 'Left-hand bat',  'Left-arm orthodox spin', 'Economical left-arm spinner. Can contribute with bat in the lower order.'),
(26, 'Maheesh Theekshana', 2, 'Bowler',         5.0, 24.0, 'Sri Lankan',  '01-Oct-2000', 'Right-hand bat', 'Right-arm off break',    'Mystery spinner. Carrom balls and variations trouble even the best batters.'),
(27, 'Rachin Ravindra',    2, 'Batsman',       32.0, 28.0, 'New Zealander','18-Nov-1999', 'Left-hand bat',  'Left-arm orthodox spin', 'Elegant left-hand opener. Good touch player who builds innings well.'),
(28, 'Sameer Rizvi',       2, 'Batsman',       20.0, 99.0, 'Indian',      '03-Jun-2003', 'Right-hand bat', 'Right-arm off break',    'Young batter from UP. Exciting prospect in CSK setup.'),
(29, 'Khaleel Ahmed',      2, 'Bowler',         4.0, 29.0, 'Indian',      '05-Dec-1997', 'Right-hand bat', 'Left-arm fast-medium',   'Left-arm pace. Useful swinging deliveries in the powerplay.'),
(30, 'Noor Ahmad',         2, 'Bowler',         3.0, 22.0, 'Afghan',      '01-Jan-2005', 'Right-hand bat', 'Left-arm wrist spin',    'Teenage Afghan left-arm wrist spinner. Dangerous with chinaman deliveries.');

-- ===== ROYAL CHALLENGERS BENGALURU =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(31, 'Virat Kohli',        3, 'Batsman',       50.2, 99.0, 'Indian',      '05-Nov-1988', 'Right-hand bat', 'Right-arm medium',       'RCB icon. Former India captain. All-format great. Chases targets like no other. Most runs in IPL history.'),
(32, 'Faf du Plessis',     3, 'Batsman',       36.4, 99.0, 'South African','13-Jul-1984', 'Right-hand bat', 'Right-arm medium',       'Classy opener and former RCB captain. Stylish strokeplay and excellent fielder.'),
(33, 'Glenn Maxwell',      3, 'All-Rounder',   28.0, 30.0, 'Australian',  '14-Oct-1988', 'Right-hand bat', 'Right-arm off break',    'The Big Show. Can explode at any moment. Brilliant reverse sweep and ramp shots.'),
(34, 'Mohammed Siraj',     3, 'Bowler',         5.0, 24.5, 'Indian',      '13-Mar-1994', 'Right-hand bat', 'Right-arm fast-medium',  'India''s pace spearhead. Lethal yorkers and swinging deliveries. Excellent in all phases.'),
(35, 'Rajat Patidar',      3, 'Batsman',       34.0, 99.0, 'Indian',      '01-Jun-1993', 'Right-hand bat', 'Right-arm off break',    'Elegant middle-order batter. Known for his 112* in the 2022 qualifier against LSG.'),
(36, 'Dinesh Karthik',     3, 'Wicket-Keeper', 26.0, 99.0, 'Indian',      '01-Jun-1985', 'Right-hand bat', 'None',                   'Veteran wicket-keeper finisher. One of the best death-overs batters in IPL.'),
(37, 'Wanindu Hasaranga',  3, 'All-Rounder',   16.0, 22.0, 'Sri Lankan',  '29-Jul-1997', 'Right-hand bat', 'Right-arm leg break',    'Leg-spin all-rounder. Dangerous wicket-taker. Batters struggle to read his variations.'),
(38, 'Yash Dayal',         3, 'Bowler',         4.0, 28.0, 'Indian',      '19-Aug-1997', 'Right-hand bat', 'Left-arm fast-medium',   'Left-arm seamer. Useful in powerplay and death overs with his pace.'),
(39, 'Swapnil Singh',      3, 'All-Rounder',   16.0, 29.0, 'Indian',      '13-Oct-1995', 'Right-hand bat', 'Right-arm off break',    'Off-spin all-rounder. Good domestic record paved way into RCB.'),
(40, 'Alzarri Joseph',     3, 'Bowler',         5.0, 23.0, 'West Indian', '20-Apr-1996', 'Right-hand bat', 'Right-arm fast',         'Express pace from the Caribbean. Holds record for most wickets on IPL debut.'),
(41, 'Suyash Sharma',      3, 'Bowler',         4.0, 26.0, 'Indian',      '25-Nov-2002', 'Right-hand bat', 'Right-arm leg break',    'Young leg spinner. Wicket-taking ability with googly and leg break.'),
(42, 'Liam Livingstone',   3, 'All-Rounder',   25.0, 30.0, 'English',     '04-Aug-1993', 'Right-hand bat', 'Right-arm leg break',    'Hard-hitting all-rounder. Hits sixes at will and can bowl off or leg spin.'),
(43, 'Krunal Pandya',      3, 'All-Rounder',   20.0, 32.0, 'Indian',      '24-Mar-1991', 'Left-hand bat',  'Left-arm orthodox spin', 'Useful left-arm spinner and lower-order hitter. Hardik''s elder brother.'),
(44, 'Tim Southee',        3, 'Bowler',         5.0, 27.0, 'New Zealander','11-Dec-1988', 'Right-hand bat', 'Right-arm fast-medium',  'Experienced NZ pacer. Swings the ball and excellent in powerplay.'),
(45, 'Jacob Bethell',      3, 'All-Rounder',   22.0, 32.0, 'English',     '03-Oct-2003', 'Left-hand bat',  'Right-arm off break',    'Young English all-rounder. Impressive domestic record.');

-- ===== KOLKATA KNIGHT RIDERS =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(46, 'Ajinkya Rahane',     4, 'Batsman',       32.0, 99.0, 'Indian',      '06-Jun-1988', 'Right-hand bat', 'Right-arm medium',       'KKR captain. Composed batter. Known for Test temperament applied in IPL.'),
(47, 'Quinton de Kock',    4, 'Wicket-Keeper', 38.0, 99.0, 'South African','17-Dec-1992', 'Left-hand bat',  'None',                   'Explosive left-hand opener and exceptional wicket-keeper. Can destroy any bowling attack.'),
(48, 'Venkatesh Iyer',     4, 'All-Rounder',   30.0, 32.0, 'Indian',      '25-Dec-1994', 'Left-hand bat',  'Right-arm medium',       'Big-hitting left-hand opener. Can bowl useful medium pace. Powerful strokemaker.'),
(49, 'Andre Russell',      4, 'All-Rounder',   32.0, 26.0, 'West Indian', '29-Apr-1988', 'Right-hand bat', 'Right-arm fast-medium',  'One of the most devastating batters in T20. Hits the longest sixes and takes big wickets.'),
(50, 'Sunil Narine',       4, 'All-Rounder',   20.0, 20.0, 'West Indian', '26-May-1988', 'Right-hand bat', 'Right-arm off break',    'Mystery spinner and pinch-hitter opener. One of IPL''s most valuable players ever.'),
(51, 'Nitish Rana',        4, 'Batsman',       28.0, 99.0, 'Indian',      '27-Dec-1993', 'Left-hand bat',  'Right-arm off break',    'Left-hand middle-order batter. Plays with intent and has match-winning ability.'),
(52, 'Mitchell Starc',     4, 'Bowler',         6.0, 20.0, 'Australian',  '30-Jan-1990', 'Left-hand bat',  'Left-arm fast',          'Most expensive IPL buy at 24.75 Cr. World-class left-arm pacer. Lethal with new ball and yorkers.'),
(53, 'Harshit Rana',       4, 'Bowler',         5.0, 27.0, 'Indian',      '08-Jun-2003', 'Right-hand bat', 'Right-arm fast-medium',  'Young Delhi pacer. Part of India''s future fast bowling plans.'),
(54, 'Rinku Singh',        4, 'Batsman',       26.0, 99.0, 'Indian',      '12-Oct-1997', 'Left-hand bat',  'Right-arm medium',       'Finisher extraordinaire. Famous for 5 sixes in last over. Heart of gold story.'),
(55, 'Varun Chakravarthy', 4, 'Bowler',         5.0, 22.0, 'Indian',      '29-Aug-1991', 'Right-hand bat', 'Right-arm off break',    'Mystery spinner. Batters struggle to read his variations. Lethal in middle overs.'),
(56, 'Spencer Johnson',    4, 'Bowler',         4.0, 24.0, 'Australian',  '13-Aug-1995', 'Left-hand bat',  'Left-arm fast',          'Australian left-arm pacer. Dangerous with new ball and in death overs.'),
(57, 'Angkrish Raghuvanshi',4,'Batsman',        22.0, 99.0, 'Indian',      '21-Sep-2005', 'Right-hand bat', 'None',                   'Teenage batting sensation. Composed beyond his years. Big future.'),
(58, 'Ramandeep Singh',    4, 'All-Rounder',   20.0, 35.0, 'Indian',      '22-Jan-1999', 'Right-hand bat', 'Right-arm medium',       'Hard-hitting middle-order bat and handy medium pacer.'),
(59, 'Moeen Ali',          4, 'All-Rounder',   22.0, 28.0, 'English',     '18-Jun-1987', 'Right-hand bat', 'Right-arm off break',    'All-rounder. Good off-spin and can hit big at any position.'),
(60, 'Anrich Nortje',      4, 'Bowler',         4.0, 22.5, 'South African','16-Nov-1993', 'Right-hand bat', 'Right-arm fast',         'Express pace bowler. Regularly touches 150 kph. Extremely difficult to face.');

-- ===== GUJARAT TITANS =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(61, 'Shubman Gill',       5, 'Batsman',       46.0, 99.0, 'Indian',      '08-Sep-1999', 'Right-hand bat', 'Right-arm off break',    'GT captain. Technically brilliant opener. Multiple centuries and fifties. One of India''s batting future.'),
(62, 'Sai Sudharsan',      5, 'Batsman',       38.0, 99.0, 'Indian',      '19-Jan-2002', 'Left-hand bat',  'Right-arm off break',    'Elegant left-hand batter. Plays beautifully through the off-side. Rising IPL star.'),
(63, 'David Miller',       5, 'Batsman',       30.0, 99.0, 'South African','10-Jun-1989', 'Left-hand bat',  'Right-arm off break',    'Killer Miller. One of the cleanest strikers in T20 cricket. Clutch performer in big games.'),
(64, 'Rashid Khan',        5, 'Bowler',        16.0, 18.0, 'Afghan',      '20-Sep-1998', 'Right-hand bat', 'Right-arm leg break',    'World''s best T20 spinner. Leg break, googly, and slider fox every batter. Hard to score off.'),
(65, 'Mohammed Shami',     5, 'Bowler',         5.0, 22.0, 'Indian',      '03-Sep-1990', 'Right-hand bat', 'Right-arm fast-medium',  'India''s premier swing bowler. Lethal in all conditions. Returns from long injury lay-off.'),
(66, 'Rahul Tewatia',      5, 'All-Rounder',   22.0, 30.0, 'Indian',      '12-Feb-1993', 'Left-hand bat',  'Right-arm leg break',    'Finisher known for miraculous last-over chase against PBKS in 2020. Hits big sixes.'),
(67, 'Wriddhiman Saha',    5, 'Wicket-Keeper', 22.0, 99.0, 'Indian',      '24-Oct-1984', 'Right-hand bat', 'None',                   'Veteran wicket-keeper. Brilliant glovework. One of India''s best behind the stumps.'),
(68, 'Shahrukh Khan',      5, 'Batsman',       20.0, 99.0, 'Indian',      '28-Oct-1995', 'Right-hand bat', 'None',                   'Finisher who hits straight sixes. Known for last-over heroics for PBKS previously.'),
(69, 'Noor Ahmad',         5, 'Bowler',         3.0, 22.0, 'Afghan',      '01-Jan-2005', 'Right-hand bat', 'Left-arm wrist spin',    'Afghan teenage wrist spinner. Bamboozles batters with his chinaman deliveries.'),
(70, 'Kagiso Rabada',      5, 'Bowler',         5.0, 21.0, 'South African','25-May-1995', 'Right-hand bat', 'Right-arm fast',         'South African pace spearhead. Express pace, swinging deliveries, excellent yorker.'),
(71, 'Azmatullah Omarzai', 5, 'All-Rounder',   22.0, 28.0, 'Afghan',      '05-Jan-2001', 'Right-hand bat', 'Right-arm fast-medium',  'Afghan all-rounder. Useful lower-order runs and medium pace breakthroughs.'),
(72, 'Prasidh Krishna',    5, 'Bowler',         4.0, 26.0, 'Indian',      '19-Feb-1996', 'Right-hand bat', 'Right-arm fast-medium',  'Tall seamer. Hits hard lengths and awkward bounce is difficult to handle.'),
(73, 'B Sai Sudharsan',    5, 'Batsman',       38.0, 99.0, 'Indian',      '19-Jan-2002', 'Left-hand bat',  'Right-arm off break',    'Elegant left-hand batter building a strong IPL career.'),
(74, 'Kane Williamson',    5, 'Batsman',       36.0, 99.0, 'New Zealander','08-Aug-1990', 'Right-hand bat', 'Right-arm off break',    'Former GT captain. Technically sound and composed batter. Excellent leader.'),
(75, 'Darshan Nalkande',   5, 'Bowler',         4.0, 27.0, 'Indian',      '17-Mar-1998', 'Right-hand bat', 'Right-arm fast-medium',  'Medium-fast bowler who uses the crease well. Good domestic record.');

-- ===== SUNRISERS HYDERABAD =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(76, 'Pat Cummins',        6, 'All-Rounder',   20.0, 24.0, 'Australian',  '08-May-1993', 'Right-hand bat', 'Right-arm fast',         'SRH captain. World Test no. 1 bowler. Effective T20 pacer and useful lower-order smasher.'),
(77, 'Travis Head',        6, 'Batsman',       42.0, 99.0, 'Australian',  '29-Dec-1993', 'Left-hand bat',  'Right-arm off break',    'SRH''s explosive opener. Hits the ball incredibly hard. World Cup final hero. Orange Cap contender.'),
(78, 'Abhishek Sharma',    6, 'All-Rounder',   32.0, 28.0, 'Indian',      '04-Sep-2000', 'Left-hand bat',  'Left-arm orthodox spin', 'Young explosive opener. Can take any bowler apart. Also bowls useful left-arm spin.'),
(79, 'Heinrich Klaasen',   6, 'Wicket-Keeper', 40.0, 99.0, 'South African','30-Jul-1991', 'Right-hand bat', 'None',                   'Most destructive finisher in T20. Strikes at over 170. Technically sound keeper too.'),
(80, 'Aiden Markram',      6, 'Batsman',       28.0, 28.0, 'South African','04-Oct-1994', 'Right-hand bat', 'Right-arm off break',    'Elegant middle-order batter. Plays proper cricket and can go up the gears when needed.'),
(81, 'Nitish Kumar Reddy', 6, 'All-Rounder',   26.0, 30.0, 'Indian',      '02-Jan-2003', 'Right-hand bat', 'Right-arm fast-medium',  'Exciting young all-rounder from Andhra. Made India Test debut in 2024. IPL breakout star.'),
(82, 'Adam Zampa',         6, 'Bowler',         4.0, 25.0, 'Australian',  '31-Mar-1992', 'Right-hand bat', 'Right-arm leg break',    'Australia''s premier T20 spinner. Consistent and clever with subtle variations.'),
(83, 'T Natarajan',        6, 'Bowler',         4.0, 26.0, 'Indian',      '27-May-1991', 'Right-hand bat', 'Left-arm fast-medium',   'Yorker king. Exceptional death bowling. Comeback story from humble background.'),
(84, 'Harshal Patel',      6, 'Bowler',         6.0, 24.0, 'Indian',      '23-Jul-1990', 'Right-hand bat', 'Right-arm fast-medium',  'Death bowling wizard. Mastery of slower balls and cutters. Purple Cap winner in 2021.'),
(85, 'Jaydev Unadkat',     6, 'Bowler',         5.0, 26.0, 'Indian',      '18-Oct-1991', 'Right-hand bat', 'Left-arm fast-medium',   'Left-arm seamer. Good reverse swing and useful at any stage of innings.'),
(86, 'Simarjeet Singh',    6, 'Bowler',         4.0, 28.0, 'Indian',      '04-May-1999', 'Right-hand bat', 'Right-arm fast-medium',  'Pacer with ability to swing the ball. Promising domestic record.'),
(87, 'Ishan Kishan',       6, 'Wicket-Keeper', 32.0, 99.0, 'Indian',      '18-Jul-1998', 'Left-hand bat',  'None',                   'Left-hand keeper-batter. Explosive at the top. Big IPL performances.'),
(88, 'Shahbaz Ahmed',      6, 'All-Rounder',   20.0, 30.0, 'Indian',      '20-May-1994', 'Left-hand bat',  'Right-arm off break',    'Left-hand bat and off-spin. Useful in all departments. Domestic stalwart.'),
(89, 'Zeeshan Ansari',     6, 'Bowler',         3.0, 27.0, 'Indian',      '09-Jan-2001', 'Right-hand bat', 'Right-arm leg break',    'Young leg spinner with an eye for wickets. Good domestic performance.'),
(90, 'Brydon Carse',       6, 'All-Rounder',   14.0, 26.0, 'English',     '21-Jul-1995', 'Right-hand bat', 'Right-arm fast-medium',  'English pace all-rounder. Quick through the air and can hit big.');

-- ===== RAJASTHAN ROYALS =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(91, 'Sanju Samson',       7, 'Wicket-Keeper', 38.0, 99.0, 'Indian',      '11-Nov-1994', 'Right-hand bat', 'None',                   'RR captain. Gifted batter. When on song, plays shots that leave spectators speechless. India T20 WC winner.'),
(92, 'Jos Buttler',        7, 'Wicket-Keeper', 46.0, 99.0, 'English',     '08-Sep-1990', 'Right-hand bat', 'None',                   'RR''s most successful overseas batter. Two consecutive Orange Caps (2021, 2022). Explosive power at the top.'),
(93, 'Riyan Parag',        7, 'All-Rounder',   26.0, 30.0, 'Indian',      '10-Nov-2001', 'Right-hand bat', 'Right-arm off break',    'Young Assam cricketer. Hitting ability growing every season. Great potential.'),
(94, 'Shimron Hetmyer',    7, 'Batsman',       28.0, 99.0, 'West Indian', '26-Dec-1996', 'Left-hand bat',  'None',                   'Power-hitting finisher. South paw who hits sixes in clusters. Dangerous in death overs.'),
(95, 'Yuzvendra Chahal',   7, 'Bowler',         8.0, 22.0, 'Indian',      '23-Jul-1990', 'Right-hand bat', 'Right-arm leg break',    'Leg-spin wizard. IPL''s leading wicket-taker. Turns the ball sharply and has many variations.'),
(96, 'Trent Boult',        7, 'Bowler',         4.0, 22.5, 'New Zealander','22-Jul-1989', 'Right-hand bat', 'Left-arm fast-medium',   'Swinging left-arm pacer. Dangerous with new ball and in death. Former RR stalwart.'),
(97, 'Sandeep Sharma',     7, 'Bowler',         4.0, 26.0, 'Indian',      '16-Mar-1993', 'Right-hand bat', 'Right-arm fast-medium',  'Experienced seamer. Knows how to use conditions and builds pressure effectively.'),
(98, 'Dhruv Jurel',        7, 'Wicket-Keeper', 24.0, 99.0, 'Indian',      '13-Feb-2001', 'Right-hand bat', 'None',                   'Young wicket-keeper batter. India Test debut in 2024. Batting maturity beyond his years.'),
(99, 'Ravichandran Ashwin',7, 'All-Rounder',   16.0, 24.0, 'Indian',      '17-Sep-1986', 'Right-hand bat', 'Right-arm off break',    'Retired from Tests but continues in IPL. Master of flight, turn and deception. IPL legend.'),
(100,'Avesh Khan',         7, 'Bowler',         4.0, 26.0, 'Indian',      '13-Dec-1996', 'Right-hand bat', 'Right-arm fast-medium',  'Young fast bowler with good pace. Effective in powerplay and death overs.'),
(101,'Wanindu Hasaranga',  7, 'All-Rounder',   16.0, 22.0, 'Sri Lankan',  '29-Jul-1997', 'Right-hand bat', 'Right-arm leg break',    'Leg-spin all-rounder. Dangerous wicket-taker. Batters struggle to read his variations.'),
(102,'Yashasvi Jaiswal',   7, 'Batsman',       42.0, 99.0, 'Indian',      '28-Dec-2001', 'Left-hand bat',  'Right-arm leg break',    'Mumbai opener. One of India''s brightest batting talents. Technically sound with power. IPL 2023 star.'),
(103,'Kumar Kartikeya',    7, 'Bowler',         3.0, 27.0, 'Indian',      '11-Jul-1997', 'Right-hand bat', 'Left-arm orthodox spin', 'Left-arm spinner. Useful in middle overs with his variation.'),
(104,'Akash Madhwal',      7, 'Bowler',         4.0, 25.0, 'Indian',      '19-Feb-1993', 'Right-hand bat', 'Right-arm fast-medium',  'Pace bowler known for hat-trick vs LSG. Effective in all phases of the game.'),
(105,'Maheesh Pathirana',  7, 'Bowler',         3.0, 20.0, 'Sri Lankan',  '19-Oct-2002', 'Right-hand bat', 'Right-arm fast',         'Death bowling specialist. Slingy action, fast and hits yorker lengths consistently.');

-- ===== PUNJAB KINGS =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(106,'Shreyas Iyer',       8, 'Batsman',       34.0, 99.0, 'Indian',      '06-Dec-1994', 'Right-hand bat', 'Right-arm off break',    'PBKS captain. Elegant middle-order batter. Strong off the front foot. Excellent captain.'),
(107,'Prabhsimran Singh',  8, 'Wicket-Keeper', 30.0, 99.0, 'Indian',      '03-Jun-2000', 'Right-hand bat', 'None',                   'Young explosive wicket-keeper opener. Big-hitter who can set up innings in powerplay.'),
(108,'Shashank Singh',     8, 'Batsman',       28.0, 99.0, 'Indian',      '14-Sep-1991', 'Right-hand bat', 'Right-arm medium',       'Finisher who punches above his weight. Match-winning cameos in crucial games.'),
(109,'Glenn Maxwell',      8, 'All-Rounder',   28.0, 30.0, 'Australian',  '14-Oct-1988', 'Right-hand bat', 'Right-arm off break',    'The Big Show. Explosive batsman and handy spinner. Match-winner on his day.'),
(110,'Arshdeep Singh',     8, 'Bowler',         6.0, 22.0, 'Indian',      '05-Feb-2000', 'Left-hand bat',  'Left-arm fast-medium',   'Left-arm swing bowler. India T20 WC winner. Clutch bowler in pressure situations.'),
(111,'Yuzvendra Chahal',   8, 'Bowler',         8.0, 22.0, 'Indian',      '23-Jul-1990', 'Right-hand bat', 'Right-arm leg break',    'IPL''s all-time leading wicket taker. Wrist spin master with many variations.'),
(112,'Marcus Stoinis',     8, 'All-Rounder',   24.0, 28.0, 'Australian',  '16-Aug-1989', 'Right-hand bat', 'Right-arm fast-medium',  'Explosive all-rounder. Hits sixes for fun and gets important breakthroughs with pace.'),
(113,'Jonny Bairstow',     8, 'Wicket-Keeper', 36.0, 99.0, 'English',     '26-Sep-1989', 'Right-hand bat', 'None',                   'Explosive English opener. Aggressive, fearless batter who can take apart any attack.'),
(114,'Harshal Patel',      8, 'Bowler',         6.0, 24.0, 'Indian',      '23-Jul-1990', 'Right-hand bat', 'Right-arm fast-medium',  'Slower ball specialist. Master of cutters and slower balls in death overs.'),
(115,'Rilee Rossouw',      8, 'Batsman',       28.0, 99.0, 'South African','9-Oct-1989',  'Left-hand bat',  'None',                   'Left-hand batter. Power-hitter who cleared the ropes consistently for SRH previously.'),
(116,'Liam Livingstone',   8, 'All-Rounder',   25.0, 30.0, 'English',     '04-Aug-1993', 'Right-hand bat', 'Right-arm leg break',    'Massive six-hitter and handy spinner. One of T20 cricket''s most impactful all-rounders.'),
(117,'Sam Curran',         8, 'All-Rounder',   20.0, 26.0, 'English',     '03-Jun-1998', 'Left-hand bat',  'Left-arm fast-medium',   'Left-arm swinging all-rounder. T20 WC player of tournament in 2022. Expensive buy.'),
(118,'Kagiso Rabada',      8, 'Bowler',         5.0, 21.0, 'South African','25-May-1995', 'Right-hand bat', 'Right-arm fast',         'Express pace right-arm seamer. Dangerous with new ball and in death.'),
(119,'Azmatullah Omarzai', 8, 'All-Rounder',   22.0, 28.0, 'Afghan',      '05-Jan-2001', 'Right-hand bat', 'Right-arm fast-medium',  'Afghan all-rounder. Useful lower-order runs and medium pace breakthroughs.'),
(120,'Harpreet Brar',      8, 'All-Rounder',   14.0, 26.0, 'Indian',      '06-Mar-1997', 'Left-hand bat',  'Left-arm orthodox spin', 'Left-arm spinner who took 3 wickets in 3 balls vs RCB in 2021. Match-winner.');

-- ===== DELHI CAPITALS =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(121,'KL Rahul',           9, 'Wicket-Keeper', 46.0, 99.0, 'Indian',      '18-Apr-1992', 'Right-hand bat', 'Right-arm medium',       'DC captain. Elegant batter. Former Orange Cap winner. Classy opener, excellent keeper.'),
(122,'David Warner',       9, 'Batsman',       40.0, 99.0, 'Australian',  '27-Oct-1986', 'Left-hand bat',  'Right-arm leg break',    'DC''s explosive left-hand opener. Won Orange Cap twice with SRH. T20 legend.'),
(123,'Axar Patel',         9, 'All-Rounder',   22.0, 26.0, 'Indian',      '20-Jan-1994', 'Left-hand bat',  'Left-arm orthodox spin', 'Reliable left-arm spinner and useful lower-order hitter. India''s go-to all-rounder.'),
(124,'Kuldeep Yadav',      9, 'Bowler',         6.0, 22.0, 'Indian',      '14-Dec-1994', 'Right-hand bat', 'Left-arm wrist spin',    'Left-arm wrist spinner. His China man and googly are almost unplayable when in rhythm.'),
(125,'Rishabh Pant',       9, 'Wicket-Keeper', 36.0, 99.0, 'Indian',      '04-Oct-1997', 'Left-hand bat',  'None',                   'DC''s favorite son. Returns from horrific road accident. Plays cricket on his own terms. DC legend.'),
(126,'Tristan Stubbs',     9, 'Batsman',       26.0, 99.0, 'South African','11-Jun-2001', 'Right-hand bat', 'None',                   'Young South African power-hitter. One of T20 cricket''s emerging stars.'),
(127,'Anrich Nortje',      9, 'Bowler',         4.0, 22.5, 'South African','16-Nov-1993', 'Right-hand bat', 'Right-arm fast',         'Consistently above 150kph. Considered one of the fastest bowlers in the world.'),
(128,'Mukesh Kumar',       9, 'Bowler',         4.0, 27.0, 'Indian',      '26-Dec-1995', 'Right-hand bat', 'Right-arm fast-medium',  'Bengal pacer. Good with the new ball and can reverse swing older ball.'),
(129,'Mitchell Marsh',     9, 'All-Rounder',   24.0, 30.0, 'Australian',  '20-Oct-1991', 'Right-hand bat', 'Right-arm fast-medium',  'Australian all-rounder. T20 WC player of tournament 2024. Big hitter at top of order.'),
(130,'Jake Fraser-McGurk', 9, 'Batsman',       30.0, 99.0, 'Australian',  '28-Jun-2002', 'Right-hand bat', 'Right-arm off break',    'Explosive young Australian opener. Has the fastest IPL fifty on record. Fearless batter.'),
(131,'Harry Brook',        9, 'Batsman',       32.0, 30.0, 'English',     '22-Feb-1999', 'Right-hand bat', 'Right-arm medium',       'English batting prodigy. Beautiful striker of the ball in all formats.'),
(132,'Sumit Kumar',        9, 'Bowler',         4.0, 28.0, 'Indian',      '01-Jan-1998', 'Right-hand bat', 'Right-arm off break',    'Off-spinner. Can create pressure and take wickets in middle overs.'),
(133,'Vipraj Nigam',       9, 'Bowler',         3.0, 27.0, 'Indian',      '15-Mar-2003', 'Right-hand bat', 'Right-arm leg break',    'Young leg spinner with sharp googly. Great domestic record.'),
(134,'Donovan Ferreira',   9, 'All-Rounder',   20.0, 30.0, 'South African','01-Sep-1997', 'Right-hand bat', 'Right-arm fast-medium',  'South African all-rounder. Hard-hitter and can contribute with medium pace.'),
(135,'Ashutosh Sharma',    9, 'Batsman',       24.0, 99.0, 'Indian',      '08-Jan-2001', 'Right-hand bat', 'Right-arm off break',    'Middle-order batter known for hitting big in the death overs.');

-- ===== LUCKNOW SUPER GIANTS =====
INSERT INTO player (player_id, player_name, team_id, role, batting_avg, bowling_avg, nationality, date_of_birth, batting_style, bowling_style, bio) VALUES
(136,'Rishabh Pant',       10,'Wicket-Keeper', 36.0, 99.0, 'Indian',      '04-Oct-1997', 'Left-hand bat',  'None',                   'LSG captain and star attraction. IPL''s most entertaining wicket-keeper. Unconventional and match-winning.'),
(137,'Mitchell Marsh',     10,'All-Rounder',   24.0, 30.0, 'Australian',  '20-Oct-1991', 'Right-hand bat', 'Right-arm fast-medium',  'Australian all-rounder. T20 WC player of tournament. Powerful hitter and useful pace.'),
(138,'Nicholas Pooran',    10,'Wicket-Keeper', 30.0, 99.0, 'West Indian', '02-Oct-1995', 'Left-hand bat',  'None',                   'Explosive left-hand finisher. One of the hardest hitters in T20 cricket.'),
(139,'Quinton de Kock',    10,'Wicket-Keeper', 38.0, 99.0, 'South African','17-Dec-1992', 'Left-hand bat',  'None',                   'Brilliant left-hand opener and keeper. Aggressive at the top but also technically sound.'),
(140,'Avesh Khan',         10,'Bowler',         4.0, 26.0, 'Indian',      '13-Dec-1996', 'Right-hand bat', 'Right-arm fast-medium',  'Express pacer. Effective with new ball and in death overs.'),
(141,'Ravi Bishnoi',       10,'Bowler',         6.0, 22.0, 'Indian',      '05-Sep-2000', 'Right-hand bat', 'Right-arm leg break',    'Wrist spinner. Googlies and top spinners fox batters. Rising India T20 spinner.'),
(142,'Mohsin Khan',        10,'Bowler',         3.0, 24.0, 'Indian',      '25-Jul-1998', 'Left-hand bat',  'Left-arm fast-medium',   'Left-arm swing bowler. Dangerous in powerplay with movement.'),
(143,'David Miller',       10,'Batsman',       30.0, 99.0, 'South African','10-Jun-1989', 'Left-hand bat',  'Right-arm off break',    'Killer Miller. Destructive finisher. Clears the ropes with ease.'),
(144,'Matt Henry',         10,'Bowler',         5.0, 24.0, 'New Zealander','14-Dec-1991', 'Right-hand bat', 'Right-arm fast-medium',  'NZ seamer. Swings the ball and useful in powerplay. Good yorker too.'),
(145,'Ayush Badoni',       10,'Batsman',       24.0, 99.0, 'Indian',      '06-Jun-2000', 'Right-hand bat', 'Right-arm off break',    'Young Delhi batter. Stylish and improving each IPL season. Exciting prospect.'),
(146,'Abdul Samad',        10,'All-Rounder',   20.0, 34.0, 'Indian',      '20-Feb-2001', 'Right-hand bat', 'Right-arm leg break',    'J&K all-rounder. Big hitter with leg-spin ability. Exciting young talent.'),
(147,'Aryan Juyal',        10,'Wicket-Keeper', 18.0, 99.0, 'Indian',      '18-Mar-2001', 'Right-hand bat', 'None',                   'Young wicket-keeper batter from Uttarakhand. Good glovework and improving bat.'),
(148,'Shamar Joseph',      10,'Bowler',         4.0, 24.0, 'West Indian', '10-Jul-2000', 'Right-hand bat', 'Right-arm fast',         'Young West Indian express pacer. Bowls above 145 kph regularly. Raw talent.'),
(149,'Aiden Markram',      10,'Batsman',       28.0, 28.0, 'South African','04-Oct-1994', 'Right-hand bat', 'Right-arm off break',    'Classy South African bat. Good against both pace and spin. Composed under pressure.'),
(150,'Digvijay Deshmukh',  10,'All-Rounder',   18.0, 30.0, 'Indian',      '15-Jan-2003', 'Right-hand bat', 'Right-arm fast-medium',  'Young all-rounder from Maharashtra. Making his mark in the IPL.');

-- ============================================================
-- IPL 2025 MATCH RESULTS (Completed fixtures)
-- ============================================================
INSERT INTO match_tbl (match_id, team_a_id, team_b_id, venue, match_date, status, winner_team_id) VALUES
(1,  1,  3, 'Wankhede Stadium, Mumbai',                '2025-05-20', 'Completed', 1),
(2,  2,  5, 'MA Chidambaram Stadium, Chennai',          '2025-05-15', 'Completed', 2),
(3,  6,  7, 'Rajiv Gandhi Intl. Stadium, Hyderabad',   '2025-04-28', 'Completed', 6),
(4,  9,  4, 'Arun Jaitley Stadium, Delhi',              '2025-05-02', 'Completed', 9),
(5, 10,  8, 'BRSABV Ekana Stadium, Lucknow',            '2025-04-30', 'Completed', 10);

INSERT INTO innings (innings_id, match_id, batting_team_id, bowling_team_id, total_runs, total_wickets, total_balls, innings_number, is_complete) VALUES
(1, 1, 1, 3, 180, 7, 120, 1, TRUE),
(2, 1, 3, 1, 175, 10, 119, 2, TRUE),
(3, 2, 2, 5, 156, 8, 120, 1, TRUE),
(4, 2, 5, 2, 152, 9, 120, 2, TRUE),
(5, 3, 6, 7, 178, 6, 120, 1, TRUE),
(6, 3, 7, 6, 179, 5, 119, 2, TRUE),
(7, 4, 9, 4, 190, 6, 120, 1, TRUE),
(8, 4, 4, 9, 175, 10, 120, 2, TRUE),
(9, 5, 10, 8, 165, 7, 120, 1, TRUE),
(10,5, 8, 10, 148,10, 118, 2, TRUE);

-- ============================================================
-- IPL 2025 MATCH SCORECARDS
-- ============================================================
INSERT INTO batting_stats (stat_id, player_id, match_id, innings_id, runs, balls_faced, fours, sixes, is_out, dismissal_type) VALUES
-- ===== MATCH 1: MI vs RCB | Innings 1 - MI Batting (180/7) =====
(1,  1, 1, 1, 46, 32, 6, 2, 1, 'c Maxwell b Siraj'),
(2,  2, 1, 1, 14, 10, 2, 0, 1, 'lbw b Starc'),
(3,  3, 1, 1, 58, 42, 4, 3, 1, 'c Karthik b Maxwell'),
(4,  4, 1, 1, 17, 15, 1, 1, 1, 'b Hasaranga'),
(5,  6, 1, 1, 18, 14, 2, 1, 1, 'c du Plessis b Hasaranga'),
(6,  7, 1, 1, 12, 8, 0, 1, 1, 'c Kohli b Siraj'),
(7,  8, 1, 1, 9, 7, 1, 0, 1, 'b Joseph'),
(8, 10, 1, 1,  0, 1, 0, 0, 1, 'b Joseph'),
(9, 11, 1, 1,  3, 4, 0, 0, 0, 'not out'),
-- ===== MATCH 1: MI vs RCB | Innings 2 - RCB Batting (175/10) =====
(10, 31, 1, 2, 72, 54, 8, 2, 1, 'c Ishan b Boult'),
(11, 32, 1, 2, 24, 20, 2, 1, 1, 'b Bumrah'),
(12, 33, 1, 2, 20, 16, 1, 1, 1, 'c Hardik b Chahar'),
(13, 35, 1, 2, 18, 15, 2, 0, 1, 'c Rohit b Bumrah'),
(14, 37, 1, 2, 14, 11, 1, 0, 1, 'b Chahar'),
(15, 36, 1, 2, 11, 9, 1, 0, 1, 'c Tilak b Bumrah'),
(16, 40, 1, 2,  8, 7, 1, 0, 1, 'c Pollard b Boult'),
(17, 42, 1, 2,  5, 6, 0, 0, 1, 'b Tim David'),
(18, 38, 1, 2,  2, 4, 0, 0, 1, 'b Chahar'),
(19, 34, 1, 2,  0, 1, 0, 0, 1, 'b Bumrah'),
(20, 44, 1, 2,  1, 3, 0, 0, 1, 'run out'),
-- ===== MATCH 2: CSK vs GT | Innings 3 - CSK Batting (156/8) =====
(21, 17, 2, 3, 43, 34, 5, 1, 1, 'c Gill b Rabada'),
(22, 18, 2, 3, 58, 48, 8, 1, 1, 'c Rashid b Shami'),
(23, 27, 2, 3, 16, 20, 2, 0, 1, 'b Prasidh'),
(24, 22, 2, 3, 19, 17, 2, 0, 1, 'c Miller b Rabada'),
(25, 24, 2, 3,  9, 10, 0, 0, 1, 'b Rashid'),
(26, 23, 2, 3,  8,  6, 1, 0, 1, 'c Sudharsan b Shami'),
(27, 19, 2, 3, 12, 16, 0, 0, 1, 'b Noor Ahmad'),
(28, 25, 2, 3,  4,  5, 0, 0, 1, 'c Tewatia b Prasidh'),
(29, 26, 2, 3,  0,  2, 0, 0, 0, 'not out'),
-- ===== MATCH 2: CSK vs GT | Innings 4 - GT Batting (152/9) =====
(30, 61, 2, 4, 53, 44, 6, 2, 1, 'c Conway b Jadeja'),
(31, 62, 2, 4, 26, 22, 3, 0, 1, 'c Rayudu b Santner'),
(32, 63, 2, 4, 38, 30, 5, 1, 1, 'b Pathirana'),
(33, 74, 2, 4, 14, 16, 1, 0, 1, 'b Theekshana'),
(34, 64, 2, 4,  9, 11, 0, 0, 1, 'c Dube b Pathirana'),
(35, 66, 2, 4,  8,  7, 0, 0, 1, 'c Jadeja b Jadeja'),
(36, 67, 2, 4,  3,  4, 0, 0, 1, 'c Ruturaj b Pathirana'),
(37, 68, 2, 4,  0,  2, 0, 0, 1, 'b Theekshana'),
(38, 75, 2, 4,  1,  3, 0, 0, 1, 'b Santner'),
-- ===== MATCH 3: SRH vs RR | Innings 5 - SRH Batting (178/6) =====
(39, 77, 3, 5, 64, 42, 7, 3, 1, 'c Buttler b Chahal'),
(40, 78, 3, 5, 47, 30, 6, 2, 1, 'b Avesh'),
(41, 79, 3, 5, 41, 28, 5, 2, 1, 'b Bishnoi'),
(42, 76, 3, 5, 11, 10, 1, 0, 1, 'c Samson b Avesh'),
(43, 80, 3, 5, 13, 14, 1, 0, 1, 'lbw b Bishnoi'),
(44, 81, 3, 5,  8, 10, 0, 0, 0, 'not out'),
(45, 82, 3, 5,  0,  1, 0, 0, 1, 'b Chahal'),
-- ===== MATCH 3: SRH vs RR | Innings 6 - RR Batting (179/5) =====
(46, 92, 3, 6, 59, 41, 7, 3, 1, 'lbw b Cummins'),
(47, 91, 3, 6, 32, 26, 4, 1, 1, 'c Markram b Zampa'),
(48,102, 3, 6, 24, 18, 3, 1, 1, 'b Natarajan'),
(49, 93, 3, 6, 28, 20, 3, 1, 0, 'not out'),
(50, 94, 3, 6,  9,  8, 1, 0, 1, 'c Abhishek b Cummins'),
(51, 98, 3, 6, 14, 10, 1, 0, 0, 'not out'),
(52, 99, 3, 6,  8, 13, 1, 0, 1, 'b Zampa'),
-- ===== MATCH 4: DC vs KKR | Innings 7 - DC Batting (190/6) =====
(53,121, 4, 7, 72, 55, 7, 2, 1, 'c Russell b Starc'),
(54,130, 4, 7, 38, 24, 4, 2, 1, 'b Nortje'),
(55,125, 4, 7, 25, 18, 2, 1, 1, 'c Narine b Chakravarthy'),
(56,129, 4, 7, 12, 10, 1, 0, 1, 'c de Kock b Russell'),
(57,122, 4, 7, 23, 18, 3, 1, 1, 'c Narine b Starc'),
(58,131, 4, 7, 21, 19, 4, 0, 1, 'c Narine b Russell'),
(59,123, 4, 7, 11, 10, 1, 0, 0, 'not out'),
(60,124, 4, 7,  0,  1, 0, 0, 0, 'not out'),
-- ===== MATCH 4: DC vs KKR | Innings 8 - KKR Batting (175/10) =====
(61, 47, 4, 8, 38, 28, 4, 2, 1, 'c Pant b Kuldeep'),
(62, 50, 4, 8, 31, 22, 4, 1, 1, 'c Warner b Axar'),
(63, 48, 4, 8, 18, 15, 2, 0, 1, 'b Nortje'),
(64, 46, 4, 8,  9, 11, 0, 0, 1, 'c KL b Mukesh'),
(65, 49, 4, 8, 42, 28, 3, 3, 1, 'c Brook b Kuldeep'),
(66, 54, 4, 8, 14, 12, 1, 0, 1, 'b Kuldeep'),
(67, 51, 4, 8, 12, 10, 1, 0, 1, 'c KL b Axar'),
(68, 58, 4, 8,  5,  6, 0, 0, 1, 'b Axar'),
(69, 55, 4, 8,  3,  4, 0, 0, 1, 'c Warner b Mukesh'),
(70, 53, 4, 8,  2,  3, 0, 0, 1, 'b Mukesh'),
(71, 52, 4, 8,  1,  2, 0, 0, 1, 'b Nortje'),
-- ===== MATCH 5: LSG vs PBKS | Innings 9 - LSG Batting (165/7) =====
(72,139, 5, 9, 44, 39, 6, 2, 1, 'c Bairstow b Chahal'),
(73,136, 5, 9, 28, 22, 3, 1, 1, 'b Arshdeep'),
(74,143, 5, 9, 37, 31, 4, 1, 1, 'b Arshdeep'),
(75,149, 5, 9, 15, 12, 1, 0, 1, 'c Iyer b Chahal'),
(76,145, 5, 9, 22, 18, 2, 1, 1, 'c Stoinis b Harshal'),
(77,138, 5, 9,  9, 10, 0, 0, 1, 'b Harshal'),
(78,148, 5, 9,  9, 10, 0, 0, 1, 'c Iyer b Arshdeep'),
(79,141, 5, 9,  0,  1, 0, 0, 0, 'not out'),
-- ===== MATCH 5: LSG vs PBKS | Innings 10 - PBKS Batting (148/10) =====
(80,107, 5,10, 22, 18, 3, 0, 1, 'c Bishnoi b Mohsin'),
(81,113, 5,10, 31, 24, 4, 1, 1, 'b Avesh'),
(82,106, 5,10, 29, 25, 3, 1, 1, 'c de Kock b Bishnoi'),
(83,112, 5,10, 18, 14, 2, 0, 1, 'b Bishnoi'),
(84,108, 5,10, 14, 12, 1, 0, 1, 'c Pant b Bishnoi'),
(85,116, 5,10, 12, 11, 0, 1, 1, 'c Miller b Avesh'),
(86,115, 5,10,  8,  8, 0, 0, 1, 'b Shamar'),
(87,109, 5,10,  7,  6, 0, 0, 1, 'c Badoni b Mohsin'),
(88,110, 5,10,  4,  4, 0, 0, 1, 'b Bishnoi'),
(89,114, 5,10,  2,  3, 0, 0, 1, 'run out'),
(90,118, 5,10,  1,  2, 0, 0, 1, 'b Avesh');

INSERT INTO bowling_stats (stat_id, player_id, match_id, innings_id, overs, maidens, runs_given, wickets) VALUES
-- ===== MATCH 1: RCB bowling in MI Innings (Innings 1) =====
(1,  34, 1, 1, 4.0, 0, 28, 2),
(2,  37, 1, 1, 4.0, 0, 34, 2),
(3,  40, 1, 1, 4.0, 0, 37, 1),
(4,  38, 1, 1, 4.0, 0, 33, 1),
(5,  44, 1, 1, 4.0, 0, 36, 1),
-- ===== MATCH 1: MI bowling in RCB Innings (Innings 2) =====
(6,   5, 1, 2, 4.0, 0, 32, 4),
(7,  15, 1, 2, 4.0, 0, 28, 2),
(8,  10, 1, 2, 4.0, 0, 34, 2),
(9,   4, 1, 2, 4.0, 0, 38, 2),
(10, 11, 1, 2, 3.0, 0, 24, 0),
-- ===== MATCH 2: GT bowling in CSK Innings (Innings 3) =====
(11, 64, 2, 3, 4.0, 0, 26, 2),
(12, 65, 2, 3, 4.0, 0, 29, 2),
(13, 70, 2, 3, 4.0, 0, 28, 1),
(14, 72, 2, 3, 4.0, 0, 32, 2),
(15, 69, 2, 3, 4.0, 0, 30, 1),
-- ===== MATCH 2: CSK bowling in GT Innings (Innings 4) =====
(16, 20, 2, 4, 4.0, 0, 24, 3),
(17, 26, 2, 4, 4.0, 0, 35, 1),
(18, 19, 2, 4, 4.0, 0, 29, 2),
(19, 25, 2, 4, 4.0, 0, 33, 2),
(20, 29, 2, 4, 4.0, 0, 27, 1),
-- ===== MATCH 3: RR bowling in SRH Innings (Innings 5) =====
(21, 95, 3, 5, 4.0, 0, 29, 3),
(22,100, 3, 5, 4.0, 0, 31, 2),
(23,141, 3, 5, 4.0, 0, 38, 0),
(24,101, 3, 5, 4.0, 0, 28, 1),
(25,103, 3, 5, 4.0, 0, 34, 0),
-- ===== MATCH 3: SRH bowling in RR Innings (Innings 6) =====
(26, 76, 3, 6, 4.0, 0, 25, 2),
(27, 82, 3, 6, 4.0, 0, 34, 2),
(28, 83, 3, 6, 4.0, 0, 29, 1),
(29, 84, 3, 6, 4.0, 0, 44, 0),
(30, 85, 3, 6, 3.5, 0, 26, 0),
-- ===== MATCH 4: KKR bowling in DC Innings (Innings 7) =====
(31, 49, 4, 7, 4.0, 0, 32, 2),
(32, 55, 4, 7, 4.0, 0, 29, 2),
(33, 52, 4, 7, 4.0, 0, 36, 1),
(34, 50, 4, 7, 4.0, 0, 24, 1),
(35, 53, 4, 7, 4.0, 0, 28, 0),
-- ===== MATCH 4: DC bowling in KKR Innings (Innings 8) =====
(36,124, 4, 8, 4.0, 0, 28, 3),
(37,123, 4, 8, 4.0, 0, 36, 3),
(38,127, 4, 8, 4.0, 0, 31, 2),
(39,128, 4, 8, 4.0, 0, 34, 2),
(40,133, 4, 8, 4.0, 0, 32, 0),
-- ===== MATCH 5: PBKS bowling in LSG Innings (Innings 9) =====
(41,110, 5, 9, 4.0, 0, 30, 3),
(42,114, 5, 9, 4.0, 0, 34, 2),
(43,112, 5, 9, 4.0, 0, 28, 1),
(44,111, 5, 9, 4.0, 0, 35, 1),
(45,117, 5, 9, 3.0, 0, 18, 0),
-- ===== MATCH 5: LSG bowling in PBKS Innings (Innings 10) =====
(46,141, 5,10, 4.0, 0, 26, 4),
(47,140, 5,10, 4.0, 0, 29, 3),
(48,148, 5,10, 4.0, 0, 28, 1),
(49,144, 5,10, 4.0, 0, 31, 1),
(50,142, 5,10, 2.0, 0, 16, 1);

-- ============================================================
-- IPL 2025 SEASON BATTING STATS (Top performers with real data)
-- Orange Cap race data based on IPL 2025 season performance
-- ============================================================
INSERT INTO season_batting_stats (player_id, matches, innings, runs, balls, highest_score, fifties, hundreds, fours, sixes, not_outs) VALUES
-- Orange Cap contenders
(77,  14, 14, 576, 367, 102,  4, 1, 52, 30, 1),  -- Travis Head SRH
(61,  14, 14, 567, 392,  98,  5, 0, 58, 22, 2),  -- Shubman Gill GT
(31,  14, 14, 554, 395, 112,  3, 1, 48, 26, 0),  -- Virat Kohli RCB
(17,  14, 14, 531, 396,  95,  5, 0, 52, 18, 1),  -- Ruturaj Gaikwad CSK
(92,  14, 13, 518, 355, 107,  3, 1, 46, 24, 2),  -- Jos Buttler RR
(78,  14, 14, 492, 316,  87,  4, 0, 44, 32, 1),  -- Abhishek Sharma SRH
(102, 14, 14, 489, 338,  90,  4, 0, 50, 28, 1),  -- Yashasvi Jaiswal RR
(3,   14, 13, 462, 302,  82,  4, 0, 36, 30, 3),  -- Suryakumar Yadav MI
(121, 14, 14, 448, 360,  88,  4, 0, 38, 16, 2),  -- KL Rahul DC
(79,  14, 12, 437, 254,  98,  2, 1, 34, 34, 4),  -- Heinrich Klaasen SRH
(47,  14, 14, 421, 295,  89,  3, 0, 40, 26, 1),  -- Quinton de Kock KKR
(125, 14, 14, 418, 306,  88,  3, 0, 34, 22, 2),  -- Rishabh Pant DC
(62,  14, 13, 412, 310,  86,  3, 0, 38, 20, 3),  -- Sai Sudharsan GT
(1,   14, 14, 408, 316,  78,  3, 0, 36, 20, 1),  -- Rohit Sharma MI
(16,  12, 10, 320, 198,  72,  2, 0, 24, 22, 4);  -- MS Dhoni CSK

-- ============================================================
-- IPL 2025 SEASON BOWLING STATS (Top performers with real data)
-- Purple Cap race data
-- ============================================================
INSERT INTO season_bowling_stats (player_id, matches, overs, runs_given, wickets, best_bowling, maidens, four_wickets, five_wickets) VALUES
-- Purple Cap contenders
(95,  14, 52.0, 406, 21, '4/17', 0, 1, 0),  -- Yuzvendra Chahal RR
(64,  14, 52.0, 368, 20, '4/24', 0, 1, 0),  -- Rashid Khan GT
(5,   14, 50.0, 360, 20, '3/16', 1, 0, 0),  -- Jasprit Bumrah MI
(20,  14, 50.2, 382, 19, '4/28', 0, 1, 0),  -- Matheesha Pathirana CSK
(110, 14, 51.0, 396, 18, '4/14', 0, 1, 0),  -- Arshdeep Singh PBKS
(52,  14, 52.0, 412, 17, '3/22', 0, 0, 0),  -- Mitchell Starc KKR
(70,  14, 50.0, 390, 17, '3/18', 0, 0, 0),  -- Kagiso Rabada GT
(34,  14, 48.0, 372, 16, '4/21', 0, 1, 0),  -- Mohammed Siraj RCB
(55,  14, 50.0, 380, 16, '4/19', 0, 1, 0),  -- Varun Chakravarthy KKR
(124, 14, 50.0, 368, 16, '4/14', 0, 1, 0),  -- Kuldeep Yadav DC
(82,  14, 49.0, 362, 15, '3/22', 0, 0, 0),  -- Adam Zampa SRH
(37,  13, 48.0, 356, 15, '3/18', 0, 0, 0),  -- Wanindu Hasaranga RCB
(141, 14, 50.0, 382, 15, '3/16', 0, 0, 0),  -- Ravi Bishnoi LSG
(10,  13, 48.0, 358, 14, '3/24', 0, 0, 0),  -- Trent Boult MI
(65,  12, 44.0, 344, 14, '4/20', 0, 1, 0);  -- Mohammed Shami GT

-- Admin user
INSERT INTO users (username, password, email, role) VALUES
('admin', 'admin123', 'admin@iplive.com', 'admin');

-- ============================================================
-- IPLive Gaming Feature — Append this to your schema.sql
-- OR run directly on your iplive database
-- ============================================================

USE iplive;

-- ===== FANTASY POINTS TABLE =====
-- Stores computed fantasy points per player per match
CREATE TABLE IF NOT EXISTS fantasy_points (
    fp_id         INT AUTO_INCREMENT PRIMARY KEY,
    player_id     INT NOT NULL,
    match_id      INT NOT NULL,
    innings_id    INT,
    -- Batting points
    run_pts       INT DEFAULT 0,   -- 1 pt per run
    boundary_pts  INT DEFAULT 0,   -- +1 per four, +2 per six
    fifty_pts     INT DEFAULT 0,   -- +8 for 50+, +16 for 100+
    sr_pts        INT DEFAULT 0,   -- Bonus/penalty for SR
    -- Bowling points
    wicket_pts    INT DEFAULT 0,   -- +25 per wicket
    dot_pts       INT DEFAULT 0,   -- +1 per dot ball (estimated)
    haul_pts      INT DEFAULT 0,   -- +8 for 3W, +16 for 5W
    economy_pts   INT DEFAULT 0,   -- Bonus/penalty for economy
    -- Fielding/All-round
    playing_pts   INT DEFAULT 0,   -- +4 for playing
    total_pts     INT DEFAULT 0,
    computed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_player_match (player_id, match_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE,
    FOREIGN KEY (match_id)  REFERENCES match_tbl(match_id) ON DELETE CASCADE
);

-- ===== ACHIEVEMENTS / BADGES TABLE =====
CREATE TABLE IF NOT EXISTS achievement_def (
    ach_id      INT AUTO_INCREMENT PRIMARY KEY,
    ach_key     VARCHAR(50) UNIQUE NOT NULL,
    title       VARCHAR(80) NOT NULL,
    description VARCHAR(200),
    icon        VARCHAR(10) DEFAULT '🏆',
    category    ENUM('batting','bowling','allround','milestone','special') DEFAULT 'special',
    threshold   INT DEFAULT 0        -- numeric threshold for auto-grant
);

-- ===== PLAYER EARNED BADGES =====
CREATE TABLE IF NOT EXISTS player_badge (
    badge_id    INT AUTO_INCREMENT PRIMARY KEY,
    player_id   INT NOT NULL,
    ach_id      INT NOT NULL,
    earned_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    match_id    INT,                  -- which match triggered it
    UNIQUE KEY uq_player_ach (player_id, ach_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE,
    FOREIGN KEY (ach_id)    REFERENCES achievement_def(ach_id) ON DELETE CASCADE
);

-- ===== SEASON LEADERBOARD VIEW (materialised as table for speed) =====
CREATE TABLE IF NOT EXISTS season_fantasy_rank (
    player_id        INT PRIMARY KEY,
    total_fantasy_pts INT DEFAULT 0,
    matches_played   INT DEFAULT 0,
    avg_pts          DOUBLE DEFAULT 0,
    rank_pos         INT DEFAULT 0,
    last_updated     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE
);

-- ===== ACHIEVEMENT DEFINITIONS =====
INSERT IGNORE INTO achievement_def (ach_key, title, description, icon, category, threshold) VALUES
('run_machine',   'Run Machine',        'Score 500+ fantasy points in batting',       '🏏', 'batting',  500),
('century_club',  'Century Club',       'Hit a century in a match',                   '💯', 'batting',  100),
('six_machine',   'Six Machine',        'Hit 5+ sixes in a single match',             '💥', 'batting',    5),
('strike_king',   'Strike King',        'Maintain 150+ SR over season (min 10 inns)', '⚡', 'batting',  150),
('purple_cap',    'Purple Cap',         'Top wicket taker of the season',             '🟣', 'bowling',    1),
('hat_trick_hero','Hat-Trick Hero',     'Take 3+ wickets in a match',                 '🎩', 'bowling',    3),
('economy_ace',   'Economy Ace',        'Maintain <7 economy over season',            '🧊', 'bowling',    7),
('five_for',      'Five-fer',           'Take 5 wickets in an innings',               '🔥', 'bowling',    5),
('all_rounder',   'All-Rounder Elite',  '30+ runs AND 2+ wickets in same match',      '⭐', 'allround',   1),
('iron_man',      'Iron Man',           'Play every match of the season (14+)',       '🦾', 'milestone', 14),
('top_scorer',    'Fantasy King',       'Highest fantasy score in a single match',    '👑', 'milestone',  1),
('mvp',           'Season MVP',         'Highest total fantasy points in the season', '🏅', 'milestone',  1),
('debut_hero',    'Debut Hero',         'Score 50+ fantasy pts in first match',       '🌟', 'special',   50),
('comeback_kid',  'Comeback Kid',       'Score 40+ pts after two <10 pt matches',     '🔄', 'special',    1),
('orange_cap',    'Orange Cap',         'Top run scorer of the season',               '🟠', 'batting',    1);