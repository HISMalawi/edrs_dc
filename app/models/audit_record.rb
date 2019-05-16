class AuditRecord < ActiveRecord::Base
	self.table_name = "audit_trail"
	def person
		return Person.find(self.record_id) rescue nil
	end
end