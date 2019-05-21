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
		if params[:time_line].blank?
			start_date = Time.now.strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		else
			case params[:time_line]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Date range"
				start_date = params[:start_date].to_time.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	params[:end_date].to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			end
		end
		status = params[:status].present? ? params[:status] : 'DC ACTIVE'
		total_male   =  0
	    total_female =  0
	    gender = ['Male','Female']
	    connection = ActiveRecord::Base.connection

	    reg_type = {}
	    types = ["Normal Cases","Abnormal Deaths","Dead on Arrival","Unclaimed bodies","Missing Persons","Deaths Abroad"]
	    types.each do |type|
	    	reg_type[type] = {}
	    	gender.each do |g|
	    		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' AND gender='#{g}'
					 	 AND person_record_status.district_code = '#{User.current_user.district_code}' 
					 	 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}' 
					 	 AND people.registration_type = '#{type}'"
				reg_type[type][g] = connection.select_all(query).as_json.last['total'] rescue 0
	    	end
	    end

	    delayed = {}
	    ["Yes","No"].each do |response|
	    	delayed[response] = {}
	    	gender.each do |g|
	    		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' AND gender='#{g}'
					 	 AND person_record_status.district_code = '#{User.current_user.district_code}' 
					 	 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}'
	    				 AND people.delayed_registration = '#{response}'"
				delayed[response][g] = connection.select_all(query).as_json.last['total'] rescue 0
	    	end
		end

		places = {}
		["Home","Health Facility", "Other"].each do |place|
			places[place] = {}
			gender.each do |g|
	    		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' AND gender='#{g}'
					 	 AND person_record_status.district_code = '#{User.current_user.district_code}' 
					 	 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}' 
	    				 AND people.place_of_death = '#{place}'"
				places[place][g] = connection.select_all(query).as_json.last['total'] rescue 0

				if g =="Male"
					total_male = total_male + places[place][g]
				else
					total_female = total_female + places[place][g]
				end
	    	end
		end

		age_estimate = {}
		["Yes","No"].each do |response|
			mapped = {"Yes" => 1, "No" => 0}
			age_estimate[response]  = {} 

			gender.each do |g|
	    		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' AND gender='#{g}'
					 	 AND person_record_status.district_code = '#{User.current_user.district_code}' 
					 	 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}' 
	    				 AND people.birthdate_estimated = '#{mapped[response]}'"
				age_estimate[response][g] = connection.select_all(query).as_json.last['total'] rescue 0
			end
		end
		total = {"Total" =>{"Male" => total_male, "Female" => total_female}}.as_json
		data = {
				"Registration Type" => reg_type,
				"Delayed Registration"=> delayed,
				"Age Estimated" => age_estimate,
				"Place of Death" => places,
				"#{status}" => total }


		return data
	end

	def self.by_registartion_type(params)
		if params[:timeline].blank?
			start_date = Time.now.strftime("%Y-%m-%d")
			end_date =	Date.today.to_time.strftime("%Y-%m-%d")
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Date range"
				start_date = params[:start_date].to_time.strftime("%Y-%m-%d")
				end_date =	params[:end_date].to_time.strftime("%Y-%m-%d")
			end
		end
		status = params[:status].present? ? params[:status] : 'DC ACTIVE'
		connection = ActiveRecord::Base.connection

		gender_query = ""
		if params[:gender].present? && params[:gender] != "Total"
			gender_query = "AND gender='#{params[:gender]}'"
		end

		type_query = ""
		if params[:type].present? && params[:type] != "All"
			type_query = " AND people.registration_type = '#{params[:type]}'"
		end
		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' #{gender_query}
					 	 AND person_record_status.district_code = '#{User.current_user.district_code}' AND person_record_status.voided = 0
					 	 AND DATE_FORMAT(person_record_status.created_at,'%Y-%m-%d') BETWEEN '#{start_date}' AND '#{end_date}'
					 	#{type_query}"

		return {:count=> (connection.select_all(query).as_json.last['total'] rescue 0), :gender => params[:gender], :type => params[:type]}
	end

	def self.by_place_of_death(params)
		if params[:timeline].blank?
			start_date = Time.now.strftime("%Y-%m-%d")
			end_date =	Date.today.to_time.strftime("%Y-%m-%d")
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Date range"
				start_date = params[:start_date].to_time.strftime("%Y-%m-%d")
				end_date =	params[:end_date].to_time.strftime("%Y-%m-%d")
			end
		end
		status = params[:status].present? ? params[:status] : 'DC ACTIVE'
		connection = ActiveRecord::Base.connection

		gender_query = ""
		if params[:gender].present? && params[:gender] != "Total"
			gender_query = "AND gender='#{params[:gender]}'"
		end

		if params[:place].present? && params[:place] != "All"
			place_query = " AND people.place_of_death = '#{params[:place]}'"
		end

		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' #{gender_query} 
					 	 AND person_record_status.district_code = '#{User.current_user.district_code}' AND person_record_status.voided = 0
					 	 AND DATE_FORMAT(person_record_status.created_at,'%Y-%m-%d') BETWEEN '#{start_date}' AND '#{end_date}' 
	    				#{place_query}"

	    #raise query.to_s
		return {:count=> (connection.select_all(query).as_json.last['total'] rescue 0) , :gender => params[:gender], :place => params[:place]}
		
	end

	def self.by_date_of_death_and_gender(params)
		if params[:timeline].blank?
			start_date = Time.now.strftime("%d/%m/%Y")
			end_date =	Date.today.to_time.strftime("%d/%m/%Y")
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d")
			when "Date range"
				start_date = params[:start_date].to_time.strftime("%Y-%m-%d")
				end_date =	params[:end_date].to_time.strftime("%Y-%m-%d")
			end
		end
		connection = ActiveRecord::Base.connection
		gender_query = ""
		if params[:gender].present? && params[:gender] != "Total"
			gender_query = "AND gender='#{params[:gender]}'"
		end

		if User.current_user.username == "admin"
			districts_query = District.all.collect{|d| d.name}.join(",")
		else	
			districts_query = User.current_user.district_code
		end

		query = "SELECT count(*) as total FROM people WHERE people.district_code IN ('#{User.current_user.district_code}') #{gender_query}
				 AND DATE_FORMAT(people.date_of_death,'%Y-%m-%d') BETWEEN '#{start_date}' AND '#{end_date}'"
	    
	    #raise query.to_s
		return {:count=> (connection.select_all(query).as_json.last['total'] rescue 0) , :gender => params[:gender]}
	end

	def self.audits(params)	
		offset = params[:page].to_i  *  40
		query = "DATE_FORMAT(created_at,'%Y-%m-%d') BETWEEN '#{params[:start_date]}' AND '#{params[:end_date]}'"
		#query = "DATE_FORMAT(created_at,'%Y-%m-%d') BETWEEN '2019-01-01' AND '2019-05-21'"
		data = []

		AuditRecord.where(query).order("created_at DESC").limit(40).offset(offset).each do |audit|
			entry = {}
			user = User.find(audit.user_id)
			next if user.blank?
			entry["username"] = user.username
			entry["name"] = "#{user.first_name} #{user.last_name} (#{user.role})"
			entry["audit_type"] =  audit.audit_type
			entry["change"] = (audit.model.present? ? audit.model.humanize : "N/A")
			entry["previous_value"] = (audit.previous_value.present? ? audit.previous_value : "N/A")
			entry["current_value"] = (audit.current_value.present? ? audit.current_value : "N/A")
			entry["reason"] =  audit.reason
			entry["time"] = audit.created_at.to_time.strftime("%Y-%m-%d  %H:%M")
			data << entry
		end
		return data
	end
end