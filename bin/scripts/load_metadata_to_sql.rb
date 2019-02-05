#Creating metadata tables
create_facility_table = "CREATE TABLE IF NOT EXISTS health_facility (
                            health_facility_id varchar(225) NOT NULL,
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
							barcode_id varchar(225) NOT NULL,
							person_record_id varchar(225) NOT NULL,
							barcode varchar(100) NOT NULL,
							assigned INT(1),
							district_code varchar(5) NOT NULL,
							creator varchar(225) NOT NULL,
                          PRIMARY KEY (barcode_id)
                        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
SimpleSQL.query_exec(create_barcode_table);


SimpleSQL.load_dump("#{Rails.root}/db/dump.sql");

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