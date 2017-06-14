        DROP TABLE IF EXISTS `traditional_authority`;
        CREATE TABLE `traditional_authority` (
        `traditional_authority_id` VARCHAR(225) NOT NULL,
      `district_id` VARCHAR(255) DEFAULT NULL,
      `name` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`traditional_authority_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
