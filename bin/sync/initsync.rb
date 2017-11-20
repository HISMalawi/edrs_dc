=begin
puts "Clearing Elasticsearch"
SETTING = YAML.load_file("#{Rails.root}/config/elasticsearchsetting.yml")['elasticsearch']
puts `curl -XDELETE #{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}`

puts "Cleaning mysql"
SimpleSQL.query_exec("DROP DATABASE #{MYSQL['database']}") 

puts "Cleaning couch"
db_settings = YAML.load_file("#{Rails.root}/config/couchdb.yml")
couch_db_settings =  db_settings[Rails.env]

couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]

`curl -X DELETE http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}`

puts "Databases cleared"
=end

Person.count
@settings = SYNC_SETTINGS
district_code = SETTINGS['district_code']
person_count = Person.count

if SETTINGS['site_type'] == "facility"
	source = @settings[:fc]
else
	source = @settings[:dc]
end

hq = @settings[:hq]

target_to_source = %x[curl -k -H 'Content-Type: application/json' -X POST -d '#{{
                  source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  retries_per_request: 20,
                  http_connections: 30,
                  continuous: true
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]


JSON.parse(target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
end
puts "\nDistricts :#{District.count} \n"
puts "\nTAs :#{TraditionalAuthority.count} \n"
puts "\nVillages :#{Village.count} \n"

PersonIdentifier.can_assign_den = false
`rake edrs:build_mysql`
PersonIdentifier.can_assign_den = true
puts "Tables Creatted"



        
                  
        
                
