class GlobalProperty < CouchRest::Model::Base
    
    use_database "global_property"
  
	def setting=(value)
		self['_id'] = value.to_s
	end

	def setting
		self['_id']
	end
	
	property :value, String
	
	timestamps!
	
	design do

        view :by__id
        
        view :by_setting
        
        view :by_value
        
        view :by_created_at
        
        view :by_updated_at
    
    end  
end
