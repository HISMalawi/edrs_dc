require 'couchrest_model'
class Nationality < CouchRest::Model::Base

  property :nationality, String
  design do
    view :by__id
    view :by_nationality
  end

end
