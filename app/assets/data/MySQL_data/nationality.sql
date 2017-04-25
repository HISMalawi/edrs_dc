        DROP TABLE IF EXISTS `nationality`;
        CREATE TABLE `nationality` (
        `nationality_id` VARCHAR(225) NOT NULL,
      `nationality` VARCHAR(255) DEFAULT NULL,
      PRIMARY KEY (`nationality_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
