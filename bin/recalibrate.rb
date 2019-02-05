#Load metadata
puts "########### LOADING METADATA PLEASE WAIT ITS GOING TO TAKE A MOMENT ###########"
`cd #{Rails.root} && bundle exec rails r bin/script/load_metadata_to_sql.rb`
puts "########### DONE LOADING METADATA ###########"
puts "########################################################################################"
puts "########### LOADING DATA PLEASE WAIT ITS GOING TO TAKE A MOMENT ######################"
#Save data to mysql
`cd #{Rails.root} && bundle exec rails r bin/script/save_mysql.rb`
puts "########################################################################################"
puts "################################# DONE LOADING DATA #################################"
puts "########################################################################################"
puts "################################# ADDING ENTRIES TO CRONTAB #################################"
puts `cd #{Rails.root} && bundle exec rails r bin/script/add_to_crontab.rb`
puts "################################# DONE RECALIBRATION #################################"
