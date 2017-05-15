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
