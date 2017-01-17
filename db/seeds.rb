
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

CSV.foreach("#{Rails.root}/app/assets/data/districts_with_codes.csv", :headers => true) do |row|
 next if row[0].blank?
 row[1] = 'Nkhata-bay' if row[1].match(/Nkhata/i)

 district = District.by_name.key(row[1]).first rescue nil
 next unless district.blank?

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

CSV.foreach("#{Rails.root}/app/assets/data/health_facilities.csv", :headers => true) do |h|
  next if h[0].blank?
  h[0] = 'Nkhata-bay' if h[0].match(/Nkhata/i)
  district = District.by_name.key(h[0]).first
   
  HealthFacility.create(district_id: district.id,facility_code: h[2], 
  								name: h[3], zone: h[4], f_type: h[7],
  								lon: h[9], lat:	h[8], facility_type: h[6])
end


puts "Initialising Nations"

CSV.foreach("#{Rails.root}/app/assets/data/nationality.txt", :headers => false) do |row|
 next if row[0].blank?
 nationality = Nationality.find(row[0])
 
 if nationality.blank?
    nationality = Nationality.new()
    nationality.nationality = row[0]  
    nationality.save!
 else
    puts "Nationality already exists"
 end
        
end
puts "Nation count : #{Nationality.all.count}"

file = File.open("#{Rails.root}/app/assets/data/districts.json").read
json = JSON.parse(file)


puts "Initialising TAs"

json.each do |district, traditional_authorities|
  traditional_authorities.each do |ta, villages|
    d = District.by_name.key(district).first rescue nil
    next if d.blank?
    next if ta.blank?
    TraditionalAuthority.create(district_id: d.id, name: ta)
  end
end
puts "TA count : #{TraditionalAuthority.all.count}"


puts "Initialising Villages"

json.each do |district, traditional_authorities|
  traditional_authorities.each do |ta, villages|
    villages.each do |village|
      d_name = district
      d_name = 'Nkhata-bay' if district.match(/Nkhata/i)
      d = District.by_name.key(d_name).first rescue nil

      t = TraditionalAuthority.by_district_id_and_name.key([d.id.to_s,ta.to_s]).first rescue nil
      next if t.blank?
      Village.create(ta_id: t.id, name: village)
    end
  end
end
puts "Village count : #{Village.all.count}"

Person.count rescue nil
puts "Created Person database"
Audit.count rescue nil
puts "Created audit database"
puts "Application setup succesfully!!!"

puts "Login details username: #{user.username} password: password"
