class RecordIdentifier < ActiveRecord::Base
	after_commit :push_to_remote,:push_to_couchDB
	before_create :set_id
	self.table_name = "person_identifier"
	def person
		return Record.find(self.person_record_id)
	end
	def set_id
		self.person_identifier_id = SecureRandom.uuid if self.person_identifier_id.blank?
	end
	def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "person_identifier_id"
			 	data["_id"] = self.as_json[key]
			else
			 	data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "PersonIdentifier"
			end
		end
		
		return  Pusher.database.save_doc(data)

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
			person_assigened_den.push_to_couch

			RecordStatus.where(person_record_id: person.id).order(:created_at).each do |s|
				s.voided = 1
				s.save
			end
			
			RecordStatus.create({
									  :person_record_id => person.id.to_s,
									  :status => "HQ ACTIVE",
									  :district_code => (district_code rescue SETTINGS['district_code']),
									  :comment=> "Record approved at DC",
									  :creator => creator,
									  :voided => 0,
                                      :created_at => Time.now,
                              	      :updated_at => Time.now})
  
			person.approved = "Yes"
			person.approved_at = Time.now
  
			person.save
  
	 	else
		end


	end

	def push_to_remote
		data = self.as_json
		if data["type"].nil?
			data["type"] = "RecordIdentifier"
		end
		return  RemotedPusher.push(data)
	end
end
