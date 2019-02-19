
User.current_user = User.first

def create
  (1.upto(100)).each do |n|
    sleep 0.3
    gender = ["Male","Female"].sample
    person = Person.new()
    #name = ["N'gambi","Ng'ombe","O'neal"]
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
    person.hospital_of_death = HealthFacility.by_district_id.keys([District.by_name.key(person.place_of_death_district.to_s).first.id]).collect{|f| f.name }.sample
    person.informant_first_name = Faker::Name.first_name
    person.informant_last_name = Faker::Name.first_name
    person.district_code = SETTINGS["district_code"]
    person.current_country = "Malawi"
    person.current_district = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.sample
    person.current_ta = TraditionalAuthority.by_district_id.key(District.by_name.key(person.current_district.to_s).first.id).collect{|f| f.name }.sample
    district = District.by_name.key(person.current_district.strip).first
    ta =TraditionalAuthority.by_district_id_and_name.key([district.id, person.current_ta]).first
    person.current_village = Village.by_ta_id.key(ta.id.strip).collect{|f| f.name }.sample
    person.district_code = SETTINGS['district_code']


=begin
    person.hospital_of_death_name = 
    person.other_place_of_death = 
    person.place_of_death_village = 
    person.place_of_death_ta = 
    person.place_of_death_district = 
    person.cause_of_death1 = 
    person.cause_of_death2 = 
    person.cause_of_death3 = 
    person.cause_of_death4 = 
    person.onset_death_interval1 = 
    person.onset_death_death_interval2 = 
    person.onset_death_death_interval3 = 
    person.onset_death_death_interval4 = 
    person.cause_of_death_conditions = 
    person.manner_of_death = 
    person.other_manner_of_death = 
    person.death_by_accident = 
    person.other_death_by_accident = 
    person.home_village = 
    person.home_ta = 
    person.home_district = 
    person.home_country = 
    person.death_by_pregnancy = 
    person.updated_by = 
    person.voided_by = 
    person.voided_date = 
    person.voided = false
    person.form_signed = 
=end
    person.save
    person.reload
    sleep 0.5
    status = "MARKED APPROVAL"

    PersonRecordStatus.create({
                                      :person_record_id => person.id.to_s,
                                      :status => status,
                                      :district_code =>  person.district_code,
                                      :created_by => User.current_user.id})

    identifier = PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "Form Barcode", 
                                      :identifier => rand(10 ** 10),
                                      :site_code => SETTINGS['site_code'],
                                      :district_code => SETTINGS['district_code'],
                                      :creator => User.current_user.id})
    sleep 0.5
    SimpleElasticSearch.add(person)

    puts "#{person.first_name} #{person.last_name}"
  end

end

create