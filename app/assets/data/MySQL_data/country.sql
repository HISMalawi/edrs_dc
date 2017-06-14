        DROP TABLE IF EXISTS `country`;
        CREATE TABLE `country` (
        `country_id` VARCHAR(225) NOT NULL,
      `name` VARCHAR(255) DEFAULT NULL,
      `iso` VARCHAR(255) DEFAULT NULL,
      `numcode` VARCHAR(255) DEFAULT NULL,
      `phonecode` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`country_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
