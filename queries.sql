-- Football Analytics Queries
SET search_path = football_analytics, public;

-- 1) Top scorers (view)
SELECT * FROM v_top_scorers;

-- 2) Goals per club
SELECT c.name AS club, COUNT(*) AS goals
FROM events e
JOIN clubs c ON c.club_id = e.club_id
WHERE e.type = 'GOAL'
GROUP BY c.name
ORDER BY goals DESC;

-- 3) Player goal timeline with window function (cumulative goals)
WITH goals AS (
  SELECT e.player_id, e.minute, e.match_id, e.club_id, e.event_id,
         ROW_NUMBER() OVER (PARTITION BY e.player_id ORDER BY e.match_id, e.minute) AS goal_no
  FROM events e
  WHERE e.type = 'GOAL'
)
SELECT g.player_id, p.first_name, p.last_name, g.goal_no, g.match_id, g.minute
FROM goals g
JOIN players p ON p.player_id = g.player_id
ORDER BY p.last_name, g.goal_no;

-- 4) Discipline table (cards by player)
SELECT p.first_name, p.last_name,
       SUM(CASE WHEN e.type = 'YELLOW' THEN 1 ELSE 0 END) AS yellows,
       SUM(CASE WHEN e.type = 'RED' THEN 1 ELSE 0 END) AS reds
FROM players p
LEFT JOIN events e ON e.player_id = p.player_id
GROUP BY p.first_name, p.last_name
ORDER BY reds DESC, yellows DESC, last_name;

-- 5) Match results table (W/D/L) for each club
WITH results AS (
  SELECT m.match_id, m.match_date, m.home_club_id, m.away_club_id, m.home_goals, m.away_goals,
         CASE
           WHEN home_goals > away_goals THEN 'H'
           WHEN home_goals < away_goals THEN 'A'
           ELSE 'D'
         END AS outcome
  FROM matches m
)
SELECT c.name AS club,
       SUM(CASE WHEN (r.outcome = 'H' AND r.home_club_id = c.club_id) OR (r.outcome = 'A' AND r.away_club_id <> c.club_id AND r.away_club_id = c.club_id AND r.away_goals > r.home_goals) THEN 1 ELSE 0 END) AS wins,
       SUM(CASE WHEN r.outcome = 'D' AND (r.home_club_id = c.club_id OR r.away_club_id = c.club_id) THEN 1 ELSE 0 END) AS draws,
       SUM(CASE WHEN (r.outcome = 'H' AND r.away_club_id = c.club_id) OR (r.outcome = 'A' AND r.home_club_id = c.club_id) THEN 1 ELSE 0 END) AS losses
FROM clubs c
LEFT JOIN results r ON r.home_club_id = c.club_id OR r.away_club_id = c.club_id
GROUP BY c.name
ORDER BY wins DESC, draws DESC;

-- 6) Transfer history per player
SELECT p.first_name, p.last_name, c1.name AS from_club, c2.name AS to_club, t.fee_m_eur, t.transfer_date
FROM transfers t
JOIN players p ON p.player_id = t.player_id
LEFT JOIN clubs c1 ON c1.club_id = t.from_club_id
LEFT JOIN clubs c2 ON c2.club_id = t.to_club_id
ORDER BY t.transfer_date DESC;

-- 7) Index usefulness
EXPLAIN ANALYZE SELECT * FROM players WHERE club_id = 1;

-- 8) Appearances per player
SELECT p.first_name, p.last_name, COUNT(*) AS appearances
FROM appearances a
JOIN players p ON p.player_id = a.player_id
GROUP BY p.first_name, p.last_name
ORDER BY appearances DESC, last_name;

-- 9) Goals per match with dense_rank by match date
WITH g AS (
  SELECT match_id, COUNT(*) AS goals
  FROM events WHERE type = 'GOAL'
  GROUP BY match_id
)
SELECT m.match_id, m.match_date, COALESCE(g.goals,0) AS goals,
       DENSE_RANK() OVER (ORDER BY m.match_date) AS match_rank
FROM matches m
LEFT JOIN g ON g.match_id = m.match_id
ORDER BY m.match_date;

-- 10) Players by market value (top N)
SELECT first_name, last_name, market_value_m_eur
FROM players
ORDER BY market_value_m_eur DESC, last_name
LIMIT 5;