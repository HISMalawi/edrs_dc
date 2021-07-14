require 'couchrest_model'

class MyLock < CouchRest::Model::Base
	 use_database "local"
	 before_save :set_district_code

	 property :person_id, String
	 property :user_id, String
	 property :district_code, String

	 design do
	 	view :by__id
	 	view :by_person_id
	 	view :by_user_id
	 	view :by_person_id_and_district_code
	 	view :by_user_id_and_person_id
	 end

	 def set_district_code
	    self.district_code = (UserModel.current_user.district_code rescue "HQ")
	 end
end