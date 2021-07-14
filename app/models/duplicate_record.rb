class DuplicateRecord < ActiveRecord::Base
	before_create :set_id
	self.table_name = "duplicates"
	def set_id
		self.audit_record_id = SecureRandom.uuid if self.audit_record_id.blank?
	end
end