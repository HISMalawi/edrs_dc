require "rails"
class PersonService
	def self.qr_code_data(person)
	    date_registered = person.created_at
	    PersonRecordStatus.by_person_record_id.key(person.id).each.sort_by{|s| s.created_at}.each do |state|
	      if state.status == "HQ ACTIVE"
	          date_registered = state.created_at
	          break;
	      end
	    end
	    str = "05~#{person.npid}-#{person.den}-#{person.drn}"
	    str += "~#{person.person_name}~#{person.birthdate.to_date.strftime("%d-%b-%Y")}~#{person.gender.first}"
	    str += "~#{person.nationality}"    
	    str += "~#{person.date_of_death.to_date.strftime("%d-%b-%Y")}"
	    str += "~#{person.printable_place_of_death}"
	    str += ("~#{person.mothers_name}" rescue '~')
	    str += ("~#{person.fathers_name}" rescue '~')
	    str += ("~#{date_registered.to_date.strftime("%d-%b-%Y")}" rescue nil)

	    str
  	end
end