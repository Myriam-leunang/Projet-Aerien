-- =========================================================
-- PROJETR - SCHEMA MYSQL (phpMyAdmin)
-- =========================================================

CREATE DATABASE IF NOT EXISTS ProjetR
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE ProjetR;

-- Pour éviter les blocages pendant la création
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------
-- airlines
-- ---------------------------------------------------------
DROP TABLE IF EXISTS airlines;
CREATE TABLE airlines (
  carrier VARCHAR(5) NOT NULL,
  name    VARCHAR(255) NULL,
  PRIMARY KEY (carrier)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- airports
-- ---------------------------------------------------------
DROP TABLE IF EXISTS airports;
CREATE TABLE airports (
  faa   VARCHAR(3) NOT NULL,
  name  VARCHAR(255) NULL,
  lat   DOUBLE NULL,
  lon   DOUBLE NULL,
  alt   DOUBLE NULL,
  tz    DOUBLE NULL,
  dst   VARCHAR(255) NULL,
  tzone VARCHAR(255) NULL,
  PRIMARY KEY (faa)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- planes
-- ---------------------------------------------------------
DROP TABLE IF EXISTS planes;
CREATE TABLE planes (
  tailnum       VARCHAR(20) NOT NULL,
  `year`        INT NULL,
  `type`        VARCHAR(255) NULL,
  manufacturer  VARCHAR(255) NULL,
  model         VARCHAR(255) NULL,
  engines       INT NULL,
  seats         INT NULL,
  speed         INT NULL,
  engine        VARCHAR(255) NULL,
  PRIMARY KEY (tailnum)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- weather
-- PK composite: (year, month, day, hour, origin)
-- ---------------------------------------------------------
DROP TABLE IF EXISTS weather;
CREATE TABLE weather (
  origin      VARCHAR(3) NOT NULL,
  `year`      INT NOT NULL,
  `month`     INT NOT NULL,
  `day`       INT NOT NULL,
  `hour`      INT NOT NULL,
  temp        DOUBLE NULL,
  dewp        DOUBLE NULL,
  humid       DOUBLE NULL,
  wind_dir    DOUBLE NULL,
  wind_speed  DOUBLE NULL,
  wind_gust   DOUBLE NULL,
  precip      DOUBLE NULL,
  pressure    DOUBLE NULL,
  visib       DOUBLE NULL,
  time_hour   DATETIME NULL,
  PRIMARY KEY (`year`, `month`, `day`, `hour`, origin)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- flights
-- PK composite: (year, month, day, hour, carrier, flight)
-- ---------------------------------------------------------
DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
  `year`          INT NOT NULL,
  `month`         INT NOT NULL,
  `day`           INT NOT NULL,
  dep_time        DOUBLE NULL,
  sched_dep_time  DOUBLE NULL,
  dep_delay       DOUBLE NULL,
  arr_time        DOUBLE NULL,
  sched_arr_time  DOUBLE NULL,
  arr_delay       DOUBLE NULL,
  carrier         VARCHAR(5) NOT NULL,
  flight          INT NOT NULL,
  tailnum         VARCHAR(20) NULL,
  origin          VARCHAR(3) NULL,
  dest            VARCHAR(3) NULL,
  air_time        DOUBLE NULL,
  distance        DOUBLE NULL,
  `hour`          INT NOT NULL,
  minute          DOUBLE NULL,
  time_hour       DATETIME NULL,
  PRIMARY KEY (`year`, `month`, `day`, `hour`, carrier, flight),
  INDEX idx_flights_carrier (carrier),
  INDEX idx_flights_origin (origin),
  INDEX idx_flights_dest (dest),
  INDEX idx_flights_tailnum (tailnum)
) ENGINE=InnoDB;

-- (Optionnel) table de staging si tu veux
DROP TABLE IF EXISTS stg_airports;
CREATE TABLE stg_airports (
  idx   INT NULL,
  faa   VARCHAR(10) NULL,
  name  VARCHAR(200) NULL,
  lat   DOUBLE NULL,
  lon   DOUBLE NULL,
  alt   INT NULL,
  tz    INT NULL,
  dst   VARCHAR(10) NULL,
  tzone VARCHAR(50) NULL
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;
