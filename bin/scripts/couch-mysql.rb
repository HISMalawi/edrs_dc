require "rails"
require "yaml"
DIR = File.dirname(__FILE__)

def save_to_mysql(record,map_key,db_maps)
	table = map_key.split("|")[1]
	primary_key = db_maps[map_key]["_id"] 

	query ="SELECT #{primary_key} FROM #{table} WHERE #{primary_key}= '#{record['id']}'"

	connection = ActiveRecord::Base.connection
	id = connection.select_all(query).as_json.last["#{primary_key}"]

	if id.present?
		insert_update_sql = "UPDATE #{table} SET "
		keys_count = (record["doc"].keys - ["type","_rev"]).sort.count
		i = 0
		(record["doc"].keys - ["type","_rev"]).sort.each do |field|
			i = i + 1
			next if record["doc"][field].blank?
			next if field == "_id"
			next if field == "type"

			value = record["doc"][field].to_s.gsub("'","''")
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

			if i == keys_count
				insert_update_sql = "#{insert_update_sql} #{field}=\"#{value}\""
			else	
				insert_update_sql = "#{insert_update_sql} #{field}=\"#{value}\","
			end
			
		end
		insert_update_sql = "#{insert_update_sql} WHERE #{primary_key}=\"#{id}\""
		#puts insert_update_sql
	else
		insert_update_sql = "INSERT INTO #{table}("
		keys_count = (record["doc"].keys - ["type","_rev"]).sort.count
		i = 0
		(record["doc"].keys - ["type","_rev"]).sort.each do |field|
			i = i + 1
			next if record["doc"][field].blank?
			next if field == "type"
			if field == "_id"
				field = primary_key
			end

			if i == keys_count
				insert_update_sql = "#{insert_update_sql} #{field})"
			else	
				insert_update_sql = "#{insert_update_sql} #{field},"
			end
			
		end
		
		insert_update_sql = "#{insert_update_sql} VALUES("

		i = 0
		(record["doc"].keys - ["type","_rev"]).sort.each do |field|
			i = i + 1
			next if record["doc"][field].blank?
			next if field == "type"
			value = record["doc"][field].to_s.gsub("'","''")
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
			if i == keys_count
				insert_update_sql = "#{insert_update_sql} \"#{value}\")"
			else	
				insert_update_sql = "#{insert_update_sql} \"#{value}\","
			end
			
		end
		#puts insert_update_sql
	end
	connection.execute(insert_update_sql)
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

begin
	seq = CouchdbSequence.last.seq rescue 0 

	changes_link = "#{couch_protocol}://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}/_changes?include_docs=true&limit=500&since=#{seq}"

	data = JSON.parse(RestClient.get(changes_link))
	records  = data["results"]

	records.each do |record|
			db_maps.keys.each do |key|
				parts = key.split("|")
				if record["doc"]["type"] == parts[0]
					save_to_mysql(record,key,db_maps)
				else
					next
				end
			end

			last_seq = CouchdbSequence.last
			last_seq = CouchdbSequence.new if last_seq.blank?
			last_seq.seq = data["last_seq"] 
			last_seq.save
	end
rescue Exception => e
	puts "CouchdbSequence not created yet"
end
