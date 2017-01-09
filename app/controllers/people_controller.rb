class PeopleController < ApplicationController

	before_filter :find_person, :except => [:index, :query, :create, :new, :child_label]

  	before_filter :check_if_user_admin

	def index

		    @icoFolder = icoFolder("icoFolder")

		    @section = "Home"

		    @targeturl = "/logout"

		    @targettext = "Logout"

		    render :layout => "facility"

  	end

  	def new

	    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Register a record"))

	    if !params[:id].blank?

	    else

	    	@person = Person.new if @person.nil?

	    end

	    @section = "New Person"

	    render :layout => "touch"

  end

  def create

      person_params = params[:person]

      person_params[:creator] = User.current_user.id

      person_params[:changed_by] = User.current_user.id

      person = Person.create(person_params);

      PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "NEW",
                                  :district_code => CONFIG['district_code'],
                                  :creator => User.current_user.id});

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



      redirect_to "/people/view/#{person.id.to_s}" and return
  	
  end

  def view

       render :layout => "touch"
      
  end

  def all

      people = Person.all

      render :text => people.to_json
    
  end

  def show

      @person = Person.find(params[:id])

      excludes = ["first_name_code","last_name_code", "middle_name_code",
                  "birthdate_estimated", "created_by", "date_created", 
                  "updated_by","voided_by", "voided", "voided_date",
                  "status_changed_by","approved_by","approved_at","creator",
                  "cahnged_by","id","_rev","created_at","updated_at","type",
                  "changed_by","_deleted","_id"]

      @keys = @person.keys - excludes
  	
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
      entry = params["search"].soundex
        data = Person.by_first_name_code.startkey(entry).endkey("#{entry}\ufff0").limit(10) rescue nil
        if data.present?
		  		render :text => data.collect{ |w| "<li>#{w.first_name}" }.uniq.join("</li>")+"</li>"
		  	else
		    	render :text => "<li></li>"
      	end
  end

  def get_last_names
        entry = params["search"].soundex
        data = Person.by_last_name_code.startkey(entry).endkey("#{entry}\ufff0").limit(10) rescue nil
        if data.present?
          render :text => data.collect{ |w| "<li>#{w.last_name}" }.uniq.join("</li>")+"</li>"
        else
          render :text => "<li></li>"
        end
  end

  def districts
  
    if params[:place].present? && params[:place] == "Hospital/Institution"
    
        data = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.sort rescue []
    
    else

        data = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.sort rescue []
    
        #data = JSON.parse(File.open("#{Rails.root}/app/assets/data/districts.json").read).keys.push("Lilongwe City", "Blantyre City", "Zomba City", "Mzuzu City").sort
    
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

    render :text => facilities.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"
  end

  def nationalities
    nationalities = Nationality.all.collect(&:nationality).sort
    render :text => nationalities.insert(0, nationalities.delete_at(107)).uniq.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"
  end

  def tas

    result = []

    if !params[:district].blank?

      result = Village.by_district.key([params[:district].strip]).collect(&:ta).uniq

    end

    result = result.sort

    render :text => result.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"
  end


  def villages

    result = []

    if !params[:district].blank? and !params[:ta].blank?

     result = Village.by_district_and_ta.key([params[:district].strip, params[:ta].strip]).collect(&:village).uniq

    end

    result = result.sort

    render :text => result.collect { |w| "<li>#{w}" }.join("</li>")+"</li>"

  end

  protected

  def find_person

    @person = Person.find(params[:id]) rescue nil

    @person = Person.new if @child.nil?

  end

end
