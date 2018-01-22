User.current_user = User.first

def create
  
  (1.upto(50)).each do |n|
    gender = ["Male","Female"].sample
    person = Person.new()
    person.first_name = Faker::Name.first_name
    person.last_name =  Faker::Name.last_name
    person.middle_name = [Faker::Name.first_name,""].sample
    person.gender = gender
    person.birthdate = Faker::Time.between("1964-01-01".to_time, Time.now()).to_date
    person.birthdate_estimated = 1
    person.date_of_death = Date.today
    person.nationality=  "Malawi"
    person.place_of_death = "Health Facility"
    person.place_of_death_district = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.sample
    person.hospital_of_death = HealthFacility.by_district_id.keys([District.by_name.key(person.place_of_death_district.to_s).first.id]).collect{|f| f.name unless f.name.blank? }.sample
    person.informant_first_name = Faker::Name.first_name
    person.informant_last_name = Faker::Name.first_name
    person.district_code = CONFIG["district_code"]
    person.current_country = "Malawi"
    person.current_district = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.sample
    person.current_ta = TraditionalAuthority.by_district_id.key(District.by_name.key(person.current_district.to_s).first.id).collect{|f| f.name }.sample
    district = District.by_name.key(person.current_district.strip).first
    ta =TraditionalAuthority.by_district_id_and_name.key([district.id, person.current_ta]).first
    person.current_village = Village.by_ta_id.key(ta.id.strip).collect{|f| f.name }.sample
    person.district_code = SETTINGS[' district_code']
    #District.all.each.collect{|d| d.id unless d.name.include?("City")}.sample


    person.save

    person.reload

    status = "DC COMPLETE"

    record_status = PersonRecordStatus.new 
    record_status.person_record_id = person.id.to_s
    record_status.status = status
    record_status.district_code = person.district_code
    record_status.creator = User.current_user.id
    if record_status.save
          PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "Form Barcode", 
                                      :identifier => rand(10 ** 10),
                                      :site_code => CONFIG['site_code'],
                                      :district_code => CONFIG['district_code'],
                                      :creator => User.current_user.id})

        title = "#{person.first_name} #{person.last_name}"

        puts "........... #{title}"

    else
      person.destroy!
      put "Error Reverting changes"
    end
  end

end

create
