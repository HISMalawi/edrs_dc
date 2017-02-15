namespace :edrs do
  desc "Creating default user"
  
  task initsync: :environment do

    require Rails.root.join('bin','initsync.rb')

  end
  task sync: :environment do

  	if CONFIG['site_type'] =="facility"

  			puts "Facility Sync"

    		require Rails.root.join('bin','facility_sync.rb')
    else

    		puts "DC Sync"

    		require Rails.root.join('bin','dc_sync.rb')

   	end

  end

end