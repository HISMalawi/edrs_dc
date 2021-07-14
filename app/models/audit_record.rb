class AuditRecord < ActiveRecord::Base
	after_commit :push_to_couchDB
	before_create :set_id
	self.table_name = "audit_trail"

	def person
		return Record.find(self.person_record_id)
	end
	def set_id
		self.audit_record_id = SecureRandom.uuid if self.audit_record_id.blank?
	end
	def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "audit_record_id"
				data["_id"] = self.as_json[key]
			else
				data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "Audit"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end
end