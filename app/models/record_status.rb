class RecordStatus < ActiveRecord::Base
	self.table_name = "person_record_status"
	def person
		return Person.find(self.person_record_id)
	end
end
