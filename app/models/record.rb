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
       return RecordStatus.where(person_record_id: self.person_id).last.status
  	end
end
