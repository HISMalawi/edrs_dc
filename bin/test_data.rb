require 'sql_search'
User.current_user = User.first
def format_content(person)
     
     search_content = ""
      if person.middle_name.present?
         search_content = person.middle_name + ", "
      end 

      birthdate_formatted = person.birthdate.to_date.strftime("%Y-%m-%d")
      search_content = search_content + birthdate_formatted + " "
      death_date_formatted = person.date_of_death.to_date.strftime("%Y-%m-%d")
      search_content = search_content + death_date_formatted + " "
      search_content = search_content + person.gender.upcase + " "

      if person.place_of_death_district.present?
        search_content = search_content + person.place_of_death_district + " " 
      else
        registration_district = District.find(person.district_code).name
        search_content = search_content + registration_district + " " 
      end    

      if person.mother_first_name.present?
        search_content = search_content + person.mother_first_name + " " 
      end

      if person.mother_middle_name.present?
         search_content = search_content + person.mother_middle_name + " "
      end   

      if person.mother_last_name.present?
        search_content = search_content + person.mother_last_name + " "
      end

      if person.father_first_name.present?
         search_content = search_content + person.father_first_name + " "
      end 

      if person.father_middle_name.present?
         search_content = search_content + person.father_middle_name + " "
      end 

      if person.father_last_name.present?
         search_content = search_content + person.father_last_name
      end 

      return search_content.squish

  end
def create
  
  (1.upto(20000)).each do |n|
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
    person.place_of_death_district = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.sample
    person.informant_first_name = Faker::Name.first_name
    person.informant_last_name = Faker::Name.first_name
    person.district_code = "BT"

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

    title = "#{person.first_name} #{person.last_name}"
    content =  format_content(person)

    query = "INSERT INTO documents(couchdb_id,title,content,date_added,created_at,updated_at) 
              VALUES('#{person.id}','#{title}','#{title} #{content}','#{person.created_at}',NOW(),NOW())"

    SQLSearch.query_exec(query)

    puts "........... #{person.first_name}"
  end

end

create
