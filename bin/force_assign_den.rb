limit = 10000
if ARGV.length > 0
	limit = ARGV[0].to_i
end

RecordStatus.where(status:'MARKED APPROVAL',voided:0, district_code: SETTINGS['district_code']).order(:created_at).limit(limit).each do |s|
	begin
		a = Person.find(s.person_record_id)
		if a.den.split("/")[0] != SETTINGS['district_code']
			PersonIdentifier.assign_den(a, s.creator)
			d= PersonRecordStatus.find(s.person_record_status_id)
			d.voided = true
			d.save
			s.voided = 1
			s.save
		else
			if a.status == "MARKED APPROVAL"
				PersonRecordStatus.change_status(person, "HQ ACTIVE")
			end
			d= PersonRecordStatus.find(s.person_record_status_id)
			d.voided = true
			d.save
			s.voided = 1
			s.save
		end
		puts a.den
		puts s.person_record_id
   rescue
   end
end
