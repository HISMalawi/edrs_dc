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
		begin
			barcode.insert_update_into_mysql
		rescue Exception => e
			error = "#{barcode.id} : #{e.to_s}"
			add_to_file(error)
		end
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
				record.destroy
				error = "#{identifier.id} : #{e.to_s}"
				add_to_file(error)          		
          	end

          end						
		end
	end

	puts page
	page = page + 1
end