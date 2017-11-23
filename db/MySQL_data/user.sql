        DROP TABLE IF EXISTS `user`;
        CREATE TABLE `user` (
        `user_id` VARCHAR(225) NOT NULL,
      `username` VARCHAR(255) DEFAULT NULL,
      `first_name` VARCHAR(255) DEFAULT NULL,
      `last_name` VARCHAR(255) DEFAULT NULL,
      `password_hash` VARCHAR(255) DEFAULT NULL,
      `last_password_date` datetime DEFAULT NULL,
      `password_attempt` INT(11) DEFAULT NULL,
      `login_attempt` INT(11) DEFAULT NULL,
      `email` VARCHAR(255) DEFAULT NULL,
      `active` tinyint(1) NOT NULL  DEFAULT '0',
      `notify` tinyint(1) NOT NULL  DEFAULT '0',
      `role` VARCHAR(255) DEFAULT NULL,
      `district_code` VARCHAR(255) DEFAULT NULL,
      `site_code` VARCHAR(255) DEFAULT NULL,
      `preferred_keyboard` VARCHAR(255) DEFAULT NULL,
      `creator` VARCHAR(255) DEFAULT NULL,
      `plain_password` VARCHAR(255) DEFAULT NULL,
      `un_or_block_reason` VARCHAR(255) DEFAULT NULL,
      `_rev` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`user_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;

INSERT INTO user (user_id, username, first_name, last_name, password_hash, last_password_date, password_attempt, login_attempt, email, active, notify, role, district_code, site_code, preferred_keyboard, creator, plain_password, un_or_block_reason, _rev, updated_at, created_at) VALUES 
('00684d94b8a6df9a485d0c0aa47d5eaa', "admin","EDRS","Administrator","$2a$10$wO7ghG5FUqLuZPn.gnpnc.pxR6da9evXfw/cfDemwyg6CWvxz.M1O","2017-11-23 09:48:36",'0','0',"admin@baobabhealth.org",'true',0, "System Administrator",NULL, "HQ","abc","admin",NULL, NULL, "1-e90fda05e4336be505799d2a77a9596b","2017-11-23 09:48:36","2017-11-23 09:48:36"),('9fe69aea4af3a0cdfd91104803c7dc24', "clerk","Clerk","DC","$2a$10$F8oX5PdSpr17UVw4Ir9vluTt8F/R6o5q/z9kwZayleyOUn4pYjRgC","2017-11-23 10:24:49",'0','0',NULL, 'true',0, "Data Clerk","BT",NULL, "abc","admin",NULL, NULL, "1-0f61b28231aade7d4d82129af56fc190","2017-11-23 10:25:57","2017-11-23 10:25:57");
