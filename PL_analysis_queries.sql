-- ============================================
-- Premier League 2025/26 Season Analysis
-- ============================================

-- 1. Most goals scored at home
SELECT 
	home_team, SUM(fulltime_home_goals) AS home_goals_scored
FROM
    matches
GROUP BY home_team
ORDER BY home_goals_scored DESC;

-- 2. Most away goals scored
SELECT
	away_team, SUM(fulltime_away_goals) AS away_goals_scored
FROM
	matches
GROUP BY away_team
ORDER BY away_goals_scored DESC;

-- 3. Best win rate away from home
-- Aggregation in the SELECT clause
SELECT
	away_team, SUM(CASE WHEN fulltime_result = 'A' THEN 1 ELSE 0 END) AS total_away_wins,
    count(*) AS total_away_games, ROUND(SUM(CASE WHEN fulltime_result = 'A' THEN 1 ELSE 0 END) / count(*) * 100.0, 2) AS away_win_rate
FROM
	matches
GROUP BY away_team
ORDER BY total_away_wins DESC;


-- 4. Best win rate (home and away)
SELECT team, SUM(wins) AS total_wins, COUNT(*) AS total_games, ROUND(SUM(wins) / COUNT(*) * 100.0, 2) AS win_percentage
FROM (
	SELECT home_team AS team,
		CASE
			WHEN fulltime_result = 'H' THEN 1 ELSE 0
		END AS wins
    FROM matches
    
    UNION ALL
    
    SELECT away_team AS team,
		CASE
			WHEN fulltime_result = 'A' THEN 1 ELSE 0
        END AS wins
    FROM matches
) AS all_results
GROUP BY team
ORDER BY win_percentage DESC;

-- 5. Team with most goals scored
SELECT teams, SUM(goals) AS total_goals_scored
FROM(
	SELECT home_team AS teams, SUM(fulltime_home_goals) AS goals
    FROM matches
    GROUP BY home_team
    
    UNION ALL
    
    SELECT away_team AS teams, SUM(fulltime_away_goals) AS goals
    FROM matches
    GROUP BY away_team
) AS team_goals
GROUP BY teams
ORDER BY total_goals_scored DESC;


-- 6. Team with best defence
SELECT teams, SUM(goals_against) AS goals_conceded
FROM (
	SELECT home_team AS teams, SUM(fulltime_away_goals) AS goals_against
    FROM matches
    GROUP BY home_team
    
    UNION ALL
    
    SELECT away_team AS teams, SUM(fulltime_home_goals) AS goals_against
    FROM matches
    GROUP BY away_team
) AS total_conceded_goals
GROUP BY teams
ORDER BY goals_conceded;

-- 7. Most matches officiated
SELECT referee, COUNT(*) AS total_games_officiated
FROM matches
GROUP BY referee
ORDER BY total_games_officiated DESC;


-- 8. Most Booked team
SELECT teams,
	SUM(yellow_card) AS total_yellow_card,
	SUM(red_card) AS total_red_card,
    SUM(yellow_card) + SUM(red_card) AS total_cards_received
FROM(
	SELECT home_team AS teams, SUM(home_yellow) AS yellow_card, SUM(home_red) AS red_card
	FROM matches
    GROUP BY home_team
    
    UNION ALL
    
    SELECT away_team AS teams, SUM(away_yellow) AS yellow_card, SUM(away_red) AS red_card
    FROM matches
    GROUP BY away_team
) AS total_cards
GROUP BY teams
ORDER BY total_cards_received DESC;
