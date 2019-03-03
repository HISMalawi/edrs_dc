#Creating metadata tables
create_facility_table = "CREATE TABLE IF NOT EXISTS health_facility (
                            health_facility_id varchar(255) NOT NULL,
                            district_id varchar(5) NOT NULL,
  							facility_code varchar(40),
 							name varchar(40),
							zone varchar(40),
							facility_type varchar(255),
							f_type varchar(40),
							latitude varchar(40),
							longitude varchar(40),
                            created_at datetime DEFAULT NULL,
                            updated_at datetime DEFAULT NULL,
                          PRIMARY KEY (health_facility_id)
                        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
SimpleSQL.query_exec(create_facility_table); 

create_barcode_table = "CREATE TABLE IF NOT EXISTS barcodes (
							barcode_id varchar(255) NOT NULL,
							person_record_id varchar(225) NOT NULL,
							barcode varchar(255) NOT NULL,
							assigned INT(1),
							district_code varchar(5) NOT NULL,
							creator varchar(255) NOT NULL,
                          PRIMARY KEY (barcode_id)
                        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
SimpleSQL.query_exec(create_barcode_table);

alter_person_identifier_id = "ALTER TABLE person_identifier MODIFY COLUMN person_identifier_id VARCHAR(255)"

SimpleSQL.query_exec(alter_person_identifier_id);

SimpleSQL.load_dump("#{Rails.root}/db/dump.sql");

test_ids = "9580f39875071e0df2999ce39e0adc9d , 9580f39875071e0df2999ce39e0b965c , 9580f39875071e0df2999ce39e0b9a69 , 9580f39875071e0df2999ce39e0b9a88 , 9580f39875071e0df2999ce39e0ba7bb , 
			9580f39875071e0df2999ce39e0baa97 , 9580f39875071e0df2999ce39e0bb7e5 , 9580f39875071e0df2999ce39e0bba9a , 9580f39875071e0df2999ce39e0bc211 , 9580f39875071e0df2999ce39e0bc6ca , 
			9580f39875071e0df2999ce39e0bc760 , 9580f39875071e0df2999ce39e0bcaea , 9580f39875071e0df2999ce39e0bd581 , 9580f39875071e0df2999ce39e0bd6a6 , 9580f39875071e0df2999ce39e0be286 , 
			9580f39875071e0df2999ce39e0bebf1 , 9580f39875071e0df2999ce39e0bf036 , 9580f39875071e0df2999ce39e0bf567 , 9580f39875071e0df2999ce39e0bf776 , 9580f39875071e0df2999ce39e0bfed6 , 
			9580f39875071e0df2999ce39e0c7e3a , 9580f39875071e0df2999ce39e0e3be0 , 9580f39875071e0df2999ce39e0e4f80 , 9580f39875071e0df2999ce39e0e5f1a , 9580f39875071e0df2999ce39e0e60a2 , 
			9580f39875071e0df2999ce39e0e69a8 , 9580f39875071e0df2999ce39e0e7050 , 9580f39875071e0df2999ce39e0e76d3 , 9580f39875071e0df2999ce39e0e8634 , 9580f39875071e0df2999ce39e0e91e8 , 
			9580f39875071e0df2999ce39e0e94b0 , 9580f39875071e0df2999ce39e0e9cb1 , 9580f39875071e0df2999ce39e0eaa9c , 9580f39875071e0df2999ce39e0eb607 , 9580f39875071e0df2999ce39e0ec18c , 
			9580f39875071e0df2999ce39e0ec615 , 9580f39875071e0df2999ce39e0f5550 , 9580f39875071e0df2999ce39e0f58ad , 9580f39875071e0df2999ce39e0f5bbc , 9580f39875071e0df2999ce39e0fbcdf , 
			9580f39875071e0df2999ce39e0fca19 , 9580f39875071e0df2999ce39e0fd36c , 9580f39875071e0df2999ce39e0cf648 , 9580f39875071e0df2999ce39e0cfb56 , 9580f39875071e0df2999ce39e0d085a , 
			9580f39875071e0df2999ce39e0d0f38 , 9580f39875071e0df2999ce39e0d1174 , 9580f39875071e0df2999ce39e0d1d50 , 9580f39875071e0df2999ce39e0d2414 , 9580f39875071e0df2999ce39e0d2416 , 
			9580f39875071e0df2999ce39e0d3182 , 9580f39875071e0df2999ce39e0d3a66 , 9580f39875071e0df2999ce39e0d3e9a , 9580f39875071e0df2999ce39e0d4e4d , 9580f39875071e0df2999ce39e0d52d7 , 
			9580f39875071e0df2999ce39e0d5a67 , 9580f39875071e0df2999ce39e0d648a , 9580f39875071e0df2999ce39e0d71bf , 9580f39875071e0df2999ce39e0d7ad8 , 9580f39875071e0df2999ce39e0d84d7 , 
			9580f39875071e0df2999ce39e0d8b1a , 9580f39875071e0df2999ce39e0d94bc , 9580f39875071e0df2999ce39e0da2f9 , 9580f39875071e0df2999ce39e0da666 , 9580f39875071e0df2999ce39e0dafb8 , 
			9580f39875071e0df2999ce39e0dbc83 , 9580f39875071e0df2999ce39e0dbe0e , 9580f39875071e0df2999ce39e0dc625 , 9580f39875071e0df2999ce39e0dc8d3 , 9580f39875071e0df2999ce39e0dd04c , 
			9580f39875071e0df2999ce39e0dd3ec , 9580f39875071e0df2999ce39e0ddba8 , 9580f39875071e0df2999ce39e0de1c5 , 9580f39875071e0df2999ce39e0decd2 , 9580f39875071e0df2999ce39e0df9cc , 
			9580f39875071e0df2999ce39e0e0270 , 9580f39875071e0df2999ce39e0e028b , 9580f39875071e0df2999ce39e0e0c16 , 9580f39875071e0df2999ce39e0e0e24 , 9580f39875071e0df2999ce39e0e0f88 , 
			9580f39875071e0df2999ce39e0e157f , 9580f39875071e0df2999ce39e0e4026 , 9580f39875071e0df2999ce39e0ecebc , 9580f39875071e0df2999ce39e0edced , 9580f39875071e0df2999ce39e0ee640 , 
			9580f39875071e0df2999ce39e0eea58 , 9580f39875071e0df2999ce39e0eeadb , 9580f39875071e0df2999ce39e0eebe9 , 9580f39875071e0df2999ce39e0ef4cb , 9580f39875071e0df2999ce39e0eff2b , 
			9580f39875071e0df2999ce39e0f04ba , 9580f39875071e0df2999ce39e0f062d , 9580f39875071e0df2999ce39e0f13ec , 9580f39875071e0df2999ce39e0f2101 , 9580f39875071e0df2999ce39e0f2c95 , 
			9580f39875071e0df2999ce39e0f341b , 9580f39875071e0df2999ce39e0f3fa1 , 9580f39875071e0df2999ce39e0f444a , 9580f39875071e0df2999ce39e0f46fe , 9580f39875071e0df2999ce39e0f4dc8 , 
			9580f39875071e0df2999ce39e0f6693 , 9580f39875071e0df2999ce39e0f72b0 , 9580f39875071e0df2999ce39e0f8162 , 9580f39875071e0df2999ce39e0f8764 , 9580f39875071e0df2999ce39e0f9167 , 
			9580f39875071e0df2999ce39e0f9704 , 9580f39875071e0df2999ce39e0f972d , 9580f39875071e0df2999ce39e0fa244 , 9580f39875071e0df2999ce39e0faba1 , 9580f39875071e0df2999ce39e0fb55e , 
			9580f39875071e0df2999ce39e0fdfe8 , 9580f39875071e0df2999ce39e0fe3aa , 9580f39875071e0df2999ce39e0fec95 , 9580f39875071e0df2999ce39e0ffc63 , 9580f39875071e0df2999ce39e100c06 , 
			9580f39875071e0df2999ce39e0a6f36 , 9580f39875071e0df2999ce39e0a7828 , 9580f39875071e0df2999ce39e0a866f , 9580f39875071e0df2999ce39e0a8c7c , 9580f39875071e0df2999ce39e0a8eda , 
			9580f39875071e0df2999ce39e0a8ff9 , 9580f39875071e0df2999ce39e0a968c , 9580f39875071e0df2999ce39e0a9fae , 9580f39875071e0df2999ce39e0a9fe2 , 9580f39875071e0df2999ce39e0aa6bf , 
			9580f39875071e0df2999ce39e0aad82 , 9580f39875071e0df2999ce39e0abb7b , 9580f39875071e0df2999ce39e0ac49a , 9580f39875071e0df2999ce39e0acbdd , 9580f39875071e0df2999ce39e0aecfd , 
			9580f39875071e0df2999ce39e0af38a , 9580f39875071e0df2999ce39e0b00d9 , 9580f39875071e0df2999ce39e0b0cd2 , 9580f39875071e0df2999ce39e0b19b1 , 9580f39875071e0df2999ce39e0b1e56 , 
			9580f39875071e0df2999ce39e0b2268 , 9580f39875071e0df2999ce39e0b2eda , 9580f39875071e0df2999ce39e0b3790 , 9580f39875071e0df2999ce39e0b451b , 9580f39875071e0df2999ce39e0b4e4a , 
			9580f39875071e0df2999ce39e0b5d83 , 9580f39875071e0df2999ce39e0b78f7 , 9580f39875071e0df2999ce39e0c8932 , 9580f39875071e0df2999ce39e0c9851 , 9580f39875071e0df2999ce39e0ca10b , 
			9580f39875071e0df2999ce39e0caece , 9580f39875071e0df2999ce39e0cb51f , 9580f39875071e0df2999ce39e0cbc79 , 9580f39875071e0df2999ce39e0cc4b7 , 9580f39875071e0df2999ce39e0ccb71 , 
			9580f39875071e0df2999ce39e0ccc81 , 9580f39875071e0df2999ce39e0cd0c1 , 9580f39875071e0df2999ce39e0cdb5c , 9580f39875071e0df2999ce39e0ce475 , 9580f39875071e0df2999ce39e0cf381 , 
			9580f39875071e0df2999ce39e0b799d , 9580f39875071e0df2999ce39e0c8767 , 9580f39875071e0df2999ce39e0a0a56 , 9580f39875071e0df2999ce39e0a0e22 , 9580f39875071e0df2999ce39e0a116e , 
			9580f39875071e0df2999ce39e0a11c2 , 9580f39875071e0df2999ce39e0a15e6 , 9580f39875071e0df2999ce39e0a2501 , 9580f39875071e0df2999ce39e0a2b21 , 9580f39875071e0df2999ce39e0a39c3 , 
			9580f39875071e0df2999ce39e0a4300 , 9580f39875071e0df2999ce39e0a4e53 , 9580f39875071e0df2999ce39e0a5c8c , 9580f39875071e0df2999ce39e0a6912 , 9580f39875071e0df2999ce39e0abb36 , 
			9580f39875071e0df2999ce39e0acf71 , 9580f39875071e0df2999ce39e0aeae2 , 9580f39875071e0df2999ce39e0b6d52 , 9580f39875071e0df2999ce39e0b8154 , 9580f39875071e0df2999ce39e0b8c8c , 
			9580f39875071e0df2999ce39e0b8f34 , 9580f39875071e0df2999ce39e0b8fcb , 9580f39875071e0df2999ce39e0c0992 , 9580f39875071e0df2999ce39e0c12af , 9580f39875071e0df2999ce39e0c1a9f , 
			9580f39875071e0df2999ce39e0c1b44 , 9580f39875071e0df2999ce39e0c2320 , 9580f39875071e0df2999ce39e0c2e89 , 9580f39875071e0df2999ce39e0c374e , 9580f39875071e0df2999ce39e0c3d32 , 
			9580f39875071e0df2999ce39e0c4a5f , 9580f39875071e0df2999ce39e0c50e1 , 9580f39875071e0df2999ce39e0c51e8 , 9580f39875071e0df2999ce39e0c5ca5 , 9580f39875071e0df2999ce39e0c68c4 , 
			9580f39875071e0df2999ce39e0c75e8 , 9580f39875071e0df2999ce39e0c7d90 , 9580f39875071e0df2999ce39e0ce6b1 , 9580f39875071e0df2999ce39e0cf4da"
ids = test_ids.split(" , ").collect { |e| e.squish  }

delete_ids = "DELETE FROM person_record_status WHERE person_record_status_id IN ('#{ids.join("','")}')"

SimpleSQL.query_exec(delete_ids);

SimpleSQL.load_dump("#{Rails.root}/db/directory.sql");

#Loading metadata
count = HealthFacility.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	HealthFacility.all.page(page).per(pagesize).each do |facility|
		facility.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

exit 

count = Nationality.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	Nationality.all.page(page).per(pagesize).each do |country|
		country.insert_update_into_mysql
	end

	puts page
	page = page + 1
end


count = Country.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	Country.all.page(page).per(pagesize).each do |country|
		country.insert_update_into_mysql
	end

	puts page
	page = page + 1
end



count = District.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	District.all.page(page).per(pagesize).each do |district|
		district.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

count = TraditionalAuthority.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	TraditionalAuthority.all.page(page).per(pagesize).each do |ta|
		ta.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

count = Village.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	Village.all.page(page).per(pagesize).each do |vl|
		vl.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

puts "Done loading metadata"