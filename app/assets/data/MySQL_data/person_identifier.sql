        DROP TABLE IF EXISTS `person_identifier`;
        CREATE TABLE `person_identifier` (
        `person_identifier_id` VARCHAR(225) NOT NULL,
      `person_record_id` VARCHAR(255) DEFAULT NULL,
      `identifier_type` VARCHAR(255) DEFAULT NULL,
      `identifier` VARCHAR(255) DEFAULT NULL,
      `check_digit` TEXT DEFAULT NULL,
      `site_code` VARCHAR(255) DEFAULT NULL,
      `den_sort_value` INT(11) DEFAULT NULL,
      `drn_sort_value` INT(11) DEFAULT NULL,
      `district_code` VARCHAR(255) DEFAULT NULL,
      `creator` VARCHAR(255) DEFAULT NULL,
      `_rev` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`person_identifier_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;

INSERT INTO person_identifier (person_identifier_id, person_record_id, identifier_type, identifier, check_digit, site_code, den_sort_value, drn_sort_value, district_code, creator, _rev, updated_at, created_at) VALUES 
('fd38f9bced717f5fd43e8884dea587a6', "fd38f9bced717f5fd43e8884dea6030f","DEATH ENTRY NUMBER","BT/0000002/2017","0",NULL, 20170000002,NULL, "BT","fd38f9bced717f5fd43e8884dea632bd","1-35e4487e7d2ba2a9f3a0124cfe788abf","2017-04-25 16:24:58","2017-04-25 16:24:58"),('fd38f9bced717f5fd43e8884dea5aab5', "fd38f9bced717f5fd43e8884dea5e137","DEATH ENTRY NUMBER","BT/0000001/2017","1",NULL, 20170000001,NULL, "BT","fd38f9bced717f5fd43e8884dea632bd","1-a8399cfe144cb779cf39480eabfb841c","2017-04-25 16:23:10","2017-04-25 16:23:10"),('fd38f9bced717f5fd43e8884dea5d96f', "fd38f9bced717f5fd43e8884dea5e137","Form Barcode","24254252","0",NULL, NULL, NULL, "BT","fd38f9bced717f5fd43e8884dea652c4","1-bb6b74d6aaec8b68fc17f17c9cf04101","2017-04-25 16:15:33","2017-04-25 16:15:33"),('fd38f9bced717f5fd43e8884dea5eda5', "fd38f9bced717f5fd43e8884dea6030f","Form Barcode","3563625","7",NULL, NULL, NULL, "BT","fd38f9bced717f5fd43e8884dea652c4","1-cfee43581b9805192ef14d92c1e42a63","2017-04-25 16:09:55","2017-04-25 16:09:55"),('fd38f9bced717f5fd43e8884dea61299', "fd38f9bced717f5fd43e8884dea626a1","Form Barcode","355363","3",NULL, NULL, NULL, "BT","fd38f9bced717f5fd43e8884dea652c4","1-9739c8c8dd87544159c57799872cbb02","2017-04-25 16:06:45","2017-04-25 16:06:45");
