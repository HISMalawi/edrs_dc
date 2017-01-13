
puts "Initialising user roles"

roles = {
    "Facility" => {
        "Data Clerk" => [
            "Register a record",
            "View a record",
            "Change own password"
        ],
        "Nurse/Midwife" => [
            "Register a record",
            "View a record",
            "Change own password"
        ],
        "System Administrator" => [
            "Activate User",
            "Deactivate User",
            "Create User",
            "Update User",
            "View Users",
            "Change own password"
        ]
    },
    "DC" => {
        "Data Clerk" => [
            "Register a record",
            "View a record",
            "Change own password"
        ],
        "Logistics Officer" => [
            "Register a record",
            "View a record",
            "Edit a record",
            "Check completeness",
            "Check for duplicates",
            "View closed cases",
            "Change own password"
        ],
        "ADR" => [
            "View a record",
            "Edit a record",
            "Check completeness",
            "Manage duplicates",
            "Approve a record",
            "Void a record",
            "Request to open a closed case",
            "View closed cases",
            "Change own password"
        ],
        "System Administrator" => [
            "Activate User",
            "Deactivate User",
            "Create User",
            "Update User",
            "Void outstanding records",
            "Change own password",
            "View voided records",
						"Initialise Sync",
						"View audit report",
						"View sync report"
        ]
    },
    "HQ" => {
        "Data Checking Clerk" => [
            "View a record",
            "Check completeness",
            "Check for duplicates",
            "Change own password"
        ],
        "Data Supervisor" => [
            "View a record",
            "Make ammendments",
            "Manage duplicates",
            "Manage incomplete records",
            "Change own password"
        ],
        "Data Manager" => [
            "View a record",
            "Approve/Reject a record",
            "Reject a record",
            "Authorise printing",
            "Authorise reprinting of a certificate",
            "Open a closed case",
            "View closed cases",
            "Change own password"
        ],
        "Quality Supervisor" => [
            "Assess certificate quality",
            "Request certificate reprint",
            "Void outstanding records"
        ],
        "System Administrator" => [
            "Activate User",
            "Deactivate User",
            "Create User",
            "Update User",
            "Void outstanding records",
            "Change own password",
            "View user log",
						"View record log",
						"View sync report",
						"View turn-time report",
						"Edit metadata",
						"Update system"
        ]
    }
}

puts "Loading user roles"

roles.each do |level, user|

  user.each do |role, activities|

    puts "Loading #{level}:#{role}..." if Role.by_level_and_role.key([level, role]).each.size <= 0

    puts "Skipping #{level}:#{role}..." if Role.by_level_and_role.key([level, role]).each.size > 0

    Role.create(role: role, level: level, activities: activities) if Role.by_level_and_role.key([level, role]).each.size <= 0

  end

end

puts "User role count : #{Role.count}"

puts "Initializing default user"

user = User.find('admin')

if user.blank?

	User.create(username: "admin", plain_password: "password", last_password_date: Time.now,
							password_attempt: 0, login_attempt: 0, first_name: "EDRS",
							last_name: "Administrator", role: "System Administrator",
							email: "admin@baobabhealth.org")
							
  puts "User created succesfully!"
else
  puts "User already exists"
end

puts "Users count : #{User.all.count}"

File.open("#{Rails.root}/app/assets/data/facilities.txt").readlines.each do |f| 

  h = f.strip.split("|")
    
  Hospital.create(hospital_id: h[0], 
  								region: h[1], 
  								district: h[2], 
  								lon: h[3], lat: 
  								h[4]) if Hospital.find(h[0]).blank?
  								
end

puts "Initialising health facilities"

CSV.foreach("#{Rails.root}/app/assets/data/health_facilities.csv", :headers => true) do |row|

 next if row[2].blank?
 
 health_facility = HealthFacility.find(row[2])
 
 if health_facility.blank? 
    health_facility = HealthFacility.create(facility_code: row[2],
                                            district: row[0] ,
                                            district_code: row[1],
                                            name: row[3],
                                            zone: row[4] , 
                                            fac_type: row[5], 
                                            mga: row[6], 
                                            f_type: row[7],
                                            latitude: row[8], 
                                            longitude: row[9])
                                            
    if health_facility.present?
      puts health_facility.name + " initialised succesfully!"
    else
      puts row[3] + " could not be saved!"
    end
     
 else
    puts row[3] + " healthy facility already exists"
 end
        
end

puts "Health facilities count : #{HealthFacility.all.count}"

puts "Initialising Districts"

CSV.foreach("#{Rails.root}/app/assets/data/districts_with_codes.csv", :headers => true) do |row|
 next if row[0].blank?
 district = District.find(row[0])
 
 if district.blank?
    district = District.create(district_code: row[0], name: row[1], region: row[2])
    
    if district.present?
       puts district.name + " district initialised succesfully!"
    else
       puts row[1] + " could not be saved!"
    end
    
 else
    puts  row[1] + " district already exists"
 end
        
end
puts "Districts count : #{District.all.count}"

CSV.foreach("#{Rails.root}/app/assets/data/nationality.txt", :headers => false) do |row|
 next if row[0].blank?
 nationality = Nationality.find(row[0])
 
 if nationality.blank?
    nationality = Nationality.new()
    nationality.nationality = row[0]  
    nationality.save!
    puts "Nationality initialised succesfully!"
 else
    puts "Nationality already exists"
 end
        
end

file = File.open("#{Rails.root}/app/assets/data/districts.json").read

json = JSON.parse(file)

json.each do |district, traditional_authorities|

    traditional_authorities.each do |ta, villages|
    
        villages.each do |village|
        
            count = Village.by_district_ta_and_village.key([district, ta, village]).each.count
                
            if count <= 0
            
                puts "Adding #{[district, ta, village]}"
                
                Village.create(district: district, ta: ta, village: village) 
                
            else 
            
                puts "#{[district, ta, village]} already exists"
            
            end
        
        end
    
    end

end

Person.count rescue nil
puts "Created Person database"
Audit.count rescue nil
puts "Created audit database"
puts "Application setup succesfully!!!"
