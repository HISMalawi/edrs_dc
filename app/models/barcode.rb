class Barcode < CouchRest::Model::Base
	before_save :set_district_code
	property :person_record_id, String
	property :barcode, String
	property :assigned, TrueClass, :default => true
	property :district_code, String
	timestamps!

	unique_id :barcode

	design do
    	view :by__id
    	filter :district_sync, "function(doc,req) {return req.query.assigned == true }"
    end

   	def set_distict_code
    	self.district_code = self.person.district_code
   	end

   	def person
	    person = Person.find(self.person_record_id)
	    return person
   	end
end