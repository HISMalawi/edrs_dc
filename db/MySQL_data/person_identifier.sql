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

INSERT INTO person_identifier (person_identifier_id, person_record_id, identifier_type, identifier, check_digit, site_code, den_sort_value, drn_sort_value, district_code, creator, _rev, updated_at, created_at) VALUES 
('12345', "9fe69aea4af3a0cdfd91104803c7cad2","Form Barcode","12345","5",NULL, NULL, NULL, "BT","9fe69aea4af3a0cdfd91104803c7dc24","1-4fff275308426b6d66cc0cd1d771b39c","2017-11-23 10:29:59","2017-11-23 10:29:59"),('1234567', "9fe69aea4af3a0cdfd91104803c7bcac","Form Barcode","1234567","4",NULL, NULL, NULL, "BT","9fe69aea4af3a0cdfd91104803c7dc24","1-496c97b85bd43be7edf97b0c2c467968","2017-11-23 10:35:07","2017-11-23 10:35:07"),('454747', "f540b578b0f138322f947fe80d29eb63","Form Barcode","454747","7",NULL, NULL, NULL, "BT","9fe69aea4af3a0cdfd91104803c7dc24","1-267e396367a9f2c38d575fca3b257540","2017-11-23 10:48:06","2017-11-23 10:48:06");
