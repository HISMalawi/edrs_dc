class SimpleElasticSearch
  SETTING = YAML.load_file("#{Rails.root}/config/elasticsearchsetting.yml")['elasticsearch']
  def self.format_content(person)
     
     search_content = ""
      if person.middle_name.present?
         search_content = self.escape_single_quotes(person.middle_name) + ", "
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

  def self.escape_single_quotes(string)
    if string.present?
        string = string.gsub("'", "'\\\\''")
    end
    return string
  end

  def self.elastic_format(person)
     content =  self.format_content(person)
     if person.place_of_death_district.present?
          registration_district = person.place_of_death_district
     else
          registration_district = District.find(person.district_code).name
     end
     elastic_search_index = "curl -XPUT 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/documents/#{person.id}'  -d '
              {
                \"user\" : \"#{User.current_user.id}\",
                \"first_name\": \"#{self.escape_single_quotes(person.first_name)}\",
                \"last_name\": \"#{self.escape_single_quotes(person.last_name)}\",
                \"middle_name\": \"#{self.escape_single_quotes(person.middle_name) rescue ''}\",
                \"gender\": \"#{person.gender}\",
                \"birthdate\": \"#{person.birthdate.to_date.strftime("%Y-%m-%d")}\",
                \"date_of_death\": \"#{person.date_of_death.to_date.strftime("%Y-%m-%d")}\",
                \"place_of_death_district\": \"#{registration_district}\",
                \"mother_first_name\": \"#{self.escape_single_quotes(person.mother_first_name)}\",
                \"mother_last_name\": \"#{self.escape_single_quotes(person.mother_last_name)}\",
                \"father_first_name\": \"#{self.escape_single_quotes(person.father_first_name)}\",
                \"father_last_name\": \"#{self.escape_single_quotes(person.father_last_name)}\",
                \"content\" : \"#{self.escape_single_quotes(person.first_name)} #{self.escape_single_quotes(person.last_name)} #{self.escape_single_quotes(content)}\"
              }'"

      return elastic_search_index
  end

  def self.add(person)
    #puts self.elastic_format(person)
   puts `#{self.elastic_format(person)}`
  end

  def self.query(field,query_content,precision)
    if precision.blank?
      precision = SETTING['precision']
    end
    puts precision
    query = "curl -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/documents/_search?pretty=true' -H 'Content-Type: application/json' -d'
            {
              \"query\": {
                  \"match\": {
                    \"#{field}\":{
                          \"query\":\"#{self.escape_single_quotes(query_content)}\",
                          \"minimum_should_match\": \"#{precision}%\"
                    }
                  }
                }
              }'"
      
      data = JSON.parse(`#{query}`)

      if data["error"].blank?
         return data["hits"]["hits"]
      else
         return []
      end
     
  end

  def self.query_duplicate(person,precision)
      content =  self.format_content(person)
      query_string = "#{person.first_name} #{person.last_name} #{content}"

      potential_duplicates = []
      hits = self.query("content",query_string,precision)
      hits.each do |hit|
        next if Person.find(hit["_id"]).voided
        potential_duplicates << hit if hit["_id"] != person.id
      end

      return potential_duplicates
  end
end