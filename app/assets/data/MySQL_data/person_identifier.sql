        DROP TABLE IF EXISTS `person_identifier`;
        CREATE TABLE `person_identifier` (
        `person_identifier_id` VARCHAR(225) NOT NULL,
      `person_record_id` VARCHAR(255) DEFAULT NULL,
      `identifier_type` VARCHAR(255) DEFAULT NULL,
      `identifier` VARCHAR(255) DEFAULT NULL,
      `check_digit` TEXT DEFAULT NULL,
      `site_code` VARCHAR(255) DEFAULT NULL,
      `den_sort_value` VARCHAR(255) DEFAULT NULL,
      `drn_sort_value` VARCHAR(255) DEFAULT NULL,
      `district_code` VARCHAR(255) DEFAULT NULL,
      `creator` VARCHAR(255) DEFAULT NULL,
      `_rev` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`person_identifier_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
