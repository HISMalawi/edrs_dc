
def format_content(record)
	content = "#{record[:first_name]} #{record[:last_name]}"
	content = content +" #{record[:birthdate].to_date.strftime("%Y-%m-%d")}"
	content = content +" #{record[:sex]}"
	content = content +" #{record[:district_of_birth]}"
	content = content +" #{record[:mother_first_name]} #{record[:mother_last_name]}"
	return content
end
def write_csv_header(file, header)
    CSV.open(file, 'w' ) do |exporter|
        exporter << header
    end
end

def write_csv_content(file, content)
    CSV.open(file, 'a+' ) do |exporter|
        exporter << content
    end
end
child = {
			first_name: "Mary",
			last_name: "Banda",
			birthdate: "27/Sep/2017",
			sex: "FEMALE",
			district_of_birth: "Balaka",
			mother_first_name: "Jennifer",
			mother_last_name: "Banda"
}
records = []
records << child

child_name = [['Mary','Banda'],['Merry','Banda'],['Maria','Banda'],['Mary','Bandawe'],['Harry','Banda'],['Marth','Banda']]
mother_name =[['Jennifer','Banda'],['Jenifer','Banda'],['Jenifer','Bandason'],['Jane','Banda'],['Jennifer','Bandawe'],['Jennifer','Band'], ['Jean','Banda'],['Jean','Bandason']]
gender = ['MALE','FEMALE']
districts = ["Blantyre","Ntcheu"]

#change the district of the original record
districts.each do |district|
	records << {
			first_name: child[:first_name],
			last_name: child[:last_name],
			birthdate: child[:birthdate],
			sex: child[:sex],
			district_of_birth: district,
			mother_first_name: child[:mother_first_name],
			mother_last_name: child[:mother_last_name]
	}
end

#change birthdate for five
birthdates = ["28/Sep/2017","27/Sep/2016","27/Aug/2017"]
birthdates.each do |birthdate|
	
	records << {
			first_name: child[:first_name],
			last_name: child[:last_name],
			birthdate: birthdate,
			sex: child[:sex],
			district_of_birth: "Balaka",
			mother_first_name: child[:mother_first_name],
			mother_last_name: child[:mother_last_name]
	}
end

#change gender
gender.each do |g|
	records << {
			first_name: child[:first_name],
			last_name: child[:last_name],
			birthdate: child[:birthdate],
			sex: g,
			district_of_birth: "Balaka",
			mother_first_name: child[:mother_first_name],
			mother_last_name: child[:mother_last_name]
	}
end

#swaping childs first name with last name
records << {
			first_name: child_name[0][1],
			last_name: child_name[0][0],
			birthdate: child[:birthdate],
			sex: child[:sex],
			district_of_birth: "Balaka",
			mother_first_name: child[:mother_first_name],
			mother_last_name: child[:mother_last_name]
		}

#swaping mother firt name with last name

records << {
			first_name: child[:first_name],
			last_name: child[:last_name],
			birthdate: child[:birthdate],
			sex: child[:sex],
			district_of_birth: "Balaka",
			mother_first_name: mother_name[0][1],
			mother_last_name: mother_name[0][0]
	}

#swaping mothers name with childs name
records << {
			first_name: mother_name[0][1],
			last_name: mother_name[0][0],
			birthdate: child[:birthdate],
			sex: child[:sex],
			district_of_birth: "Balaka",
			mother_first_name: child_name[0][1],
			mother_last_name: child_name[0][0]
	}
#Generate record as they using random sampling 
for i in 0..50
	records << {
			first_name:child_name[rand(child_name.count - 1)][0],
			last_name: child_name[rand(child_name.count - 1)][1],
			birthdate: child[:birthdate],
			sex: gender.sample,
			district_of_birth: "Balaka",
			mother_first_name: mother_name[rand(mother_name.count - 1)][0],
			mother_last_name: mother_name[rand(mother_name.count - 1)][1]
	}
end

for i in 0..100
	records << {
			first_name:[child_name[rand(child_name.count - 1)][0],Faker::Name.first_name].sample,
			last_name: [child_name[rand(child_name.count - 1)][1],Faker::Name.last_name].sample,
			birthdate: birthdates.sample,
			sex: gender.sample,
			district_of_birth: districts.sample,
			mother_first_name: [mother_name[rand(mother_name.count - 1)][0],Faker::Name.first_name].sample,
			mother_last_name: [mother_name[rand(mother_name.count - 1)][1],Faker::Name.last_name].sample
	}
end
rec_string = []
records.each do |rec|
	rec_string << format_content(rec)
end
write_csv_header("#{Rails.root}/db/whites.csv", ['Content', 'Percentage'])
rec_string.uniq.each do |rec|
	write_csv_content("#{Rails.root}/db/whites.csv", [rec, (WhiteSimilarity.similarity(format_content(child),rec) * 100)])
	puts "#{rec}  #{WhiteSimilarity.similarity(format_content(child),rec) * 100}"
end
