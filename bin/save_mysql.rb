
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
	PersonIdentifier.all.page(page).per(pagesize).each do |status|
		status.insert_update_into_mysql
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
		barcode.insert_update_into_mysql
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