-- Football Analytics Schema
DROP SCHEMA IF EXISTS football_analytics CASCADE;
CREATE SCHEMA football_analytics;
SET search_path = football_analytics, public;

CREATE TABLE clubs (
  club_id SERIAL PRIMARY KEY,
  name    TEXT NOT NULL UNIQUE,
  country TEXT NOT NULL
);

CREATE TABLE players (
  player_id SERIAL PRIMARY KEY,
  club_id   INT REFERENCES clubs(club_id) ON DELETE SET NULL,
  first_name TEXT NOT NULL,
  last_name  TEXT NOT NULL,
  dob        DATE NOT NULL,
  position   TEXT NOT NULL CHECK (position IN ('GK','DF','MF','FW')),
  market_value_m_eur NUMERIC(12,2) CHECK (market_value_m_eur >= 0)
);

CREATE INDEX idx_players_club ON players(club_id);

CREATE TABLE matches (
  match_id SERIAL PRIMARY KEY,
  match_date DATE NOT NULL,
  home_club_id INT NOT NULL REFERENCES clubs(club_id) ON DELETE RESTRICT,
  away_club_id INT NOT NULL REFERENCES clubs(club_id) ON DELETE RESTRICT,
  home_goals INT NOT NULL DEFAULT 0 CHECK (home_goals >= 0),
  away_goals INT NOT NULL DEFAULT 0 CHECK (away_goals >= 0)
);

CREATE INDEX idx_matches_date ON matches(match_date);

-- Player appearance per match: minutes, starter, etc.
CREATE TABLE appearances (
  appearance_id SERIAL PRIMARY KEY,
  match_id INT NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
  player_id INT NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,
  club_id   INT NOT NULL REFERENCES clubs(club_id) ON DELETE CASCADE,
  minutes_played INT NOT NULL CHECK (minutes_played BETWEEN 0 AND 120),
  starter BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT uq_player_match UNIQUE (match_id, player_id)
);

-- Events (goal, assist, card, shot, etc.)
CREATE TABLE events (
  event_id SERIAL PRIMARY KEY,
  match_id INT NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
  minute   INT NOT NULL CHECK (minute BETWEEN 0 AND 120),
  player_id INT REFERENCES players(player_id) ON DELETE SET NULL,
  club_id   INT REFERENCES clubs(club_id) ON DELETE SET NULL,
  type TEXT NOT NULL CHECK (type IN ('GOAL','ASSIST','YELLOW','RED','SHOT','FOUL','SAVE'))
);

CREATE INDEX idx_events_match ON events(match_id);
CREATE INDEX idx_events_player ON events(player_id);

-- Transfers
CREATE TABLE transfers (
  transfer_id SERIAL PRIMARY KEY,
  player_id INT NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,
  from_club_id INT REFERENCES clubs(club_id) ON DELETE SET NULL,
  to_club_id   INT REFERENCES clubs(club_id) ON DELETE SET NULL,
  fee_m_eur NUMERIC(12,2) CHECK (fee_m_eur >= 0),
  transfer_date DATE NOT NULL
);

-- View: top scorers per club (goals only)
CREATE OR REPLACE VIEW v_top_scorers AS
SELECT p.player_id, p.first_name, p.last_name, c.name AS club, COUNT(*) AS goals
FROM events e
JOIN players p ON p.player_id = e.player_id
JOIN clubs   c ON c.club_id   = e.club_id
WHERE e.type = 'GOAL'
GROUP BY p.player_id, p.first_name, p.last_name, c.name
ORDER BY goals DESC, last_name;