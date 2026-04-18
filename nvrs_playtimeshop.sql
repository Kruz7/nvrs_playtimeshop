CREATE TABLE IF NOT EXISTS `nvrs_playtimeshop` (
  `#` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) NOT NULL DEFAULT '0',
  `coin` int(11) NOT NULL DEFAULT 0,
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `next_playtime_reward_at` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`#`),
  UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nvrs_playtimeshop_codes` (
  `#` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(64) NOT NULL,
  `credit` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`#`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
