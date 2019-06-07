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

		end
	end

	puts page
	page = page + 1
end