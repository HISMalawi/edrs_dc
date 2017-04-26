        DROP TABLE IF EXISTS `person_record_status`;
        CREATE TABLE `person_record_status` (
        `person_record_status_id` VARCHAR(225) NOT NULL,
      `person_record_id` VARCHAR(255) DEFAULT NULL,
      `status` VARCHAR(255) DEFAULT NULL,
      `prev_status` VARCHAR(255) DEFAULT NULL,
      `district_code` VARCHAR(255) DEFAULT NULL,
      `facility_code` VARCHAR(255) DEFAULT NULL,
      `voided` tinyint(1) NOT NULL  DEFAULT '0',
      `reprint` tinyint(1) NOT NULL  DEFAULT '0',
      `registration_type` VARCHAR(255) DEFAULT NULL,
      `creator` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`person_record_status_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;

INSERT INTO person_record_status (person_record_status_id, person_record_id, status, prev_status, district_code, facility_code, voided, reprint, registration_type, creator, updated_at, created_at) VALUES 
('fd38f9bced717f5fd43e8884dea5797f', "fd38f9bced717f5fd43e8884dea626a1","DC PENDING","NEW","BT","2926",0, 0, "Natural Deaths","fd38f9bced717f5fd43e8884dea63fc0","2017-04-25 16:27:48","2017-04-25 16:27:48"),('fd38f9bced717f5fd43e8884dea593ab', "fd38f9bced717f5fd43e8884dea6030f","DC APPROVED",NULL, "BT","2926",0, 0, "Natural Deaths","fd38f9bced717f5fd43e8884dea632bd","2017-04-25 16:24:58","2017-04-25 16:24:58"),('fd38f9bced717f5fd43e8884dea596da', "fd38f9bced717f5fd43e8884dea6030f","MARKED APPROVAL","DC COMPLETE","BT","2926",true,0, "Natural Deaths","fd38f9bced717f5fd43e8884dea632bd","2017-04-25 16:24:58","2017-04-25 16:24:56"),('fd38f9bced717f5fd43e8884dea59b8d', "fd38f9bced717f5fd43e8884dea6030f","DC COMPLETE","NEW","BT","2926",true,0, "Natural Deaths","fd38f9bced717f5fd43e8884dea63fc0","2017-04-25 16:24:56","2017-04-25 16:24:07"),('fd38f9bced717f5fd43e8884dea5b3bd', "fd38f9bced717f5fd43e8884dea5e137","DC APPROVED",NULL, "BT","2926",0, 0, "Natural Deaths","fd38f9bced717f5fd43e8884dea632bd","2017-04-25 16:23:10","2017-04-25 16:23:10"),('fd38f9bced717f5fd43e8884dea5bdef', "fd38f9bced717f5fd43e8884dea5e137","MARKED APPROVAL","DC COMPLETE","BT","2926",true,0, "Natural Deaths","fd38f9bced717f5fd43e8884dea632bd","2017-04-25 16:23:10","2017-04-25 16:23:09"),('fd38f9bced717f5fd43e8884dea5c737', "fd38f9bced717f5fd43e8884dea5e137","DC COMPLETE","NEW","BT","2926",true,0, "Natural Deaths","fd38f9bced717f5fd43e8884dea63fc0","2017-04-25 16:23:09","2017-04-25 16:17:14"),('fd38f9bced717f5fd43e8884dea5d31e', "fd38f9bced717f5fd43e8884dea5e137","NEW",NULL, "BT","2926",true,0, "Natural Deaths",NULL, "2017-04-25 16:17:14","2017-04-25 16:15:33"),('fd38f9bced717f5fd43e8884dea5e46f', "fd38f9bced717f5fd43e8884dea6030f","NEW",NULL, "BT","2926",true,0, "Natural Deaths",NULL, "2017-04-25 16:24:07","2017-04-25 16:09:55"),('fd38f9bced717f5fd43e8884dea61223', "fd38f9bced717f5fd43e8884dea626a1","NEW",NULL, "BT","2926",true,0, "Natural Deaths",NULL, "2017-04-25 16:27:48","2017-04-25 16:06:45");
