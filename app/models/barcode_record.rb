class BarcodeRecord < ActiveRecord::Base
	self.table_name = "barcodes"
	def person
		return Person.find(self.person_record_id)
	end
end