require 'csv'

@@mapping = "#{Rails.root}/bin/scripts/migration/mapped_old_to_hq.csv"
@@mapping_person = "#{Rails.root}//bin/scripts/migration/mapped.csv"
@@olddata = "#{Rails.root}/bin/scripts/migration/persondata.csv"

password = CONFIG["crtkey"] rescue nil
password = "password" if password.blank?

$private_key = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/config/private.pem"), password)

@@status_map ={
                "Printed" =>"HQ DISPATCHED",
                "Reprinted" =>"HQ DISPATCHED",
                "Active"     => "DC COMPLETE",
                "Approved" => "HQ APPROVED"
}

@@mapped = {}

def decrypt(value)
  string = $private_key.private_decrypt(Base64.decode64(value)) rescue nil

  return value if string.nil?

  return string.strip

end

def get_nationality_id(nationality)

    result = Nationality.by_nationality.key(nationality).rows
    return result[0]['id']

end

def get_hospital_id(name)

    result = HealthFacility.by_name.key(name).rows
    return result[0]['id']

end

def get_village_id(name)

    result = Village.by_name.key(name).rows
    return result[0]['id']

end

def get_ta_id(name)

    result = TraditionalAuthority.by_name.key(name).rows
    return result[0]['id']

end

def get_distict_id(name)

    result = District.by_name.key(name).rows
    return result[0]['id']

end

def transform_data(records)

  begin
    map = CSV.foreach(@@mapping, :headers => true)
    map.collect do |row|
      old_edrs_field = row[0]
      new_edrs_field = row[1]
      new_edrs_model = row[2]
      new_edrs_model_type = row[3]
      new_edrs_model_field = row[4]

      field_array = ['','','','']
      unless old_edrs_field.blank?
        unless new_edrs_field.blank?
          @@mapped[old_edrs_field] = ["#{new_edrs_field}",'','','']
          #puts ">>>>>>>> #{old_edrs_field} == #{new_edrs_field}"

        else
          if not new_edrs_model.blank?
            @@mapped[old_edrs_field] = ['',"#{new_edrs_model}","#{new_edrs_model_type}","#{new_edrs_model_field}"]
           # puts "::::::: #{old_edrs_field} == #{eval(new_edrs_model).count} .......... #{new_edrs_field2}"

          end
        end
      else
        if not new_edrs_field.blank?
         #puts "NEW FIEELD >>> #{Person.last.send(new_edrs_field)}"

              end
        end
    end
    mapped_fields = JSON.parse(@@mapped.to_json)

    to_decrypt = ['first_name',
                  'last_name',
                  'middle_name',
                  'status',
                  'birth_certificate_number',
                  'father_first_name',
                  'father_last_name',
                  'father_middle_name',
                  'mother_first_name',
                  'mother_last_name',
                  'mother_middle_name',
                  'informant_first_name',
                  'informant_last_name',
                  'informant_middle_name',
                  'id_number',
                  'father_id_number',
                  'mother_id_number',
                  'informant_id_number'
                  ]

    (records || []).each do |doc|

       r = doc["doc"].with_indifferent_access
       
       source_fields =  r.keys

       person = Person.new

       identifiers = {}
       status = ''

    if r['_id'] != '4045a248ef5fde881f6ef6520d75aace'

       puts "Migrating doc: #{r['_id']}"

       source_fields.each do |field|
        
        next if ["_rev"].include?(field.squish)
        if mapped_fields[field].present?
           new_field = (mapped_fields[field][0] rescue '')
           if new_field.present?
             person[new_field] = to_decrypt.include?(field) ? decrypt(r[field]) : r[field]

           else
              if mapped_fields[field][2].present?
                 identifiers[mapped_fields[field][2]] = to_decrypt.include?(field) ? decrypt(r[field]) : r[field]
              else
                 status = to_decrypt.include?(field) ? decrypt(r[field]) : r[field]
              end

           end
        else

        end
       end

     district_code = (District.by_name.key(person.place_of_death_district).first.code rescue 'LL')
     person['district_code'] = district_code

     if["Home(Place of residence)"].include? r['place_of_death']
        person['place_of_death'] = "Home"
     end

     if["Hospital/Institution"].include? r['place_of_death']
        person['place_of_death'] = "Hospital"
     end

     if !r['place_of_death'].present? && !r['other_place_of_death'].present?
         person['other_place_of_death'] ="Other"
     end

     person.save
     person.reload

       if identifiers["DEATH ENTRY NUMBER"].present?
          person_identifier = PersonIdentifier.new
          person_identifier.person_record_id = person.id
          person_identifier.identifier_type = "DEATH ENTRY NUMBER"
          person_identifier.identifier = identifiers["DEATH ENTRY NUMBER"]
          district_code = (District.by_name.key(person.place_of_death_district).first.code rescue 'LL')
          person_identifier.district_code = district_code
          sort_value = (identifiers["DEATH ENTRY NUMBER"].split("/")[2] + identifiers["DEATH ENTRY NUMBER"].split("/")[1]).to_i
          person_identifier.den_sort_value = sort_value
          person_identifier.save
        end
        #Death registration Number
        if identifiers["DEATH REGISTRATION NUMBER"].present?
          person_identifier = PersonIdentifier.new
          person_identifier.person_record_id = person.id
          person_identifier.identifier_type = "DEATH REGISTRATION NUMBER"
          person_identifier.identifier = identifiers["DEATH REGISTRATION NUMBER"]
          district_code = (District.by_name.key(person.place_of_death_district).first.code rescue 'LL')
          person_identifier.district_code = district_code
          person_identifier.save
        end

        #Death registration Number
        if identifiers["National ID"].present?
          person_identifier = PersonIdentifier.new
          person_identifier.person_record_id = person.id
          person_identifier.identifier_type = "National ID"
          person_identifier.identifier = identifiers["National ID"]
          district_code = (District.by_name.key(person.place_of_death_district).first.code rescue 'LL')
          person_identifier.district_code = district_code
          person_identifier.save
        end
        #raise @@status_map[status].inspect
        if @@status_map[status].present? && person.first_name.present?
          record_status = PersonRecordStatus.new
          record_status.person_record_id = person.id
          record_status.status = @@status_map[status]
          if status == "Reprinted"
            record_status.reprint = true
          end
          record_status.district_code =  (District.by_name.key(person.place_of_death_district).first.code  rescue 'LL')
          record_status.save
        else
          record_status = PersonRecordStatus.new
          record_status.person_record_id = person.id
          record_status.status = "HQ INCOMPLETE MIGRATION"
          record_status.district_code =  (District.by_name.key(person.place_of_death_district).first.code  rescue 'LL')
          record_status.save
        end

        puts "Migrated #{person.first_name} #{person.last_name}"

        sleep 0.5
    end

   end
  puts "Records migrated so far: #{Person.count}"
  rescue Exception => e
      puts "#{e.message} >>>>>>>>>>>>>>>>>>>>"
  end
end

def fetch_source_data

   protocol = 'http'
   password = 'test'
   username = 'admini'
   port = '5984'
   db = 'edrs_death'
   host = 'localhost'
   
   records = JSON.parse(`curl -s -X GET #{protocol}://#{username}:#{password}@#{host}:#{port}/#{db}/_design/Person/_view/all?include_docs=true`)

   transform_data(records["rows"])

end

def start
  map = CSV.foreach(@@mapping, :headers => true)
  map.collect do |row|
    old_edrs_field = row[0]
    new_edrs_field = row[1]
    new_edrs_model = row[2]
    new_edrs_model_type = row[3]
    new_edrs_model_field = row[4]

    field_array = ['','','','']
    unless old_edrs_field.blank?
      unless new_edrs_field.blank?
        @@mapped[old_edrs_field] = ["#{new_edrs_field}",'','','']
        #puts ">>>>>>>> #{old_edrs_field} == #{new_edrs_field}"

      else
        if not new_edrs_model.blank?
          @@mapped[old_edrs_field] = ['',"#{new_edrs_model}","#{new_edrs_model_type}","#{new_edrs_model_field}"]
         # puts "::::::: #{old_edrs_field} == #{eval(new_edrs_model).count} .......... #{new_edrs_field2}"

        end
      end
    else
      if not new_edrs_field.blank?
       #puts "NEW FIEELD >>> #{Person.last.send(new_edrs_field)}"

            end
      end
  end

  mapped_fields = JSON.parse(@@mapped.to_json)
  #puts mapped_fields

  headers = []
  file = File.open(@@olddata).each_line do |line|
    row = line.gsub("&#39;","'").split(";");
    if row[0]=='first_name'
      headers = row
      next
    end
    identifiers ={}
    status = ''
    person = Person.new
    headers.each do |field|
         if mapped_fields[field].present?
           new_field = (mapped_fields[field][0] rescue '')
           if new_field.present?
             person[new_field] = row[headers.index(field)]
           else
              if mapped_fields[field][2].present?
                 identifiers[mapped_fields[field][2]] = row[headers.index(field)]
              else
                 status = row[headers.index(field)]
              end

           end
         else

         end

    end


    person.save
    person.reload
    #Death entry Nunmber
    if identifiers["DEATH ENTRY NUMBER"].present?
      person_identifier = PersonIdentifier.new
      person_identifier.person_record_id = person.id
      person_identifier.identifier_type = "DEATH ENTRY NUMBER"
      person_identifier.identifier = identifiers["DEATH ENTRY NUMBER"]
      district_code = (District.by_name.key(person.place_of_death_district).first.code rescue 'HQ')
      person_identifier.district_code = district_code
      sort_value = (identifiers["DEATH ENTRY NUMBER"].split("/")[2] + identifiers["DEATH ENTRY NUMBER"].split("/")[1]).to_i
      person_identifier.den_sort_value = sort_value
      person_identifier.save
     end
    #Death registration Number
    if identifiers["DEATH REGISTRATION NUMBER"].present?
      person_identifier = PersonIdentifier.new
      person_identifier.person_record_id = person.id
      person_identifier.identifier_type = "DEATH REGISTRATION NUMBER"
      person_identifier.identifier = identifiers["DEATH REGISTRATION NUMBER"]
      district_code = (District.by_name.key(person.place_of_death_district).first.code rescue 'HQ')
      person_identifier.district_code = district_code
      person_identifier.save
    end

    #Death registration Number
    if identifiers["National ID"].present?
      person_identifier = PersonIdentifier.new
      person_identifier.person_record_id = person.id
      person_identifier.identifier_type = "National ID"
      person_identifier.identifier = identifiers["National ID"]
      district_code = (District.by_name.key(person.place_of_death_district).first.code rescue 'HQ')
      person_identifier.district_code = district_code
      person_identifier.save
    end
    if @@status_map[status].present? && person.first_name.present?
      record_status = PersonRecordStatus.new
      record_status.person_record_id = person.id
      record_status.status = @@status_map[status]
      if status == "Reprinted"
        record_status.reprint = true
      end
      record_status.district_code =  (District.by_name.key(person.place_of_death_district).first.code  rescue 'HQ')
      record_status.save
    else
      record_status = PersonRecordStatus.new
      record_status.person_record_id = person.id
      record_status.status = "HQ INCOMPLETE MIGRATION"
      record_status.district_code =  (District.by_name.key(person.place_of_death_district).first.code  rescue 'HQ')
      record_status.save
    end
  end

end

#start
fetch_source_data
