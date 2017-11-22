        DROP TABLE IF EXISTS `role`;
        CREATE TABLE `role` (
        `role_id` VARCHAR(225) NOT NULL,
      `role` VARCHAR(255) DEFAULT NULL,
      `level` VARCHAR(255) DEFAULT NULL,
      `activities` TEXT DEFAULT NULL,
      PRIMARY KEY (`role_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;

INSERT INTO role (role_id, role, level, activities) VALUES 
('6df6bb47f32babe151a5242b1f1fa258', "System Administrator","Facility",'["Activate User", "Deactivate User", "Create User", "Update User", "View Users", "Change own password"]'),('6df6bb47f32babe151a5242b1f1fb172', "Nurse/Midwife","Facility",'["Register a record", "View a record", "Change own password"]'),('6df6bb47f32babe151a5242b1f1fb26c', "Data Clerk","Facility",'["Register a record", "View a record", "Change own password"]');
