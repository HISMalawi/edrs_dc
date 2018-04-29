class Barcode < CouchRest::Model::Base
	before_save :set_district_code
	property :person_record_id, String
	property :barcode, String
	property :assigned, String, :default => 'true'
	property :district_code, String
	property :creator, String
	timestamps!

	design do
    	view :by__id
    	view :by_assigned
    	filter :assigned_sync, "function(doc,req) {return req.query.assigned == 'true' }"
    end

   	def set_district_code
    	self.district_code = self.person.district_code
   	end

   	def person
	    person = Person.find(self.person_record_id)
	    return person
   	end
end