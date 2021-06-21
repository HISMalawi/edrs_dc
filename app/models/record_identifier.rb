class RecordIdentifier < ActiveRecord::Base
	self.table_name = "person_identifier"
	def person
		return Person.find(self.person_record_id)
	end

	def self.assign_den(person, creator) 
		year = Date.today.year
		district_code = person.district_code
		if SETTINGS['site_type'] == "dc"
			return if person.district_code.to_s.squish != SETTINGS['district_code'].to_s.squish
		else 
			return if SETTINGS['exclude'].split(",").include?(DistrictRecord.where(district_id: district_code).first.name)
		end
	
	
		dens = DeathEntryNumber.where(district_code: district_code, year: year).order(:value) rescue nil
		den_value = self.check_for_skipped_dens(dens)
	
		if den_value[0]
		  num = den_value[1]
		else
		  num = den_value[1].to_i + 1
		end

		den_assigned_to_person = DeathEntryNumber.where(district_code: district_code, year: year, value: num).first

		person_assigened_den =  DeathEntryNumber.where(person_record_id:person.id.to_s).first rescue nil

		if  person_assigened_den.blank? && den_assigned_to_person.blank?
			begin
				identifier_record = DeathEntryNumber.create(person_record_id: person.id.to_s,
															value: num,
															district_code: district_code,
															year: year,
															created_at: Time.now,
															updated_at: Time.now)
				if identifier_record.present?
					RecordStatus.where(person_record_id: person.id).order(:created_at).each do |s|
						next if s === new_status
						s.voided = 1
						s.save
					end
					RecordStatus.create({
										:person_record_id => person.id.to_s,
										:status => "HQ ACTIVE",
										:district_code => (district_code rescue SETTINGS['district_code']),
										:comment=> "Record approved at DC",
										:creator => creator})
				end

				person.approved = "Yes"
				person.approved_at = Time.now
	
				person.save

			rescue Exception => e
			end
		elsif person_assigened_den.present?
			verify_not_duplicate(person_assigened_den)
			person_assigened_den.push_to_couch

			RecordStatus.where(person_record_id: person.id).order(:created_at).each do |s|
				next if s === new_status
				s.voided = 1
				s.save
			end
			
			RecordStatus.create({
									  :person_record_id => person.id.to_s,
									  :status => "HQ ACTIVE",
									  :district_code => (district_code rescue SETTINGS['district_code']),
									  :comment=> "Record approved at DC",
									  :creator => creator})
  
			person.approved = "Yes"
			person.approved_at = Time.now
  
			person.save
  
	 	else
		end


	end

	def verify_not_duplicate(assigned)
		den = PersonIdentifier.find("#{assigned.district_code}/#{assigned.value.to_s.rjust(7,"0")}/#{assigned.year}")
		if assigned.person_record_id == den.person_record_id
		  return
		else
		  den.person_record_id = assigned.person_record_id
		  den.save
		end
	end

	def self.check_for_skipped_dens(dens)
		den = dens.last.value rescue 0
		actual_dens =  dens.collect{|d| d.value}
		difference = [*1..den] - actual_dens
		if difference.blank?
			return false, den
		else
			return true, difference[0]
		end
	end
end
