require 'couchrest_model'

class Village < CouchRest::Model::Base

  property :ta_id, String
  property :name, String
  
  timestamps!

  design do
      view :by_ta_id,
      	   :map => "function(doc){
      	   				if(doc.type=='Village'){
      	   					emit(doc.ta_id,{name : doc.name})
      	   				}
      	   		   }"
      view :by_name
      view :by_ta_id_and_name
  end

end
