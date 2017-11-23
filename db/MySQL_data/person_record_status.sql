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
('9fe69aea4af3a0cdfd91104803c7a4a4', "9fe69aea4af3a0cdfd91104803c7bcac","NEW",NULL, "BT","2926",0, 0, "Natural Deaths",NULL, "2017-11-23 10:35:07","2017-11-23 10:35:07"),('9fe69aea4af3a0cdfd91104803c7c0ef', "9fe69aea4af3a0cdfd91104803c7cad2","NEW",NULL, "BT","2926",0, 0, "Natural Deaths",NULL, "2017-11-23 10:29:59","2017-11-23 10:29:59"),('f540b578b0f138322f947fe80d29d15d', "f540b578b0f138322f947fe80d29eb63","NEW",NULL, "BT","2926",0, 0, "Natural Deaths",NULL, "2017-11-23 10:48:06","2017-11-23 10:48:06");
