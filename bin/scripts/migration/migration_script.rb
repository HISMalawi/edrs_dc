require 'csv'

$debug_variable = ""
$id = ""
$person_rec = ""
@dump_files = "#{Rails.root}/app/assets/data/"

$mapping = "#{Rails.root}/bin/scripts/migration/mapped_old_to_hq.csv"
$mapping_person = "#{Rails.root}/bin/scripts/migration/mapped.csv"
$olddata = "#{Rails.root}/bin/scripts/migration/persondata.csv"

password = CONFIG["crtkey"] rescue nil
password = "password" if password.blank?

$docs_with_issues = ['2381037872008bd526c50803e48a8541',
                     '23bb787af2de33cf1c3b94fb4164473f',
                     'a1f8cfc17eaed9ef9a565319f353d84b',
                     '0499759122205161dd74e70c239dcb19',
                     '086d76023d215701f7b430f563ba2386',
                     '25e2b4e59786a90bf54b6418ffff0c4f',
                     '3a2f7759f2b1581211fd6cc1fb853d4b',
                     '3a2f7759f2b1581211fd6cc1fb854245',
                     '3b8950b942854c84b27fa8711edfc791',
                     '3f69ebd631c6a88fcfceb451f8d0f378',
                     '4045a248ef5fde881f6ef6520d75aace',
                     '4c9423434d80b44384e836d6af9236a9',
                     '4d7466ce4980b01ac80d3d0dfdcd382c',
                     '4f7c4ffb2f4bc5197521961c9f491ab5',
                     '5643e09f0494a24918c34f6650c57ab3',
                     '56d72abbf130cda0c708165391dc176',
                     '56d72abbf130cda0c708165391dc1769',
                     '571df3b3e2fe1f0a711efee6c5a46e9c',
                     '66a4a7ad9c231650ed73bdcfdb35d799',
                     '683b474552a375211e6261dafae37bb1',
                     '6959d4a1571d4e7348fba6832d399f6f',
                     '7d5a55d4deca257dd7d3d0e8994a8747',
                     '82a89cb4e21f757eca091c460207faee',
                     '8a41f24cc64259df0fe39af41edf3f8a',
                     '9244f706eb4f2ca7ff9e2dde63894436',
                     '9343307ee2783c47bfa17de00e8b19a9',
                     '9343307ee2783c47bfa17de00e8b41ab',
                     '9343307ee2783c47bfa17de00e8b4e36',
                     '99c1e61c0f708f0fbbd095dadfc5b6a6',
                     'a09f55fb3a312f859a82e2cbe6476caf'
                     'a93c70f1d91e5743069eef75a97916d3']

$private_key = OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/config/private.pem"), password)

$status_map ={
                "Printed" =>"HQ DISPATCHED",
                "Reprinted" =>"HQ DISPATCHED",
                "Active"     => "DC COMPLETE",
                "Approved" => "HQ APPROVED"
}

$mapped = {}

def decrypt(value)
  string = $private_key.private_decrypt(Base64.decode64(value)) rescue nil

  return value if string.nil?

  return string.strip

end

def get_nationality_id(nationality)

    result = Nationality.by_nationality.key(nationality).rows
    return result[0]['id']

end

def new_den(identifiers,current_den)

   identifiers = identifiers.each_with_object(Hash.new(0)){|t,count| count[t] += 1}
   t = (identifiers[current_den].to_i > 1? identifiers[current_den].to_i + 1 : 1)

   return current_den + "-" + t.to_s
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
    map = CSV.foreach($mapping, :headers => true)
    map.collect do |row|
      old_edrs_field = row[0]
      new_edrs_field = row[1]
      new_edrs_model = row[2]
      new_edrs_model_type = row[3]
      new_edrs_model_field = row[4]

      field_array = ['','','','']
      unless old_edrs_field.blank?
        unless new_edrs_field.blank?
          $mapped[old_edrs_field] = ["#{new_edrs_field}",'','','']
          #puts ">>>>>>>> #{old_edrs_field} == #{new_edrs_field}"

        else
          if not new_edrs_model.blank?
            $mapped[old_edrs_field] = ['',"#{new_edrs_model}","#{new_edrs_model_type}","#{new_edrs_model_field}"]
           # puts "::::::: #{old_edrs_field} == #{eval(new_edrs_model).count} .......... #{new_edrs_field2}"

          end
        end
      else
        if not new_edrs_field.blank?
         #puts "NEW FIEELD >>> #{Person.last.send(new_edrs_field)}"

              end
        end
    end

    mapped_fields = JSON.parse($mapped.to_json)

    to_decrypt = ['first_name',
                  'last_name',
                  'middle_name',
                  'status',
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

    if !$docs_with_issues.include? r['_id']

       puts "Migrating doc: #{r['_id']}"

       $debug_variable = r['_id']

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
     
     if r['place_of_death_district'].present?
       person['district_code'] = District.by_name.key(r['place_of_death_district']).first.id
     end
 
     person.save
     person.reload

     $person_rec = Person.find(person.id)
     $id = person.id

   
        #if $person_rec['_id'] != $id

           if identifiers["DEATH ENTRY NUMBER"].present?

              puts "================================= Saving DEN for   #{person.id}"

              identifiers_present = PersonIdentifier.by_identifier.keys().each

              if identifiers_present.include? identifiers["DEATH ENTRY NUMBER"]

                 puts " Duplicate DEN found! >>>>>>>>>>>>>>> Resolving ..."
                 identifiers["DEATH ENTRY NUMBER"] = new_den(identifiers_present,identifiers["DEATH ENTRY NUMBER"])
                 puts ".........................."
                 puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> DEN Resolved!"
              end

              person_identifier = PersonIdentifier.new
              person_identifier.person_record_id = person.id
              person_identifier.identifier_type = "DEATH ENTRY NUMBER"
              person_identifier.identifier = identifiers["DEATH ENTRY NUMBER"]
              district_code = (District.by_name.key(person.place_of_death_district).first.code rescue 'LL')
              person_identifier.district_code = district_code
              sort_value = (identifiers["DEATH ENTRY NUMBER"].split("/")[2] + identifiers["DEATH ENTRY NUMBER"].split("/")[1]).to_i
              person_identifier.den_sort_value = sort_value

              person_identifier.save

              puts "=========================== DEN for   #{person.id}   successfully saved ==========="
            end
        #else
            #$id = $id + ","
            #{}`echo -n '#{$id}' >> #{@dump_files}duplicate_docs.txt`
        #end
        #Death registration Number
        if identifiers["DEATH REGISTRATION NUMBER"].present?

          identifiers_present = PersonIdentifier.by_identifier.keys().each

            if identifiers_present.include? identifiers["DEATH REGISTRATION NUMBER"]

                 puts " Duplicate DRN found! >>>>>>>>>>>>>>> Migration will abort ... Doc id: #{$person_rec['_id']}"
                 puts " >>>>>>>>>>>>>>> Resolving ..."
                 identifiers["DEATH REGISTRATION NUMBER"] = new_den(identifiers_present,identifiers["DEATH REGISTRATION NUMBER"])
                 puts ".........................."
                 puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> DRN Resolved!"
            end

          person_identifier = PersonIdentifier.new
          person_identifier.person_record_id = person.id
          person_identifier.identifier_type = "OLD DEATH REGISTRATION NUMBER"
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
        #raise $status_map[status].inspect
        if $status_map[status].present? && person.first_name.present?

          record_status = PersonRecordStatus.new
          record_status.person_record_id = person.id
          record_status.status = $status_map[status]
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

      puts "#{e.message} >>>>>>>>>>>>>>>>>>>>#{$id} >>>>>>>>>>>>>>>>>>> Doc id: #{$debug_variable}" 
       
  end
end

def fetch_source_data

   protocol = MIGRATION['protocol']
   password = MIGRATION['password']
   username = MIGRATION['username']
   port = MIGRATION['port']
   db = MIGRATION['db']
   host = MIGRATION['host']
   
   records = JSON.parse(`curl -s -X GET #{protocol}://#{username}:#{password}@#{host}:#{port}/#{db}/_design/Person/_view/all?include_docs=true`)

   transform_data(records["rows"])

end

def start
  map = CSV.foreach($mapping, :headers => true)
  map.collect do |row|
    old_edrs_field = row[0]
    new_edrs_field = row[1]
    new_edrs_model = row[2]
    new_edrs_model_type = row[3]
    new_edrs_model_field = row[4]

    field_array = ['','','','']
    unless old_edrs_field.blank?
      unless new_edrs_field.blank?
        $mapped[old_edrs_field] = ["#{new_edrs_field}",'','','']
        #puts ">>>>>>>> #{old_edrs_field} == #{new_edrs_field}"

      else
        if not new_edrs_model.blank?
          $mapped[old_edrs_field] = ['',"#{new_edrs_model}","#{new_edrs_model_type}","#{new_edrs_model_field}"]
         # puts "::::::: #{old_edrs_field} == #{eval(new_edrs_model).count} .......... #{new_edrs_field2}"

        end
      end
    else
      if not new_edrs_field.blank?
       #puts "NEW FIEELD >>> #{Person.last.send(new_edrs_field)}"

            end
      end
  end

  mapped_fields = JSON.parse($mapped.to_json)
  #puts mapped_fields

  headers = []
  file = File.open($olddata).each_line do |line|
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
    if $status_map[status].present? && person.first_name.present?
      record_status = PersonRecordStatus.new
      record_status.person_record_id = person.id
      record_status.status = $status_map[status]
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

start
fetch_source_data

