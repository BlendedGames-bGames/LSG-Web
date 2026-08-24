-- ============================================
-- LifeSync Games Cloud Module — Demo Seed Data
-- ============================================
-- Run this AFTER bGames_backup.sql and 002_sso_migration.sql have been loaded.
-- Safe to run multiple times (uses INSERT IGNORE).
--
-- This script populates the bgames database with realistic demo data
-- so the S12 Website dashboard shows meaningful visualizations:
--   - Radar charts (dimension levels)
--   - Line charts (dimension evolution over time)
--   - Circle Package charts (sensor contributions)
--   - TreeMap charts (sensor endpoint contributions)
--   - Data tables (acquired subattributes list, expended attributes list)
--
-- Record counts:
--   online_sensor:                              4 sensors
--   sensor_endpoint:                           12 endpoints (3 per sensor)
--   ` conversion`:                             12 conversions (ids 1-12)
--   subattributes:                             14 new + 1 existing = 15 total
--   subattributes_conversion_sensor_endpoint:  20 junction records
--   player_online_sensor:                       4 records
--   players_sensor_endpoint:                   12 records
--   adquired_subattribute:                    270 records (~3 months of readings)
--   playerss_attributes:                        5 updated dimension totals
--   videogame:                                  2 new games (ids 3, 4)
--   modifiable_mechanic:                        4 new mechanics (ids 2-5)
--   modifiable_mechanic_videogames:             6 new junction records
--   modifiable_conversion_attribute:            8 new junction records
--   expended_attribute:                        50 records
-- ============================================

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE;
SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';

-- ============================================
-- 1. ONLINE SENSORS
-- ============================================
-- 4 realistic sensors representing different data sources
-- base_url = NULL means offline/local sensor (no OAuth needed)

INSERT IGNORE INTO `online_sensor`
  (`id_online_sensor`, `name`, `description`, `base_url`, `initiated_date`, `last_modified`)
VALUES
  (0, 'Chess.com', 'Online chess platform — cognitive and strategic gameplay metrics', 'https://api.chess.com/pub/player/', NOW(), NOW()),
  (1, 'Duolingo', 'Language learning platform — linguistic skill progression', 'https://www.duolingo.com/2017-06-30/users/', NOW(), NOW()),
  (2, 'Fitbit Tracker', 'Wearable fitness tracker — physical activity and health metrics', NULL, NOW(), NOW()),
  (3, 'Twitter/X Social', 'Social media platform — social interaction and influence metrics', 'https://api.twitter.com/2/users/', NOW(), NOW());


-- ============================================
-- 2. SENSOR ENDPOINTS
-- ============================================
-- 3 endpoints per sensor = 12 total
-- Each endpoint represents a specific data point that can be captured

INSERT IGNORE INTO `sensor_endpoint`
  (`id_sensor_endpoint`, `sensor_endpoint_id_online_sensor`, `name`, `description`,
   `url_endpoint`, `token_parameters`, `specific_parameters`, `watch_parameters`,
   `initiated_date`, `last_modified`)
VALUES
  -- Chess.com endpoints (sensor 0)
  (0, 0, 'games_played',   'Number of chess games played in a period',
   '/stats', NULL, NULL, NULL, NOW(), NOW()),
  (1, 0, 'rating_elo',     'Current ELO rating in rapid/blitz chess',
   '/stats', NULL, NULL, NULL, NOW(), NOW()),
  (2, 0, 'puzzles_solved', 'Number of tactical puzzles solved',
   '/stats', NULL, NULL, NULL, NOW(), NOW()),

  -- Duolingo endpoints (sensor 1)
  (3, 1, 'lessons_completed', 'Language lessons completed',
   '/courses', NULL, NULL, NULL, NOW(), NOW()),
  (4, 1, 'streak_days',      'Consecutive days of practice',
   '/streak', NULL, NULL, NULL, NOW(), NOW()),
  (5, 1, 'xp_earned',        'Experience points earned from exercises',
   '/xp', NULL, NULL, NULL, NOW(), NOW()),

  -- Fitbit Tracker endpoints (sensor 2, offline)
  (6, 2, 'steps_count',    'Daily step count from wearable device',
   NULL, NULL, NULL, NULL, NOW(), NOW()),
  (7, 2, 'heart_rate_avg', 'Average resting heart rate in BPM',
   NULL, NULL, NULL, NULL, NOW(), NOW()),
  (8, 2, 'sleep_hours',    'Hours of sleep per night',
   NULL, NULL, NULL, NULL, NOW(), NOW()),

  -- Twitter/X Social endpoints (sensor 3)
  (9,  3, 'tweets_count',      'Number of tweets/posts published',
   '/tweets/counts', NULL, NULL, NULL, NOW(), NOW()),
  (10, 3, 'followers_gained',  'New followers gained in period',
   '/followers', NULL, NULL, NULL, NOW(), NOW()),
  (11, 3, 'interactions',      'Total likes, retweets, and replies received',
   '/tweets', NULL, NULL, NULL, NOW(), NOW());


-- ============================================
-- 3. CONVERSIONS
-- ============================================
-- NOTE: Table name has a leading space: ` conversion`
-- Each conversion defines a formula to transform raw sensor data
-- into subattribute points. The `operations` field stores the formula.

INSERT IGNORE INTO ` conversion`
  (`id_conversion`, `name`, `description`, `operations`, `initiated_date`, `last_modified`)
VALUES
  -- id 0 already exists (placeholder)
  (1,  'linear_add_2',       'Simple linear: x + 2',               'x+2',          NOW(), NOW()),
  (2,  'half_value',         'Half the raw value: x * 0.5',        'x*0.5',        NOW(), NOW()),
  (3,  'sqrt_plus_one',      'Square root scaling: sqrt(x+1)',     'sqrt(x+1)',    NOW(), NOW()),
  (4,  'double_value',       'Double the raw value: x * 2',        'x*2',          NOW(), NOW()),
  (5,  'log_scale',          'Logarithmic scaling: log2(x+1)',     'log2(x+1)',    NOW(), NOW()),
  (6,  'tenth_value',        'Scale down by 10: x * 0.1',          'x*0.1',        NOW(), NOW()),
  (7,  'linear_add_5',       'Linear offset: x + 5',               'x+5',          NOW(), NOW()),
  (8,  'quarter_value',      'Quarter the raw value: x * 0.25',    'x*0.25',       NOW(), NOW()),
  (9,  'cube_root',          'Cube root scaling: cbrt(x)',          'cbrt(x)',      NOW(), NOW()),
  (10, 'triple_value',       'Triple the raw value: x * 3',        'x*3',          NOW(), NOW()),
  (11, 'diminishing_return', 'Diminishing returns: x / (x+10)',    'x/(x+10)',     NOW(), NOW()),
  (12, 'step_normalize',     'Step normalization: floor(x/100)',    'floor(x/100)', NOW(), NOW());


-- ============================================
-- 4. SUBATTRIBUTES
-- ============================================
-- Expand from 1 existing (id 0, Reconocimiento, Social) to 15 total.
-- 3 subattributes per dimension × 5 dimensions = 15
-- attributes_id_attributes: 0=Social, 1=Fisica, 2=Afectivo, 3=Cognitivo, 4=Linguistico

INSERT IGNORE INTO `subattributes`
  (`id_subattributes`, `name`, `description`, `initiated_date`, `last_modified`, `attributes_id_attributes`)
VALUES
  -- Social (attribute 0) — id 0 already exists
  (1,  'Empatia',                'Capacidad de comprender y compartir sentimientos de otros',            NOW(), NOW(), 0),
  (2,  'Colaboracion',           'Capacidad de trabajar efectivamente en equipo',                        NOW(), NOW(), 0),

  -- Fisica (attribute 1)
  (3,  'Resistencia',            'Capacidad de mantener actividad fisica prolongada',                    NOW(), NOW(), 1),
  (4,  'Coordinacion',           'Habilidad motriz y coordinacion ojo-mano',                             NOW(), NOW(), 1),
  (5,  'Fuerza',                 'Capacidad de ejercer fuerza fisica',                                   NOW(), NOW(), 1),

  -- Afectivo (attribute 2)
  (6,  'Motivacion',             'Nivel de motivacion intrinseca y persistencia',                         NOW(), NOW(), 2),
  (7,  'Autoconfianza',          'Nivel de confianza en las propias capacidades',                        NOW(), NOW(), 2),
  (8,  'Regulacion Emocional',   'Capacidad de gestionar emociones en situaciones de estres',            NOW(), NOW(), 2),

  -- Cognitivo (attribute 3)
  (9,  'Resolucion de Problemas','Capacidad de analizar y resolver problemas complejos',                 NOW(), NOW(), 3),
  (10, 'Memoria',                'Capacidad de retener y recuperar informacion',                         NOW(), NOW(), 3),
  (11, 'Pensamiento Estrategico','Habilidad de planificar y anticipar consecuencias',                    NOW(), NOW(), 3),

  -- Linguistico (attribute 4)
  (12, 'Comprension Lectora',    'Capacidad de comprender textos escritos',                              NOW(), NOW(), 4),
  (13, 'Vocabulario',            'Amplitud y riqueza del vocabulario utilizado',                          NOW(), NOW(), 4),
  (14, 'Expresion Escrita',      'Capacidad de comunicarse efectivamente por escrito',                   NOW(), NOW(), 4);


-- ============================================
-- 5. JUNCTION: subattributes_conversion_sensor_endpoint
-- ============================================
-- Links sensor endpoints → subattributes via conversions.
-- This is the core mapping: "endpoint X feeds subattribute Y using conversion Z"
-- Each sensor can contribute to multiple dimensions.
--
-- Design rationale for mappings:
--   Chess.com → Cognitivo (primary), Afectivo (secondary)
--   Duolingo  → Linguistico (primary), Cognitivo (secondary)
--   Fitbit    → Fisica (primary), Afectivo (secondary)
--   Twitter   → Social (primary), Linguistico (secondary)

INSERT IGNORE INTO `subattributes_conversion_sensor_endpoint`
  (`id_subattributes_conversion_sensor_endpoint`, `id_subattributes`, `id_sensor_endpoint`, `id_conversion`, `parameters_watched`)
VALUES
  -- Chess.com: games_played (endpoint 0)
  (0,  9,  0, 2,  NULL),  -- games_played → Resolucion de Problemas (half_value)
  (1,  6,  0, 5,  NULL),  -- games_played → Motivacion (log_scale)

  -- Chess.com: rating_elo (endpoint 1)
  (2,  11, 1, 6,  NULL),  -- rating_elo → Pensamiento Estrategico (tenth_value)
  (3,  7,  1, 12, NULL),  -- rating_elo → Autoconfianza (step_normalize)

  -- Chess.com: puzzles_solved (endpoint 2)
  (4,  9,  2, 1,  NULL),  -- puzzles_solved → Resolucion de Problemas (linear_add_2)
  (5,  10, 2, 3,  NULL),  -- puzzles_solved → Memoria (sqrt_plus_one)

  -- Duolingo: lessons_completed (endpoint 3)
  (6,  13, 3, 4,  NULL),  -- lessons_completed → Vocabulario (double_value)
  (7,  12, 3, 1,  NULL),  -- lessons_completed → Comprension Lectora (linear_add_2)

  -- Duolingo: streak_days (endpoint 4)
  (8,  6,  4, 7,  NULL),  -- streak_days → Motivacion (linear_add_5)
  (9,  14, 4, 2,  NULL),  -- streak_days → Expresion Escrita (half_value)

  -- Duolingo: xp_earned (endpoint 5)
  (10, 13, 5, 6,  NULL),  -- xp_earned → Vocabulario (tenth_value)
  (11, 10, 5, 8,  NULL),  -- xp_earned → Memoria (quarter_value)

  -- Fitbit: steps_count (endpoint 6)
  (12, 3,  6, 12, NULL),  -- steps_count → Resistencia (step_normalize — floor(x/100))
  (13, 5,  6, 8,  NULL),  -- steps_count → Fuerza (quarter_value)

  -- Fitbit: heart_rate_avg (endpoint 7)
  (14, 4,  7, 11, NULL),  -- heart_rate_avg → Coordinacion (diminishing_return)
  (15, 8,  7, 9,  NULL),  -- heart_rate_avg → Regulacion Emocional (cube_root)

  -- Fitbit: sleep_hours (endpoint 8)
  (16, 8,  8, 4,  NULL),  -- sleep_hours → Regulacion Emocional (double_value)

  -- Twitter: tweets_count (endpoint 9)
  (17, 14, 9, 3,  NULL),  -- tweets_count → Expresion Escrita (sqrt_plus_one)

  -- Twitter: followers_gained (endpoint 10)
  (18, 0,  10, 10, NULL), -- followers_gained → Reconocimiento (triple_value)

  -- Twitter: interactions (endpoint 11)
  (19, 1,  11, 2,  NULL); -- interactions → Empatia (half_value)


-- ============================================
-- 6. PLAYER-SENSOR ASSOCIATIONS
-- ============================================
-- Associate player 0 (test) with all 4 sensors and all 12 endpoints

-- player_online_sensor: player 0 ↔ each sensor
INSERT IGNORE INTO `player_online_sensor`
  (`id_players_online_sensor`, `id_online_sensor`, `tokens`, `initiated_date`, `last_modified`)
VALUES
  (0, '0', '{"access_token": "demo_chess_token"}',  NOW(), NOW()),
  (1, '1', '{"access_token": "demo_duolingo_token"}', NOW(), NOW()),
  (2, '2', NULL, NOW(), NOW()),  -- Fitbit is offline, no token needed
  (3, '3', '{"access_token": "demo_twitter_token"}', NOW(), NOW());

-- players_sensor_endpoint: player 0 ↔ each endpoint
INSERT IGNORE INTO `players_sensor_endpoint`
  (`id_players_sensor_endpoint`, `id_players`, `Id_sensor_endpoint`,
   `specific_parameters`, `activated`, `schedule_time`)
VALUES
  (0,  0, 0,  NULL, 1, 3600),
  (1,  0, 1,  NULL, 1, 3600),
  (2,  0, 2,  NULL, 1, 3600),
  (3,  0, 3,  NULL, 1, 3600),
  (4,  0, 4,  NULL, 1, 3600),
  (5,  0, 5,  NULL, 1, 3600),
  (6,  0, 6,  NULL, 1, 3600),
  (7,  0, 7,  NULL, 1, 3600),
  (8,  0, 8,  NULL, 1, 3600),
  (9,  0, 9,  NULL, 1, 3600),
  (10, 0, 10, NULL, 1, 3600),
  (11, 0, 11, NULL, 1, 3600);


-- ============================================
-- 7. ACQUIRED SUBATTRIBUTES (Bulk Sensor Readings)
-- ============================================
-- ~270 records for player 0, spread across Dec 2025 – Feb 2026
-- Realistic patterns:
--   - Physical activity (Fitbit) higher on weekends
--   - Language learning (Duolingo) mostly weekday mornings
--   - Chess in evenings
--   - Social (Twitter) throughout the day
--
-- Values are the CONVERTED values (after applying the conversion formula),
-- i.e., the actual points added to the subattribute.
--
-- id_subattributes_conversion_sensor_endpoint references junction table (section 5)

INSERT IGNORE INTO `adquired_subattribute`
  (`id_adquired_subattribute`, `id_players`, `id_subattributes_conversion_sensor_endpoint`, `data`, `created_time`)
VALUES
-- ==============================
-- DECEMBER 2025
-- ==============================

-- Dec 1 (Mon) — Chess evening, Duolingo morning
(1,   0, 0,  3,  '2025-12-01 20:15:00'),  -- Chess games → Resolucion Problemas
(2,   0, 2,  8,  '2025-12-01 20:15:00'),  -- Chess elo → Pensamiento Estrategico
(3,   0, 6,  6,  '2025-12-01 07:30:00'),  -- Duolingo lessons → Vocabulario
(4,   0, 7,  4,  '2025-12-01 07:30:00'),  -- Duolingo lessons → Comprension Lectora
(5,   0, 12, 45, '2025-12-01 18:00:00'),  -- Fitbit steps → Resistencia

-- Dec 3 (Wed)
(6,   0, 0,  4,  '2025-12-03 21:00:00'),
(7,   0, 4,  5,  '2025-12-03 21:00:00'),  -- Chess puzzles → Resolucion Problemas
(8,   0, 5,  3,  '2025-12-03 21:00:00'),  -- Chess puzzles → Memoria
(9,   0, 6,  8,  '2025-12-03 07:15:00'),  -- Duolingo → Vocabulario
(10,  0, 8,  12, '2025-12-03 07:15:00'),  -- Duolingo streak → Motivacion
(11,  0, 12, 52, '2025-12-03 18:30:00'),  -- Fitbit steps → Resistencia
(12,  0, 19, 5,  '2025-12-03 14:00:00'),  -- Twitter interactions → Empatia

-- Dec 5 (Fri)
(13,  0, 2,  9,  '2025-12-05 22:00:00'),  -- Chess elo → Pensamiento Estrategico
(14,  0, 1,  2,  '2025-12-05 22:00:00'),  -- Chess games → Motivacion
(15,  0, 10, 4,  '2025-12-05 08:00:00'),  -- Duolingo xp → Vocabulario
(16,  0, 11, 6,  '2025-12-05 08:00:00'),  -- Duolingo xp → Memoria
(17,  0, 12, 38, '2025-12-05 17:00:00'),  -- Fitbit steps → Resistencia
(18,  0, 17, 3,  '2025-12-05 12:30:00'),  -- Twitter tweets → Expresion Escrita

-- Dec 6 (Sat) — More physical activity on weekends
(19,  0, 12, 95, '2025-12-06 10:00:00'),  -- Fitbit steps (weekend, high)
(20,  0, 13, 18, '2025-12-06 10:00:00'),  -- Fitbit steps → Fuerza
(21,  0, 14, 4,  '2025-12-06 10:00:00'),  -- Fitbit HR → Coordinacion
(22,  0, 15, 3,  '2025-12-06 10:00:00'),  -- Fitbit HR → Regulacion Emocional
(23,  0, 16, 14, '2025-12-06 23:00:00'),  -- Fitbit sleep → Regulacion Emocional
(24,  0, 18, 6,  '2025-12-06 15:00:00'),  -- Twitter followers → Reconocimiento
(25,  0, 19, 7,  '2025-12-06 15:00:00'),  -- Twitter interactions → Empatia

-- Dec 7 (Sun) — Weekend physical
(26,  0, 12, 110,'2025-12-07 11:00:00'),  -- Fitbit steps (Sunday hike)
(27,  0, 13, 22, '2025-12-07 11:00:00'),  -- Fitbit → Fuerza
(28,  0, 16, 16, '2025-12-07 23:30:00'),  -- Fitbit sleep → Regulacion Emocional
(29,  0, 0,  5,  '2025-12-07 20:00:00'),  -- Chess games → Resolucion Problemas
(30,  0, 2,  11, '2025-12-07 20:00:00'),  -- Chess elo → Pensamiento Estrategico

-- Dec 9 (Tue)
(31,  0, 6,  10, '2025-12-09 07:00:00'),  -- Duolingo → Vocabulario
(32,  0, 7,  6,  '2025-12-09 07:00:00'),  -- Duolingo → Comprension Lectora
(33,  0, 8,  14, '2025-12-09 07:00:00'),  -- Duolingo streak → Motivacion
(34,  0, 12, 48, '2025-12-09 18:00:00'),  -- Fitbit → Resistencia
(35,  0, 0,  3,  '2025-12-09 21:30:00'),  -- Chess → Resolucion Problemas

-- Dec 11 (Thu)
(36,  0, 4,  7,  '2025-12-11 21:00:00'),  -- Chess puzzles → Resolucion Problemas
(37,  0, 5,  4,  '2025-12-11 21:00:00'),  -- Chess puzzles → Memoria
(38,  0, 10, 5,  '2025-12-11 07:45:00'),  -- Duolingo xp → Vocabulario
(39,  0, 9,  3,  '2025-12-11 07:45:00'),  -- Duolingo streak → Expresion Escrita
(40,  0, 12, 55, '2025-12-11 19:00:00'),  -- Fitbit → Resistencia
(41,  0, 17, 4,  '2025-12-11 13:00:00'),  -- Twitter tweets → Expresion Escrita

-- Dec 13 (Sat) — Weekend
(42,  0, 12, 120,'2025-12-13 09:00:00'),  -- Fitbit steps (weekend run)
(43,  0, 13, 25, '2025-12-13 09:00:00'),  -- Fitbit → Fuerza
(44,  0, 14, 5,  '2025-12-13 09:00:00'),  -- Fitbit HR → Coordinacion
(45,  0, 15, 4,  '2025-12-13 09:00:00'),  -- Fitbit HR → Regulacion Emocional
(46,  0, 16, 15, '2025-12-13 23:00:00'),  -- Fitbit sleep → Regulacion Emocional
(47,  0, 18, 9,  '2025-12-13 16:00:00'),  -- Twitter followers → Reconocimiento
(48,  0, 2,  12, '2025-12-13 22:00:00'),  -- Chess elo → Pensamiento Estrategico

-- Dec 14 (Sun)
(49,  0, 12, 105,'2025-12-14 10:30:00'),  -- Fitbit steps
(50,  0, 13, 20, '2025-12-14 10:30:00'),  -- Fitbit → Fuerza
(51,  0, 0,  6,  '2025-12-14 19:30:00'),  -- Chess → Resolucion Problemas
(52,  0, 1,  3,  '2025-12-14 19:30:00'),  -- Chess → Motivacion

-- Dec 16 (Tue)
(53,  0, 6,  12, '2025-12-16 06:45:00'),  -- Duolingo → Vocabulario
(54,  0, 7,  7,  '2025-12-16 06:45:00'),  -- Duolingo → Comprension Lectora
(55,  0, 12, 42, '2025-12-16 18:00:00'),  -- Fitbit → Resistencia
(56,  0, 19, 8,  '2025-12-16 11:00:00'),  -- Twitter → Empatia

-- Dec 18 (Thu)
(57,  0, 4,  8,  '2025-12-18 20:30:00'),  -- Chess puzzles → Resolucion Problemas
(58,  0, 5,  5,  '2025-12-18 20:30:00'),  -- Chess puzzles → Memoria
(59,  0, 3,  10, '2025-12-18 20:30:00'),  -- Chess elo → Autoconfianza
(60,  0, 10, 6,  '2025-12-18 08:00:00'),  -- Duolingo xp → Vocabulario
(61,  0, 12, 50, '2025-12-18 17:30:00'),  -- Fitbit → Resistencia

-- Dec 20 (Sat) — Weekend
(62,  0, 12, 130,'2025-12-20 08:30:00'),  -- Fitbit steps (long walk)
(63,  0, 13, 28, '2025-12-20 08:30:00'),  -- Fitbit → Fuerza
(64,  0, 14, 5,  '2025-12-20 08:30:00'),  -- Fitbit HR → Coordinacion
(65,  0, 16, 16, '2025-12-20 23:00:00'),  -- Fitbit sleep → Regulacion Emocional
(66,  0, 18, 12, '2025-12-20 14:00:00'),  -- Twitter followers → Reconocimiento
(67,  0, 19, 10, '2025-12-20 14:00:00'),  -- Twitter → Empatia

-- Dec 21 (Sun)
(68,  0, 12, 88, '2025-12-21 11:00:00'),  -- Fitbit
(69,  0, 0,  4,  '2025-12-21 21:00:00'),  -- Chess → Resolucion Problemas
(70,  0, 2,  7,  '2025-12-21 21:00:00'),  -- Chess elo → Pensamiento Estrategico

-- Dec 23 (Tue) — Holiday season, more activity
(71,  0, 6,  14, '2025-12-23 07:30:00'),  -- Duolingo → Vocabulario
(72,  0, 7,  8,  '2025-12-23 07:30:00'),  -- Duolingo → Comprension Lectora
(73,  0, 8,  16, '2025-12-23 07:30:00'),  -- Duolingo streak → Motivacion
(74,  0, 12, 65, '2025-12-23 16:00:00'),  -- Fitbit → Resistencia
(75,  0, 18, 8,  '2025-12-23 13:00:00'),  -- Twitter followers → Reconocimiento

-- Dec 25 (Thu) — Christmas
(76,  0, 16, 18, '2025-12-25 23:30:00'),  -- Fitbit sleep (good rest)
(77,  0, 12, 35, '2025-12-25 15:00:00'),  -- Fitbit steps (light day)
(78,  0, 19, 12, '2025-12-25 12:00:00'),  -- Twitter interactions (holiday posts)
(79,  0, 18, 15, '2025-12-25 12:00:00'),  -- Twitter followers → Reconocimiento

-- Dec 27 (Sat)
(80,  0, 12, 140,'2025-12-27 09:00:00'),  -- Fitbit steps (weekend hike)
(81,  0, 13, 30, '2025-12-27 09:00:00'),  -- Fitbit → Fuerza
(82,  0, 15, 4,  '2025-12-27 09:00:00'),  -- Fitbit HR → Regulacion Emocional
(83,  0, 0,  7,  '2025-12-27 20:00:00'),  -- Chess → Resolucion Problemas
(84,  0, 2,  13, '2025-12-27 20:00:00'),  -- Chess elo → Pensamiento Estrategico
(85,  0, 4,  9,  '2025-12-27 20:00:00'),  -- Chess puzzles → Resolucion Problemas

-- Dec 29 (Mon)
(86,  0, 6,  8,  '2025-12-29 08:00:00'),  -- Duolingo → Vocabulario
(87,  0, 10, 7,  '2025-12-29 08:00:00'),  -- Duolingo xp → Vocabulario
(88,  0, 11, 8,  '2025-12-29 08:00:00'),  -- Duolingo xp → Memoria
(89,  0, 12, 58, '2025-12-29 17:00:00'),  -- Fitbit → Resistencia
(90,  0, 17, 5,  '2025-12-29 15:00:00'),  -- Twitter tweets → Expresion Escrita

-- Dec 31 (Wed) — New Year's Eve
(91,  0, 12, 75, '2025-12-31 14:00:00'),  -- Fitbit steps
(92,  0, 19, 15, '2025-12-31 22:00:00'),  -- Twitter interactions (NYE)
(93,  0, 18, 18, '2025-12-31 22:00:00'),  -- Twitter followers → Reconocimiento
(94,  0, 16, 12, '2025-12-31 23:59:00'),  -- Fitbit sleep

-- ==============================
-- JANUARY 2026
-- ==============================

-- Jan 2 (Fri)
(95,  0, 0,  5,  '2026-01-02 21:00:00'),  -- Chess → Resolucion Problemas
(96,  0, 2,  10, '2026-01-02 21:00:00'),  -- Chess elo → Pensamiento Estrategico
(97,  0, 3,  8,  '2026-01-02 21:00:00'),  -- Chess elo → Autoconfianza
(98,  0, 6,  10, '2026-01-02 07:00:00'),  -- Duolingo → Vocabulario
(99,  0, 7,  6,  '2026-01-02 07:00:00'),  -- Duolingo → Comprension Lectora
(100, 0, 12, 60, '2026-01-02 18:00:00'),  -- Fitbit → Resistencia

-- Jan 3 (Sat) — Weekend
(101, 0, 12, 125,'2026-01-03 09:30:00'),  -- Fitbit (weekend run)
(102, 0, 13, 26, '2026-01-03 09:30:00'),  -- Fitbit → Fuerza
(103, 0, 14, 5,  '2026-01-03 09:30:00'),  -- Fitbit HR → Coordinacion
(104, 0, 16, 15, '2026-01-03 23:00:00'),  -- Fitbit sleep
(105, 0, 0,  6,  '2026-01-03 20:00:00'),  -- Chess → Resolucion Problemas
(106, 0, 4,  10, '2026-01-03 20:00:00'),  -- Chess puzzles → Resolucion Problemas

-- Jan 4 (Sun)
(107, 0, 12, 115,'2026-01-04 10:00:00'),  -- Fitbit
(108, 0, 13, 24, '2026-01-04 10:00:00'),  -- Fitbit → Fuerza
(109, 0, 15, 4,  '2026-01-04 10:00:00'),  -- Fitbit HR → Regulacion Emocional
(110, 0, 19, 6,  '2026-01-04 16:00:00'),  -- Twitter → Empatia

-- Jan 6 (Tue)
(111, 0, 6,  14, '2026-01-06 07:15:00'),  -- Duolingo → Vocabulario
(112, 0, 7,  8,  '2026-01-06 07:15:00'),  -- Duolingo → Comprension Lectora
(113, 0, 8,  18, '2026-01-06 07:15:00'),  -- Duolingo streak → Motivacion
(114, 0, 9,  4,  '2026-01-06 07:15:00'),  -- Duolingo streak → Expresion Escrita
(115, 0, 12, 55, '2026-01-06 18:30:00'),  -- Fitbit → Resistencia
(116, 0, 17, 4,  '2026-01-06 12:00:00'),  -- Twitter tweets → Expresion Escrita

-- Jan 8 (Thu)
(117, 0, 0,  4,  '2026-01-08 20:45:00'),  -- Chess → Resolucion Problemas
(118, 0, 2,  9,  '2026-01-08 20:45:00'),  -- Chess elo → Pensamiento Estrategico
(119, 0, 5,  5,  '2026-01-08 20:45:00'),  -- Chess puzzles → Memoria
(120, 0, 10, 5,  '2026-01-08 08:00:00'),  -- Duolingo xp → Vocabulario
(121, 0, 12, 48, '2026-01-08 17:00:00'),  -- Fitbit → Resistencia

-- Jan 10 (Sat)
(122, 0, 12, 135,'2026-01-10 08:00:00'),  -- Fitbit (weekend)
(123, 0, 13, 28, '2026-01-10 08:00:00'),  -- Fitbit → Fuerza
(124, 0, 14, 6,  '2026-01-10 08:00:00'),  -- Fitbit HR → Coordinacion
(125, 0, 15, 4,  '2026-01-10 08:00:00'),  -- Fitbit HR → Regulacion Emocional
(126, 0, 16, 16, '2026-01-10 23:00:00'),  -- Fitbit sleep
(127, 0, 18, 10, '2026-01-10 15:00:00'),  -- Twitter followers → Reconocimiento
(128, 0, 19, 9,  '2026-01-10 15:00:00'),  -- Twitter → Empatia

-- Jan 11 (Sun)
(129, 0, 12, 100,'2026-01-11 11:00:00'),  -- Fitbit
(130, 0, 0,  8,  '2026-01-11 19:00:00'),  -- Chess → Resolucion Problemas
(131, 0, 2,  14, '2026-01-11 19:00:00'),  -- Chess elo → Pensamiento Estrategico
(132, 0, 1,  3,  '2026-01-11 19:00:00'),  -- Chess games → Motivacion

-- Jan 13 (Tue)
(133, 0, 6,  16, '2026-01-13 07:00:00'),  -- Duolingo → Vocabulario
(134, 0, 7,  9,  '2026-01-13 07:00:00'),  -- Duolingo → Comprension Lectora
(135, 0, 8,  20, '2026-01-13 07:00:00'),  -- Duolingo streak → Motivacion (growing streak!)
(136, 0, 12, 50, '2026-01-13 18:00:00'),  -- Fitbit → Resistencia

-- Jan 15 (Thu)
(137, 0, 4,  11, '2026-01-15 21:00:00'),  -- Chess puzzles → Resolucion Problemas
(138, 0, 5,  6,  '2026-01-15 21:00:00'),  -- Chess puzzles → Memoria
(139, 0, 3,  12, '2026-01-15 21:00:00'),  -- Chess elo → Autoconfianza (improving!)
(140, 0, 10, 7,  '2026-01-15 08:00:00'),  -- Duolingo xp → Vocabulario
(141, 0, 11, 9,  '2026-01-15 08:00:00'),  -- Duolingo xp → Memoria
(142, 0, 12, 58, '2026-01-15 17:30:00'),  -- Fitbit → Resistencia
(143, 0, 17, 5,  '2026-01-15 13:00:00'),  -- Twitter → Expresion Escrita

-- Jan 17 (Sat) — Weekend
(144, 0, 12, 145,'2026-01-17 08:30:00'),  -- Fitbit (best weekend yet!)
(145, 0, 13, 32, '2026-01-17 08:30:00'),  -- Fitbit → Fuerza
(146, 0, 14, 6,  '2026-01-17 08:30:00'),  -- Fitbit HR → Coordinacion
(147, 0, 16, 17, '2026-01-17 23:00:00'),  -- Fitbit sleep
(148, 0, 18, 14, '2026-01-17 14:00:00'),  -- Twitter followers → Reconocimiento
(149, 0, 2,  15, '2026-01-17 21:00:00'),  -- Chess elo → Pensamiento Estrategico

-- Jan 18 (Sun)
(150, 0, 12, 108,'2026-01-18 10:00:00'),  -- Fitbit
(151, 0, 13, 22, '2026-01-18 10:00:00'),  -- Fitbit → Fuerza
(152, 0, 19, 11, '2026-01-18 16:00:00'),  -- Twitter → Empatia

-- Jan 20 (Tue)
(153, 0, 6,  18, '2026-01-20 06:30:00'),  -- Duolingo → Vocabulario
(154, 0, 7,  10, '2026-01-20 06:30:00'),  -- Duolingo → Comprension Lectora
(155, 0, 8,  22, '2026-01-20 06:30:00'),  -- Duolingo streak → Motivacion
(156, 0, 12, 52, '2026-01-20 18:00:00'),  -- Fitbit → Resistencia
(157, 0, 0,  5,  '2026-01-20 21:00:00'),  -- Chess → Resolucion Problemas

-- Jan 22 (Thu)
(158, 0, 4,  12, '2026-01-22 20:00:00'),  -- Chess puzzles → Resolucion Problemas
(159, 0, 5,  7,  '2026-01-22 20:00:00'),  -- Chess puzzles → Memoria
(160, 0, 2,  11, '2026-01-22 20:00:00'),  -- Chess elo → Pensamiento Estrategico
(161, 0, 10, 8,  '2026-01-22 08:00:00'),  -- Duolingo xp → Vocabulario
(162, 0, 12, 62, '2026-01-22 17:00:00'),  -- Fitbit → Resistencia

-- Jan 24 (Sat)
(163, 0, 12, 150,'2026-01-24 08:00:00'),  -- Fitbit (peak weekend)
(164, 0, 13, 35, '2026-01-24 08:00:00'),  -- Fitbit → Fuerza
(165, 0, 14, 7,  '2026-01-24 08:00:00'),  -- Fitbit HR → Coordinacion
(166, 0, 15, 5,  '2026-01-24 08:00:00'),  -- Fitbit HR → Regulacion Emocional
(167, 0, 16, 16, '2026-01-24 23:00:00'),  -- Fitbit sleep
(168, 0, 18, 12, '2026-01-24 15:00:00'),  -- Twitter followers → Reconocimiento
(169, 0, 19, 8,  '2026-01-24 15:00:00'),  -- Twitter → Empatia

-- Jan 25 (Sun)
(170, 0, 12, 95, '2026-01-25 11:00:00'),  -- Fitbit
(171, 0, 0,  7,  '2026-01-25 19:30:00'),  -- Chess → Resolucion Problemas
(172, 0, 2,  12, '2026-01-25 19:30:00'),  -- Chess elo → Pensamiento Estrategico

-- Jan 27 (Tue)
(173, 0, 6,  20, '2026-01-27 07:00:00'),  -- Duolingo → Vocabulario (improving!)
(174, 0, 7,  11, '2026-01-27 07:00:00'),  -- Duolingo → Comprension Lectora
(175, 0, 9,  5,  '2026-01-27 07:00:00'),  -- Duolingo streak → Expresion Escrita
(176, 0, 12, 55, '2026-01-27 18:00:00'),  -- Fitbit → Resistencia
(177, 0, 17, 6,  '2026-01-27 12:30:00'),  -- Twitter tweets → Expresion Escrita

-- Jan 29 (Thu)
(178, 0, 0,  6,  '2026-01-29 21:15:00'),  -- Chess → Resolucion Problemas
(179, 0, 4,  13, '2026-01-29 21:15:00'),  -- Chess puzzles → Resolucion Problemas
(180, 0, 5,  7,  '2026-01-29 21:15:00'),  -- Chess puzzles → Memoria
(181, 0, 3,  14, '2026-01-29 21:15:00'),  -- Chess elo → Autoconfianza
(182, 0, 12, 48, '2026-01-29 17:30:00'),  -- Fitbit → Resistencia

-- Jan 31 (Sat)
(183, 0, 12, 138,'2026-01-31 09:00:00'),  -- Fitbit
(184, 0, 13, 30, '2026-01-31 09:00:00'),  -- Fitbit → Fuerza
(185, 0, 14, 6,  '2026-01-31 09:00:00'),  -- Fitbit HR → Coordinacion
(186, 0, 16, 15, '2026-01-31 23:00:00'),  -- Fitbit sleep
(187, 0, 19, 10, '2026-01-31 16:00:00'),  -- Twitter → Empatia
(188, 0, 18, 9,  '2026-01-31 16:00:00'),  -- Twitter followers → Reconocimiento

-- ==============================
-- FEBRUARY 2026
-- ==============================

-- Feb 1 (Sun)
(189, 0, 12, 112,'2026-02-01 10:00:00'),  -- Fitbit
(190, 0, 13, 23, '2026-02-01 10:00:00'),  -- Fitbit → Fuerza
(191, 0, 0,  8,  '2026-02-01 20:00:00'),  -- Chess → Resolucion Problemas
(192, 0, 2,  16, '2026-02-01 20:00:00'),  -- Chess elo → Pensamiento Estrategico (peak!)

-- Feb 3 (Tue)
(193, 0, 6,  22, '2026-02-03 07:00:00'),  -- Duolingo → Vocabulario
(194, 0, 7,  12, '2026-02-03 07:00:00'),  -- Duolingo → Comprension Lectora
(195, 0, 8,  24, '2026-02-03 07:00:00'),  -- Duolingo streak → Motivacion (long streak!)
(196, 0, 9,  6,  '2026-02-03 07:00:00'),  -- Duolingo streak → Expresion Escrita
(197, 0, 12, 58, '2026-02-03 18:00:00'),  -- Fitbit → Resistencia
(198, 0, 0,  4,  '2026-02-03 21:30:00'),  -- Chess → Resolucion Problemas

-- Feb 5 (Thu)
(199, 0, 4,  14, '2026-02-05 20:30:00'),  -- Chess puzzles → Resolucion Problemas
(200, 0, 5,  8,  '2026-02-05 20:30:00'),  -- Chess puzzles → Memoria
(201, 0, 2,  13, '2026-02-05 20:30:00'),  -- Chess elo → Pensamiento Estrategico
(202, 0, 10, 9,  '2026-02-05 08:00:00'),  -- Duolingo xp → Vocabulario
(203, 0, 11, 10, '2026-02-05 08:00:00'),  -- Duolingo xp → Memoria
(204, 0, 12, 65, '2026-02-05 17:00:00'),  -- Fitbit → Resistencia
(205, 0, 17, 6,  '2026-02-05 13:00:00'),  -- Twitter tweets → Expresion Escrita

-- Feb 7 (Sat)
(206, 0, 12, 155,'2026-02-07 08:00:00'),  -- Fitbit (new personal best!)
(207, 0, 13, 38, '2026-02-07 08:00:00'),  -- Fitbit → Fuerza
(208, 0, 14, 7,  '2026-02-07 08:00:00'),  -- Fitbit HR → Coordinacion
(209, 0, 15, 5,  '2026-02-07 08:00:00'),  -- Fitbit HR → Regulacion Emocional
(210, 0, 16, 17, '2026-02-07 23:00:00'),  -- Fitbit sleep
(211, 0, 18, 15, '2026-02-07 14:00:00'),  -- Twitter followers → Reconocimiento
(212, 0, 19, 12, '2026-02-07 14:00:00'),  -- Twitter → Empatia

-- Feb 8 (Sun)
(213, 0, 12, 120,'2026-02-08 10:30:00'),  -- Fitbit
(214, 0, 13, 25, '2026-02-08 10:30:00'),  -- Fitbit → Fuerza
(215, 0, 0,  9,  '2026-02-08 19:00:00'),  -- Chess → Resolucion Problemas
(216, 0, 2,  15, '2026-02-08 19:00:00'),  -- Chess elo → Pensamiento Estrategico
(217, 0, 1,  4,  '2026-02-08 19:00:00'),  -- Chess games → Motivacion

-- Feb 10 (Tue)
(218, 0, 6,  24, '2026-02-10 06:45:00'),  -- Duolingo → Vocabulario (best session!)
(219, 0, 7,  13, '2026-02-10 06:45:00'),  -- Duolingo → Comprension Lectora
(220, 0, 8,  26, '2026-02-10 06:45:00'),  -- Duolingo streak → Motivacion
(221, 0, 12, 62, '2026-02-10 18:00:00'),  -- Fitbit → Resistencia
(222, 0, 19, 7,  '2026-02-10 11:00:00'),  -- Twitter → Empatia

-- Feb 12 (Thu)
(223, 0, 4,  15, '2026-02-12 20:00:00'),  -- Chess puzzles → Resolucion Problemas
(224, 0, 5,  9,  '2026-02-12 20:00:00'),  -- Chess puzzles → Memoria
(225, 0, 3,  15, '2026-02-12 20:00:00'),  -- Chess elo → Autoconfianza (peak!)
(226, 0, 10, 8,  '2026-02-12 07:30:00'),  -- Duolingo xp → Vocabulario
(227, 0, 11, 11, '2026-02-12 07:30:00'),  -- Duolingo xp → Memoria
(228, 0, 12, 55, '2026-02-12 17:00:00'),  -- Fitbit → Resistencia
(229, 0, 17, 7,  '2026-02-12 12:30:00'),  -- Twitter → Expresion Escrita

-- Feb 14 (Sat) — Valentine's Day weekend
(230, 0, 12, 142,'2026-02-14 09:00:00'),  -- Fitbit
(231, 0, 13, 32, '2026-02-14 09:00:00'),  -- Fitbit → Fuerza
(232, 0, 14, 7,  '2026-02-14 09:00:00'),  -- Fitbit HR → Coordinacion
(233, 0, 16, 16, '2026-02-14 23:00:00'),  -- Fitbit sleep
(234, 0, 18, 20, '2026-02-14 13:00:00'),  -- Twitter followers → Reconocimiento (Valentine spike!)
(235, 0, 19, 18, '2026-02-14 13:00:00'),  -- Twitter → Empatia

-- Feb 15 (Sun)
(236, 0, 12, 98, '2026-02-15 11:00:00'),  -- Fitbit
(237, 0, 0,  10, '2026-02-15 18:00:00'),  -- Chess → Resolucion Problemas
(238, 0, 2,  17, '2026-02-15 18:00:00'),  -- Chess elo → Pensamiento Estrategico

-- Feb 17 (Tue)
(239, 0, 6,  20, '2026-02-17 07:00:00'),  -- Duolingo → Vocabulario
(240, 0, 7,  11, '2026-02-17 07:00:00'),  -- Duolingo → Comprension Lectora
(241, 0, 8,  28, '2026-02-17 07:00:00'),  -- Duolingo streak → Motivacion
(242, 0, 12, 60, '2026-02-17 18:30:00'),  -- Fitbit → Resistencia

-- Feb 19 (Thu)
(243, 0, 0,  6,  '2026-02-19 21:00:00'),  -- Chess → Resolucion Problemas
(244, 0, 4,  16, '2026-02-19 21:00:00'),  -- Chess puzzles → Resolucion Problemas
(245, 0, 5,  9,  '2026-02-19 21:00:00'),  -- Chess puzzles → Memoria
(246, 0, 2,  14, '2026-02-19 21:00:00'),  -- Chess elo → Pensamiento Estrategico
(247, 0, 10, 10, '2026-02-19 08:00:00'),  -- Duolingo xp → Vocabulario
(248, 0, 12, 68, '2026-02-19 17:00:00'),  -- Fitbit → Resistencia
(249, 0, 17, 8,  '2026-02-19 12:00:00'),  -- Twitter → Expresion Escrita

-- Feb 21 (Sat)
(250, 0, 12, 160,'2026-02-21 08:00:00'),  -- Fitbit (all-time best!)
(251, 0, 13, 40, '2026-02-21 08:00:00'),  -- Fitbit → Fuerza
(252, 0, 14, 8,  '2026-02-21 08:00:00'),  -- Fitbit HR → Coordinacion
(253, 0, 15, 5,  '2026-02-21 08:00:00'),  -- Fitbit HR → Regulacion Emocional
(254, 0, 16, 18, '2026-02-21 23:00:00'),  -- Fitbit sleep
(255, 0, 18, 16, '2026-02-21 15:00:00'),  -- Twitter followers → Reconocimiento
(256, 0, 19, 14, '2026-02-21 15:00:00'),  -- Twitter → Empatia

-- Feb 22 (Sun)
(257, 0, 12, 110,'2026-02-22 10:30:00'),  -- Fitbit
(258, 0, 0,  9,  '2026-02-22 19:00:00'),  -- Chess → Resolucion Problemas
(259, 0, 2,  16, '2026-02-22 19:00:00'),  -- Chess elo → Pensamiento Estrategico
(260, 0, 1,  4,  '2026-02-22 19:00:00'),  -- Chess games → Motivacion

-- Feb 24 (Tue)
(261, 0, 6,  22, '2026-02-24 07:00:00'),  -- Duolingo → Vocabulario
(262, 0, 7,  12, '2026-02-24 07:00:00'),  -- Duolingo → Comprension Lectora
(263, 0, 8,  30, '2026-02-24 07:00:00'),  -- Duolingo streak → Motivacion (85-day streak!)
(264, 0, 9,  7,  '2026-02-24 07:00:00'),  -- Duolingo streak → Expresion Escrita
(265, 0, 12, 65, '2026-02-24 18:00:00'),  -- Fitbit → Resistencia

-- Feb 26 (Thu) — Final data points
(266, 0, 4,  18, '2026-02-26 20:30:00'),  -- Chess puzzles → Resolucion Problemas
(267, 0, 5,  10, '2026-02-26 20:30:00'),  -- Chess puzzles → Memoria
(268, 0, 2,  18, '2026-02-26 20:30:00'),  -- Chess elo → Pensamiento Estrategico (all-time high!)
(269, 0, 3,  16, '2026-02-26 20:30:00'),  -- Chess elo → Autoconfianza
(270, 0, 12, 70, '2026-02-26 17:00:00');  -- Fitbit → Resistencia


-- ============================================
-- 8. UPDATE DIMENSION TOTALS (playerss_attributes)
-- ============================================
-- Recalculate the `data` column for player 0's 5 dimension records
-- based on the sum of all acquired subattributes per dimension.
--
-- The totals are computed from the adquired_subattribute data above,
-- aggregated by the dimension each subattribute belongs to.
--
-- Dimension mapping (via subattributes_conversion_sensor_endpoint → subattributes → attributes):
--   Social (0): subattributes 0 (Reconocimiento), 1 (Empatia), 2 (Colaboracion)
--     SCSE IDs: 18 (→0), 19 (→1)
--   Fisica (1): subattributes 3 (Resistencia), 4 (Coordinacion), 5 (Fuerza)
--     SCSE IDs: 12 (→3), 13 (→5), 14 (→4)
--   Afectivo (2): subattributes 6 (Motivacion), 7 (Autoconfianza), 8 (Regulacion Emocional)
--     SCSE IDs: 1 (→6), 8 (→6), 3 (→7), 15 (→8), 16 (→8)
--   Cognitivo (3): subattributes 9 (Resolucion), 10 (Memoria), 11 (Pensamiento Estrategico)
--     SCSE IDs: 0 (→9), 4 (→9), 2 (→11), 5 (→10), 11 (→10)
--   Linguistico (4): subattributes 12 (Comprension), 13 (Vocabulario), 14 (Expresion Escrita)
--     SCSE IDs: 6 (→13), 7 (→12), 10 (→13), 9 (→14), 17 (→14)

-- Use a calculated UPDATE based on actual inserted data
-- Social (attribute 0): sum of SCSE 18, 19
UPDATE `playerss_attributes` pa
SET `data` = (
    SELECT COALESCE(SUM(aq.data), 0)
    FROM `adquired_subattribute` aq
    JOIN `subattributes_conversion_sensor_endpoint` scse
      ON scse.id_subattributes_conversion_sensor_endpoint = aq.id_subattributes_conversion_sensor_endpoint
    JOIN `subattributes` sa ON sa.id_subattributes = scse.id_subattributes
    WHERE sa.attributes_id_attributes = 0
      AND aq.id_players = 0
),
`last_modified` = NOW()
WHERE pa.id_playerss = 0 AND pa.id_attributes = 0;

-- Fisica (attribute 1)
UPDATE `playerss_attributes` pa
SET `data` = (
    SELECT COALESCE(SUM(aq.data), 0)
    FROM `adquired_subattribute` aq
    JOIN `subattributes_conversion_sensor_endpoint` scse
      ON scse.id_subattributes_conversion_sensor_endpoint = aq.id_subattributes_conversion_sensor_endpoint
    JOIN `subattributes` sa ON sa.id_subattributes = scse.id_subattributes
    WHERE sa.attributes_id_attributes = 1
      AND aq.id_players = 0
),
`last_modified` = NOW()
WHERE pa.id_playerss = 0 AND pa.id_attributes = 1;

-- Afectivo (attribute 2)
UPDATE `playerss_attributes` pa
SET `data` = (
    SELECT COALESCE(SUM(aq.data), 0)
    FROM `adquired_subattribute` aq
    JOIN `subattributes_conversion_sensor_endpoint` scse
      ON scse.id_subattributes_conversion_sensor_endpoint = aq.id_subattributes_conversion_sensor_endpoint
    JOIN `subattributes` sa ON sa.id_subattributes = scse.id_subattributes
    WHERE sa.attributes_id_attributes = 2
      AND aq.id_players = 0
),
`last_modified` = NOW()
WHERE pa.id_playerss = 0 AND pa.id_attributes = 2;

-- Cognitivo (attribute 3)
UPDATE `playerss_attributes` pa
SET `data` = (
    SELECT COALESCE(SUM(aq.data), 0)
    FROM `adquired_subattribute` aq
    JOIN `subattributes_conversion_sensor_endpoint` scse
      ON scse.id_subattributes_conversion_sensor_endpoint = aq.id_subattributes_conversion_sensor_endpoint
    JOIN `subattributes` sa ON sa.id_subattributes = scse.id_subattributes
    WHERE sa.attributes_id_attributes = 3
      AND aq.id_players = 0
),
`last_modified` = NOW()
WHERE pa.id_playerss = 0 AND pa.id_attributes = 3;

-- Linguistico (attribute 4)
UPDATE `playerss_attributes` pa
SET `data` = (
    SELECT COALESCE(SUM(aq.data), 0)
    FROM `adquired_subattribute` aq
    JOIN `subattributes_conversion_sensor_endpoint` scse
      ON scse.id_subattributes_conversion_sensor_endpoint = aq.id_subattributes_conversion_sensor_endpoint
    JOIN `subattributes` sa ON sa.id_subattributes = scse.id_subattributes
    WHERE sa.attributes_id_attributes = 4
      AND aq.id_players = 0
),
`last_modified` = NOW()
WHERE pa.id_playerss = 0 AND pa.id_attributes = 4;


-- ============================================
-- 9. ADDITIONAL VIDEOGAMES
-- ============================================
-- 2 new games to complement the existing StrategyGame and Minecraft

INSERT IGNORE INTO `videogame`
  (`id_videogame`, `name`, `genre`, `engine`, `developer`, `publisher`, `version`)
VALUES
  (3, 'LSG Language Quest',    'Educational', 'Unity',     'LifeSync Games', 'USACH', '1.0'),
  (4, 'bGames Fitness Runner', 'Casual',      'Godot',     'LifeSync Games', 'USACH', '1.0');


-- ============================================
-- 10. MODIFIABLE MECHANICS FOR NEW GAMES
-- ============================================
-- Each game has mechanics that can be modified by spending dimension points

-- New mechanics
INSERT IGNORE INTO `modifiable_mechanic`
  (`id_modifiable_mechanic`, `name`, `description`, `type`, `initiated_date`, `last_modified`)
VALUES
  (2, 'Vocabulary Boost',    'Unlocks advanced vocabulary challenges',        '1', NOW(), NOW()),
  (3, 'Grammar Shield',      'Provides grammar hints during gameplay',        '2', NOW(), NOW()),
  (4, 'Speed Boost',         'Increases player running speed',                '1', NOW(), NOW()),
  (5, 'Endurance Extension', 'Extends stamina bar duration',                  '2', NOW(), NOW());

-- Link mechanics to games
INSERT IGNORE INTO `modifiable_mechanic_videogames`
  (`id_modifiable_mechanic_videogame`, `id_modifiable_mechanic`, `id_videogame`, `options`)
VALUES
  -- LSG Language Quest (videogame 3)
  (2, 2, 3, 'null'),  -- Vocabulary Boost in Language Quest
  (3, 3, 3, 'null'),  -- Grammar Shield in Language Quest
  -- bGames Fitness Runner (videogame 4)
  (4, 4, 4, 'null'),  -- Speed Boost in Fitness Runner
  (5, 5, 4, 'null'),  -- Endurance Extension in Fitness Runner
  -- Add new mechanics to existing StrategyGame (vg 0)
  (6, 2, 0, 'null'),  -- Vocabulary Boost also available in StrategyGame
  (7, 4, 0, 'null'),  -- Speed Boost also available in StrategyGame
  -- Faster Peasants also in StrategyGame (original data only had it in vg 1)
  (8, 1, 0, 'null'),  -- Faster Peasants in StrategyGame
  -- Bonus Town Size and Faster Peasants in Minecraft (vg 2)
  (9,  0, 2, 'null'), -- Bonus Town Size in Minecraft
  (10, 1, 2, 'null'); -- Faster Peasants in Minecraft

-- modifiable_conversion_attribute: link mechanics to attributes via conversions
-- This defines WHICH attribute (dimension) is consumed to power each mechanic
INSERT IGNORE INTO `modifiable_conversion_attribute`
  (`id_modifiable_conversion_attribute`, `id_attribute`, `id_conversion`, `id_modifiable_mechanic`)
VALUES
  -- id 0 and 1 already exist (Social→Bonus Town Size, Social→Faster Peasants)
  (2,  4, 0, 2),  -- Linguistico → Vocabulary Boost (using placeholder conversion)
  (3,  4, 0, 3),  -- Linguistico → Grammar Shield
  (4,  1, 0, 4),  -- Fisica → Speed Boost
  (5,  1, 0, 5),  -- Fisica → Endurance Extension
  (6,  3, 0, 2),  -- Cognitivo → Vocabulary Boost (in StrategyGame context)
  (7,  3, 0, 4),  -- Cognitivo → Speed Boost (in StrategyGame context)
  (8,  0, 0, 2),  -- Social → Vocabulary Boost
  (9,  2, 0, 5);  -- Afectivo → Endurance Extension


-- ============================================
-- 11. EXPENDED ATTRIBUTES (Game Usage)
-- ============================================
-- 50 records of player 0 spending dimension points in games
-- Spread across Dec 2025 – Feb 2026
-- Cognitive and Social spent more often in StrategyGame

INSERT IGNORE INTO `expended_attribute`
  (`id_expended_attribute`, `id_players`, `id_videogame`, `id_modifiable_conversion_attribute`, `data`, `created_time`)
VALUES
-- December 2025 — StrategyGame (videogame 0)
(1,  0, 0, 0, 3, '2025-12-02 21:00:00'),  -- Social → Bonus Town Size
(2,  0, 0, 1, 2, '2025-12-02 21:05:00'),  -- Social → Faster Peasants
(3,  0, 0, 0, 4, '2025-12-05 20:30:00'),  -- Social → Bonus Town Size
(4,  0, 0, 7, 5, '2025-12-05 20:45:00'),  -- Cognitivo → Speed Boost
(5,  0, 0, 6, 3, '2025-12-08 19:00:00'),  -- Cognitivo → Vocabulary Boost
(6,  0, 0, 0, 2, '2025-12-08 19:15:00'),  -- Social → Bonus Town Size
(7,  0, 0, 1, 3, '2025-12-10 21:00:00'),  -- Social → Faster Peasants
(8,  0, 0, 7, 4, '2025-12-10 21:10:00'),  -- Cognitivo → Speed Boost
(9,  0, 0, 6, 5, '2025-12-14 20:00:00'),  -- Cognitivo → Vocabulary Boost
(10, 0, 0, 0, 3, '2025-12-14 20:15:00'),  -- Social → Bonus Town Size
(11, 0, 0, 7, 6, '2025-12-18 19:30:00'),  -- Cognitivo → Speed Boost
(12, 0, 0, 1, 2, '2025-12-18 19:45:00'),  -- Social → Faster Peasants

-- December — Minecraft (videogame 2)
(13, 0, 2, 0, 5, '2025-12-07 15:00:00'),  -- Social → Bonus Town Size
(14, 0, 2, 1, 3, '2025-12-13 14:00:00'),  -- Social → Faster Peasants

-- December — LSG Language Quest (videogame 3)
(15, 0, 3, 2, 4, '2025-12-04 19:00:00'),  -- Linguistico → Vocabulary Boost
(16, 0, 3, 3, 3, '2025-12-09 18:30:00'),  -- Linguistico → Grammar Shield
(17, 0, 3, 2, 5, '2025-12-15 20:00:00'),  -- Linguistico → Vocabulary Boost
(18, 0, 3, 3, 4, '2025-12-20 19:00:00'),  -- Linguistico → Grammar Shield

-- December — bGames Fitness Runner (videogame 4)
(19, 0, 4, 4, 6, '2025-12-06 17:00:00'),  -- Fisica → Speed Boost
(20, 0, 4, 5, 4, '2025-12-13 16:00:00'),  -- Fisica → Endurance Extension
(21, 0, 4, 4, 5, '2025-12-20 11:00:00'),  -- Fisica → Speed Boost
(22, 0, 4, 5, 7, '2025-12-27 10:00:00'),  -- Fisica → Endurance Extension

-- January 2026 — StrategyGame
(23, 0, 0, 0, 4, '2026-01-03 21:00:00'),  -- Social → Bonus Town Size
(24, 0, 0, 6, 6, '2026-01-03 21:15:00'),  -- Cognitivo → Vocabulary Boost
(25, 0, 0, 7, 5, '2026-01-07 20:00:00'),  -- Cognitivo → Speed Boost
(26, 0, 0, 1, 3, '2026-01-07 20:10:00'),  -- Social → Faster Peasants
(27, 0, 0, 0, 5, '2026-01-11 19:30:00'),  -- Social → Bonus Town Size
(28, 0, 0, 6, 7, '2026-01-15 21:00:00'),  -- Cognitivo → Vocabulary Boost
(29, 0, 0, 7, 6, '2026-01-20 20:00:00'),  -- Cognitivo → Speed Boost
(30, 0, 0, 0, 3, '2026-01-20 20:15:00'),  -- Social → Bonus Town Size
(31, 0, 0, 1, 4, '2026-01-25 19:00:00'),  -- Social → Faster Peasants
(32, 0, 0, 6, 8, '2026-01-29 21:00:00'),  -- Cognitivo → Vocabulary Boost

-- January — LSG Language Quest
(33, 0, 3, 2, 6, '2026-01-05 18:00:00'),  -- Linguistico → Vocabulary Boost
(34, 0, 3, 3, 5, '2026-01-12 19:30:00'),  -- Linguistico → Grammar Shield
(35, 0, 3, 2, 7, '2026-01-19 20:00:00'),  -- Linguistico → Vocabulary Boost
(36, 0, 3, 3, 6, '2026-01-26 19:00:00'),  -- Linguistico → Grammar Shield

-- January — bGames Fitness Runner
(37, 0, 4, 4, 7, '2026-01-04 11:00:00'),  -- Fisica → Speed Boost
(38, 0, 4, 5, 5, '2026-01-11 10:00:00'),  -- Fisica → Endurance Extension
(39, 0, 4, 4, 8, '2026-01-18 09:30:00'),  -- Fisica → Speed Boost
(40, 0, 4, 5, 6, '2026-01-25 10:00:00'),  -- Fisica → Endurance Extension

-- February 2026 — StrategyGame
(41, 0, 0, 0, 5, '2026-02-01 20:30:00'),  -- Social → Bonus Town Size
(42, 0, 0, 6, 9, '2026-02-05 21:00:00'),  -- Cognitivo → Vocabulary Boost
(43, 0, 0, 7, 7, '2026-02-08 19:30:00'),  -- Cognitivo → Speed Boost
(44, 0, 0, 1, 4, '2026-02-12 20:00:00'),  -- Social → Faster Peasants
(45, 0, 0, 0, 6, '2026-02-15 18:30:00'),  -- Social → Bonus Town Size
(46, 0, 0, 6, 10,'2026-02-19 21:00:00'),  -- Cognitivo → Vocabulary Boost

-- February — LSG Language Quest
(47, 0, 3, 2, 8, '2026-02-03 18:00:00'),  -- Linguistico → Vocabulary Boost
(48, 0, 3, 3, 7, '2026-02-10 19:30:00'),  -- Linguistico → Grammar Shield

-- February — bGames Fitness Runner
(49, 0, 4, 4, 9, '2026-02-07 10:00:00'),  -- Fisica → Speed Boost
(50, 0, 4, 5, 8, '2026-02-14 11:00:00');  -- Fisica → Endurance Extension


-- ============================================
-- VERIFICATION QUERIES (optional, for debugging)
-- ============================================
-- Uncomment to verify data was inserted correctly:
--
-- SELECT 'online_sensor' AS tbl, COUNT(*) AS cnt FROM online_sensor
-- UNION ALL SELECT 'sensor_endpoint', COUNT(*) FROM sensor_endpoint
-- UNION ALL SELECT ' conversion', COUNT(*) FROM ` conversion`
-- UNION ALL SELECT 'subattributes', COUNT(*) FROM subattributes
-- UNION ALL SELECT 'scse', COUNT(*) FROM subattributes_conversion_sensor_endpoint
-- UNION ALL SELECT 'player_online_sensor', COUNT(*) FROM player_online_sensor
-- UNION ALL SELECT 'players_sensor_endpoint', COUNT(*) FROM players_sensor_endpoint
-- UNION ALL SELECT 'adquired_subattribute', COUNT(*) FROM adquired_subattribute
-- UNION ALL SELECT 'videogame', COUNT(*) FROM videogame
-- UNION ALL SELECT 'modifiable_mechanic', COUNT(*) FROM modifiable_mechanic
-- UNION ALL SELECT 'mod_mech_vg', COUNT(*) FROM modifiable_mechanic_videogames
-- UNION ALL SELECT 'mod_conv_attr', COUNT(*) FROM modifiable_conversion_attribute
-- UNION ALL SELECT 'expended_attribute', COUNT(*) FROM expended_attribute;
--
-- -- Check dimension totals for player 0:
-- SELECT a.name, pa.data
-- FROM playerss_attributes pa
-- JOIN attributes a ON a.id_attributes = pa.id_attributes
-- WHERE pa.id_playerss = 0
-- ORDER BY a.id_attributes;

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET SQL_MODE=@OLD_SQL_MODE;
