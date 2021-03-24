puts "################################# CREATING DIRECTORIES #################################"
puts "Creating Barcode / Certificate and Dispatch paths"
if ["dc","remote"].include?(SETTINGS['site_type'])
    Dir.mkdir(SETTINGS['barcodes_path']) unless Dir.exist?(SETTINGS['barcodes_path'])
    File.chmod(0777, SETTINGS['barcodes_path'])
    puts File.stat(SETTINGS['barcodes_path']).mode.to_s(8)

    Dir.mkdir(SETTINGS['qrcodes_path']) unless Dir.exist?(SETTINGS['qrcodes_path'])
    File.chmod(0777, SETTINGS['qrcodes_path'])
    puts File.stat(SETTINGS['qrcodes_path']).mode.to_s(8)

    Dir.mkdir(SETTINGS['certificates_path']) unless Dir.exist?(SETTINGS['certificates_path'])
    File.chmod(0777, SETTINGS['certificates_path'])
    puts File.stat(SETTINGS['certificates_path']).mode.to_s(8)

    Dir.mkdir(SETTINGS['dispatch_path']) unless Dir.exist?(SETTINGS['dispatch_path'])
    File.chmod(0777, SETTINGS['dispatch_path'])
    puts File.stat(SETTINGS['dispatch_path']).mode.to_s(8)
end
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
Kernel.system("cd #{Rails.root}/bin/ && bash couchdb-backup.sh -r -H #{couch_host} -d #{couch_db} -f #{Rails.root}/db/edrs_dc.json -u #{couch_username} -p #{couch_password} -P #{couch_port}")

SimpleSQL.load_dump("#{Rails.root}/db/edrs_dc.sql");

puts "################################# INDEX COUCHDB #################################"
p1 = fork { Kernel.system("cd #{Rails.root} && bundle exec rails r bin/scripts/index_couchdb.rb") }
Process.detach(p1)
puts "################################# ADDING ENTRIES TO CRONTAB #################################"
puts `cd #{Rails.root} && bundle exec rails r bin/scripts/add_to_crontab.rb`
puts "Done"
