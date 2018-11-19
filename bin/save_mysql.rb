
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

a = JSON.parse(RestClient.get("http://localhost:5984/edrs_dc/_changes"))

last_seq = CouchdbSequence.last
last_seq = CouchdbSequence.new if last_seq.blank?
last_seq.seq = a["last_seq"].to_i
last_seq.save



#Include Couch sequence code