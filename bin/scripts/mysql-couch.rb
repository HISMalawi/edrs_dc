count = Record.count
pagesize = 200
pages = (count / pagesize) + 1

page = 0

id = []

db_settings = YAML.load_file("#{Rails.root}/config/couchdb.yml")
couch_db_settings =  db_settings[Rails.env]

couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]

puts "/////////////////////////////Records///////////////////////////////////////////////////"
while page <= pages
	Record.all.limit(200).offset(page * 200).each do |person|
		#raise person.attributes.inspect

		couch_record = Person.find(person.id);
		if couch_record.blank?
			barcode = BarcodeRecord.where(person_record_id: person.id).first
			next if barcode.blank?

			json = person.attributes
			person.attributes.keys.each do |key|
				json[key] = "" if json[key].blank?
			end
			json["_id"] = json["person_id"]
			json.delete("person_id")
			json.delete("_deleted")
			json.delete("_rev")
			json["type"] = "Person"
			begin

				RestClient.post("http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}", json.to_json, {content_type: :json, accept: :json})
			rescue RestClient::ExceptionWithResponse => err
  				puts  err.response.inspect
			end
			id << person.id
			puts person.id
			RecordStatus.where(person_record_id: person.id).each do |status|
				couch_status = PersonRecordStatus.find(status.id)
				next if couch_status.present?
				status_json = status.attributes
				status.attributes.keys.each do |key|
					status_json[key] = "" if status_json[key].blank?
				end
				status_json["_id"] = status_json["person_record_status_id"]
				status_json.delete("person_record_status_id")
				status_json.delete("_deleted")
				status_json.delete("_rev")
				status_json["type"] = "PersonRecordStatus"
				begin

					RestClient.post("http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}", status_json.to_json, {content_type: :json, accept: :json})
				rescue RestClient::ExceptionWithResponse => err
	  				puts  err.response.inspect
				end				
			end
			puts "Missing Records #{json['type']} #{json['_id']}"
		end
	end

	puts page
	page = page + 1
end


puts "////////////////////////////////////////////////////////////////////////////////"
puts "Missing Records #{id.count}"
puts "////////////////////////////////////////////////////////////////////////////////"

count = BarcodeRecord.count
pagesize = 200
pages = (count / pagesize) + 1

page = 0

db_settings = YAML.load_file("#{Rails.root}/config/couchdb.yml")
couch_db_settings =  db_settings[Rails.env]

couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]
puts "/////////////////////////////Barcode Records///////////////////////////////////////////////////"

while page <= pages
	BarcodeRecord.all.limit(200).offset(page * 200).each do |barcode|
		couch_record = Barcode.find(barcode.id);
		if couch_record.blank?
			json = barcode.attributes
			barcode.attributes.keys.each do |key|
				json[key] = "" if json[key].blank?
			end
			json["_id"] = json["barcode_id"]
			json.delete("barcode_id")
			json.delete("_deleted")
			json.delete("_rev")
			json["type"] = "Barcode"

			begin

				RestClient.post("http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}", json.to_json, {content_type: :json, accept: :json})
			rescue RestClient::ExceptionWithResponse => err
	  			puts  err.response.inspect
			end

			puts "Missing Records #{json['type']} #{json['_id']}"
		end

	end
	puts page
	page = page + 1
end



count = RecordIdentifier.count
pagesize = 200
pages = (count / pagesize) + 1

page = 0

db_settings = YAML.load_file("#{Rails.root}/config/couchdb.yml")
couch_db_settings =  db_settings[Rails.env]

couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]
puts "/////////////////////////////Record Identifier///////////////////////////////////////////////////"

while page <= pages
	RecordIdentifier.all.limit(200).offset(page * 200).each do |identifier|
		couch_record = PersonIdentifier.find(identifier.id);
		if couch_record.blank?
			json = identifier.attributes
			identifier.attributes.keys.each do |key|
				json[key] = "" if json[key].blank?
			end
			json["_id"] = json["person_identifier_id"]
			json.delete("person_identifier_id")
			json.delete("_deleted")
			json.delete("_rev")
			json["type"] = "PersonIdentifier"

			begin

				RestClient.post("http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}", json.to_json, {content_type: :json, accept: :json})
			rescue RestClient::ExceptionWithResponse => err
	  			puts  err.response.inspect
			end

			puts "Missing Records #{json['type']} #{json['_id']}"

		end

	end

    puts page
	page = page + 1
end

count = UserModel.count
pagesize = 200
pages = (count / pagesize) + 1

page = 0

db_settings = YAML.load_file("#{Rails.root}/config/couchdb.yml")
couch_db_settings =  db_settings[Rails.env]

couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]
puts "/////////////////////////////User Records///////////////////////////////////////////////////"

while page <= pages
	UserModel.all.limit(200).offset(page * 200).each do |user|
		couch_record = User.find(user.id);
		if couch_record.blank?
			json = user.attributes
			user.attributes.keys.each do |key|
				json[key] = "" if json[key].blank?
			end
			json["_id"] = json["user_id"]
			json.delete("user_id")
			json.delete("_deleted")
			json.delete("_rev")
			json["type"] = "User"

			begin

				RestClient.post("http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}", json.to_json, {content_type: :json, accept: :json})
			rescue RestClient::ExceptionWithResponse => err
	  			puts  err.response.inspect
			end

			puts "Missing Records #{json['type']} #{json['_id']}"

		end

	end
    puts page
	page = page + 1
end