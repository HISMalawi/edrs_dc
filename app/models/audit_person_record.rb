class AuditPersonRecord < ActiveRecord::Base
	after_commit :push_to_remote
	before_create :set_id
	self.table_name = "audit_people"

	def set_id
		self.audit_person_id = SecureRandom.uuid if self.audit_person_id.blank?
	end

	def push_to_remote
		data = self.as_json
		if data["type"].nil?
			data["type"] = "AuditPersonRecord"
		end
		return  RemotedPusher.push(data)
	end
end
