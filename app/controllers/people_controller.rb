class PeopleController < ApplicationController

	before_filter :find_person, :except => [:index, :query, :create, :new, :person_label]

  before_filter :check_if_user_admin

  before_filter :facility_info

  before_filter :check_user_level_and_site

  def new_split
      render :layout => false
  end

	def index

      @facility = facility

      @district = district

      @section = "Home"

      @portal_link = (UserAccess.by_user_id.key(User.current_user.id).last.portal_link rescue nil)

      render :layout => "landing"

  end

  def portal_logout

    if User.current_user.present?
      MyLock.by_user_id.key(User.current_user.id).each do |lock|
        lock.destroy
      end      
    end

    user_access = UserAccess.by_user_id.key(User.current_user.id).each
    user_access.each do |access|
      access.destroy
    end

    logout!

    render :text => "Logout"
  end

  def new_person_type
      @section = "Registration Categories"
      @facility = facility
      @district = district
      @targeturl = "/"
      render :layout => "landing" 
  end

  def form_type
      @section = "Select Form Type"
      @facility = facility
      @district = district
      @targeturl = "/"
      render :layout => "landing"
  end

  def register_special_cases
      render :layout => "touch"
  end

  def new
	   #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Register a record"))
     @site_type = site_type.to_s
     @current_nationality = Nationality.by_nationality.key("Malawian").last
     if session[:district_code].blank?
        if SETTINGS['site_type'] == "dc" || SETTINGS['site_type'] == "facility"
            session[:district_code] = SETTINGS['district_code'] 
        else
            flash[:error] = 'Session expired please login again!'
            redirect_to "/login" and return          
        end
     end

     @district_code =  session[:district_code]
     
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

      if SETTINGS["potential_duplicate"]

          record = {}
          record["first_name"] = params[:person][:first_name]
          record["last_name"] = params[:person][:last_name]
          record["middle_name"] = (params[:person][:middle_name] rescue nil)
          record["gender"] = params[:person][:gender]
          record["place_of_death_district"] = params[:person][:place_of_death_district]
          record["birthdate"] = params[:person][:birthdate]
          record["date_of_death"] = params[:person][:date_of_death]
          record["mother_last_name"] = (params[:person][:mother_last_name] rescue nil)
          record["mother_middle_name"] =(params[:person][:mother_middle_name] rescue nil)
          record["mother_first_name"] = (params[:person][:mother_first_name] rescue nil)
          record["father_last_name"] = (params[:person][:father_last_name] rescue nil)
          record["father_middle_name"] = (params[:person][:father_middle_name] rescue nil)
          record["father_first_name"] = (params[:person][:father_first_name] rescue nil)
          record["location"] = record["place_of_death_district"]
          record["id"] = person.id
          record["district_code"] = (person.district_code rescue SETTINGS['district_code'])

          if SETTINGS['use_mysql_potential_search']
              insert_potential_search(record)
          else
              SimpleElasticSearch.add(record)            
          end

          
          
      end

      create_directory(params)

      if !person_params[:barcode].blank? && !person_params[:barcode].nil? 

            Barcode.create({
                              :person_record_id => person.id.to_s,
                              :barcode => person_params[:barcode].to_s,
                              :district_code => (person.district_code  rescue SETTINGS['district_code']),
                              :creator => User.current_user.id
                              })
        
      end

      #create status

      if Person.duplicate.nil?
          PersonRecordStatus.create({
                                      :person_record_id => person.id.to_s,
                                      :status => "DC ACTIVE",
                                      :comment =>"Record Created",
                                      :district_code =>  person.district_code,
                                      :creator => User.current_user.id})
        else
          
          change_log = [{:duplicates => Person.duplicate.to_s}]

          Audit.create({
                          :record_id  => person.id.to_s,
                          :audit_type => "POTENTIAL DUPLICATE",
                          :reason     => "Record is a potential",
                          :change_log => change_log
          })

          if eval(params[:person][:is_exact_duplicate])
              if SETTINGS['site_type'] =="facility"
                status = "FC EXACT DUPLICATE"
              else
                status = "DC EXACT DUPLICATE"
              end
          else
              if SETTINGS['site_type'] =="facility"
                status = "FC POTENTIAL DUPLICATE"
              else
                status = "DC POTENTIAL DUPLICATE"
              end
          end

          PersonRecordStatus.create({
                                      :person_record_id => person.id.to_s,
                                      :status => status,
                                      :district_code => person.district_code,
                                      :comment =>"System mark record as a potential",
                                      :creator => User.current_user.id})

          Person.duplicate = nil

        end

      Sync.create({
                    :person_record_id => person.id.to_s,
                    :record_status => "DC ACTIVE"
      })
      
      #redirect_to "/people/view/#{person.id.to_s}" and return
      #redirect_to "/people/finalize_create/#{person.id}" and return
      redirect_to "/people/view"

        	
  end

  def search_similar_record

      field_hash = {
                      :first_name=>params[:first_name], 
                      :last_name => params[:last_name],
                      :middle_name => (params[:middle_name] rescue nil),
                      :gender => params[:gender],
                      :place_of_death_district => params[:place_of_death_district],
                      :birthdate => params[:birthdate],
                      :date_of_death => params[:date_of_death],
                      :mother_last_name => (params[:mother_last_name] rescue nil),
                      :mother_middle_name => (params[:mother_middle_name] rescue nil),
                      :mother_first_name => (params[:mother_first_name] rescue nil),
                      :father_last_name => (params[:father_last_name] rescue nil),
                      :father_middle_name => (params[:father_middle_name] rescue nil),
                      :father_first_name => (params[:father_first_name] rescue nil)
                    }

      person  = Person.new(field_hash)
      people = []
      exact_duplicate = false
      if SETTINGS["potential_duplicate"]
        results = []
        results = SimpleElasticSearch.query_duplicate_coded(person,100)
        if results.blank?
            results = SimpleElasticSearch.query_duplicate_coded(person,SETTINGS['duplicate_precision'])
        else
            exact_duplicate  = true
        end
      else
        #exact search
        results = []
      end
      people = results
      
      if people.count == 0

        render :text => {:response => false}.to_json
      else

        render :text => {:response => people,:exact => exact_duplicate}.to_json
      end 
  end


  def view

      @section = "View"

      if SETTINGS['site_type'] =="facility"
          @statuses = ["DC ACTIVE","FC POTENTIAL DUPLICATE"]
      else
          @statuses = ["DC ACTIVE"]
      end

      @next_url = "/people/view"

      @search = true

      render :layout => "landing"
      
  end

  def view_datatable

      @section = "View"

      if SETTINGS['site_type'] =="facility"
          @statuses = ["DC ACTIVE","FC POTENTIAL DUPLICATE"]
      else
          @statuses = ["DC ACTIVE"]
      end
      @next_url = "/people/view_datatable"

      @search = true

      render :layout => "landing"
      
  end

  def all

      people = Person.all

      render :text => people.to_json
    
  end


  def search_by_status
     
    status = params[:statuses]
    page = params[:page] rescue 0
    size = params[:size] rescue 40
    people = []
    record_status = []

    
    RecordStatus.where("status IN('#{params[:statuses].join("','")}') AND voided = 0 AND district_code = '#{User.current_user.district_code}'").limit(params[:size].to_i).offset(params[:page].to_i * params[:size].to_i).each do |status|

      person = Record.find(status.person_record_id) rescue nil
      next if person.nil?
      den = person.den rescue ""
      drn = person.drn rescue ""

     
      if den.blank? && params[:den].present? && eval(params[:den])
        next
      end

      person = person.as_json
      person["den"] = den
      person["drn"] = drn
      people << person
    end

=begin
    if SETTINGS['site_type'] == "remote"
     
      statuses = params[:statuses]

      statuses.each do |status|
          record_status << [User.current_user.district_code,status]
      end

    
      PersonRecordStatus.by_district_code_and_record_status.keys(record_status).page(page).per(size).each do |status|
        
          person = status.person
          person["den"] = person.den rescue ""
          person["drn"] = person.drn rescue ""
          people << person
        
      end
    else
        statuses = params[:statuses]
          
        if params[:statuses].include?("DC INCOMPLETE")
         statuses << "DC REJECTED"
        end
        
        statuses.each do |status|
          record_status << [SETTINGS['district_code'],status]
        end

        
        PersonRecordStatus.by_district_code_and_record_status.keys(record_status).page(page).per(size).each  do |status|
      
        person = status.person
       
        person["den"] = person.den rescue ""

        people << person
      
        end
       
    end
=end    
    render  :text => people.to_json
  end


  def search_by_status_with_prev_status
      sql = "SELECT c.person_record_id FROM person_record_status c INNER JOIN person_record_status p ON p.person_record_id = c.person_record_id
             WHERE c.status IN ('#{params[:statuses].join("','")}') AND p.status IN ('#{params[:prev_statuses].join("','")}') AND p.voided = 1 
             LIMIT 40 OFFSET #{(params[:page].to_i - 1) * 40}"
      connection = ActiveRecord::Base.connection
      data = connection.select_all(sql).as_json

      cases = []

      data.each do |row|
          person = Person.find(row["person_record_id"])
          person["den"] = person.den rescue ""
          person["drn"] = person.drn rescue ""
          people << person
          cases << people
      end

      render text: cases.to_json and return
  end

  def search

    if params[:search_criteria].present?

      @search = true

      if params[:search_criteria] == "General Search"
        keys = params.keys - ['utf8','controller','action','field_group','search_criteria']
        @params_string =""
        keys.each do |key|
          @params_string = "#{@params_string}&#{key}=#{params[key]}" if params[key].present?
        end
      end

       @section ="Search Results"

       @next_url = "/"

       render :layout => "landing"

    else  
      @section ="Search Criteria"
      render :layout => "touch"
    end

    
  end

  def general_search
    map = {
                "details_of_deceased" => ['first_name', 'last_name', 'gender','date_of_death'],
                "physical_address"  => ["current_country","current_district","current_ta","current_village"],
                "home_address" => ['home_country','home_district', 'home_ta', 'home_village'],
                "mother" => ['mother_first_name', 'mother_last_name'],
                "father" => ['father_first_name', 'father_last_name'],
                "informant" => ['informant_first_name', 'informant_last_name'],
                "informant_address" => ['informant_current_district', 'informant_current_ta', 'informant_current_village'],
                "place_death" => ['place_of_death', 'place_of_death_district', 'place_of_death_ta', 'place_of_death_village', 'hospital_of_death', 'other_place_of_death']
              }

    results = SimpleSQL.query(map, params)

    render :text => results.to_json
  end

  def search_by_fields

    status = params[:status]
    page = params[:page] rescue 1
    size = params[:size] rescue 40
    people = []

    if params[:death_entry_number].present?
   
      offset = page.to_i * size.to_i

      RecordIdentifier.where(identifier: params[:death_entry_number]).offset(offset).limit(size).each do |pid|
        
          person = pid.person
          if SETTINGS['site_type'] == "remote"
              next if User.current_user.district_code != person.district_code
          end
          people << person_selective_fields(person)
      end               
      
    end
    if params[:barcode].present?

      offset = page.to_i * size.to_i
   
      BarcodeRecord.where(barcode: params[:barcode]).offset(offset).limit(size).each do |pid|
        
          person = pid.person

          people << person_selective_fields(person)
      end               
      
    end
    if params[:death_registration_number].present?

      offset = page.to_i * size.to_i
      
      RecordIdentifier.where(identifier: params[:death_registration_number]).offset(offset).limit(size) do |pid|

          person = pid.person

          people << person_selective_fields(person)

       end
    end

    if params[:national_id].present?
      Person.by_id_number.key(params[:national_id]).page(page).per(size).each do |person|
        
          people << person_selective_fields(person)
      end               
      
    end

    render  :text => people.to_json
  end

  def clear_all_locks
      MyLock.all.each do |lock|
        lock.destroy
      end

      flash[:notice] = "Successfully unlock all records"
      redirect_to "/"
  end

  def unlock_record
      lock = MyLock.find(params[:lock_id]) rescue nil
 
      if lock.present?
        if lock.user_id == User.current_user.id
          lock.destroy
        end
      end
      redirect_to params[:next_url]
  end

  def remove_redu_states(person_id)
      #puts person_id
      state = ["DC ACTIVE", "DC COMPLETE","HQ ACTIVE","HQ COMPLETE","MARKED HQ APPROVAL", "HQ CAN PRINT", "HQ PRINTED","HQ DISPATCHED"]
      statuses = PersonRecordStatus.by_person_record_id.key(person_id).each
      statuses.each do |st|
          st.insert_update_into_mysql
      end
      
      uniqstatus = statuses.collect{|d| d.status}.uniq

      uniqstatus.each do |us|
          redundantstatuses = PersonRecordStatus.by_person_record_id.key(person_id).each.reject{|s| s.status != us}.sort_by{|s| s.created_at}

          puts "destroying multiple #{us}"
          redundantstatuses.each_with_index do |red, i|
                  if i != 0
                      begin
                          redundantstatuses[i].destroy
                      rescue
                          puts "Error : #{redundantstatuses[i].id}"
                          puts "Retry"
                          begin
                              RecordStatus.find(redundantstatuses[i].id).destroy
                              PersonRecordStatus.find(redundantstatuses[i].id).destroy
                              
                          rescue
                              puts "Fail"
                          end
                      end
                  else
                      redundantstatuses[i].insert_update_into_mysql
                  end
          end
      end

      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>"

      PersonRecordStatus.by_person_record_id.key(person_id).each do |s|
          if s.status.blank?
              s.destroy
          end
      end
    
      last = 0

      RecordStatus.where(person_record_id: person_id).order(:created_at).each do |d|
          person_status = PersonRecordStatus.by_person_recent_status.key(d.person_record_id).last
          if state.find_index(d.status).to_i > last
              last = state.find_index(d.status).to_i
          end

          if person_status.present? && state.find_index(d.status).to_i < state.find_index(person_status.status).to_i
                  d.voided = 1 
                  d.save
          end
          couch_status = PersonRecordStatus.find(d.person_record_status_id)
          if couch_status.blank?
              d.destroy
          end
      end

      RecordStatus.where(person_record_id: person_id, voided: 0).each do |d|
          if last != state.find_index(d.status).to_i
                  couch_status = PersonRecordStatus.find(d.person_record_status_id)
                  couch_status.voided = true
                  couch_status.save
                  d.voided = 1 
                  d.save
          else
              couch_status = PersonRecordStatus.find(d.person_record_status_id)
              couch_status.voided = false
              couch_status.save
              d.voided = 0 
              d.save            
          end
      end
      RecordStatus.where(person_record_id: person_id,status: state[last] ).each do |d|
          puts d.status
          couch_status = PersonRecordStatus.find(d.person_record_status_id)
          couch_status.voided = false
          couch_status.save
          d.voided = 0 
          d.save  
      end

  end

  def show
      
      @person = to_readable(Person.find(params[:id]))

      @lock = MyLock.by_person_id.key(params[:id]).last
      if @lock.blank?
        @lock = MyLock.create(:person_id => params[:id],:user_id => User.current_user.id)
      end

      if User.current_user.id != @lock.user_id
        @locked = true
      else
        @locked = false
      end

      #Duplicate capturing 
      if SETTINGS["potential_duplicate"]

              record = {}
              record["first_name"] = @person.first_name
              record["last_name"] = @person.last_name
              record["middle_name"] = (@person.middle_name rescue nil)
              record["gender"] = @person.gender
              record["place_of_death_district"] = @person.place_of_death_district
              record["birthdate"] = @person.birthdate
              record["date_of_death"] = @person.date_of_death
              record["mother_last_name"] = (@person.mother_last_name rescue nil)
              record["mother_middle_name"] = (@person.mother_middle_name rescue nil)
              record["mother_first_name"] = (@person.mother_first_name rescue nil)
              record["father_last_name"] = (@person.father_last_name rescue nil)
              record["father_middle_name"] = (@person.father_middle_name rescue nil)
              record["father_first_name"] = (@person.father_first_name rescue nil)
              record["id"] = @person.id
              record["person_id"] = @person.id
              record["location"] = record["place_of_death_district"]
              record["district_code"] = @person.district_code
              
              if SETTINGS['use_mysql_potential_search']
                 record["gender"] = @person.gender.first
                 DeDuplication.add(record,true,false,false)
                 @duplicates = DeDuplication.query_duplicate(record,50,true)
                 if @duplicates.present?
                    audit = Audit.new
                    audit.audit_type = "POTENTIAL DUPLICATE"
                    audit.record_id = record["person_id"]
                    audit.change_log =[{'duplicates' => @duplicates.collect{|d|d["person_id"]}.join("|")}]
                    audit.reason = "Record is a potential"
                    audit.save
                   if @duplicates.count == 1 && @duplicates.first["score"] == 100
                      RecordStatus.change_status(@person, 'DC EXACT DUPLICATE','System caught it as exact duplicate')
                   else
                      RecordStatus.change_status(@person, 'DC POTENTIAL DUPLICATE','System caught it as potential duplicate')
                   end                   
                 end
              else
                SimpleElasticSearch.add(record)            
              end
      end
      # @status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last



      # #Recorrecting statuses thatt have not changed

      # PersonRecordStatus.by_person_recent_status.key(params[:id]).each.sort_by{|d| d.created_at}.each do |s|
      #   next if s === @status
      #   s.voided = true
      #   s.save
      # end

      connection = ActiveRecord::Base.connection
      statuses_query = "SELECT * FROM person_record_status WHERE  person_record_id='#{params[:id]}' ORDER BY created_at"
      statuses = connection.select_all(statuses_query).as_json

      @status = statuses.last


      if @status['status'] =="DC AMEND"
        redirect_to "/dc/ammendment/#{params[:id]}?next_url=#{params[:next_url]}"
      elsif @status['status'].include?("DUPLICATE")
        redirect_to "/dc/show_duplicate/#{params[:id]}?index=0&next_url=#{params[:next_url]}"
      else

          @person_place_details = place_details(@person)

          @section = "View"
          #raise params[:id].inspect
          @burial_report = BurialReport.by_person_record_id.key(params[:id]).first


          comment_statuses = []

          @comments = []
          statuses.each do |status|
            next if comment_statuses.include?(status['status'])
            next if status['status'].blank?
            next if status['comment'].blank?
            comment_statuses << status['status']
            user = User.find(status['creator'])
            @comments << {created_at: status['created_at'],status: status['status'] , reason: status['comment'], user: "#{user.first_name rescue ''} #{user.last_name rescue ''}", user_role: (user.role rescue '') } if status['comment'].present?
          end
          #raise @comments.inspect
          render :layout => "landing"
      end
  end
  def find
    person = Person.find(params[:id])
    person["status"] = PersonRecordStatus.by_person_recent_status.key(params[:id]).last.status
    render :text => person_selective_fields(person).to_json
  end

  def find_by_barcode
    barcode = Barcode.by_barcode.key(params[:barcode]).first
    person = barcode.person
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
      if person.update_person(params[:id],params[:person])
          change_log = {}
          params[:person].keys.each do |key|
            change_log[key] = params[:person][key]
          end
          Audit.create({
                          :record_id  => person.id.to_s,
                          :audit_type => "UPDATE RECORD",
                          :reason     => "Record update",
                          :change_log => change_log
          })

          if SETTINGS["potential_duplicate"]
              record = {}
              record["first_name"] = person.first_name
              record["last_name"] = person.last_name
              record["middle_name"] = (person.middle_name rescue nil)
              record["gender"] = person.gender
              record["place_of_death_district"] = person.place_of_death_district
              record["birthdate"] = person.birthdate
              record["date_of_death"] = person.date_of_death
              record["mother_last_name"] = (person.mother_last_name rescue nil)
              record["mother_middle_name"] = (person.mother_middle_name rescue nil)
              record["mother_first_name"] = (person.mother_first_name rescue nil)
              record["father_last_name"] = (person.father_last_name rescue nil)
              record["father_middle_name"] = (person.father_middle_name rescue nil)
              record["father_first_name"] = (person.father_first_name rescue nil)
              record["id"] = person.id
              record["district_code"] = (User.current_user.district_code rescue SETTINGS['district_code'])

              if SETTINGS['use_mysql_potential_search']
                  insert_potential_search(record)
              else
                  SimpleElasticSearch.add(record)            
              end
          end
      end

      redirect_to "/people/view/#{params[:id]}?next_url=#{params[:next_url]}"
    
  end

  def get_first_names
      entry = params["search"].soundex rescue nil
        data = Person.by_name_codes.startkey(entry).endkey("#{entry}\ufff0").limit(10) rescue nil
        if data.present?
		  		render :text => data.collect{ |w| "<li>#{w.first_name}" }.uniq.join("</li>")+"</li>"
		  	else
		    	render :text => "<li></li>"
      	end
  end

  def get_last_names
        entry = params["search"].soundex rescue nil
        data = Person.by_name_codes.startkey(entry).endkey("#{entry}\ufff0").limit(10) rescue nil
        if data.present?
          render :text => data.collect{ |w| "<li>#{w.last_name}" }.uniq.join("</li>")+"</li>"
        else
          render :text => "<li></li>"
        end
  end

  def get_names
      entry = params["search"] rescue nil
      special_character_regex = /[-!$%^&*()_+|~=`{}\[\]:";<>?\/\d+]/
      if entry.blank?
          data = []
      else
        query = "SELECT name FROM name_directory WHERE name LIKE '#{entry.gsub("'","''")}%' ORDER BY name ASC LIMIT 10"
        data = NameDirectory.find_by_sql(query);
      end
      if data.present?
          render :text => data.collect{ |w| "<li>#{w.name}" unless w.name =~ special_character_regex }.uniq.join("</li>")+"</li>"
      else
          render :text => "<li></li>"
      end
  end

  def districts
  
     entry = params["search_string"] rescue nil
     if entry.present?
        district = DistrictRecord.where("name LIKE '#{entry.gsub("'","''")}%'").order(:name)
      else
        district = DistrictRecord.all.order(:name)
     end

    if params[:place].present? && params[:place] == "Health Facility"

        cities = ["Lilongwe City", "Blantyre City", "Zomba City", "Mzuzu City"]

        render :text => district.collect { |w| "<li>#{w.name}" unless cities.include? w.name }.join("</li>")+"</li>"

    elsif params[:place].present? && params[:place] == "Other"

         render :text => district.collect { |w| "<li >#{w.name}" }.push("<li>Not indicated").join("</li>")+"</li>"
    else
        render :text => district.collect { |w| "<li >#{w.name}" }.join("</li>")+"</li>"
    
    end
  end

  def facilities

    district_param = params[:district] || '';

    if !district_param.blank?

      district = DistrictRecord.where(name: district_param.to_s).first

      facilities = Facility.where(district_id:district.id).order(:name)
    else
      facilities = Facility.all.order(:name)
    end

    list = []
    facilities.each do |f|
      if !params[:search_string].blank?
        list << f if f.name.match(/#{params[:search_string]}/i)
      else
        list << f
      end
    end

    render :text => list.sort_by {|w| w["name"]}.collect { |w| "<li>#{w.name}" }.join("</li>")+"</li><li>Other</li>"
  end

  def nationalities
    entry = params[:search_string] rescue nil
    if entry.present? && false
        nationalities = NationalityRecord.where("nationality LIKE '#{entry.gsub("'","''")}%'").order(:nationality)
    else
      nationalities = NationalityRecord.all.order(:nationality)
    end
    
    list = []
    nationalities.each do |n|
      next if n.nationality.squish =="Unknown"
      next if n.nationality.squish =="Other"
      if !params[:search_string].blank?
        list << n if n.nationality.match(/#{params[:search_string]}/i)
      else
        list << n
      end
    end

    nations = list.collect {|c| c.nationality}.sort
     if "Malawian".match(/#{params[:search_string]}/i) || params[:search_string].blank?
      nations = ["Malawian"] + nations
    end
    render :text => nations.uniq.collect { |c| "<li>#{c}" }.join("</li>")+"</li><li>Other</li><li>Unknown</li>"

  end

  def countries
    entry = params[:search_string] rescue nil
    if entry.present? && false
        countries = CountryRecord.where("name LIKE '#{entry.gsub("'","''")}%'").order(:name)
    else
      countries = CountryRecord.all.order(:name)
    end
    
    list = []
    countries.each do |n|
      next if n.name.squish =="Unknown"
      next if n.name.squish =="Other"
      if n.name =="Malawi"
          next unless params[:exclude].blank?
      end
      if !params[:search_string].blank?
        list << n if n.name.match(/#{params[:search_string]}/i)
      else
        list << n
      end
    end

    countries =  list.collect {|c| c.name}.sort

    if ("Malawi".match(/#{params[:search_string]}/i) || params[:search_string].blank?) && params[:exclude] != "Malawi"
      countries = ["Malawi"] +  countries
    end

    render :text => countries.uniq.collect { |c| "<li>#{c}" }.join("</li>")+"</li><li>Other</li><li>Unknown</li>"

  end

  def other_countries
     entry = params["search"] rescue nil
     data = Person.by_other_home_country.startkey(entry).endkey("#{entry}\ufff0").limit(32).each
     other_countries = []
     data.each do |d|
        other_countries << d.other_home_country if d.other_home_country.present?
        other_countries << d.other_current_country if d.other_current_country.present?
        other_countries << d.other_place_of_death_country if d.other_place_of_death_country.present?
     end

     render :text => other_countries.uniq.collect { |c| "<li>#{c}" }.join("</li>")+"</li>"
  end

  def tas

    result = []

    if !params[:district].blank?

      district = DistrictRecord.where(name: params[:district].strip).first

      result = TA.where(district_id: district.id).order(:name)
    else

       result = TA.all.order(:name)

    end

    list = []
    result.each do |r|
      if !params[:search_string].blank?
        list << r if r.name.match(/#{params[:search_string]}/i)
      else
        list << r
      end
    end

    render :text => list.sort_by {|w| w["name"]}.collect{|w| w.name}.uniq.collect { |w| "<li>#{w}" }.join("</li>")+"</li><li>Other</li><li>Unknown</li>"
  end


  def villages

    result = []

    if !params[:district].blank? and !params[:ta].blank?

      district = DistrictRecord.where(name: params[:district].strip).first

      ta =TA.where(district_id:district.id, name: params[:ta]).first

      result = VillageRecord.where(ta_id: ta.id.strip).order(:name)

    else
       result = Village.all.order(:name)

    end

    list = []
    result.each do |r|
      if !params[:search_string].blank?
        list << r if r.name.match(/#{params[:search_string]}/i)
      else
        list << r
      end
    end

    render :text => list.sort_by {|w| w["name"]}.collect{|w| w.name}.uniq.collect { |w| "<li>#{w}" }.join("</li>")+"</li><li>Other</li><li>Unknown</li>"

  end

  def get_disignation
       entry = params["search"] rescue nil
       data = Person.by_informant_designation.startkey(entry).endkey("#{entry}\ufff0").limit(32).each
       render :text => data.collect { |w| "<li>#{w.informant_designation}" }.join("</li>")
  end

  def get_other_ta
       entry = params["search"] rescue nil
       data = Person.by_other_ta.startkey(entry).endkey("#{entry}\ufff0").limit(32).each
       render :text => data.collect { |w| "<li>#{w.informant_designation}" }.join("</li>")
  end

  def get_other_villages
       entry = params["search"] rescue nil
       data = Person.by_other_ta.startkey(entry).endkey("#{entry}\ufff0").limit(32).each
       render :text => data.collect { |w| "<li>#{w.informant_designation}" }.join("</li>")
  end

  def print_id_label

    print_string = person_label(params[:person_id]) #rescue (raise "Unable to find person (#{params[:person_id]}) or generate a national id label for that patient")
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
        barcode = Barcode.by_barcode.key(params[:barcode]).last
        if barcode.present?
            id = barcode.person_record_id
            render :text => {:response =>  true, :id => id}.to_json
        else
           render :text => {:response => false}.to_json
        end            
      end
  end

########## Render sync status page ##################################################################################################################
  def view_sync
   @site_type = SETTINGS['site_type'].to_s
    if @site_type == "dc"
      @section ="Synced to HQ"
      @url = "/dc/query_hq_sync"
    elsif @site_type =="remote"
      @section ="Remote Synced to HQ"
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
      size = params[:size] rescue 40
      people = []
    Sync.by_facility_code.key(SETTINGS['facility_code'].to_s).page(page).per(size).each do |sync|
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
      size = params[:size] rescue 40
      offset = page.to_i * size.to_i
      render :text => Record.where(district_code: User.current_user.district_code, registration_type: params[:registration_type]).offset(offset).limit(size).each.to_json
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
      size = params[:size] rescue 40
      keys = []
      special_cases = ["Abnormal Deaths","Unclaimed bodies","Missing Persons","Deaths Abroad"]
      special_cases.each do |special_case|
          keys << [special_case,"HQ CLOSED"]
          keys << [special_case,"HQ DISPATCHED"]
      end
      people =  PersonRecordStatus.registration_type_and_recent_status.keys(keys).page(page).per(size).each
      render :text =>people.to_json
  end

  def sync_data
      `rake edrs:sync`
      redirect_to "/"
  end

  def form_container
      #raise params.inspect
      if params[:url].present?
         @url = "#{params[:url]}&form_type=#{params[:form_type]}"
      else
         @url = "/people/new?registration_type=Normal Cases&form_type=#{params[:form_type]}"
      end
      if params[:next_url].present?
        @next_url = params[:next_url]
      else
        @next_url = "/"
      end
      render :layout =>"plain_with_header"
  end

  def find_identifier
      if params[:identifier].present?
        count = PersonIdentifier.by_identifier.key(params[:identifier]).count  
        if count >= 1
            render :text => {:response =>  PersonIdentifier.by_identifier.key(params[:identifier]).first.person_record_id}.to_json
        else
           render :text => {:response => false}.to_json
        end            
      end
  end

  def insert_potential_search(person)
      connection = ActiveRecord::Base.connection
      find_sql = "SELECT * FROM potential_search WHERE person_id='#{person['id']}';"
      content = "#{person['first_name']} #{person['last_name']} #{SimpleElasticSearch.format_content(person)}".upcase
      if connection.select_all(find_sql).as_json.blank?
          sql = "INSERT INTO potential_search (person_id,content,created_at,updated_at) VALUES('#{person['id']}','#{content}', NOW(), NOW());"
          connection.execute(sql)
      else
          sql = "UPDATE potential_search SET content = '#{content}', updated_at = NOW() WHERE person_id='#{person['id']}';"
          connection.execute(sql)
      end
  end


  protected

  def find_person

    @person = Person.find(params[:id]) rescue nil

    @person = Person.new if @person.nil?

    @facility = facility

    @district = district

    @current_nation = current_nationality

    if SETTINGS['site_type'] =="facility"

          @facility_type = "Facility"

    else

            @facility_type = "DC"

    end

  end

  def create_directory(params)
      NameDirectory.create(name: params[:person][:first_name], soundex: params[:person][:first_name].soundex) rescue nil
      NameDirectory.create(name: params[:person][:last_name], soundex: params[:person][:last_name].soundex) rescue nil
      NameDirectory.create(name: params[:person][:middle_name], soundex: params[:person][:middle_name].soundex) rescue nil
      NameDirectory.create(name: params[:person][:mother_first_name], soundex: params[:person][:mother_first_name].soundex) rescue nil
      NameDirectory.create(name: params[:person][:mother_last_name], soundex: params[:person][:mother_last_name].soundex) rescue nil
      NameDirectory.create(name: params[:person][:mother_middle_name], soundex: params[:person][:mother_middle_name].soundex) rescue nil
      NameDirectory.create(name: params[:person][:father_first_name], soundex: params[:person][:father_first_name].soundex) rescue nil
      NameDirectory.create(name: params[:person][:father_last_name], soundex: params[:person][:father_last_name].soundex) rescue nil
      NameDirectory.create(name: params[:person][:father_middle_name], soundex: params[:person][:father_middle_name].soundex) rescue nil
  end

end
