class RoleRecord < ActiveRecord::Base
	before_create :set_id
	self.table_name ="role"
    def set_id
		self.role_id = SecureRandom.uuid if self.role_id.blank?
	end
end