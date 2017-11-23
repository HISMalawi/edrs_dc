class Report < ActiveRecord::Base
	def self.causes_of_death(district= nil,start_date = nil,end_date = nil, age_operator = nil, start_age= nil, end_age =nil, autopsy =nil )
		district_query = ''
		if district.present?
			district_query = " AND district_code = '#{District.by_name.key(district).first.id}'" 
		end

		date_query = ''
		if start_date.present?
			date_query = " AND date_of_death >=Date('#{start_date}') AND date_of_death <=Date('#{end_date}')"
		end

		autopsy_query = ''
		if autopsy.present?
			autopsy_query = "AND autopsy_requested = '#{autopsy}'"
		end

        age_query = ''

		if age_operator.present?
	        if age_operator ==  "=> Age <="
	            age_query = " AND (DATEDIFF(date_of_death,birthdate)/365) >= #{start_age} AND (DATEDIFF(date_of_death,birthdate)/365) <= #{end_age} "
	        else
	            age_query = " AND (DATEDIFF(date_of_death,birthdate)/365) #{age_operator} #{start_age} "
	        end
		end

		connection = ActiveRecord::Base.connection
		codes_query = "SELECT distinct icd_10_code FROM people WHERE icd_10_code IS NOT NULL LIMIT 20"
		codes = connection.select_all(codes_query).as_json
		data  = {}
		codes.each do |code|

			data[code["icd_10_code"]] = {}
			gender = ['Male','Female']
			gender.each do |g|
				query = "SELECT count(*) as total FROM people WHERE  gender='#{g}' AND icd_10_code = '#{code['icd_10_code']}' #{district_query} #{date_query} #{age_query} #{autopsy_query}"
				data[code["icd_10_code"]][g] = connection.select_all(query).as_json.last['total'] rescue 0
			end			
		end
		return data

	end

	def self.manner_of_death(district= nil,start_date = nil,end_date = nil, age_operator = nil, start_age= nil, end_age =nil, autopsy =nil )
		district_query = ''
		if district.present?
			district_query = " AND district_code = '#{District.by_name.key(district).first.id}'" 
		end

		date_query = ''
		if start_date.present?
			date_query = " AND date_of_death >=Date('#{start_date}') AND date_of_death <=Date('#{end_date}')"
		end

		autopsy_query = ''
		if autopsy.present?
			autopsy_query = "AND autopsy_requested = '#{autopsy}'"
		end

        age_query = ''

		if age_operator.present?
	        if age_operator ==  "=> Age <="
	            age_query = " AND (DATEDIFF(date_of_death,birthdate)/365) >= #{start_age} AND (DATEDIFF(date_of_death,birthdate)/365) <= #{end_age} "
	        else
	            age_query = " AND (DATEDIFF(date_of_death,birthdate)/365) #{age_operator} #{start_age} "
	        end
		end

		connection = ActiveRecord::Base.connection
		manner_of_death = ['Natural','Accident','Homicide','Suicide','Poisoning','Pending Investigation','Could not be determined','Other']
		data  = {}
		manner_of_death.each do |manner|
			data[manner] = {}
			gender = ['Male','Female']
			gender.each do |g|
				query = "SELECT count(*) as total FROM people WHERE  gender='#{g}' AND manner_of_death = '#{manner}' #{district_query} #{date_query} #{age_query} #{autopsy_query}"
				data[manner][g] = connection.select_all(query).as_json.last['total'] rescue 0
			end
		end

		return data
	end

	def self.general(params)
		status = "Reported"
		total_male   =  0
	    total_female =  0

	    reg_type = {}
	    types = ["Natural Deaths","Unnatural Deaths","Dead on Arrival","Unclaimed bodies","Missing Persons","Deaths Abroad"]
	    types.each do |type|
	    	reg_type[type] = {}
	    	reg_type[type]['Male']  = 0
	    	reg_type[type]['Female']  = 0
	    end
	    delayed = {}
	    ["Yes","No"].each do |response|
	    	delayed[response] = {}
	    	delayed[response]["Male"] = 0
	    	delayed[response]["Female"] = 0
		end

		places = {}
		["Home","Health Facility", "Other"].each do |place|
			places[place] = {}
			places[place]["Male"] = 0
			places[place]["Female"] = 0
		end

		total = {"Total" =>{"Male" => total_male, "Female" => total_female}}.as_json
		data = {
				"Registration Type" => reg_type,
				"Delayed Registration"=> delayed,
				"Place of Death" => places,
				"#{status}" => total }


		return data
	end
end