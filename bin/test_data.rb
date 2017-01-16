
User.current_user = User.first

def create
  gender = 'M'

  (1.upto(101)).each do |n|
    person = Person.new()
    person.first_name = Faker::Name.first_name
    person.last_name =  Faker::Name.last_name
    person.gender = gender
    person.birthdate = Faker::Time.between("1964-01-01".to_time, Time.now()).to_date
    person.birthdate_estimated = 1
    person.date_of_death = Date.today
    person.citizenship = 'Malawian'
    person.place_of_death = 'Lilongwe'
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
    puts "........... #{person.first_name}"
  end

end

create
