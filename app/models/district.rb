require 'couchrest_model'

class District < CouchRest::Model::Base

  property :code, String
  property :name, String
  property :region, String
  
  timestamps!

  design do
      view :by__id
      view :by_name
      view :by_region
      view :by_code
  end

end
