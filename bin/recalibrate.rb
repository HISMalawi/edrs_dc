#Load metadata
puts "########### LOADING METADATA PLEASE WAIT ITS GOING TO TAKE A MOMENT ###########"
`cd #{Rails.root} && bundle exec rails r bin/load_metadata_to_sql.rb`
puts "########### DONE LOADING METADATA ###########"
puts "########################################################################################"
puts "########### LOADING DATA PLEASE WAIT ITS GOING TO TAKE A MOMENT ######################"
#Save data to mysql
`cd #{Rails.root} && bundle exec rails r bin/save_mysql.rb`
puts "########################################################################################"
puts "################################# DONE LOADING DATA #################################"