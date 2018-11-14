class Record < ActiveRecord::Base
	attr_accessor :den
	attr_accessor :_id
	attr_accessor :drn
	attr_accessor :barcode
	self.table_name = "people"

	def get_den
		return RecordIdentifier.where("person_record_id='#{self.person_id}' AND identifier_type = 'DEATH ENTRY NUMBER'").first.identifier rescue ''
	end

	def get_drn
		return RecordIdentifier.where("person_record_id='#{self.person_id}' AND identifier_type = 'DEATH REGISTRATION NUMBER'").first.identifier rescue ''
	end

	def get_barcode
		return RecordIdentifier.where("person_record_id='#{self.person_id}' AND identifier_type = 'DEATH REGISTRATION NUMBER'").first.identifier rescue ''
	end
end
