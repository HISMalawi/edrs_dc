
sql = "select person_record_id, count(person_record_id) as count from person_identifier where identifier_type = 'DEATH ENTRY NUMBER' AND created_at LIKE '%2019%'  group by person_record_id order by count desc limit 1000;"
connection = ActiveRecord::Base.connection

dens = connection.select_all(sql).as_json

person_counter = 0

dens.each do |d|
	next if d['count'].to_i == 1
	puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	person = Person.find(d['person_record_id']) 
	identifiers = RecordIdentifier.where(person_record_id: person.id, identifier_type:'DEATH ENTRY NUMBER')
	counter = 0
	identifiers.each do |i|
		denparts = i.identifier.split("/")
		district_from_den = denparts[0] 
		if district_from_den != i.district_code || person.district_code != i.district_code
			next if ['HQ PRINTED', 'HQ DISPACHED'].include?(person.status)
			a =  PersonIdentifier.find(i.person_identifier_id)
			i.destroy
			a.destroy
		else
			 denrecord = DeathEntryNumber.where(person_record_id:person.id, district_code: denparts[0], value: denparts[1].to_i, year: denparts[2].to_i)
			 if denrecord.present?
			 	puts "Don't delete"
			 else
			 	i.destroy
			 end
		end
		counter = counter + 1
	end
	puts ">>>>>>>>>>>>>>> #{person.id} >>>>>>>>>>>>>>>>>>"
	person_counter = person_counter + 1
end

count =  RecordStatus.where("status LIKE '%HQ%' and voided = 0 and district_code ='LL'").count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	RecordStatus.where("status LIKE '%HQ%' and voided = 0 and district_code ='LL'").limit(pagesize).offset(page.to_i * pagesize.to_i).each do |status|
		person = status.person

		den = PersonIdentifier.by_person_record_id_and_identifier_type.key([person.id, "DEATH ENTRY NUMBER"]).first
		if den.blank?
			
			puts "Assigning DEN"
			denrecord = DeathEntryNumber.where(person_record_id: person.id).first
			if denrecord.present?
				false_den = PersonIdentifier.find("#{denrecord.district_code}/#{denrecord.value.to_s.rjust(7,"0")}/#{denrecord.year}")
				false_den.destroy
				denrecord.push_to_couch
			else
				PersonIdentifier.assign_den(person, status.creator)
			end
			
		end
	end

	puts page
	page = page + 1
end