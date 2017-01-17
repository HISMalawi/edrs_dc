class PersonIdentifier < CouchRest::Model::Base

    before_save :set_site_code,:set_distict_code,:set_creator

	property :person_record_id, String

	property :identifier_type, String #Entry Number|Registration Number|Death Certificate Number| National ID Number

	property :identifier, String 

	property :site_code, String

	property :district_code, String

	property :creator, String

	property :_rev, String

	timestamps!

	validates_uniqueness_of :identifier

	design do

    	view :by__id

    	view :by_person_record_id

    	view :by_identifier_type

    	view :by_identifier

    	view :by_site_code

    	view :by_district_code

    	view :by_creator

    	view :by_created_at

        view :by_person_record_id_and_identifier_type
    end

    def person
    	person = Person.find(self.person_record_id)

        return person
    	
    end

    def set_creator
        
        self.creator =  User.current_user.id

    end

    def set_site_code

        if CONFIG['site_type'] =="facility"

            self.site_code = CONFIG["facility_code"]

        else

            self.site_code = nil

        end
    end  
  
    def set_distict_code

            person = Person.find(self.person_record_id)

            self.district_code = person.district_code
        
    end 

    def self.assign_den(person)
        
        den = DeathEntryNumber.by_district_unassigned.key(CONFIG['district_code']).last

        self.create({
                    :person_record_id=>person.id.to_s,
                    :identifier_type =>"DEATH ENTRY NUMBER",
                    :identifier => den.number,
                    :district_code => CONFIG['district_code']
            })
        den.update_attributes({:assigned => true})

    end
end
