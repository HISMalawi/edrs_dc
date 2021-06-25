class DeathEntryNumber< ActiveRecord::Base
	after_commit :push_to_couch
	self.table_name = "death_entry_numbers"
	def push_to_couch
		begin
			puts "Pushing records to couch"
			identifier_record = RecordIdentifier.new
	        identifier_record.person_record_id = self.person_record_id.to_s
	        identifier_record.identifier_type = "DEATH ENTRY NUMBER"
	        den ="#{self.district_code}/#{self.value.to_s.rjust(7,"0")}/#{self.year}"
	        identifier_record.identifier =  den
	        identifier_record.den_sort_value = (self.year.to_s + self.value.to_s.rjust(7,"0")).to_i
	        identifier_record.district_code = self.district_code
	        identifier_record.save			
		rescue Exception => e
			puts "#{e}"
		end
	end
end