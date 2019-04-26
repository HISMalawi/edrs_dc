class DeDuplication


	def self.connection
		return  ActiveRecord::Base.connection
	end

	def self.init
		create_table_query = "CREATE TABLE IF NOT EXISTS potential_search (
			                    id int(11) NOT NULL AUTO_INCREMENT,
			                    person_id varchar(255) NOT NULL UNIQUE,
			                    first_name varchar(255) NOT NULL,
			                    last_name varchar(255) NOT NULL,
			                    gender char(1) DEFAULT NULL,
			                    birthdate varchar(30) DEFAULT NULL,
			                    date_of_death varchar(30) DEFAULT NULL,
			                    location varchar(255) ,
			                    mother_first_name varchar(255) DEFAULT NULL,
			                    mother_last_name varchar(255) DEFAULT NULL,
			                    father_first_name varchar(255) DEFAULT NULL,
			                    father_last_name varchar(255) DEFAULT NULL,
			                    content TEXT,
			                    created_at datetime NOT NULL,
			                    updated_at datetime NOT NULL,
			                    PRIMARY KEY (id),
			                    FULLTEXT KEY content (content)
			                  )ENGINE=InnoDB DEFAULT CHARSET=latin1;"
		self.connection.execute(create_table_query);
	end

	def self.escape_single_quotes(string)
	    if string.present?
	        string = string.gsub("'", "'\\\\''")
	    end
	    return string
	end

	def self.full_text_content(person,include_death_date=false, include_mother=false,include_father=false)
		  search_content = person["first_name"] + " "+ person["last_name"] + " "
	      birthdate_formatted = person["birthdate"].to_date.strftime("%Y %m %d")
	      search_content = search_content + birthdate_formatted + " "

	      if include_death_date
		      death_date_formatted = person["date_of_death"].to_date.strftime("%Y %m %d")
		      search_content = search_content + death_date_formatted + " "	      	
	      end

	      search_content = search_content + person["gender"].first.upcase + " "
	      search_content = search_content + person["location"]    

	      if include_mother
		      if person["mother_first_name"].present?
		        search_content = search_content + (person["mother_first_name"] rescue '') + " " 
		      end  

		      if person["mother_last_name"].present?
		        search_content = search_content + (person["mother_last_name"] rescue '') + " "
		      end	      	
	      end

	      if include_father
		      if person["fathe_first_name"].present?
		        search_content = search_content + (person["father_first_name"] rescue '') + " " 
		      end  

		      if person["father_last_name"].present?
		        search_content = search_content + (person["father_last_name"] rescue '') + " "
		      end	      	
	      end

	      return search_content.squish.upcase
		
	end

	def self.add(person, include_death_date=false,include_mother=false,include_father=false)
		find_sql = "SELECT * FROM potential_search WHERE person_id='#{person['id']}';"
      	content = DeDuplication.full_text_content(person,include_mother,include_father,include_death_date)
      	fields = ["person_id","first_name","last_name","gender","birthdate","date_of_death","location",
      			  "mother_first_name","mother_last_name","father_first_name","father_last_name"]

      	if self.connection.select_all(find_sql).as_json.blank?
      	  data = fields.collect { |e| person[e] }
          sql = "INSERT INTO potential_search(#{fields.join(',')},created_at,updated_at) VALUES("
          fields.each do |field|
          	if person[field].blank?
          		sql = "#{sql}NULL,"
          	else
				sql = "#{sql}'#{person[field]}',"          		
          	end
          	
          end
          sql = "#{sql}NOW(), NOW());"
          self.connection.execute(sql)
      	else
          sql = "UPDATE potential_search SET content = '#{content}'"

          fields.each do |field|
				sql = "#{sql},#{field} = '#{person[field]}'"
          end
          sql = "#{sql} ,updated_at = NOW() WHERE person_id='#{person['person_id']}';"
          self.connection.execute(sql)
      	end
	end

	def self.check_similarity_by_position(newrecord,existingrecord,include_death_date=false,include_mother=false,include_father=false)

	      score = 0
	      #0. Records
	      #newrecord = self.person_details(newrecord_id)
	      return 0 if existingrecord.blank?

	      # 1. Comparing person name
	      newrecord_name = "#{newrecord['first_name']} #{newrecord['last_name']}"
	      existingrecord_name = "#{existingrecord['first_name']} #{existingrecord['last_name']}"
	      if newrecord_name.squish == existingrecord_name.squish
	         score = score + 2 
	      elsif newrecord['first_name'].squish == existingrecord['first_name'].squish
	         score = score + 1 + WhiteSimilarity.similarity(newrecord['last_name'].squish, existingrecord['last_name'])
	      elsif newrecord['last_name'].squish == existingrecord['last_name'].squish
	         score = score + 1 + WhiteSimilarity.similarity(newrecord['first_name'].squish, existingrecord['first_name'])
	      elsif newrecord['first_name'].squish == existingrecord['last_name'].squish
	        score = score + 0.9 + WhiteSimilarity.similarity(newrecord['last_name'].squish, existingrecord['first_name'])
	      elsif newrecord['last_name'].squish == existingrecord['first_name'].squish  
	        score = score + 0.9 + WhiteSimilarity.similarity(newrecord['first_name'].squish, existingrecord['last_name'])
	      else
	         score = score + WhiteSimilarity.similarity(newrecord_name, existingrecord_name) * 2   
	      end
	     
	      # 2. Comparing date of birth
	      newrecord_birthdate = newrecord["birthdate"].to_date.strftime("%Y-%m-%d").split("-")
	      existingrecord_birthdate = existingrecord["birthdate"].to_date.strftime("%Y-%m-%d").split("-")

	      i = 0
	      while i < newrecord_birthdate.length
	          score = score + WhiteSimilarity.similarity(newrecord_birthdate[i], existingrecord_birthdate[i])
	          i = i + 1
	      end
	      
	      # 3. Comparing gender
	      newrecord_gender = newrecord["gender"].first.upcase
	      existingrecord_gender = existingrecord["gender"].first.upcase
	      if newrecord_gender == existingrecord_gender
	          score = score + 1
	      else
	          score = score + 0
	      end

	      # 4. comparing districts of birth
	      newrecord_district = newrecord["location"]
	      existingrecord_district = existingrecord["location"]
	      score = score + WhiteSimilarity.similarity(newrecord_district, existingrecord_district)

	      #5. Date of death 
	      newrecord_date_of_death = newrecord["date_of_death"].to_date.strftime("%Y-%m-%d").split("-")
	      existingrecord_date_of_death = existingrecord["date_of_death"].to_date.strftime("%Y-%m-%d").split("-")

	      i = 0
	      while i < newrecord_date_of_death.length
	          score = score + WhiteSimilarity.similarity(newrecord_date_of_death[i], existingrecord_date_of_death[i])
	          i = i + 1
	      end

	      return (score / 10) * 100
	end

	def self.query_duplicate(person,percent_similarity, include_death_date = false)
      	content = DeDuplication.full_text_content(person,include_death_date,false,false)
      	sql = "SELECT *, MATCH(content) AGAINST('#{content}') AS score FROM 
             potential_search WHERE MATCH(content) AGAINST('#{content}') ORDER BY score DESC LIMIT 10;"

      	potention_results =  self.connection.select_all(sql)
      	results = []
      	potention_results.each do |p|
      		next if p['person_id'].to_s == person["person_id"]
      		score = check_similarity_by_position(person,p,true)
      		p["score"] = score
      		results << p if  score >= percent_similarity
      	end
		return results
	end
end