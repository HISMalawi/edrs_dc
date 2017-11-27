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
('00684d94b8a6df9a485d0c0aa47d5eaa', "admin","EDRS","Administrator","$2a$10$wO7ghG5FUqLuZPn.gnpnc.pxR6da9evXfw/cfDemwyg6CWvxz.M1O","2017-11-23 09:48:36",'0','0',"admin@baobabhealth.org",'true',0, "System Administrator",NULL, "HQ","abc","admin",NULL, NULL, "1-e90fda05e4336be505799d2a77a9596b","2017-11-23 09:48:36","2017-11-23 09:48:36"),('9fe69aea4af3a0cdfd91104803c7dc24', "clerk","Clerk","DC","$2a$10$F8oX5PdSpr17UVw4Ir9vluTt8F/R6o5q/z9kwZayleyOUn4pYjRgC","2017-11-23 10:24:49",'0','0',NULL, 'true',0, "Data Clerk","BT",NULL, "abc","admin",NULL, NULL, "1-0f61b28231aade7d4d82129af56fc190","2017-11-23 10:25:57","2017-11-23 10:25:57"),('7c112c918424754798a9b565402f12da', "logistic","LO","DC","$2a$10$GXM7d3Qerr8YpG1YZ7q3P.wEkLpMSu3nU1XpODhemkNG0wVktJcuC","2017-11-23 12:50:32",'0','0',NULL, 'true',0, "Logistics Officer","BT",NULL, "abc","admin",NULL, NULL, "1-bf08f6b9f961bf8ee4549162b32f4de9","2017-11-23 12:53:40","2017-11-23 12:53:40"),('7c112c918424754798a9b565402f0760', "adr","ADR","DC","$2a$10$5sDx7ylW7cysKyvjiPT8Quu1eHbdnKNqPi60/nRyBh.jGr5YPf43C","2017-11-23 12:50:32",'0','0',NULL, 'true',0, "ADR","BT",NULL, "abc","admin",NULL, NULL, "1-034375eb4515fb296c2e929f58941005","2017-11-23 12:54:16","2017-11-23 12:54:16"),('b1fca5ba792d7441abdcff3210d54b99', "dataverifier","DV","HQ","$2a$10$rPZoLxI8fjtaaFaq8SCOwOhM5m7AnGiWqXSk4/gYWgc4OhPdFDLNi","2017-11-23 13:17:12",'0','0',NULL, 'true',0, "Data Checking Clerk",NULL, NULL, "abc","admin",NULL, NULL, "1-4f48edfe930ff7f32c2866b975df6f2b","2017-11-23 13:17:40","2017-11-23 13:17:40"),('b1fca5ba792d7441abdcff3210d54397', "datamanager","DM","HQ","$2a$10$8szqKa1EL.kX4kMu/t//TOn4HhhaJ8Fd8Aq47KW6r2qvj1bckToDO","2017-11-23 13:17:12",'0','0',NULL, 'true',0, "Data Manager",NULL, NULL, "abc","admin",NULL, NULL, "1-896201580ec6520f7c23d6460e9635e5","2017-11-23 13:18:45","2017-11-23 13:18:45"),('5246e1087c35a02c11bd9d66990c5c78', "coder","Coder","Person","$2a$10$g7D4wo24jR1LXfxhnUuXzu46OGaA466OFKSeTFhyZid1wPLjogHUm","2017-11-23 13:39:46",'0','0',NULL, 'true',0, "Coder",NULL, NULL, "abc","admin",NULL, NULL, "1-888b1dbbe99474c1f073aef6702befeb","2017-11-23 13:42:06","2017-11-23 13:42:06"),('7b8f3cf04a8ce8172ba599bd7a23eda2', "dm","DM","DM","$2a$10$RspWvBz0U.fpPcHXv9wKXOrCiJw4GODfXyAWne39m4QNYhtSQUorS","2017-11-23 18:55:48",'0','0',NULL, 'true',0, "Data Manager",NULL, NULL, "abc","admin",NULL, NULL, "1-96ceb2d090c5ffc3a336ee4cc7aba470","2017-11-23 18:59:26","2017-11-23 18:59:26");
