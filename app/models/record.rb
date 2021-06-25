class Record < ActiveRecord::Base

	self.table_name = "people"

	def den
		return RecordIdentifier.where("person_record_id='#{self.person_id}' AND identifier_type = 'DEATH ENTRY NUMBER'").first.identifier rescue ''
	end

	def drn
		return RecordIdentifier.where("person_record_id='#{self.person_id}' AND identifier_type = 'DEATH REGISTRATION NUMBER'").first.identifier rescue ''
	end

	def barcode
		return RecordIdentifier.where("person_record_id='#{self.person_id}' AND identifier_type = 'DEATH REGISTRATION NUMBER'").first.identifier rescue ''
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
end
