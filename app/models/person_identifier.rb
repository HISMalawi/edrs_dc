class PersonIdentifier < CouchRest::Model::Base

  before_save :set_site_code,:set_distict_code,:set_check_digit

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

  #validates_uniqueness_of :identifier

  design do
    view :by__id
    view :by_person_record_id
    view :by_identifier_type
    view :by_identifier
    view :by_identifier_and_identifier_type
    view :by_site_code
    view :by_district_code_and_den_sort_value,
         :map => "function(doc) {
                  if (doc['type'] == 'PersonIdentifier' && doc['den_sort_value'] != null ) {
                    emit(doc['district_code']+doc['den_sort_value']);
                  }
                }"
    view :by_den_sort_value,
         :map => "function(doc) {
                  if (doc['type'] == 'PersonIdentifier' && doc['district_code'] == '#{CONFIG['district_code']}') {
                    emit(doc['den_sort_value']);
                  }
                }"
    view :by_drn_sort_value,
         :map => "function(doc) {
                  if ((doc['type'] == 'PersonIdentifier')) {
                    emit(doc['drn_sort_value']);
                  }
                }"
    view :by_district_code
    view :by_creator
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
    if CONFIG['site_type'] == "facility"
      self.site_code = self.person.facility_code rescue nil
    else
      self.site_code = nil
    end
  end

  def set_distict_code
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

  def self.assign_den(person, creator)
    if CONFIG['site_type'] =="remote"
      year = Date.today.year
      district_code = User.find(creator).district_code

      start_key = "#{district_code}#{year}0000001"
      end_key = "#{district_code}#{year}99999999"

      den = PersonIdentifier.by_district_code_and_den_sort_value.startkey(start_key).endkey(end_key).last.identifier rescue nil
    else
      den = PersonIdentifier.by_den_sort_value.last.identifier rescue nil
      year = Date.today.year
    end
    

    if den.blank? || !den.match(/#{year}$/)
      n = 1
    else
      n = den.scan(/\/\d+\//).last.scan(/\d+/).last.to_i + 1
    end

    code = person.district_code

    num = n.to_s.rjust(7,"0")
    new_den = "#{code}/#{num}/#{year}"

    #check_new_den = SimpleSQL.query_exec("SELECT den FROM dens WHERE den ='#{new_den}' LIMIT 1").split("\n")

    den_assigned_to_person = PersonIdentifier.by_identifier.key(new_den).first

    person_assigened_den =  (PersonIdentifier.by_person_record_id_and_identifier_type.key([person.id.to_s, "DEATH ENTRY NUMBER"]).first.identifier rescue nil)

    if self.can_assign_den && person_assigened_den.blank? && den_assigned_to_person.blank?
        self.can_assign_den = false
        sort_value = (year.to_s + num).to_i
        identifier_record = PersonIdentifier.create({
                        :person_record_id=>person.id.to_s,
                        :identifier_type =>"DEATH ENTRY NUMBER",
                        :identifier => new_den,
                        :creator => creator,
                        :den_sort_value => sort_value,
                        :district_code => (person.district_code rescue CONFIG['district_code'])
                    })

        status = PersonRecordStatus.by_person_recent_status.key(person.id.to_s).last

        status.update_attributes({:voided => true})

        PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "DC APPROVED",
                                  :district_code => (district_code rescue CONFIG['district_code']),
                                  :creator => creator})

        person.approved = "Yes"
        person.approved_at = Time.now

        person.save

        Audit.create(record_id: person.id,
                       audit_type: "Audit",
                       user_id: creator,
                       level: "Person",
                       reason: "Approved record")

        stat = Statistic.by_person_record_id.key(person.id).first

        if stat.present?
           stat.update_attributes({:date_doc_approved => person.approved_at.to_time})
        else
          stat = Statistic.new
          stat.person_record_id = person.id
          stat.date_doc_created = person.created_at.to_time
          stat.date_doc_approved = person.approved_at.to_time
          stat.save
        end
        self.can_assign_den = true
    elsif den_assigned_to_person.present?
      puts "DEN is assign to #{den_assigned_to_person.person_record_id rescue ''}"
      self.can_assign_den = true
    elsif person_assigened_den.present?
      puts "Person #{den_assigned_to_person.person_record_id rescue ''} already assigned DEN"
      self.can_assign_den = true
    else
        puts "Can not assign DEN"
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
                    :district_code => (person.district_code rescue CONFIG['district_code'])
                })
  end

  def self.insert_in_mysql(record)

    identifier_keys = record.keys.sort

    query = "INSERT INTO person_identifier ("

    identifier_keys.each do |key|
        field = key
        next if key == "type"
        if key =="_id"
          field = "person_identifier_id"
        end
        if identifier_keys[0] == key
            query = "#{query}#{field}"
        else
            query = "#{query},#{field}"
        end
    end


    query = "#{query}) VALUES("

    identifier_keys.each do |key|
        next if key == "type"
        value = identifier_keys[key]
        if value.blank?
          value ="NULL"
        end

        if identifier_keys[0] == key
            query = "#{query} '#{value.to_s.gsub("'","''")}'"
        else
            query = "#{query},'#{value.to_s.gsub("'","''")}'"
        end
    end


    query = "#{query})"

    SimpleSQL.query_exec(query)
  end

end
