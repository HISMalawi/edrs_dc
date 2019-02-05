require "rails"
require "yaml"
DIR = File.dirname(__FILE__)


def save_to_mysql(record,map_key,db_maps)
	$models = {
				"people" => "Record",
				"person_record_status" => "RecordStatus",
				"person_identifier" => "RecordIdentifier",
				"user" => "UserModel",
				"barcodes"=>"BarcodeRecord"
	}

	table = map_key.split("|")[1]
	primary_key = db_maps[map_key]["_id"] 

	return if $models[table].blank?
	

	mysql_record = eval($models[table]).where("#{primary_key}= '#{record['id']}'").first rescue nil

	if mysql_record.present?
		
		keys_count = (record["doc"].keys - ["type","_rev","_id"]).sort.count
		i = 0
		(record["doc"].keys - ["type","_rev","_id"]).sort.each do |field|
			i = i + 1
			next if record["doc"][field].blank?
			next if field == "_id"
			next if field == "type"

			#value = record["doc"][field].to_s.gsub("'","''")
			value = record["doc"][field]
			date_field = ["created_at","updated_at","last_password_date","birthdate","date_of_death"]
			if date_field.include?(field)
				value = record["doc"][field].to_time.strftime("%Y-%m-%d %H:%M:%S")
			end
			if value.to_s == "true"
				value = 1
			end
			if value.to_s == "false"
				value = 0
			end

				
			mysql_record[field] = value
			
		end
	else
		mysql_record = eval($models[table]).new
		
		keys_count = (record["doc"].keys - ["type","_rev"]).sort.count
		i = 0
		(record["doc"].keys - ["type","_rev"]).sort.each do |field|
			i = i + 1
			value = record["doc"][field]

			next if record["doc"][field].blank?
			next if field == "type"
			if field == "_id"
				field = primary_key
			end
			
			#value = record["doc"][field].to_s.gsub("'","''")
			date_field = ["created_at","updated_at","last_password_date","birthdate","date_of_death"]
			if date_field.include?(field)
				value = record["doc"][field].to_time.strftime("%Y-%m-%d %H:%M:%S")
			end
			if value.to_s == "true"
				value = 1
			end
			if value.to_s == "false"
				value = 0
			end
				
			mysql_record[field] = value
			
			
		end
	end
	mysql_record.save
end

if File.file?("/tmp/couch_to_mysql_process.pid")
else

	`PROCESS_FILE="/tmp/couch_to_mysql_process.pid"

	if [ -f $PROCESS_FILE ] ; then
	  exit
	fi

	touch $PROCESS_FILE`

	couch_mysql_path =  "#{Rails.root}/config/couchdb.yml"
	db_settings = YAML.load_file(couch_mysql_path)

	couch_db_settings =  db_settings[Rails.env]

	couch_protocol = couch_db_settings["protocol"]
	couch_username = couch_db_settings["username"]
	couch_password = couch_db_settings["password"]
	couch_host = couch_db_settings["host"]
	couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
	
	couch_port = couch_db_settings["port"]

	mysql_path = "#{Rails.root}/config/database.yml"
	mysql_db_settings = YAML.load_file(mysql_path)
	mysql_db_settings = mysql_db_settings[Rails.env]

	mysql_username = mysql_db_settings["username"]
	mysql_password = mysql_db_settings["password"]
	mysql_host = mysql_db_settings["host"]
	mysql_db = mysql_db_settings["database"]
	mysql_port =  "3306"
	mysql_adapter = mysql_db_settings["adapter"]


	#reading db_mapping
	db_map_path ="#{Rails.root}/config/db_mapping.yml"
	db_maps = YAML.load_file(db_map_path)
	last_seq = CouchdbSequence.last
	seq = last_seq.seq rescue 0

	
	begin
		seq = CouchdbSequence.last.seq rescue 0 

		changes_link = "#{couch_protocol}://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}/_changes?include_docs=true&limit=500&since=#{seq}"

		puts changes_link

		data = JSON.parse(RestClient.get(changes_link))


		records  = data["results"]
		seq = data["last_seq"] 
		records.each do |record|
				db_maps.keys.each do |key|
					parts = key.split("|")
					if record["doc"]["type"] == parts[0]
						save_to_mysql(record,key,db_maps)
					else
						next
					end
				end
		end
		last_seq = CouchdbSequence.last
		last_seq = CouchdbSequence.new if last_seq.blank?
		last_seq.seq = data["last_seq"] 
		last_seq.save

	rescue Exception => e
		puts e.to_s
		last_seq = CouchdbSequence.last
		last_seq = CouchdbSequence.new if last_seq.blank?
		last_seq.seq = seq
		last_seq.save
	end

	`PROCESS_FILE="/tmp/couch_to_mysql_process.pid"

	if [ -f $PROCESS_FILE ] ; then
	  rm $PROCESS_FILE
	fi`
end