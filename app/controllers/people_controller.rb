class PeopleController < ApplicationController

	before_filter :find_person, :except => [:index, :query, :create, :new, :person_label]

  before_filter :check_if_user_admin

  before_filter :facility_info

  def new_split
      render :layout => false
  end

	def index

      @facility = facility

      @district = district

      @section = "Home"

      render :layout => "landing"

  end

  def new_person_type
      @section = "Registration Categories"
      @facility = facility
      @district = district
      @targeturl = "/"
      render :layout => "landing" 
  end

  def new
	   #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Register a record"))
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

      if !person_params[:barcode].blank? && !person_params[:barcode].nil?

            PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "Form Barcode", 
                                      :identifier => person_params[:barcode].to_s,
                                      :site_code => CONFIG['site_code'],
                                      :district_code => CONFIG['district_code'],
                                      :creator => User.current_user.id})
        
      end

      if !person_params[:id_number].blank? && !person_params[:id_number].nil?

            PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "National ID", 
                                      :identifier => person_params[:id_number],
                                      :site_code => CONFIG['site_code'],
                                      :district_code => CONFIG['district_code'],
                                      :creator => User.current_user.id} )
        
      end

      if  !person_params[:birth_certificate_number].blank? && person_params[:birth_certificate_number].nil?

            PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "Birth Certificate Number", 
                                      :identifier => person_params[:birth_certificate_number],
                                      :site_code => CONFIG['site_code'],
                                      :district_code => CONFIG['district_code'],
                                      :creator => User.current_user.id} )
        
      end

      #create status
       if Person.duplicate.nil?
          PersonRecordStatus.create({
                                      :person_record_id => person.id.to_s,
                                      :status => "NEW",
                                      :district_code =>  person.district_code,
                                      :created_by => User.current_user.id})
        else
          
          change_log = [{:duplicates => Person.duplicate.to_s}]

          Audit.create({
                          :record_id  => person.id.to_s,
                          :audit_type => "POTENTIAL DUPLICATE",
                          :reason     => "Record is a potential",
                          :change_log => change_log
          })
          PersonRecordStatus.create({
                                      :person_record_id => person.id.to_s,
                                      :status => "DC POTENTIAL DUPLICATE",
                                      :district_code => person.district_code,
                                      :created_by => User.current_user.id})

          Person.duplicate = nil

        end

      Sync.create({
                    :person_record_id => person.id.to_s,
                    :record_status => "NEW"
      })

      #redirect_to "/people/view/#{person.id.to_s}" and return
      #redirect_to "/people/finalize_create/#{person.id}" and return
      redirect_to "/people/view"

        	
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

      @search = true

      render :layout => "landing"
      
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
    if params[:status] == "HQ REJECTED"
         #record_status = [params[:status],"HQ CONFIRMED INCOMPLETE"]
         record_status = [params[:status]]
    else
         record_status = [params[:status]]
    end
   
    PersonRecordStatus.by_record_status.keys(record_status).page(page).per(size).each do |status|
      
        person = status.person

        person["den"] = person.den rescue ""

       people << person
      
    end

    render  :text => people.to_json
  end

  def search

    if params[:search_criteria].present?

      if params[:search_criteria] == "General Search"
      end

       @section ="Search Results"

       @next_url = "/"

       render :layout => "landing"

    else  
      @section ="Search Criteria"
      render :layout => "touch"
    end

    
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
    if params[:barcode].present?
   
      PersonIdentifier.by_identifier.key(params[:barcode]).page(page).per(size).each do |pid|
        
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

      @section = "View"

      @burial_report = BurialReport.by_person_record_id.key(params[:id]).first

      @comments = Audit.by_record_id_and_audit_type.keys([[params[:id],"DC PENDING"],
                                                          [params[:id],"DC REJECTED"],
                                                          [params[:id],"HQ REJECTED"],
                                                          [params[:id],"DC REAPPROVED"],
                                                          [params[:id],"DC DUPLICATE"],
                                                          [params[:id],"RESOLVE DUPLICATE"],
                                                          [params[:id],"HQ POTENTIAL INCOMPLETE"],
                                                          [params[:id],"HQ INCOMPLETE"],
                                                          [params[:id],"HQ CONFIRMED INCOMPLETE"],
                                                          [params[:id],"DC AMEND"]

                                                          ]).each

      render :layout => "landing"
  	
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
  
    if params[:place].present? && params[:place] == "Health Facility"

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
      if n.nationality =="Unknown"
          next if params[:special].blank?
      end
      if !params[:search_string].blank?
        list << n if n.nationality.match(/#{params[:search_string]}/i)
      else
        list << n
      end
    end

    nations = list.collect {|c| c.nationality}.sort
     if "Malawian".match(/#{params[:search_string]}/i) || params[:search_string].blank?
      nations = [malawi.nationality] + nations
    end
    render :text => nations.uniq.collect { |c| "<li>#{c}" }.join("</li>")+"</li>"

  end

  def countries
    countries = Country.all
    malawi = Country.by_country.key("Malawi").last
    list = []
    countries.each do |n|
      if n.name =="Unknown"
          next if params[:special].blank?
      end
      if n.name =="Malawi"
          next unless params[:exclude].blank?
      end
      if !params[:search_string].blank?
        list << n if n.name.match(/#{params[:search_string]}/i)
      else
        list << n
      end
    end

    if ("Malawi".match(/#{params[:search_string]}/i) || params[:search_string].blank?) && params[:exclude] != "Malawi"
      list = [malawi] + list
    end

    countries = list.collect {|c| c.name}.sort

    if ("Malawi".match(/#{params[:search_string]}/i) || params[:search_string].blank?) && params[:exclude] != "Malawi"
      countries = [malawi.name] + countries
    end

    render :text => countries.uniq.collect { |c| "<li>#{c}" }.join("</li>")+"</li>"

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

    render :text => list.collect { |w| "<li>#{w.name}" }.join("</li>")+"</li><li>Other</li>"
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

    render :text => list.collect { |w| "<li>#{w.name}" }.join("</li>")+"</li><li>Other</li>"

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

  def global_phone_validation

    number = params[:value].sub("plus", "+")
    number = "" if !number.match(/\d/)
    parsed = GlobalPhone.parse(number) rescue nil

    result = {
        "national_format" => (parsed.national_format rescue ""),
        "international_format" => (parsed.international_format rescue ""),
        "country" => (Country.by_iso.key(parsed.territory.name).last.name rescue ""),
        "valid" => (parsed.valid? rescue false)
    }

    render :text => result.to_json
  end
  def search_barcode
      if params[:barcode].present?
        count = PersonIdentifier.by_identifier.key(params[:barcode]).count  
        if count >= 1
            render :text => {:response =>  PersonIdentifier.by_identifier.key(params[:barcode]).first.person_record_id}.to_json
        else
           render :text => {:response => false}.to_json
        end            
      end
  end
########## Render sync status page ##################################################################################################################
  def view_sync
   @site_type = CONFIG['site_type'].to_s
   if @site_type == "dc"
      @section ="Synced to HQ"
      @url = "/dc/query_hq_sync"
    else
      @section ="Synced to DC"
      @url = "/people/query_dc_sync"
    end
    @next_url = "/people/sync"
    render :layout => "landing"
    #render :template =>"/people/view_sync"
  end
###################################################################################################################################################
###### Query sync status for records sent to DC####################################################################################################
  
  def query_dc_sync
    page = params[:page] rescue 1
      size = params[:size] rescue 7
      people = []
    Sync.by_district_code.key(CONFIG['district_code'].to_s).page(page).per(size).each do |sync|
      person = sync.person
      person_details = {
            id:           person.id,
            first_name:   person.first_name,
            last_name:    person.last_name,
            middle_name:  person.middle_name,
            gender:       person.gender,
            date_reported:  person.created_at,
            record_status:  sync.record_status,
            dc_sync_status:  sync.dc_sync_status,
            hq_sync_status:  sync.hq_sync_status
      }
      people << person_details
    end
    render :text => people.to_json
  end
######################################################################################################################

################ View Special cases by type ##########################################################################
  def view_special
    @section = params[:registration_type]
    @registration_type = params[:registration_type]
    @next_url = "/dc/special_cases"
    @search = true
    render :layout => "landing"
      
  end
################# Query special cases by their type #####################################################################

  def query_registration_type
      page = params[:page] rescue 1
      size = params[:size] rescue 7
      render :text => Person.by_registration_type.key(params[:registration_type]).page(page).per(size).each.to_json
  end

#########################################################################################################################

def view_special_case_and_printed
    @section = "Printed Special Cases"
    @special_case_print = ["HQ CLOSED","HQ DISPATCHED"]
    @next_url = "/dc/special_cases"
    @search = true
    render :layout => "landing"
end

################## Query Specail case and their status###################################################################
  def query_registration_type_and_printed
      page = params[:page] rescue 1
      size = params[:size] rescue 7
      keys = []
      special_cases = ["Unnatural Deaths","Unclaimed bodies","Missing Persons","Deaths Abroad"]
      special_cases.each do |special_case|
          keys << [special_case,"HQ CLOSED"]
          keys << [special_case,"HQ DISPATCHED"]
      end
      people =  PersonRecordStatus.registration_type_and_recent_status.keys(keys).page(page).per(size).each
      render :text =>people.to_json
  end
  #######################################################################################################################
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
                      current_village: (person.current_village  rescue ""),
                      current_ta:  (person.current_ta rescue ""),
                      current_district: (person.current_district rescue ""),
                      current_country:  ( person.current_country rescue ""),
                      den: (den.identifier rescue ""),
                      status: (person.status),
                      nationality: person.nationality
                     }
  end

end
