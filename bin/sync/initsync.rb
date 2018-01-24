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
def finalize_setup
  if check_sync
    puts "\nDistricts :#{District.count} \n"
    puts "\nTAs :#{TraditionalAuthority.count} \n"
    puts "\nVillages :#{Village.count} \n"

    PersonIdentifier.can_assign_den = false
    `rake edrs:build_mysql`
    PersonIdentifier.can_assign_den = true
    
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

          puts "Setup successfull !\n"
          puts "login with username: #{username} , password: password"
    else
      puts "System admin User already exists"
    end
  else
      puts "Sync from HQ please wait..."
      sleep 10
      finalize_setup
  end
end
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

finalize_setup



        
                  
        
                
