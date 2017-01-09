class PersonRecordStatus < CouchRest::Model::Base

	property :person_record_id, String

	property :status, String #DC Active|HQ Active|HQ Approved|Printed|Reprinted...

	property :district_code, String

	property :voided, TrueClass, :default => false

	property :creator, String

	timestamps!

	design do 

		view :by_status

		view :by_distrit_code

		view :by_voided

		view :by_creator

	end

	def person

    	return Person.find(self.person_record_id)
    	
    end
end
