class PersonIdentifier < CouchRest::Model::Base

	property :person_record_id, String

	property :identifier_type, String #Entry Number|Registration Number|Death Certificate Number| National ID Number

	property :identifier, String 

	property :site_code, String

	property :district_code, String

	property :creator, String

	property :_rev, String

	timestamps!

	validates_uniqueness_of :identifier

	design do

    	view :by__id

    	view :by_person_record_id

    	view :by_identifier_type

    	view :by_identifier

    	view :by_site_code

    	view :by_district_code

    	view :by_creator

    	view :by_created_at
    end

    def person

    	return Person.find(self.person_record_id)
    	
    end
end
