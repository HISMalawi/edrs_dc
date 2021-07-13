file = "#{Rails.root}/log/save_barcorde_mysql.log"

if !File.exist?(file)
	File.open(file, "w+") do |f|
		  f.write("Log for #{Time.now}")
	end
else
	File.open(file, "a+") do |f|
	  f.write("\nLog for #{Time.now}")
	end	
end

def add_to_file(content)
    file = "#{Rails.root}/log/save_barcodes_mysql.log"

	File.open(file, "a+") do |f|
	  f.write("\n#{content}")
	end
end

count = Barcode.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	Barcode.all.page(page).per(pagesize).each do |barcode|
		next if barcode.district_code != SETTINGS['district_code']
		begin
			barcode.insert_update_into_mysql

			statuses_query = "SELECT * FROM person_record_status WHERE  person_record_id='#{barcode.person_record_id}' ORDER BY created_at"
			statuses = connection.select_all(statuses_query).as_json
			last_status = statuses.last rescue nil
			next if last_status.present?
			person = Person.find(barcode.person_record_id)
			person.insert_update_into_mysql
			PersonRecordStatus.by_person_record_id.key(person.id).each do |status|
				status.insert_update_into_mysql
			end
		rescue Exception => e
			error = "#{barcode.id} : #{e.to_s}"
			add_to_file(error)
		end
	end

	puts page
	page = page + 1
end


count = Person.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	Person.all.page(page).per(pagesize).each do |status|
		next if status.district_code != SETTINGS['district_code']
		status.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

count = PersonIdentifier.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	PersonIdentifier.all.page(page).per(pagesize).each do |identifier|
		next if status.district_code != SETTINGS['district_code']
		if identifier.identifier_type == "Form Barcode"
          barcode = BarcodeRecord.where(person_record_id: identifier.person_record_id).last

          if barcode.blank?
          	record = nil
          	begin
          		record = Barcode.create({
                              :person_record_id => identifier.person_record_id,
                              :barcode => identifier.identifier,
                              :district_code => identifier.district_code,
                              :creator => identifier.creator
                })          		
          	rescue Exception => e
				error = "#{identifier.id} : #{e.to_s}"
				add_to_file(error)          		
          	end 

          end						
		end
	end

	puts page
	page = page + 1
end