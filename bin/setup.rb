puts "################################# LOAD COUCHDB AND MYSQL #################################"
db_settings = YAML.load_file("#{Rails.root}/config/couchdb.yml")
couch_db_settings =  db_settings[Rails.env]

couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]

Kernel.system("curl -X DELETE http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}")
Kernel.system("curl -X PUT http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}")
Kernel.system("cd #{Rails.root}/bin/couchdb-dump/ && bash couchdb-backup.sh -r -H #{couch_host} -d #{couch_db} -f #{Rails.root}/db/edrs_dc.json -u #{couch_username} -p #{couch_password}")

SimpleSQL.load_dump("#{Rails.root}/db/edrs_dc.sql");

puts "################################# INDEX COUCHDB #################################"
p1 = fork { Kernel.system("cd #{Rails.root} && bundle exec rails r bin/scripts/index_couchdb.rb") }
Process.detach(p1)
puts "################################# ADDING ENTRIES TO CRONTAB #################################"
puts `cd #{Rails.root} && bundle exec rails r bin/scripts/add_to_crontab.rb`
puts "Done"
