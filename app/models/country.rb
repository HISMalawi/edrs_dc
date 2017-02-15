class Country < CouchRest::Model::Base
	property :name, String
	property :iso, String
	property :numcode, String
	property :phonecode, String
	timestamps!
	design do
	    view :by__id
	    view :by_country,
	    	 :map => "function(doc) {
                  if ((doc['type'] == 'Country')) {
                    emit(doc['name'], 1);
                  }
                }"
	    view :by_phonecode
	end
end
