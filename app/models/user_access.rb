class UserAccess < CouchRest::Model::Base
	use_database "local"
	property :user_id, String
	property :portal_link, String
	design do
    	view :by__id
    	view :by_user_id
    end
    def self.user
    	return User.find(self.id)
    end
end