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
('4d5d4cb1ae264f3fcde8da4e461e4220', "admin","EDRS","Administrator","$2a$10$SC25u25mJ.OV3VZiXwkPg.a7Yxeytc2kP6UdlzfYxrIMhZs80hOGq","2017-05-18 01:09:17",'0','0',"admin@baobabhealth.org",'true',0, "System Administrator",NULL, "HQ","abc","admin",NULL, NULL, "1-819b801f36fc29dbaf6bc191bc1a8448","2017-05-18 01:09:17","2017-05-18 01:09:17"),('ce6a4f40ece57428881dc2b45b361235', "nurse","Nurse","Facility","$2a$10$59iqK3tjtieNTCxp4RP5uOXwoJxIs57iLo7RgU5AP.Hn3OxvFCsL2","2017-05-18 02:33:32",'0','0',"emai@mail.com",'true',0, "Nurse/Midwife","BT","2926","abc","admin",NULL, NULL, "1-055843d6867daca76db508c841b23134","2017-05-18 02:39:04","2017-05-18 02:39:04"),('fda34d9b2c9fcb2e858c9ae354c204cf', "clerk","Clerk","DC","$2a$10$CmEAGN147ss2Sh9nEu7cueC8eJ5Ujk2r7UnFT0Qk6ek4H7IzDC2RK","2017-05-18 03:10:21",'0','0',"emns@gmail.com",'true',0, "Data Clerk","BT",NULL, "abc","admin",NULL, NULL, "1-2c6dcdeb74b512720ea92fc113236575","2017-05-18 03:14:06","2017-05-18 03:14:06"),('fda34d9b2c9fcb2e858c9ae354c1e75f', "logistic","Logistics","Officer","$2a$10$UkCWrUYHJ1D0X4SI3PesBu.zpMOfxDfkz2dlHxziC8LW/vRTBPqhi","2017-05-18 03:10:21",'0','0',"emai@mail.com",'true',0, "Logistics Officer","BT",NULL, "abc","admin",NULL, NULL, "1-1343efd02cf5c80a9631914f23b51b7d","2017-05-18 03:15:04","2017-05-18 03:15:04"),('fda34d9b2c9fcb2e858c9ae354c1dba0', "adr","ADR","DC","$2a$10$zdojEY.oGhgq5voLktGX6eOgs.qS5fHq28lAUB47oR80Kwa9pd4n2","2017-05-18 03:10:21",'0','0',"em@mail.com",'true',0, "ADR","BT",NULL, "abc","admin",NULL, NULL, "1-2ed11735abd36b8332bf1dee2d7393f9","2017-05-18 03:16:21","2017-05-18 03:16:21"),('81647621dc362019179741e41f2ffcc6', "coder","Coder","MOH","$2a$10$2SAGqI.ZqNZXJImeFUniP.kWexkpdb49jC5cNpcD45hTW3P3PX4o6","2017-05-18 03:45:16",'0','0',NULL, 'true',0, "Coder",NULL, NULL, "abc","admin",NULL, NULL, "1-0459a896473c2fff24d5bd197a8a707c","2017-05-18 03:53:52","2017-05-18 03:53:52"),('81647621dc362019179741e41f2ff05d', "dataverifier","Data Verifier","HQ","$2a$10$98.3BGkhD874hNotojUEHu7fn7MBztbuqnTjy/wVRmuY3brzRW/yW","2017-05-18 03:45:16",'0','0',NULL, 'true',0, "Data Checking Clerk",NULL, NULL, "abc","admin",NULL, NULL, "1-05a70e870435337fbe44b2a8cb49d18f","2017-05-18 03:55:11","2017-05-18 03:55:11"),('81647621dc362019179741e41f2fe255', "datamanager","Data Manager","HQ","$2a$10$GPDNjsI7lt842Sn5htjdB.XGhqnEnWwl5jU.7zwefGDlrMatgLtAy","2017-05-18 03:45:16",'0','0',NULL, 'true',0, "Data Manager",NULL, NULL, "abc","admin",NULL, NULL, "1-cb321f57ef31ab9d5dc29ac4c84319ad","2017-05-18 03:56:04","2017-05-18 03:56:04"),('9a89d03928433f9a8dd3c74a7afe504f', "clerktest","Clerk","Test","$2a$10$Qt3RiDXlGrD5od7lyCm.h.hGH3dNwg1bw9rLHzgJ9p6Z2iXXy4mXi","2017-05-23 10:13:23",'0','0',NULL, 'true',0, "Data Clerk","BT",NULL, "abc","admin",NULL, NULL, "1-00e4df4845e9e12bc0dd96373adebe08","2017-05-23 11:37:19","2017-05-23 11:37:19"),('764f1c7c48fd17812d5b31887620e6a2', "testcheck","Test","FC","$2a$10$pbZnLH5IE6AuPWujaFzgxOVTuZhe53TrWHNOWsoWOAKzSwQ8BIQAq","2017-05-19 14:15:21",'0','0',"emns@gmail.com",0, 0, "Data Clerk","BT","2926","abc","admin",NULL, "Testing","2-45009c6707f747c7978b22351d2ef10e","2017-06-09 09:58:08","2017-05-19 14:16:16");
