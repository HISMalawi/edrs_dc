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

      person = Person.create(person_params);

      PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "NEW",
                                  :district_code => CONFIG['district_code'],
                                  :created_by => User.current_user.id});

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

  def finalize_create

      person = Person.find(params[:id])

      status = PersonIdentifier.by_person_record_id_and_identifier_type.key([params[:id],"FACILITY NUMBER"]).first

      if CONFIG['facility_code'] && !CONFIG['facility_code'].blank?  && !status.present?

          NationalIdNumberCounter.assign_serial_number(person,facility.facility_code)
          
          sleep 1

          person.reload

          print_registration(person) and return

          raise person.to_yaml

          redirect_to "/people/view"

      end

      redirect_to "/people/view"
    
  end

  def view

      @section = "View"

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

          people = PersonRecordStatus.by_record_status.key(params[:status]).page(page).per(size).collect{ |status| status.person}

          render  :text => people.to_json

  end

  def show

      @person = Person.find(params[:id])

      @status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

      excludes = ["first_name_code","last_name_code", "middle_name_code",
                  "mother_first_name_code","mother_last_name_code", "mother_middle_name_code",
                  "father_first_name_code","father_last_name_code", "father_middle_name_code",
                  "informant_first_name_code","informant_last_name_code", "informant_middle_name_code",
                  "birthdate_estimated", "created_by", "date_created", 
                  "updated_by","voided_by", "voided", "voided_date",
                  "status_changed_by","approved_by","approved_at","creator",
                  "cahnged_by","id","_rev","created_at","updated_at","type",
                  "changed_by","_deleted","_id","acknowledgement_of_receipt_date"]

      @keys = @person.keys - excludes

      @section = "Show"

      render :layout => "facility"
  	
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

      person.update_attributes(params[:person])

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
    
        data = (JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys-cities).sort rescue []
    
    else

        data = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.sort rescue []
    
        #data = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.push("Lilongwe City", "Blantyre City", "Zomba City", "Mzuzu City").sort
    
    end

    if !params[:search_string].blank?
      data = data.delete_if{|n| !n.match(/#{params[:search_string]}/i)}
    end

    render :text => data.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"
  end

  def facilities

    district = params[:district] || '';

    if !district.blank?
      facilities = HealthFacility.by_district.keys([district]).all.collect(&:name).sort
    else
      facilities = HealthFacility.all.collect(&:name).sort
    end

    if !params[:search_string].blank?
      facilities = facilities.delete_if{|n| !n.match(/#{params[:search_string]}/i)}
    end

    render :text => facilities.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"
  end

  def nationalities
    nationalities = Nationality.all.collect(&:nationality).sort

    if !params[:search_string].blank?
      nationalities = nationalities.delete_if{|n| !n.match(/#{params[:search_string]}/i)}
    end
    render :text => nationalities.insert(0, nationalities.delete_at(107)).uniq.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"
  end

  def tas

    result = []

    if !params[:district].blank?

      result = Village.by_district.key([params[:district].strip]).collect(&:ta).uniq

    end

    result = result.sort

    if !params[:search_string].blank?
      result = result.delete_if{|n| !n.match(/#{params[:search_string]}/i)}
    end

    render :text => result.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"
  end


  def villages

    result = []

    if !params[:district].blank? and !params[:ta].blank?

     result = Village.by_district_and_ta.key([params[:district].strip, params[:ta].strip]).collect(&:village).uniq

    end

    result = result.sort

    if !params[:search_string].blank?
      result = result.delete_if{|n| !n.match(/#{params[:search_string]}/i)}
    end

    render :text => result.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"

  end

  def print_id_label



    print_string = person_label(params[:person_id]) #rescue (raise "Unable to find child (#{params[:child_id]}) or generate a national id label for that patient")
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:person_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end


  def person_label(person_id)

    @person = Person.find(person_id)
    sex =  @person.gender.match(/F/i) ? "(F)" : "(M)"

    place_of_death = @person.hospital_of_death_name  rescue ""
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

    if CONFIG['site_type'] =="facility"

          @facility_type = "Facility"

    else

            @facility_type = "DC"

    end

  end

end
