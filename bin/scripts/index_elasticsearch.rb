puts "Indexing to Elastic Search"
people_count = Person.count

page_number = 0
page_size = 100

pages = people_count / page_size

(0..pages).each do |page|
    Person.by__id.page(page).per(page_size).each do |person|
        if SETTINGS["potential_duplicate"]
              record = {}
              record["first_name"] = person.first_name
              record["last_name"] = person.last_name
              record["middle_name"] = (person.middle_name rescue nil)
              record["gender"] = person.gender
              record["place_of_death_district"] = person.place_of_death_district
              record["birthdate"] = person.birthdate
              record["date_of_death"] = person.date_of_death
              record["mother_last_name"] = (person.mother_last_name rescue nil)
              record["mother_middle_name"] = (person.mother_middle_name rescue nil)
              record["mother_first_name"] = (person.mother_first_name rescue nil)
              record["father_last_name"] = (person.father_last_name rescue nil)
              record["father_middle_name"] = (person.father_middle_name rescue nil)
              record["father_first_name"] = (person.father_first_name rescue nil)
              record["id"] = person.id
              record["district_code"] = person.district_code
              if (SETTINGS['site_type'] == "dc" && person.district_code == SETTINGS['district_code']) || SETTINGS["site_type"] == "remote"
                begin
                    SimpleElasticSearch.add(record)
                    sleep 0.01
                rescue Exception => e
                    
                end                               
              end
        else
          next
        end
    end
    puts "Indexed #{(page + 1) * page_size}"
end