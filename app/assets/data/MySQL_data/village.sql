        DROP TABLE IF EXISTS `village`;
        CREATE TABLE `village` (
        `village_id` VARCHAR(225) NOT NULL,
      `ta_id` VARCHAR(255) DEFAULT NULL,
      `name` VARCHAR(255) DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      PRIMARY KEY (`village_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
