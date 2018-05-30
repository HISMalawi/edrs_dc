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
      user = User.create(username: "#{users["clerk"]}#{surfix}", plain_password: "p@ssw0rd", last_password_date: Time.now,
								password_attempt: 0, login_attempt: 0, first_name: users["clerk"]["first_name"],
								last_name: users["clerk"]["last_name"], role: users["clerk"]["role"],
								email: "admin@baobabhealth.org")
		puts "#{user.username} : p@ssw0rd"
elsif SETTINGS['site_type'] == "dc"
      surfix = SETTINGS['district_code'].downcase
      puts "Login credentials"

	  users.keys.each do |username|
	  	 user = User.by_username.key("#{username}#{surfix}".downcase).first

		 if user.blank?

			user = User.create(username: "#{username}#{surfix}", plain_password: "p@ssw0rd", last_password_date: Time.now,
									password_attempt: 0, login_attempt: 0, first_name: users[username]["first_name"],
									last_name: users[username]["last_name"], role: users[username]["role"],
									email: "admin@baobabhealth.org",district_code: SETTINGS['district_code'])
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
			user = User.create(username: "#{username}#{surfix}".downcase , plain_password: "p@ssw0rd", last_password_date: Time.now,
									password_attempt: 0, login_attempt: 0, first_name: users[username]["first_name"],
									last_name: users[username]["last_name"], role: users[username]["role"],
									email: "admin@baobabhealth.org", district_code: district.id)
			puts "#{user.username} : p@ssw0rd"
		else
			puts "User already exist"
		end
	  end
	end
end
    


