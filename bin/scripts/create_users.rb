users  = {
		"clerk" => {"role" => "Data Clerk",
				"first_name" => "NRB",
				"last_name" => "Data Clerk"
		},
		"admin" => {"role" => "System Administrator",
				"first_name" => "NRB",
				"last_name" => "System Administrator"
		},
		"logistics" => {"role" => "Logistics Officer",
				"first_name" => "NRB",
				"last_name" => "Logistics officer"
		},
		"adr" => {
				"role" => "ADR",
				"first_name" => "NRB",
				"last_name" => "ADR"
		}
}

if SETTINGS['site_type'] == "facility"
      surfix = SETTINGS['facility_code']
      user = User.by_username.key("clerk#{surfix}").first

      if user.blank?
      	  user = User.new
		  user.username = "clerk#{surfix}"

		  user.plain_password = "p@ssw0rd"

	      user.first_name =  users["clerk"]["first_name"]

		  user.last_name = users["clerk"]["last_name"]

		  user.role =  users["clerk"]["role"]

		  user.email = "admin@baobabhealth.org"

		

		  user.district_code = district_code: SETTINGS['district_code']
			        
		  user.save

		  puts "#{user.username} : p@ssw0rd"
      else
      	  puts "User already exist"
      end
      
elsif SETTINGS['site_type'] == "dc"
      surfix = SETTINGS['district_code'].downcase
      puts "Login credentials"

	  users.keys.each do |username|
	  	 user = User.by_username.key("#{username}#{surfix}".downcase).first

		 if user.blank?

		 	user = User.new
		 	user.username = "#{username}#{surfix}".downcase

		    user.plain_password = "p@ssw0rd"

		    user.first_name = users[username]["first_name"]

		    user.last_name = users[username]["last_name"]

		    user.role =  users[username]["role"]

		    user.email = "admin@baobabhealth.org"

	

		    user.district_code = district_code: SETTINGS['district_code']
		        
		    

		    user.save
			
			puts "#{user.username} : p@ssw0rd"
		 else
		 	puts "User already exist"
		 end
		end
elsif  SETTINGS['site_type'] == "remote"
	District.all.each do |district|
	 next if district.name.to_s.include?("City")
	  surfix = district.id
	  puts "\nLogin credentials for #{district.name}"
	  users.keys.each do |username|
	  	user = User.by_username.key("#{username}#{surfix}".downcase).first

		if user.blank?
			user = User.new
		 	user.username = "#{username}#{surfix}".downcase

		    user.plain_password = "p@ssw0rd"

		    user.first_name = users[username]["first_name"]

		    user.last_name = users[username]["last_name"]

		    user.role =  users[username]["role"]

		    user.email = "admin@baobabhealth.org"

		    user.district_code = district.id

		    user.save

			puts "#{user.username} : p@ssw0rd"
		else
			puts "User already exist"
		end
	  end
	end
end
    


