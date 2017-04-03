require 'csv'

@@mapping = "#{Rails.root}/bin/scripts/migration/mapped_old_to_hq.csv"
@@mapping_person = "#{Rails.root}//bin/scripts/migration/mapped.csv"
@@olddata = "#{Rails.root}/bin/scripts/migration/persondata.csv"
@@status_map ={
                "Printed" =>"HQ DISPATCHED",
                "Reprinted" =>"HQ DISPATCHED",
                "Active"     => "DC COMPLETE",
                "Approved" => "HQ APPROVED"
}

@@mapped = {}

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

start
