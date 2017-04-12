class Person < CouchRest::Model::Base

  #use_database "death"

  before_save NameCodes.new("first_name")
  before_save NameCodes.new("last_name")
  before_save NameCodes.new("middle_name")

  before_save NameCodes.new("mother_first_name")
  before_save NameCodes.new("mother_last_name")
  before_save NameCodes.new("mother_middle_name")

  before_save NameCodes.new("father_first_name")
  before_save NameCodes.new("father_last_name")
  before_save NameCodes.new("father_middle_name")

  before_save NameCodes.new("informant_first_name")
  before_save NameCodes.new("informant_last_name")
  before_save NameCodes.new("informant_middle_name")

  #after_initialize :decrypt_data

  #before_save :encrypt_data

  before_save :set_facility_code,:set_district_code
  #after_create :create_status
  after_create :create_stat

  cattr_accessor :duplicate
  
  def decrypt_data
    encryptable = ["first_name","last_name",
                   "middle_name","last_name",
                   "mother_first_name","mother_last_name",
                   "mother_middle_name","mother_id_number",
                   "father_id_number","father_first_name",
                   "father_last_name","father_middle_name",
                   "father_id_number","informant_first_name","informant_last_name",
                   "informant_middle_name"]
    (self.attributes || []).each do |attribute|

      next unless encryptable.include? attribute[0] || (attribute[1].length > 20 && attribute[1].match(/\=+/))

      self.send("#{attribute[0]}=", (attribute[1].decrypt rescue attribute[1])) unless attribute[1].blank?
    end
  end
  
  def encrypt_data
    encryptable = ["first_name","last_name",
                   "middle_name","last_name",
                   "mother_first_name","mother_last_name",
                   "mother_middle_name","mother_id_number",
                   "father_id_number","father_first_name",
                   "father_last_name","father_middle_name",
                   "father_id_number","informant_first_name","informant_last_name",
                   "informant_middle_name"]
    (self.attributes || []).each do |attribute|

      next unless encryptable.include? attribute[0] || (attribute[1].length > 20 && attribute[1].match(/\=+/))

      self.send("#{attribute[0]}=", attribute[1].encrypt) unless attribute[1].blank?
    end
  end

  def create_status
    
    if self.duplicate.nil?
      PersonRecordStatus.create({
                                  :person_record_id => self.id.to_s,
                                  :status => "NEW",
                                  :district_code =>  self.district_code,
                                  :created_by => User.current_user.id})
    else
      
      change_log = [{:duplicates => self.duplicate.to_s}]

      Audit.create({
                      :record_id  => self.id.to_s,
                      :audit_type => "POTENTIAL DUPLICATE",
                      :reason     => "Record is a potential",
                      :change_log => change_log
      })
      PersonRecordStatus.create({
                                  :person_record_id => self.id.to_s,
                                  :status => "DC POTENTIAL DUPLICATE",
                                  :district_code => self.district_code,
                                  :created_by => User.current_user.id})

      self.duplicate = nil

    end
    
  end

  def create_stat
    stat = Statistic.by_person_record_id.key(self.id).first
    if stat.blank?
        Statistic.create({:person_record_id => self.id, :date_doc_created => self.created_at.to_time})
    end
  end

  #Person methods
  def person_id=(value)
    self['_id']=value.to_s
  end

  def person_id
    self['_id']
  end


  def self.update_state(id, status, audit_status)

    person = Person.find(id)
    raise "Person with ID: #{id} not found".to_s if person.blank?

    status = status
    audit_status = audit_status
    audit_reason = "Admin request"

    user = User.find("admin")
    name = user.first_name + " " + user.last_name

    person.status = status
    person.status_changed_by = name
    person.save

    audit = Audit.new()
    audit["record_id"] = person.id
    audit["audit_type"] = audit_status
    audit["reason"] = audit_reason
    audit.save
  end

 def set_district_code
    unless self.district_code.present?
      self.district_code = CONFIG["district_code"]
    end      
  end

  def set_facility_code
    unless self.facility_code.present?
      self.facility_code = (CONFIG['facility_code'] rescue nil)
    end 
  end

  def status
    PersonRecordStatus.by_person_recent_status.key(self.id).last.status
  end

  def change_status(nextstatus)
    status = PersonRecordStatus.by_person_recent_status.key(self.id.to_s).last
    status.update_attributes({:voided => true})
    PersonRecordStatus.create({
                        :person_record_id => self.id.to_s,
                        :status => nextstatus,
                        :district_code =>(self.district_code rescue CONFIG['district_code']),
                        :creator => User.current_user.id})
  end

  def self.create_person(parameters)
      params = parameters[:person]

      params[:acknowledgement_of_receipt_date] = Time.now

      if !params[:nationality].blank?

        params[:nationality_id] = Nationality.by_nationality.key(params[:nationality]).first.id

      end
      if !params[:place_of_death_district].blank?

            district = District.by_name.key(params[:place_of_death_district]).first

            params[:place_of_death_district_id] = district.id

            if !params[:hospital_of_death].blank? && params[:place_of_death].downcase.match("health facility")

                health_facility = HealthFacility.by_district_id_and_name.key([district.id, params[:hospital_of_death]]).first

                params[:hospital_of_death_id] = health_facility.id
            else

                if !params[:place_of_death_ta].blank? && params[:place_of_death_ta] != "Other"

                     place_ta = TraditionalAuthority.by_district_id_and_name.key([district.id,params[:place_of_death_ta]]).first

                     params[:place_of_death_ta_id] = place_ta.id

                     if !params[:place_of_death_village].blank? && params[:place_of_death_village] != "Other"
                        place_village = Village.by_ta_id_and_name.key([place_ta.id,params[:place_of_death_village]]).first
                        params[:place_of_death_village_id] = place_village.id
                       
                     end
                  
                end

            end

      end

      if !params[:current_country].blank?

          params[:current_country_id] = Country.by_name.key(params[:current_country]).first.id

      end

      if !params[:home_district].blank?
        
          home_district = District.by_name.key(params[:home_district]).first

          params[:home_district_id] = home_district.id

          if !params[:home_ta].blank? && params[:home_ta] != "Other"

               ta = TraditionalAuthority.by_district_id_and_name.key([home_district.id,params[:home_ta]]).first

               params[:home_ta_id] = ta.id

               if !params[:home_village].blank? && params[:home_village] != "Other"
                  village = Village.by_ta_id_and_name.key([ta.id,params[:home_village]]).first
                  params[:home_village_id] = village.id
                 
               end
            
          end
      end

    if !params[:home_country].blank?

          params[:home_country_id] = Country.by_name.key(params[:home_country]).first.id

      end

      if !params[:current_district].blank?
        
          current_district = District.by_name.key(params[:current_district]).first

          params[:current_district_id] = current_district.id

          if !params[:current_ta].blank? && params[:current_ta] != "Other"

               current_ta = TraditionalAuthority.by_district_id_and_name.key([current_district.id,params[:current_ta]]).first

               params[:current_ta_id] = current_ta.id

               if !params[:current_village].blank? && params[:current_village] != "Other"

                  current_village = Village.by_ta_id_and_name.key([current_ta.id,params[:current_village]]).first

                  params[:current_village_id] = current_village.id
                 
               end
            
          end
      end

      if !params[:informant_current_district].blank?
        
          informant_district = District.by_name.key(params[:informant_current_district]).first

          params[:informant_current_district_id] = informant_district.id

          if !params[:informant_current_ta].blank? && params[:informant_current_ta] != "Other"

               informant_ta = TraditionalAuthority.by_district_id_and_name.key([informant_district.id,params[:informant_current_ta]]).first

               params[:informant_current_ta_id] = informant_ta.id

               if !params[:informant_current_village].blank? && params[:informant_current_village] != "Other"

                  informant_village = Village.by_ta_id_and_name.key([informant_ta.id,params[:informant_current_village]]).first

                  params[:informant_current_village_id] = informant_village.id
               end
            
          end
      end

      if params[:potential_duplicate].present?
            Person.duplicate = params[:potential_duplicate]
      end
      
      Person.create(params)
    
  end

  def update_person(id,params)

      person = Person.find(id)

       if !params[:place_of_death_district].blank?

            district = District.by_name.key(params[:place_of_death_district]).first

            params[:place_of_death_district_id] = district.id

            if !params[:hospital_of_death].blank? && params[:place_of_death].downcase.match("health facility")

                health_facility = HealthFacility.by_district_id_and_name.key([district.id, params[:hospital_of_death]]).first

                params[:hospital_of_death_id] = health_facility.id
            else

                if !params[:place_of_death_ta].blank? && params[:place_of_death_ta] != "Other"

                     place_ta = TraditionalAuthority.by_district_id_and_name.key([district.id,params[:place_of_death_ta]]).first

                     params[:place_of_death_ta_id] = place_ta.id

                     if !params[:place_of_death_village].blank? && params[:place_of_death_village] != "Other"
                        place_village = Village.by_ta_id_and_name.key([place_ta.id,params[:place_of_death_village]]).first
                        params[:place_of_death_village_id] = place_village.id
                       
                     end
                  
                end

            end

      end

      if !params[:home_country].blank?

          params[:home_country_id] = Country.by_name.key(params[:home_country]).first.id

      end

      if !params[:home_district].blank?
        
          home_district = District.by_name.key(params[:home_district]).first

          params[:home_district_id] = home_district.id

          if !params[:home_ta].blank? && params[:home_ta] != "Other"

               ta = TraditionalAuthority.by_district_id_and_name.key([home_district.id,params[:home_ta]]).first

               params[:home_ta_id] = ta.id

               if !params[:home_village].blank? && params[:home_village] != "Other"
                  village = Village.by_ta_id_and_name.key([ta.id,params[:home_village]]).first
                  params[:home_village_id] = village.id
                 
               end
            
          end
      end

      if !params[:current_district].blank?
        
          current_district = District.by_name.key(params[:current_district]).first

          params[:current_district_id] = current_district.id

          if !params[:current_ta].blank? && params[:current_ta] != "Other"

               current_ta = TraditionalAuthority.by_district_id_and_name.key([current_district.id,params[:current_ta]]).first

               params[:current_ta_id] = current_ta.id

               if !params[:current_village].blank? && params[:place_of_death_ta] != "Other"

                  current_village = Village.by_ta_id_and_name.key([current_ta.id,params[:current_village]]).first

                  params[:current_village_id] = current_village.id
                 
               end
            
          end
      end

      if !params[:informant_current_district].blank? 
        
          informant_district = District.by_name.key(params[:informant_current_district]).first

          params[:informant_current_district_id] = informant_district.id

          if !params[:informant_current_ta].blank? && params[:informant_current_ta] != "Other"

               informant_ta = TraditionalAuthority.by_district_id_and_name.key([informant_district.id,params[:informant_current_ta]]).first

               params[:informant_current_ta_id] = informant_ta.id

               if !params[:informant_current_village].blank? && params[:informant_current_village] != "Other"

                  informant_village = Village.by_ta_id_and_name.key([informant_ta.id,params[:informant_current_village]]).first

                  params[:informant_village_id] = informant_village.id
               end
            
          end
      end

      person.update_attributes(params)

  end

  #Identifiers
  def den
    return PersonIdentifier.by_person_record_id_and_identifier_type.key([self.id, "DEATH ENTRY NUMBER"]).first.identifier
  end
  def national_id
    return PersonIdentifier.by_person_record_id_and_identifier_type.key([self.id,"National ID"]).first.identifier 
  end
  def barcode
      PersonIdentifier.by_person_record_id_and_identifier_type.key([self.id,"Form Barcode"]).first.identifier
  end
  def drn
      return PersonIdentifier.by_person_record_id_and_identifier_type.key([self.id, "DEATH REGISTRATION NUMBER"]).first.identifier
  end

  #Person properties
  property :first_name, String
  property :middle_name, String
  property :last_name, String
  property :first_name_code, String
  property :last_name_code, String
  property :middle_name_code, String
  property :gender, String
  property :birthdate, Date
  property :birthdate_estimated, Integer, :default => 0
  property :date_of_death, Date
  property :birth_certificate_number, String
  property :nationality_id, String
  property :nationality, String
  property :place_of_death, String
  property :hospital_of_death_id, String
  property :hospital_of_death, String
  property :other_place_of_death, String
  property :other_place_of_death_village, String
  property :place_of_death_village, String
  property :place_of_death_village_id, String
  property :other_place_of_death_ta, String
  property :place_of_death_ta_id, String
  property :place_of_death_ta, String
  property :place_of_death_district_id, String
  property :place_of_death_district, String
  property :place_of_death_country, String
  property :place_of_death_foreign, String
  property :place_of_death_foreign_state, String #State
  property :place_of_death_foreign_district, String #District
  property :place_of_death_foreign_village, String #Town / Village
  property :place_of_death_foreign_hospital, String
  property :cause_of_death_available, String
  property :cause_of_death1, String
  property :other_cause_of_death1, String
  property :cause_of_death2, String
  property :other_cause_of_death2, String
  property :cause_of_death3, String
  property :other_cause_of_death3, String
  property :cause_of_death4, String
  property :other_cause_of_death4, String
  property :onset_death_interval1, String
  property :onset_death_interval2, String
  property :onset_death_interval3, String
  property :onset_death_interval4, String
  property :cause_of_death_conditions, String
  property :icd_10_code, String
  property :manner_of_death, String
  property :other_manner_of_death, String
  property :death_by_accident, String
  property :other_death_by_accident, String
  property :other_home_village, String
  property :home_village_id, String
  property :home_village, String
  property :other_home_ta, String
  property :home_ta_id, String
  property :home_ta, String
  property :home_district_id, String
  property :home_district, String
  property :home_country_id, String
  property :home_country, String
  property :home_foreign_state, String
  property :home_foreign_district, String
  property :home_foreign_village, String
  property :home_foreign_address, String
  property :other_current_village, String
  property :current_village_id, String
  property :current_village, String
  property :other_current_ta, String
  property :current_ta_id, String
  property :current_ta, String
  property :current_district_id, String
  property :current_district, String
  property :current_country_id, String
  property :current_country, String
  property :current_foreign_state, String
  property :current_foreign_district, String
  property :current_foreign_village, String
  property :current_foreign_address, String
  property :died_while_pregnant, String, :default => "N/A"
  property :updated_by, String
  property :voided_by, String
  property :voided_date, Time
  property :voided, TrueClass, :default => false
  property :form_signed, String
  property :approved, String, :default => 'No'
  #property :status, String, :default => 'Active' #Active|Approved|Printed|Reprinted
  property :status_changed_by, String
  property :npid, String
  property :approved_by, String
  property :approved_at, Time
  property :delayed_registration, String,  :default =>"No"
  property :registration_type, String, :default => "Natural Death" # Unnatural Death | Unclaimed bodies | Missing Persons | Death abroad
  property :court_order, String, :default => "No"
  property :police_report, String, :default => "No"
  property :commissioner_documents, String, :default => "No"

  #Person's mother properties
  #property :mother do
  property :mother_id_number, String
  property :mother_first_name, String
  property :mother_middle_name, String
  property :mother_last_name, String
  property :mother_first_name_code, String
  property :mother_last_name_code, String
  property :mother_middle_name_code, String
  property :mother_gender, String
  property :mother_birthdate, Date
  property :mother_birthdate_estimated, String
  property :mother_current_village_id, String
  property :mother_current_ta_id, String
  property :mother_current_district_id, String
  property :mother_current_village, String
  property :mother_current_ta, String
  property :mother_current_district, String
  property :mother_home_village, String
  property :mother_home_ta_id, String
  property :mother_home_district_id, String
  property :mother_home_country_id, String
  property :mother_nationality_id, String
  property :mother_home_village_id, String
  property :mother_home_ta, String
  property :mother_home_district, String
  property :mother_home_country, String
  property :mother_nationality, String
  property :mother_occupation, String

  #Address details for foreigner
  property :mother_residential_country_id, String #Country
  property :mother_residential_country, String #Country

  property :mother_foreigner_current_district_id, String #District/State
  property :mother_foreigner_current_village_id, String #Village/Town
  property :mother_foreigner_current_ta_id, String #Address
  property :mother_foreigner_current_district, String #District/State
  property :mother_foreigner_current_village, String #Village/Town
  property :mother_foreigner_current_ta, String #Address

  property :mother_foreigner_home_district_id, String #District/State
  property :mother_foreigner_home_village_id, String #Village/Town
  property :mother_foreigner_home_ta_id, String #Address
  property :mother_foreigner_home_district, String #District/State
  property :mother_foreigner_home_village, String #Village/Town
  property :mother_foreigner_home_ta, String #Address

  #end

  #Person's father properties
  #property :father do
  property :father_id_number, String
  property :father_first_name, String
  property :father_middle_name, String
  property :father_last_name, String
  property :father_first_name_code, String
  property :father_last_name_code, String
  property :father_middle_name_code, String
  property :father_gender, String
  property :father_birthdate, Date
  property :father_birthdate_estimated, String
  property :father_current_village_id, String
  property :father_current_ta_id, String
  property :father_current_district_id, String
  property :father_current_village, String
  property :father_current_ta, String
  property :father_current_district, String
  property :father_home_village_id, String
  property :father_home_ta_id, String
  property :father_home_district_id, String
  property :father_home_country_id, String
  property :father_nationality_id, String
  property :father_home_village, String
  property :father_home_ta, String
  property :father_home_district, String
  property :father_home_country, String
  property :father_nationality, String
  property :father_occupation, String

  #Address details for foreigner

  property :father_residential_country_id, String #Country
  property :father_residential_country, String #Country

  property :father_foreigner_current_district_id, String #District/State
  property :father_foreigner_current_village_id, String #Village/Town
  property :father_foreigner_current_ta_id, String #Address
  property :father_foreigner_current_district, String #District/State
  property :father_foreigner_current_village, String #Village/Town
  property :father_foreigner_current_ta, String #Address

  property :father_foreigner_home_district_id, String #District/State
  property :father_foreigner_home_village_id, String #Village/Town
  property :father_foreigner_home_ta_id, String #Address
  property :father_foreigner_home_district, String #District/State
  property :father_foreigner_home_village, String #Village/Town
  property :father_foreigner_home_ta, String #Address

  #end

  #Details of senior village member
  property :headman_verified, String
  property :headman_verification_date, Date

  #Details of church elder
  property :church_verified, String
  property :church_verification_date, Date

  #Death informant properties
  #property :informant do
  property :informant_id_number, String
  property :informant_first_name, String
  property :informant_middle_name, String
  property :informant_last_name, String
  property :informant_first_name_code, String
  property :informant_last_name_code, String
  property :informant_middle_name_code, String
  property :informant_relationship_to_deceased, String
  property :informant_relationship_to_deceased_other, String
  property :informant_current_village_id, String
  property :informant_current_ta_id, String
  property :informant_current_district_id, String
  property :informant_current_village, String
  property :informant_current_other_village, String
  property :informant_current_ta, String
  property :informant_current_other_ta, String
  property :informant_current_district, String
  property :informant_current_country, String
  property :informant_addressline1, String
  property :informant_addressline2, String
  property :informant_city, String
  property :informant_phone_number, String
  property :informant_foreign_state, String
  property :informant_foreign_district, String
  property :informant_foreign_village, String
  property :informant_foreign_address, String
  property :informant_signed, String
  property :informant_signature_date, Date
  property :informant_designation, String
  property :informant_office_name,String
  property :informant_office_address, String
  #end

  property :certifier_first_name, String
  property :certifier_middle_name, String
  property :certifier_last_name, String
  property :certifier_signed, String
  property :date_certifier_signed, Date
  property :position_of_certifier, String
  property :other_position_of_certifier, String

  property :acknowledgement_of_receipt_date, Time, :default => Time.now

  #facility related information
  property :facility_code, String
  property :district_code, String

  property :date_created, Date
  property :created_by, String
  property :changed_by, String

  property :_deleted, TrueClass, :default => false
  property :_rev, String

  timestamps!

  design do
    view :by__id

    view :by_created_at

    view :by_updated_at

    view :by_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person') {
                    emit([doc['first_name_code'], doc['last_name_code']], 1);
                  }
                }"

    view :by_first_name_code

    view :by_last_name_code


    view :by_specific_birthdate,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['birthdate'] != null) {
                    var tokens = doc['birthdate'].split('/');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit(date, 1);
                  }
                }"

    view :by_birthdate_range,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['birthdate'] != null) {
                    var tokens = doc['birthdate'].split('/');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit((new Date(date)), 1);
                  }
                }"

    view :by_specific_date_of_death,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['date_of_death'] != null) {
                    var tokens = doc['date_of_death'].split('/');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit(date, 1);
                  }
                }"

    view :by_date_of_death_range,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['date_of_death'] != null) {
                    var tokens = doc['date_of_death'].split('/');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit((new Date(date)), 1);
                  }
                }"

    view :by_nationality,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['citizenship'] != null) {
                    emit(doc['citizenship'], 1);
                  }
                }"

    view :by_home_district,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['home_district'] != null) {
                    emit(doc['home_district'], 1);
                  }
                }"

    view :by_home_district_and_ta,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['home_district'] != null && doc['home_ta'] != null) {
                    emit([ doc['home_district'], doc['home_ta'] ], 1);
                  }
                }"

    view :by_home_district_ta_and_village,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['home_district'] != null && doc['home_ta'] != null && doc['home_village'] != null) {
                    emit([ doc['home_district'], doc['home_ta'], doc['home_village'] ], 1);
                  }
                }"

    view :by_hospital_of_death,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['hospital_of_death'] != null) {
                    emit(doc['hospital_of_death'], 1);
                  }
                }"

    view :by_other_place_of_death,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['other_place_of_death'] != null) {
                    emit(doc['other_place_of_death'], 1);
                  }
                }"

    view :by_place_of_death_district,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['place_of_death_district'] != null) {
                    emit(doc['place_of_death_district'], 1);
                  }
                }"

    view :by_place_of_death_district_and_ta,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['place_of_death_district'] != null && doc['place_of_death_ta'] != null) {
                    emit([ doc['place_of_death_district'], doc['place_of_death_ta'] ], 1);
                  }
                }"

    view :by_place_of_death_district_ta_and_village,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['place_of_death_district'] != null && doc['place_of_death_ta'] != null && doc['place_of_death_village'] != null) {
                    emit([ doc['place_of_death_district'], doc['place_of_death_ta'], doc['place_of_death_village'] ], 1);
                  }
                }"

    view :by_informant_last_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['informant_last_name_code'] != null) {
                    emit(doc['informant_last_name_code'], 1);
                  }
                }"

    view :by_informant_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['informant_first_name_code'] != null) {
                    emit(doc['informant_first_name_code'], 1);
                  }
                }"

    view :by_informant_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['informant_middle_name_code'] != null) {
                    emit(doc['informant_middle_name_code'], 1);
                  }
                }"

    view :by_informant_last_name_and_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['informant_last_name_code'] != null && doc['informant_first_name_code'] != null) {
                    emit([ doc['informant_last_name_code'], doc['informant_first_name_code'] ], 1);
                  }
                }"

    view :by_informant_last_name_first_name_and_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['informant_last_name_code'] != null && doc['informant_first_name_code'] != null && doc['informant_middle_name_code'] != null) {
                    emit([ doc['informant_last_name_code'], doc['informant_first_name_code'], doc['informant_middle_name_code'] ], 1);
                  }
                }"

    view :by_mother_last_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['mother_last_name_code'] != null) {
                    emit(doc['mother_last_name_code'], 1);
                  }
                }"

    view :by_mother_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['mother_first_name_code'] != null) {
                    emit(doc['mother_first_name_code'], 1);
                  }
                }"

    view :by_mother_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['mother_middle_name_code'] != null) {
                    emit(doc['mother_middle_name_code'], 1);
                  }
                }"

    view :by_mother_last_name_and_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['mother_last_name_code'] != null && doc['mother_first_name_code'] != null) {
                    emit([ doc['mother_last_name_code'], doc['mother_first_name_code'] ], 1);
                  }
                }"

    view :by_mother_last_name_first_name_and_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['mother_last_name_code'] != null && doc['mother_first_name_code'] != null && doc['mother_middle_name_code'] != null) {
                    emit([ doc['mother_last_name_code'], doc['mother_first_name_code'], doc['mother_middle_name_code'] ], 1);
                  }
                }"

    view :by_father_last_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['father_last_name_code'] != null) {
                    emit(doc['father_last_name_code'], 1);
                  }
                }"

    view :by_father_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['father_first_name_code'] != null) {
                    emit(doc['father_first_name_code'], 1);
                  }
                }"

    view :by_father_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['father_middle_name_code'] != null) {
                    emit(doc['father_middle_name_code'], 1);
                  }
                }"

    view :by_father_last_name_and_first_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['father_last_name_code'] != null && doc['father_first_name_code'] != null) {
                    emit([ doc['father_last_name_code'], doc['father_first_name_code'] ], 1);
                  }
                }"

    view :by_father_last_name_first_name_and_middle_name,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['father_last_name_code'] != null && doc['father_first_name_code'] != null && doc['father_middle_name_code'] != null) {
                    emit([ doc['father_last_name_code'], doc['father_first_name_code'], doc['father_middle_name_code'] ], 1);
                  }
                }"

    view :by_specific_date_of_death_and_location,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['date_of_death'] != null && doc['home_district'] != null) {
                    var tokens = doc['date_of_death'].replace(/,/, '').split(' ');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit([ doc['home_district'], date ], 1);
                  }
                }"

    view :by_date_of_death_range_and_location_date,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['date_of_death'] != null && doc['home_district'] != null) {
                    var tokens = doc['date_of_death'].replace(/,/, '').split(' ');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit([ doc['home_district'], (new Date(date)).getFullYear(), (new Date(date)).getMonth() + 1, (new Date(date)).getDate() ], 1);
                  }
                }"

    view :by_date_of_death_range_and_location_month,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['date_of_death'] != null && doc['home_district'] != null) {
                    var tokens = doc['date_of_death'].replace(/,/, '').split(' ');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit([ doc['home_district'], (new Date(date)).getFullYear(), (new Date(date)).getMonth() + 1 ], 1);
                  }
                }"

    view :by_date_of_death_range_and_location_year,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['date_of_death'] != null && doc['home_district'] != null) {
                    var tokens = doc['date_of_death'].replace(/,/, '').split(' ');
                    var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                    var date = tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0];
                    emit([ doc['home_district'], (new Date(date)).getFullYear() ], 1);
                  }
                }"
    view :by_demographics,
         :map => "function(doc) {
                  if (doc['type'] == 'Person') {
                    emit([doc['first_name_code'], doc['last_name_code'], doc['gender'],doc['birthdate'],doc['date_of_death'], doc['place_of_death']], 1);
                  }
                }"
    view :by_demographics_and_informant,
         :map =>"function(doc){
                    if(doc['type']=='Person'){
                        emit([doc['first_name_code'], 
                              doc['last_name_code'], 
                              doc['gender'],
                              doc['date_of_death'], 
                              doc['birthdate'], 
                              doc['place_of_death'],
                              doc['informant_first_name_code'],
                              doc['informant_last_name_code']], 1);
                    }
              }"
    view :by_demographics_with_place,
         :map => "function(doc) {
                  if (doc['type'] == 'Person') {
                    emit([doc['first_name_code'],
                          doc['middle_name_code'],
                          doc['last_name_code'],
                          doc['gender'],
                          doc['date_of_death'],
                          doc['mother_first_name_code'],
                          doc['mother_middle_name_code'],
                          doc['mother_last_name_code'],
                          doc['place_of_death'],
                          doc['place_of_death_district']
                        ], 1);
                  }
                }"
    view :by_reporting_date_and_district_code,
         :map => "function(doc) {
                  if (doc['type'] == 'Person' && doc['informant_signature_date'] != null &&
                     doc['informant_signature_date'] != '' && doc['place_of_death_district'] != null) {
                    if (doc['informant_signature_date'].trim().match(/^(\\d{2}|\\d{1})\\/[A-Z][a-z]{2}\\/\\d{4}/) ||
                        doc['informant_signature_date'].trim().match(/^(\\d{2}|\\d{1})\s[A-Z][a-z]{2},\s\\d{4}/)) {
                            var tokens = doc['informant_signature_date'].replace(/,/, '').replace(/\\//g, ' ').split(' ');
                            var months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
                              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'};
                            var date = (new Date(tokens[2] + '-' + months[tokens[1]] + '-' + tokens[0])).getTime();
                            emit([ date, doc.place_of_death_district], 1);
                    } else if(doc['informant_signature_date'].trim().length > 10){
                        var date = (new Date(doc['informant_signature_date'].trim().substring(0, 10))).getTime();
                        emit([ date, doc.place_of_death_district], 1);
                    } else {
                      var date = (new Date(doc['informant_signature_date'])).getTime();
                      emit([ date, doc.place_of_death_district], 1);
                    }
                  }
                }"

    view :by_approved

    view :by_registration_type

    filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"
    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"

  end

end

