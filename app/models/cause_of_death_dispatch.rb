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
	    unless self.district_code.present?
	      self.district_code = SETTINGS["district_code"]
	    end 
	    if SETTINGS['site_type'] == "remote"
	      self.district_code = User.current_user.district_code
	    end
   	end

   	def set_creator
	    self.creator = (User.current_user.id rescue User.by_created_at.each.first.id)
	end
end