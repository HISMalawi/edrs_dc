        DROP TABLE IF EXISTS `role`;
        CREATE TABLE `role` (
        `role_id` VARCHAR(225) NOT NULL,
      `role` VARCHAR(255) DEFAULT NULL,
      `level` VARCHAR(255) DEFAULT NULL,
      `activities` TEXT DEFAULT NULL,
      PRIMARY KEY (`role_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
