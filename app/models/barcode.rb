class Barcode < CouchRest::Model::Base
	property :person_record_id, String
	property :barcode, String
	property :assigned, TrueClass, :default => true
	timestamps!

	unique_id :barcode

	design do
    	view :by__id
    end
end