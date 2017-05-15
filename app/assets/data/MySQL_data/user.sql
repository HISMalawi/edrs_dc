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
('d9e195f94432c14966962809f93df1af', "admin","EDRS","Administrator","$2a$10$tJCdAlg.wieGJlD8zVSRn.b4Bf5M0s5ZaHFDUO9LCPOLj75wKmF6e","2017-04-25 15:30:10",0,0,"admin@baobabhealth.org",true,0, "System Administrator",NULL, "HQ","abc","admin",NULL, NULL, "1-a79a8933aaa5168c31f065c65a6a34a5","2017-04-25 15:30:10","2017-04-25 15:30:10"),('fd38f9bced717f5fd43e8884dea652c4', "clerkdc","Clerk","DC","$2a$10$ETtMHUYI2pE0AoCtdO3iOe39jXdZrZXQeHdyoOr4wQk1wZoesCSNC","2017-04-25 15:53:59",0,0,"emai@mail.com",true,0, "Data Clerk","BT",NULL, "abc","admin",NULL, NULL, "1-0f819700ff97a5a021b90ec82deefafc","2017-04-25 15:55:23","2017-04-25 15:55:23"),('fd38f9bced717f5fd43e8884dea63fc0', "logistic","Logistic","DC","$2a$10$seiMOxUH46gRZBrB902Zsej7.rz71vAhXCa.Y/UvBMeSR6zMEuBI.","2017-04-25 15:53:59",0,0,"emns@gmail.com",true,0, "Logistics Officer","BT",NULL, "abc","admin",NULL, NULL, "1-0adda50f5c12b75e74d549ef950ff167","2017-04-25 15:57:21","2017-04-25 15:57:21"),('fd38f9bced717f5fd43e8884dea632bd', "adr","ADR","DC","$2a$10$PHigpHUek5eF64wNgmgO6.UYvUM.6Il7YGBvjqRyyBlfRcVeZuCp6","2017-04-25 15:53:59",0,0,"ema@mail.com",true,0, "ADR","BT",NULL, "abc","admin",NULL, NULL, "1-7abb70d202f34752979d22c724260d59","2017-04-25 15:58:43","2017-04-25 15:58:43"),('8d47630a10093fb44bcb4321ee1f4fca', "dataverifier","Data Checki","HQ","$2a$10$/BB89aDzik2TlulxGku6eu4U7tG.M.3y/ioK/GFBh4ixOhlndTKhC","2017-05-09 08:52:35",0,0,NULL, true,0, "Data Checking Clerk",NULL, NULL, "abc","admin",NULL, NULL, "1-803710c60ab54d797a44f160f6a85e12","2017-05-09 08:54:52","2017-05-09 08:54:52"),('0c04955b944e13ab57cd60ea70644eec', "datamanager","Data Manager","HQ","$2a$10$owuYqdWKAq1OIgJm5/3ew.b2boBatPT7l2n7OLQuI.oqNp6cnomgu","2017-05-12 09:31:49",0,0,NULL, true,0, "Data Manager",NULL, NULL, "abc","admin",NULL, NULL, "1-ad334bd8c4340d1b961581c3a5aecda0","2017-05-12 09:41:55","2017-05-12 09:41:55"),('3e0d46d6ba6a239295544ccb70b0ecbc', "nurse","Nurse","Facility","$2a$10$R8FxFLr1SipabZIcCyGe3OEZrXq.n1Lv1E7RI2gnbZYCKj/JZ90dq","2017-05-12 10:16:35",0,0,"ema@mail.com",true,0, "Nurse/Midwife","BT",NULL, "abc","admin",NULL, NULL, "1-34d92742fd3e3aebe1a6119da3c63248","2017-05-12 10:18:28","2017-05-12 10:18:28");
