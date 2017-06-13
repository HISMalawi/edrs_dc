require 'sql_search'
if Rails.env == "development"
	puts Person.count
	Person.all.each do |d|
		d.destroy
	end

	puts PersonRecordStatus.count

	PersonRecordStatus.all.each do |d|
		d.destroy
	end

	puts PersonIdentifier.count

	PersonIdentifier.all.each do |d|
		d.destroy  
	end

	create_query = "DROP TABLE documents;
					CREATE TABLE IF NOT EXISTS documents (
                    id int(11) NOT NULL AUTO_INCREMENT,
                    couchdb_id varchar(255) NOT NULL UNIQUE,
                    group_id varchar(255) DEFAULT NULL,
                    group_id2 varchar(255) DEFAULT NULL,
                    date_added datetime DEFAULT NULL,
                    title TEXT,
                    content TEXT,
                    created_at datetime NOT NULL,
                    updated_at datetime NOT NULL,
                    PRIMARY KEY (id),
                    FULLTEXT KEY content (content)
                  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    SQLSearch.query_exec(create_query);

    puts "Drop documents"

    create_status_table = "DROP TABLE person_record_status ;
    					   CREATE TABLE IF NOT EXISTS person_record_status (
                            person_record_status_id varchar(225) NOT NULL,
                            person_record_id varchar(255) DEFAULT NULL,
                            status varchar(255) DEFAULT NULL,
                            prev_status varchar(255) DEFAULT NULL,
                            district_code varchar(255) DEFAULT NULL,
                            facility_code varchar(255) DEFAULT NULL,
                            voided tinyint(1) NOT NULL DEFAULT '0',
                            reprint tinyint(1) NOT NULL DEFAULT '0',
                            registration_type  varchar(255) DEFAULT NULL,
                            creator varchar(255) DEFAULT NULL,
                            updated_at datetime DEFAULT NULL,
                            created_at datetime DEFAULT NULL,
                          PRIMARY KEY (person_record_status_id)
                        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
    SQLSearch.query_exec(create_status_table); 

     puts "Drop person_record_status"  

    create_identifier_table = "DROP TABLE person_identifier;
    						   CREATE TABLE person_identifier (
                                person_identifier_id varchar(225) NOT NULL,
                                person_record_id varchar(255) DEFAULT NULL,
                                identifier_type varchar(255) DEFAULT NULL,
                                identifier varchar(255) DEFAULT NULL,
                                check_digit text,
                                site_code varchar(255) DEFAULT NULL,
                                den_sort_value int(11) DEFAULT NULL,
                                drn_sort_value int(11) DEFAULT NULL,
                                district_code varchar(255) DEFAULT NULL,
                                creator varchar(255) DEFAULT NULL,
                                _rev varchar(255) DEFAULT NULL,
                                updated_at datetime DEFAULT NULL,
                                created_at datetime DEFAULT NULL,
                              PRIMARY KEY (person_identifier_id)
                            ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"  
                            
    SQLSearch.query_exec(create_identifier_table);

    puts "Drop person_record_status"   

    if CONFIG['site_type'] != "facility"
        create_query_den_table = "DROP TABLE dens;
        						  CREATE TABLE IF NOT EXISTS dens (
                                      den_id int(11) NOT NULL AUTO_INCREMENT,
                                      person_id varchar(225) NOT NULL,
                                      den varchar(15) NOT NULL,
                                      den_sort_value varchar(15) NOT NULL,
                                      created_at datetime NOT NULL,
                                      updated_at datetime NOT NULL,
                                      PRIMARY KEY (den_id),
                                      UNIQUE KEY den (den),
                                      KEY person_id (person_id),
                                      CONSTRAINT dens_ibfk_1 FOREIGN KEY (person_id) REFERENCES people (person_id)
                                  ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
          SQLSearch.query_exec(create_query_den_table)

          puts "Drop dens"   
    end

end
