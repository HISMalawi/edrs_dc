require 'couchrest_model'

class TraditionalAuthority < CouchRest::Model::Base
  property :district_id, String
  property :name, String
  
  timestamps!
 
  design do
      view :by__id
      view :by_district_id,
      	   :map => "function(doc){

      	   			if(doc.type=='TraditionalAuthority'){

      	   				emit(doc.district_id, {name : doc.name})
      	   			}
      	  	      }"
      view :by_name
      view :by_district_id_and_name

  end
  
end
