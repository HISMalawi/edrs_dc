def check_sync
    sync = false
    if Village.count >= 33555
        if District.count >= 32
          if TraditionalAuthority.count >= 355
            if HealthFacility.count >= 1048
              sync = true
              return sync
            end
          end
        end
    end
    return sync
end
def finalize_setup(username,password)
  sleep 15
  if check_sync
    puts "\nDistricts :#{District.count} \n"
    puts "\nTAs :#{TraditionalAuthority.count} \n"
    puts "\nVillages :#{Village.count} \n"

    PersonIdentifier.can_assign_den = false
    puts "Creating mysql databse"
    `rake edrs:build_mysql`
    ActiveRecord::Schema.define(version: 0) do
      create_table "name_directory", primary_key: "name_directory_id", force: :cascade do |t|
        t.string   "name",        limit: 45,                  null: false
        t.string   "soundex",        limit: 10,                  null: false
        t.datetime "created_at", :default => Time.now
        t.datetime "updated_at", :default => Time.now
      end

      add_index "name_directory", ["soundex"], name: "name_directory_sondex", using: :btree
      add_index "name_directory", ["name"], name: "name_directory_UNIQUE", unique: true, using: :btree
    end

    puts "Loading directory names"

    SimpleSQL.load_dump("#{Rails.root}/db/directory.sql");

    puts "Setup successfull !\n"
    puts "login with username: #{username} , password: #{password}"
    PersonIdentifier.can_assign_den = true
    exit
    
  else
      puts "Sync from HQ please wait..."
      sleep 10
      finalize_setup
  end
end

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

`curl -X PUT http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}`


@settings = SYNC_SETTINGS
district_code = SETTINGS['district_code']

if SETTINGS['site_type'] == "facility"
	source = @settings[:fc]
else
	source = @settings[:dc]
end

hq = @settings[:hq]

target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
                  source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  retries_per_request: 20,
                  http_connections: 30,
                  continuous: false
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]


JSON.parse(target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
end

if SETTINGS['site_type'] == "facility"
      surfix = SETTINGS['facility_code']
else
      surfix = SETTINGS['district_code']
end
    
user = User.by_username.key("admin#{surfix}".downcase).first

if user.blank?

         username = "admin#{surfix}".downcase
         user = User.create(username: username, plain_password: "password", last_password_date: Time.now,
                         password_attempt: 0, login_attempt: 0, first_name: "EDRS #{surfix}",
                         last_name: "Administrator", role: "System Administrator",
                         email: "admin@baobabhealth.org")

else
      puts "System admin User already exists"
end
finalize_setup(username,"password")



        
                  
        
                
