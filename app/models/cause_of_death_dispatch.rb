class CauseOfDeathDispatch < CouchRest::Model::Base
	before_save :set_district_code
	property :dispatch,[]
	property :district_code, String
	property :creator, String
	timestamps!

	design do
    	view :by__id
    	view :by_creator
    	view :by_district_code
    	view :by_created_at
    	filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"
    end

   	def set_district_code
    	self.district_code = self.person.district_code
   	end
end