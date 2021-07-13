class Record < ActiveRecord::Base
	after_commit :push_to_couchDB
	before_create :set_id
	self.table_name = "people"

	def set_id
		self.person_id = SecureRandom.uuid if self.person_id.blank?
	end

	def den
		return RecordIdentifier.where("person_record_id='#{self.person_id}' AND identifier_type = 'DEATH ENTRY NUMBER'").first.identifier rescue ''
	end

	def drn
		return RecordIdentifier.where("person_record_id='#{self.person_id}' AND identifier_type = 'DEATH REGISTRATION NUMBER'").first.identifier rescue ''
	end

	def barcode
		barcode = RecordIdentifier.where(person_record_id: self.id,identifier_type: "Form Barcode").first
		if barcode.present?
		   return barcode.identifier
		else
			barcode = BarcodeRecord.where(person_record_id: self.id).last
			if barcode.present? 
				  return barcode.barcode
			else
				  return   "XXXXXXXX"
			end
		end
	end

  	def status
		connection = ActiveRecord::Base.connection
		statuses_query = "SELECT * FROM person_record_status WHERE  person_record_id='#{self.id}' ORDER BY created_at"
		statuses = connection.select_all(statuses_query).as_json
		
		status = statuses.last
       return status['status'] rescue ""
  	end


	def printable_place_of_death
		place_of_death = ""
		person = self
		case person.place_of_death
		  when "Home"
			  if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0
				  place_of_death = person.place_of_death_village
			  end
			  if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0
				  place_of_death = "#{place_of_death}, #{person.place_of_death_ta}"
			  end
			  if person.place_of_death_district.present? && person.place_of_death_district.to_s.length > 0
				  place_of_death = "#{place_of_death}, #{person.place_of_death_district}"
			  end
		  when "Health Facility"
			  place_of_death = "#{person.hospital_of_death}, #{person.place_of_death_district}"
		  else  
			  place_of_death = "#{person.other_place_of_death}, #{person.place_of_death_district}"
		  end
	
		  if person.place_of_death && person.place_of_death.strip.downcase.include?("facility")
					 place_of_death = "#{person.hospital_of_death}, #{person.place_of_death_district}"
		  elsif person.place_of_death_foreign && person.place_of_death_foreign.strip.downcase.include?("facility")
				 if person.place_of_death_foreign_hospital.present? && person.place_of_death_foreign_hospital.to_s.length > 0
					place_of_death  = person.place_of_death_foreign_hospital
				 end
				  
				 if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
					if person.place_of_death_country == "Other"
					  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
					else
					  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
					end
					 
				 end
		  elsif person.place_of_death_foreign && person.place_of_death_foreign.strip =="Home"
	
				  if person.place_of_death_foreign_village.present? && person.place_of_death_foreign_village.length > 0
					 place_of_death = person.place_of_death_foreign_village
				  end
	
				  if person.place_of_death_foreign_district.present? && person.place_of_death_foreign_district.to_s.length > 0
					 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_district}"
				  end
	
				  if person.place_of_death_foreign_state.present? && person.place_of_death_foreign_state.to_s.length > 0
					 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_state}"
				  end
	
				  if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
					if person.place_of_death_country == "Other"
					  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
					else
					  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
					end
					 
				  end
			elsif person.place_of_death_foreign && person.place_of_death_foreign.strip =="Other"
				   if person.other_place_of_death.present? && person.other_place_of_death.to_s.length > 0
					 place_of_death = person.other_place_of_death
				  end
	
				  if person.place_of_death_foreign_village.present? && person.place_of_death_foreign_village.length > 0
					 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_village}"
				  end
	
				  if person.place_of_death_foreign_district.present? && person.place_of_death_foreign_district.to_s.length > 0
					 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_district}"
				  end
	
				  if person.place_of_death_foreign_state.present? && person.place_of_death_foreign_state.to_s.length > 0
					 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_state}"
				  end
	
				  if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
					if person.place_of_death_country == "Other"
					  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
					else
					  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
					end
					 
				  end
	
		  elsif person.place_of_death  && person.place_of_death =="Other"
					if person.other_place_of_death.present?
						place_of_death  = person.other_place_of_death;
					end
					if person.place_of_death_district.present?
						place_of_death = "#{place_of_death}, #{person.place_of_death_district}"
					end
		  elsif person.place_of_death  && person.place_of_death =="Home"
			  if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0
				if person.place_of_death_village == "Other"
				   place_of_death = person.other_place_of_death_village
				else
				   place_of_death = person.place_of_death_village
				end
				 
			  end
			  if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0
				if person.place_of_death_ta == "Other"
					place_of_death = "#{place_of_death}, #{person.other_place_of_death_ta}"
				else
					place_of_death = "#{place_of_death}, #{person.place_of_death_ta}"
				end
				  
			  end
			  if person.place_of_death_district.present? && person.place_of_death_district.to_s.length > 0
				  place_of_death = "#{place_of_death}, #{person.place_of_death_district}"
			  end
	
		end
		return place_of_death 
	end
	def person_name
		str = "#{self.first_name}"
		if self.middle_name.present?
			str = "#{str} #{self.middle_name}"
		end
		str = "#{str} #{self.last_name}"
		return str.strip
	end
	
	def fathers_name
		str = ""
		if self.father_first_name.present?
			str = "#{str} #{self.father_first_name}"
		end
		if self.father_middle_name.present?
			str = "#{str} #{self.father_middle_name}"
		end
		if self.father_last_name.present?
			str = "#{str} #{self.father_last_name}"
		end
		return str.strip
	end
	
	def mothers_name
		str = ""
		if self.mother_first_name.present?
			str = "#{str} #{self.mother_first_name}"
		end
		if self.mother_middle_name.present?
			str = "#{str} #{self.mother_middle_name}"
		end
		if self.mother_last_name.present?
			str = "#{str} #{self.mother_last_name}"
		end
		return str.strip  
	end
	def self.create_person(parameters)
		params = parameters[:person]
		params[:acknowledgement_of_receipt_date] = Time.now	
		if params[:onset_death_interval1].present?
			params[:onset_death_interval1] = self.calculate_time(params[:onset_death_interval1].to_i,params[:unit_onset_death_interval1])
			
		end
	
		if params[:onset_death_interval2].present?
			params[:onset_death_interval2] = self.calculate_time(params[:onset_death_interval2].to_i,params[:unit_onset_death_interval2])
		end
	
		if params[:onset_death_interval3].present?
			params[:onset_death_interval3] = self.calculate_time(params[:onset_death_interval3].to_i,params[:unit_onset_death_interval3])
		  end
	
		if params[:onset_death_interval4].present?
			params[:onset_death_interval4] = self.calculate_time(params[:onset_death_interval4].to_i,params[:unit_onset_death_interval4])
		end
		person = self.create(params)

		if parameters[:other_sig_cause_of_death1].present?
			OtherSignificantCause.create({
				person_id: person.id,
				cause: parameters[:other_sig_cause_of_death1],
				created_at: Time.now,
				updated_at: Time.now
			})
			if parameters[:other_sig_cause_of_death2].present?
				OtherSignificantCause.create({
					person_id: person.id,
					cause: parameters[:other_sig_cause_of_death2],
					created_at: Time.now,
					updated_at: Time.now
				})
			end
		  end
	end

	def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "person_id"
			 	data["_id"] = self.as_json[key]
			elsif key=="voided"
				data[key] = (self.as_json[key]==1? true : false)
			else
			 	data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "Person"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end
end
