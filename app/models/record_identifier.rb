class RecordIdentifier < ActiveRecord::Base
	self.table_name = "person_identifier"
	def person
		return Person.find(self.person_record_id)
	end
end
