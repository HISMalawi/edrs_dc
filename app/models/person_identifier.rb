class PersonIdentifier < CouchRest::Model::Base

  before_save :set_site_code,:set_district_code,:set_check_digit
  after_create :insert_update_into_mysql
  after_save :insert_update_into_mysql
  cattr_accessor :can_assign_den
  cattr_accessor :can_assign_drn

  property :person_record_id, String
  property :identifier_type, String #Entry Number|Registration Number|Death Certificate Number| National ID Number
  property :identifier, String
  property :check_digit
  property :site_code, String
  property :den_sort_value, Integer
  property :drn_sort_value, Integer
  property :district_code, String
  property :creator, String
  property :_rev, String


  timestamps!

  unique_id :identifier

  design do
    view :by__id
    view :by_person_record_id
    view :by_identifier
    view :by_site_code
    view :by_created_at
    view :by_person_record_id_and_identifier_type
    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
    filter :facility_sync, "function(doc,req) {return req.query.site_code == doc.site_code}"
  end

  def person
    person = Person.find(self.person_record_id)
    return person
  end

  def set_creator
    self.creator =  User.current_user.id
  end

  def set_check_digit
    self.check_digit =  PersonIdentifier.calculate_check_digit(self.identifier)
  end

  def set_site_code
    if SETTINGS['site_type'] == "facility"
      self.site_code = self.person.facility_code rescue nil
    else
      self.site_code = nil
    end
  end

  def set_district_code
    self.district_code = self.person.district_code
  end

  def self.calculate_check_digit(serial_number)
    # This is Luhn's algorithm for checksums
    # http://en.wikipedia.org/wiki/Luhn_algorithm
    number = serial_number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      digit = digit * 2 if index%2!=parity
      digit = digit - 9 if digit > 9
      sum = sum + digit
    end

    check_digit = (9 * sum) % 10

    return check_digit
  end

  def self.check_for_skipped_dens(dens)
      den = dens.last.value rescue 0
      actual_dens =  dens.collect{|d| d.value}
      difference = [*1..den] - actual_dens
      if difference.blank?
          return false, den
      else
          return true, difference[0]
      end
  end

  def self.assign_den(person, creator) 
    year = Date.today.year
    district_code = person.district_code
    if SETTINGS['site_type'] == "dc"
        return if person.district_code.to_s.squish != SETTINGS['district_code'].to_s.squish
    else 
        return if SETTINGS['exclude'].split(",").include?(DistrictRecord.where(district_id: district_code).first.name)
    end


    dens = DeathEntryNumber.where(district_code: district_code, year: year).order(:value) rescue nil
    
    den_value = self.check_for_skipped_dens(dens)

    if den_value[0]
      num = den_value[1]
    else
      num = den_value[1].to_i + 1
    end

    #check_new_den = SimpleSQL.query_exec("SELECT den FROM dens WHERE den ='#{new_den}' LIMIT 1").split("\n")

    den_assigned_to_person = DeathEntryNumber.where(district_code: district_code, year: year, value: num).first

    person_assigened_den =  DeathEntryNumber.where(person_record_id:person.id.to_s).first rescue nil

    

    if self.can_assign_den && person_assigened_den.blank? && den_assigned_to_person.blank?

        self.can_assign_den = false

        begin
          identifier_record = DeathEntryNumber.create(person_record_id: person.id.to_s,
                                                      value: num,
                                                      district_code: district_code,
                                                      year: year,
                                                      created_at: Time.now,
                                                      updated_at: Time.now)
          if identifier_record.present?


            status = PersonRecordStatus.by_person_recent_status.key(person.id.to_s).last

            begin
              status.update_attributes({:voided => true}) 
            rescue
            end

            approved_already_status = RecordStatus.where(person_record_id: person.id.to_s, status: "HQ ACTIVE").first

            if approved_already_status.present? 
              approved_already_status_couch = PersonRecordStatus.find(approved_already_status.id)
              approved_already_status_couch.voided = false
              approved_already_status_couch.save
            else
              RecordStatus.create({
                                      :person_record_id => person.id.to_s,
                                      :status => "HQ ACTIVE",
                                      :district_code => (district_code rescue SETTINGS['district_code']),
                                      :comment=> "Record approved at DC",
                                      :creator => creator,
                                      :voided => 0,
                                      :created_at => Time.now,
                              	      :updated_at => Time.now})              
            end

            person.approved = "Yes"
            person.approved_at = Time.now

            person.save

            AuditRecord.create(record_id: person.id,
                           audit_type: "Audit",
                           user_id: creator,
                           level: "Person",
                           reason: "Approved record")

          end          
        rescue Exception => e
            puts "ReQueue"
        end
        self.can_assign_den = true

    elsif den_assigned_to_person.present?
      
      puts "DEN is assign to #{den_assigned_to_person.person_record_id rescue ''}"
      self.can_assign_den = true

    elsif person_assigened_den.present?
          verify_not_duplicate(person_assigened_den)
          person_assigened_den.push_to_couch

          status = PersonRecordStatus.by_person_recent_status.key(person.id.to_s).last

          begin
            status.update_attributes({:voided => true}) 
          rescue
          end
          
          RecordStatus.create({
                                    :person_record_id => person.id.to_s,
                                    :status => "HQ ACTIVE",
                                    :district_code => (district_code rescue SETTINGS['district_code']),
                                    :comment=> "Record approved at DC",
                                    :creator => creator, 
                                    :voided => 0,
                                    :created_at => Time.now,
                                    :updated_at => Time.now})

          person.approved = "Yes"
          person.approved_at = Time.now

          person.save

          Audit.create(record_id: person.id,
                         audit_type: "Audit",
                         user_id: creator,
                         level: "Person",
                         reason: "Approved record")
      self.can_assign_den = true

    else
        puts "Can not assign DEN"
    end
  end

  def verify_not_duplicate(assigned)
      den = PersonIdentifier.find("#{assigned.district_code}/#{assigned.value.to_s.rjust(7,"0")}/#{assigned.year}")
      if assigned.person_record_id == den.person_record_id
        return
      else
        den.person_record_id = assigned.person_record_id
        den.save
      end
  end

  def self.generate_drn(person)
    last_record = PersonIdentifier.by_drn_sort_value.last.identifier rescue nil
    drn = last_record.to_i + 1 rescue 1
    nat_serial_num = drn
    drn = "%08d" % drn

    infix = ""
    if person.gender.match(/^F/i)
      infix = "1"
    elsif person.gender.match(/^M/i)
      infix = "2"
    end

    drn = "#{drn[0, 4]}#{infix}#{drn[4, 10]}"
    return drn, nat_serial_num
  end

  def self.assign_drn(person, creator)

    drn, drn_sort_value = self.generate_drn(person)

    self.create({
                    :person_record_id=>person.id.to_s,
                    :identifier_type =>"DEATH REGISTRATION NUMBER",
                    :identifier => drn,
                    :creator => creator,
                    :drn_sort_value => drn_sort_value,
                    :district_code => (person.district_code rescue SETTINGS['district_code'])
                })
  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = RecordIdentifier.where(person_identifier_id: self.id).first
      sql_record = RecordIdentifier.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        if field =="_id"
            sql_record["person_identifier_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end
end
