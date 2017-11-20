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
('34cd3c2fecbee3591afc4bcd641bc9bc', "admin","EDRS","Administrator","$2a$10$VvPO5vaBjUPmUI5B0mrUi.jdEiQhPosNVHnzEpXthA2RjMjlZDThK","2017-11-20 14:18:26",'0','0',"admin@baobabhealth.org",'true',0, "System Administrator",NULL, "HQ","abc","admin",NULL, NULL, "1-35c99d89b10cf03f42c8276e1a97712e","2017-11-20 14:18:26","2017-11-20 14:18:26");
