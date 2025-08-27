-- Football Analytics Seed
SET search_path = football_analytics, public;

INSERT INTO clubs (name, country) VALUES
('Arsenal','England'),
('Real Madrid','Spain'),
('Dortmund','Germany');

INSERT INTO players (club_id, first_name, last_name, dob, position, market_value_m_eur) VALUES
(1,'Bukayo','Saka','2001-09-05','FW',130.00),
(1,'Martin','Odegaard','1998-12-17','MF',110.00),
(2,'Jude','Bellingham','2003-06-29','MF',180.00),
(2,'Vinicius','Junior','2000-07-12','FW',200.00),
(3,'Marco','Reus','1989-05-31','MF',8.00);

-- Create a few matches
INSERT INTO matches (match_date, home_club_id, away_club_id, home_goals, away_goals) VALUES
('2025-08-10', 1, 3, 2, 1), -- Arsenal vs Dortmund
('2025-08-12', 2, 1, 1, 1);  -- Real Madrid vs Arsenal

-- Appearances (simplified)
INSERT INTO appearances (match_id, player_id, club_id, minutes_played, starter) VALUES
(1, 1, 1, 90, TRUE), -- Saka
(1, 2, 1, 90, TRUE), -- Odegaard
(1, 5, 3, 90, TRUE), -- Reus
(2, 1, 1, 90, TRUE),
(2, 2, 1, 90, TRUE),
(2, 3, 2, 90, TRUE), -- Bellingham
(2, 4, 2, 90, TRUE); -- Vinicius

-- Events
-- Match 1 (Arsenal 2-1 Dortmund)
INSERT INTO events (match_id, minute, player_id, club_id, type) VALUES
(1, 15, 1, 1, 'GOAL'),
(1, 30, 2, 1, 'ASSIST'),
(1, 55, 5, 3, 'GOAL'),
(1, 70, 1, 1, 'GOAL'),
(1, 88, 5, 3, 'YELLOW');

-- Match 2 (Real Madrid 1-1 Arsenal)
INSERT INTO events (match_id, minute, player_id, club_id, type) VALUES
(2, 22, 4, 2, 'GOAL'),
(2, 76, 1, 1, 'GOAL'),
(2, 84, 3, 2, 'YELLOW');

-- Transfers (example: Reus to Arsenal, fictional date/fee)
INSERT INTO transfers (player_id, from_club_id, to_club_id, fee_m_eur, transfer_date)
VALUES (5, 3, 1, 5.00, '2025-07-15');