file = "#{Rails.root}/log/save_mysql.log"

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
    file = "#{Rails.root}/log/save_mysql.log"

	File.open(file, "a+") do |f|
	  f.write("\n#{content}")
	end
end

count = PersonRecordStatus.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	PersonRecordStatus.all.page(page).per(pagesize).each do |status|
		status.insert_update_into_mysql
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
		if identifier.identifier_type == "DEATH ENTRY NUMBER"
			den = DeathEntryNumber.where(person_record_id: identifier.person_record_id).first
			if den.blank?
				componets = identifier.identifier.split("/")
				if Person.find(identifier.person_record_id).district_code == identifier.district_code
					begin
						DeathEntryNumber.create(
								person_record_id: identifier.person_record_id, 
								district_code: identifier.district_code, 
								value: componets[1].to_i, year: componets[2].to_i, 
								created_at: identifier.created_at,
								updated_at: identifier.updated_at)							
					rescue Exception => e
						error = "#{identifier.id} : #{e.to_s}"
						add_to_file(error)
					end				
				end
			end		
		end
		begin
			identifier.insert_update_into_mysql
		rescue Exception => e
			error = "#{identifier.id} : #{e.to_s}"
			add_to_file(error)
		end
		
	end

	puts page
	page = page + 1
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

count = User.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	User.all.page(page).per(pagesize).each do |status|
		status.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

couch_mysql_path =  "#{Rails.root}/config/couchdb.yml"
db_settings = YAML.load_file(couch_mysql_path)

couch_db_settings =  db_settings[Rails.env]

couch_protocol = couch_db_settings["protocol"]
couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]

changes_link = "#{couch_protocol}://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}/_changes"

a = JSON.parse(RestClient.get(changes_link))

last_seq = CouchdbSequence.last
last_seq = CouchdbSequence.new if last_seq.blank?
last_seq.seq = a["last_seq"].to_i
last_seq.save



#Include Couch sequence code