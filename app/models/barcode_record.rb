class BarcodeRecord < ActiveRecord::Base
	after_commit :push_to_remote
	before_create :set_id
	self.table_name = "barcodes"
	def person
		return Record.find(self.person_record_id)
	end
	def set_id
		self.barcode_id = SecureRandom.uuid if self.barcode_id.blank?
	end

	def push_to_remote
		data = self.as_json
		if data["type"].nil?
			data["type"] = "BarcodeRecord"
		end
		return  RemotedPusher.push(data)
	end
end