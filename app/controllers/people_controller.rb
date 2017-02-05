class PeopleController < ApplicationController

	before_filter :find_person, :except => [:index, :query, :create, :new, :person_label]

  before_filter :check_if_user_admin

  before_filter :facility_info

  def new_split

  end

	def index

      @facility = facility

      @district = district

      @section = "Home"

      render :layout => "facility"

  end

  def new

	   # redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Register a record"))

     @current_nationality = Nationality.by_nationality.key("Malawian").last

	    if !params[:id].blank?

	    else

	    	@person = Person.new if @person.nil?

	    end

	    @section = "New Person"

	    render :layout => "touch"

  end

  def render_cause_of_death_page
    
  end

  def add_cause_of_death

        @person = Person.find(params[:id])

        render :layout => "touch"
    
  end

  def update_cause_of_death

      person = Person.find(params[:id])

      if person.update_attributes(params[:person])

          render :text => "Saved"

      else

          render :text => "Not Saved"

      end


  end

  def create

      person_params = params[:person]

      person_params[:created_by] = User.current_user.id

      person_params[:changed_by] = User.current_user.id

      person = Person.create_person(params)

      if !person_params[:id_number].blank? && !person_params[:id_number].nil?

            PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "National ID", 
                                      :indentifier => person_params[:id_number],
                                      :site_code => CONFIG['site_code'],
                                      :district_code => CONFIG['district_code'],
                                      :creator => User.current_user.id} )
        
      end

      if  !person_params[:birth_certificate_number].blank? && person_params[:birth_certificate_number].nil?

            PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "Birth Certificate Number", 
                                      :indentifier => person_params[:birth_certificate_number],
                                      :site_code => CONFIG['site_code'],
                                      :district_code => CONFIG['district_code'],
                                      :creator => User.current_user.id} )
        
      end



      #redirect_to "/people/view/#{person.id.to_s}" and return

      redirect_to "/people/finalize_create/#{person.id}" and return

        	
  end

  def search_similar_record

      values = [
                params[:first_name].soundex, 
                params[:last_name].soundex, 
                params[:gender], 
                params[:date_of_death],
                params[:birthdate],
                params[:place_of_death],
                params[:informant_first_name].soundex,
                params[:informant_last_name].soundex]

      people = Person.by_demographics_and_informant.key(values).each

      if people.count == 0

        render :text => {:response => false}.to_json
      else

        render :text => {:response => people}.to_json
      end 
  end

  def finalize_create

      person = Person.find(params[:id])

      facility_number = PersonIdentifier.by_person_record_id_and_identifier_type.key([params[:id],"FACILITY NUMBER"]).first

      if false && CONFIG['facility_code'] && !CONFIG['facility_code'].blank?  && !facility_number.present?

          NationalIdNumberCounter.assign_serial_number(person,facility.facility_code)
          
          sleep 1

          person.reload

          print_registration(person) and return

          redirect_to "/people/view"

      end

      redirect_to "/people/view"
    
  end

  def view

      @section = "View"

      @status = "NEW"

      @next_url = "/people/view"

      render :layout => "facility"
      
  end

  def all

      people = Person.all

      render :text => people.to_json
    
  end

  def search_by_status
    status = params[:status]
    page = params[:page] rescue 1
    size = params[:size] rescue 7
    people = []
    if params[:status] == "DC PENDING"
         record_status = [params[:status],"DC REJECTED"]
    else
         record_status = [params[:status]]
    end
   
    PersonRecordStatus.by_record_status.keys(record_status).page(page).per(size).each do |status|
      
        person = status.person

       people << person_selective_fields(person)
      
    end

    render  :text => people.to_json
  end

  def search

    if params[:search_criteria].present?

       @section ="Search Results"

    else  
      @section ="Search Criteria"
    end

    render :layout => "facility"
  end

  def search_by_fields

    status = params[:status]
    page = params[:page] rescue 1
    size = params[:size] rescue 7
    people = []

    if params[:death_entry_number].present?
   
      PersonIdentifier.by_identifier.key(params[:death_entry_number]).page(page).per(size).each do |pid|
        
          person = pid.person

          people << person_selective_fields(person)
      end               
      
    end

    if params[:death_registration_number].present?

       PersonIdentifier.by_identifier.key(params[:death_registration_number]).page(page).per(size).each do |pid|

          person = pid.person

          people << person_selective_fields(person)

       end
    end

    render  :text => people.to_json
  end

  def show

      @person = Person.find(params[:id])

      @status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

      @person_place_details = place_details(@person)

      @section = "Show"

      @burial_report = BurialReport.by_person_record_id.key(params[:id]).first

      @comments = Audit.by_record_id_and_audit_type.keys([[params[:id],"DC PENDING"],
                                                          [params[:id],"DC REJECTED"],
                                                          [params[:id],"HQ REJECTED"],
                                                          [params[:id],"DC REAPPROVED"],
                                                          [params[:id],"DC DUPLICATE"],
                                                          [params[:id],"RESOLVE DUPLICATE"]]).each

      render :layout => "facility"
  	
  end
  def find
      person = Person.find(params[:id])

      render :text => person_selective_fields(person).to_json
  end

  def edit

  	
  end

  def edit_field

      @person = Person.find(params[:id])

      @helpText = params[:field].humanize

      @field = "person[#{params[:field]}]"

      render :layout => "touch"

  end

  def update_field

      person = Person.find(params[:id])

      person.update_person(params[:id],params[:person])

      redirect_to "/people/view/#{params[:id]}"
    
  end

  def get_first_names
      entry = params["search"].soundex rescue nil
        data = Person.by_first_name_code.startkey(entry).endkey("#{entry}\ufff0").limit(10) rescue nil
        if data.present?
		  		render :text => data.collect{ |w| "<li>#{w.first_name}" }.uniq.join("</li>")+"</li>"
		  	else
		    	render :text => "<li></li>"
      	end
  end

  def get_last_names
        entry = params["search"].soundex rescue nil
        data = Person.by_last_name_code.startkey(entry).endkey("#{entry}\ufff0").limit(10) rescue nil
        if data.present?
          render :text => data.collect{ |w| "<li>#{w.last_name}" }.uniq.join("</li>")+"</li>"
        else
          render :text => "<li></li>"
        end
  end

  def districts
  
    if params[:place].present? && params[:place] == "Hospital/Institution"

        cities = ["Lilongwe City", "Blantyre City", "Zomba City", "Mzuzu City"]

        district = District.by_name.each

        render :text => district.collect { |w| "<li>#{w.name}" unless cities.include? w.name }.join("</li>")+"</li>"
    
    else
        district = District.by_name.each

        render :text => district.collect { |w| "<li >#{w.name}" }.join("</li>")+"</li>"
    
    end
  end

  def facilities

    district_param = params[:district] || '';

    if !district_param.blank?

      district = District.by_name.key(district_param.to_s).first

      facilities = HealthFacility.by_district_id.keys([district.id]).each
    else
      facilities = HealthFacility.by_name.each
    end

    list = []
    facilities.each do |f|
      if !params[:search_string].blank?
        list << f if f.name.match(/#{params[:search_string]}/i)
      else
        list << f
      end
    end

    render :text => list.collect { |w| "<li>#{w.name}" }.join("</li>")+"</li>"
  end

  def nationalities
    nationalities = Nationality.all
    malawi = Nationality.by_nationality.key("Malawian").last
    list = []
    nationalities.each do |n|
      if !params[:search_string].blank?
        list << n if n.nationality.match(/#{params[:search_string]}/i)
      else
        list << n
      end
    end

    if "Malawian".match(/#{params[:search_string]}/i) || params[:search_string].blank?
      list = [malawi] + list
    end

    render :text => list.uniq.collect { |w| "<li>#{w.nationality}" }.join("</li>")+"</li>"

  end

  def tas

    result = []

    if !params[:district].blank?

      district = District.by_name.key(params[:district].strip).first

      result = TraditionalAuthority.by_district_id.key(district.id)
    else

       result = TraditionalAuthority.by_district_id

    end

    list = []
    result.each do |r|
      if !params[:search_string].blank?
        list << r if r.name.match(/#{params[:search_string]}/i)
      else
        list << r
      end
    end

    render :text => list.collect { |w| "<li>#{w.name}" }.join("</li>")+"</li>"
  end


  def villages

    result = []

    if !params[:district].blank? and !params[:ta].blank?

      district = District.by_name.key(params[:district].strip).first

      ta =TraditionalAuthority.by_district_id_and_name.key([district.id, params[:ta]]).first

      result = Village.by_ta_id.key(ta.id.strip)

    else
       result = Village.by_ta_id

    end

    list = []
    result.each do |r|
      if !params[:search_string].blank?
        list << r if r.name.match(/#{params[:search_string]}/i)
      else
        list << r
      end
    end

    render :text => list.collect { |w| "<li>#{w.name}" }.join("</li>")+"</li>"

  end

  def print_id_label

    print_string = person_label(params[:person_id]) #rescue (raise "Unable to find child (#{params[:child_id]}) or generate a national id label for that patient")
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:person_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end


  def person_label(person_id)

    @person = Person.find(person_id)
    sex =  @person.gender.match(/F/i) ? "(F)" : "(M)"

    place_of_death = @person.hospital_of_death  rescue ""
    place_of_death = @person.place_of_death if place_of_death.blank?

    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{@person.facility_serial_number}")
    label.draw_multi_text("ID Number: #{@person.facility_serial_number}")
    label.draw_multi_text("Deceased: #{@person.first_name + ' ' + @person.last_name} #{sex}")
    label.draw_multi_text("DOB: #{@person.birthdate}")
    label.draw_multi_text("DOD: #{@person.date_of_death}")
    label.draw_multi_text("Death Place: #{place_of_death + '/' + @person.place_of_death_district}")
    label.draw_multi_text("Informant: #{@person.informant_first_name + ' ' + @person.informant_last_name}")
    label.draw_multi_text("Date of Reporting: #{@person.acknowledgement_of_receipt_date.strftime('%d/%B/%Y')}")
    label.print(1)
  end

  def print_registration(person)

    redirect = "/people/view"

    print_and_redirect("/people/print_id_label?person_id=#{person.id}", redirect)
    
  end

  protected

  def find_person

    @person = Person.find(params[:id]) rescue nil

    @person = Person.new if @person.nil?

    @facility = facility

    @district = district

    @current_nation = current_nationality

    if CONFIG['site_type'] =="facility"

          @facility_type = "Facility"

    else

            @facility_type = "DC"

    end

  end

  def person_selective_fields(person)

      den = PersonIdentifier.by_person_record_id_and_identifier_type.key([person.id,"DEATH ENTRY NUMBER"]).first

      return {
                      id: person.id,
                      first_name: person.first_name, 
                      last_name: person.last_name ,
                      middle_name:  (person.middle_name rescue ""),
                      gender: person.gender,
                      birthdate: person.birthdate,
                      date_of_death: person.date_of_death,
                      place_of_death: person.place_of_death,
                      hospital_of_death:(person.hospital_of_death rescue ""),
                      other_place_of_death: person.other_place_of_death,
                      place_of_death_village: (person.place_of_death_village rescue ""),
                      place_of_death_ta: (person.place_of_death_ta rescue ""),
                      place_of_death_district: (person.place_of_death_district rescue ""),
                      mother_first_name: person.mother_first_name,
                      mother_last_name: person.mother_last_name,
                      mother_middle_name: person.mother_middle_name,
                      father_first_name: person.father_first_name,
                      father_last_name: person.father_last_name,
                      father_middle_name: person.father_middle_name,
                      informant_first_name: person.informant_first_name,
                      informant_last_name: person.informant_last_name,
                      informant_middle_name: person.informant_middle_name,
                      home_village: (person.home_village  rescue ""),
                      home_ta:  (person.home_ta rescue ""),
                      home_district: (person.home_district rescue ""),
                      home_country:  ( person.home_country rescue ""),
                      den: (den.identifier rescue ""),
                      status: (person.status),
                      nationality: person.nationality
                     }
  end

end
