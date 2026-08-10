-- ============================================
-- Advanced SQL Techniques
-- Extending the Premier League 2025/26 analysis
-- ============================================

-- ============================================
-- WINDOW FUNCTIONS
-- ============================================

-- Rank teams by total goals scored, and show the goal gap to the team above
WITH team_goals AS (
    SELECT home_team AS teams, fulltime_home_goals AS goals
    FROM matches
    UNION ALL
    SELECT away_team AS teams, fulltime_away_goals AS goals
    FROM matches
),
ranked_goals AS (
    SELECT teams, 
           SUM(goals) AS total_goals_scored,
           RANK() OVER(ORDER BY SUM(goals) DESC) AS team_rank,
           LAG(SUM(goals), 1, 0) OVER(ORDER BY SUM(goals) DESC) AS previous_team_goals
    FROM team_goals
    GROUP BY teams
)
SELECT teams, total_goals_scored, team_rank, previous_team_goals,
       previous_team_goals - total_goals_scored AS goal_gap
FROM ranked_goals
ORDER BY total_goals_scored DESC;


-- ============================================
-- TEMPORARY TABLES
-- ============================================

DROP TEMPORARY TABLE IF EXISTS temp_team_goals;

CREATE TEMPORARY TABLE temp_team_goals AS
SELECT home_team AS teams, fulltime_home_goals AS goals
FROM matches
UNION ALL
SELECT away_team AS teams, fulltime_away_goals AS goals
FROM matches;

-- Query 1: total goals per team
SELECT teams, SUM(goals) AS total_goals_per_team
FROM temp_team_goals
GROUP BY teams
ORDER BY total_goals_per_team DESC;

-- Query 2: average goals scored per match, per team
SELECT teams, SUM(goals) AS overall_team_goals, AVG(goals) AS avg_goals_scored
FROM temp_team_goals
GROUP BY teams
ORDER BY avg_goals_scored DESC;


-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Procedure 1: get a single team's overall win rate (home + away combined)
DROP PROCEDURE IF EXISTS get_team_win_rate;

DELIMITER $$

CREATE PROCEDURE get_team_win_rate(IN p_teams VARCHAR(50))
BEGIN
    SELECT teams, SUM(win_points) AS total_wins, COUNT(*) AS total_matches, 
           ROUND(SUM(win_points) / COUNT(*) * 100.0, 2) AS win_pct
    FROM (
        SELECT home_team AS teams,
            CASE WHEN fulltime_result = 'H' THEN 1 ELSE 0 END AS win_points
        FROM matches
        WHERE home_team = p_teams

        UNION ALL

        SELECT away_team AS teams,
            CASE WHEN fulltime_result = 'A' THEN 1 ELSE 0 END AS win_points
        FROM matches
        WHERE away_team = p_teams
    ) AS total_win_points
    GROUP BY teams;
END $$

DELIMITER ;

-- Example call:
-- CALL get_team_win_rate('Arsenal');


-- Procedure 2: get all matches officiated by a given referee
DROP PROCEDURE IF EXISTS get_matches_by_referee;

DELIMITER //

CREATE PROCEDURE get_matches_by_referee(IN p_referee VARCHAR(50))
BEGIN
    SELECT match_id, match_date, match_time, home_team, away_team, referee
    FROM matches
    WHERE referee = p_referee
    ORDER BY match_id;
END //

DELIMITER ;

-- Example call:
-- CALL get_matches_by_referee('A Taylor');


-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger 1: prevent negative goal values from being inserted
DELIMITER //

CREATE TRIGGER prevent_negative_goals
BEFORE INSERT ON matches
FOR EACH ROW
BEGIN
    IF NEW.fulltime_home_goals < 0 OR NEW.fulltime_away_goals < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Goals cannot be negative';
    END IF;
END //

DELIMITER ;


-- Trigger 2: automatically log every new match insert
CREATE TABLE IF NOT EXISTS match_insert_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT,
    home_team VARCHAR(50),
    away_team VARCHAR(50),
    fulltime_home_goals INT,
    fulltime_away_goals INT,
    fulltime_result CHAR(1),
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER log_new_match
AFTER INSERT ON matches
FOR EACH ROW
BEGIN
    INSERT INTO match_insert_log (match_id, home_team, away_team, fulltime_home_goals, fulltime_away_goals, fulltime_result)
    VALUES (NEW.match_id, NEW.home_team, NEW.away_team, NEW.fulltime_home_goals, NEW.fulltime_away_goals, NEW.fulltime_result);
END //

DELIMITER ;


-- ============================================
-- EVENTS
-- ============================================

-- Summary table, refreshed automatically by the event below
CREATE TABLE team_goals_summary (
    teams VARCHAR(50) PRIMARY KEY,
    total_goals INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Event: automatically refreshes team_goals_summary with each team'stotal goals (home + away combined), keeping it up to date without manual intervention.
-- Tested on a 1-minute schedule to confirm it fires and updates automatically; a real deployment would typically use a longer interval (e.g. EVERY 4 DAY).

DELIMITER //

CREATE EVENT team_goal_input
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    TRUNCATE TABLE team_goals_summary;

    INSERT INTO team_goals_summary (teams, total_goals)
    SELECT teams, SUM(goals) AS total_goals
    FROM (
        SELECT home_team AS teams, fulltime_home_goals AS goals
        FROM matches
        UNION ALL
        SELECT away_team AS teams, fulltime_away_goals AS goals
        FROM matches
    ) AS raw_team_goals
    GROUP BY teams;
END //

DELIMITER ;

-- Note: event was tested, verified working (last_updated timestamps confirmed refreshing every minute), then dropped after verification:
-- DROP EVENT team_goal_input;
