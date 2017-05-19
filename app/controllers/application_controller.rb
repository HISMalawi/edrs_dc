class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery #with: :exception

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :perform_basic_auth,:check_den_assignment,:check_database, :except => ['login', 'logout', 'update_password', 'search_by_hospital',
                                                 'search_by_district', 'search_by_ta', 'search_by_village',
                                                 "update_field","reject_record","search_similar_record",
                                                  "confirm_not_duplicate", "confirm_duplicate","create_burial_report",
                                                  "mark_as_pending","mark_for_reprint","search_barcode","proceed_amend",
                                                  "block_user","unblock_user","database_load"]

  rescue_from CanCan::AccessDenied,
              :with => :access_denied

  helper_method :current_user

  def configs
    YAML.load_file("#{Rails.root}/config/couchdb.yml")["#{Rails.env}"]
  end

  def site_type
    configs['site_type']
  end

  def facility    
      return HealthFacility.by_facility_code.key(CONFIG['facility_code'].to_s).first rescue nil
  end
  
  def district
      if facility.present?
           return District.find(facility.district_id) rescue nil
      else
          if CONFIG['district_code'].blank?
            district_code = User.current_user.district_code.to_s

          else
            district_code = CONFIG['district_code'].to_s
          end
           
          district = District.find(district_code) rescue nil

          return district
      end     
  end

  def current_nationality
      return Nationality.find("Malawian")
  end
  
  def check_if_user_admin
    @admin = ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
  end

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...", show_next_button = false, patient_id = nil)
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    @show_next_button = show_next_button
    @patient_id = patient_id
    render :template => 'people/print', :layout => nil
  end

  def record_complete?(person)
    complete  = true

    if person.first_name.blank?
      return false
    end

    if person.last_name.blank? 
      return false      
    end

    if person.birthdate.blank?
        return false 
    end

    if person.date_of_death.blank?
      return false      
    end

    if person.place_of_death.blank? &&  person.place_of_death_foreign.blank?
      return false      
    end

    return complete   
  end


  #Root index of app
  def index
    if CONFIG['site_type'] =="facility" || User.current_user.role == "Data Clerk" ||  User.current_user.role == "Nurse/Midwife"
      redirect_to "/people/"
    else
      redirect_to "/dc/"
    end   
  end

  def facility_info
    @facility = facility
    @district = district
    if CONFIG['site_type'] =="facility"
      @facility_type = "Facility"
    elsif CONFIG['site_type'] =="dc"
      @facility_type = "DC"
    else
      @facility_type = "Remote"
    end
  end

  def place_details(person)
    places = {}
    places['home_country'] = Nationality.find(person.nationality_id).nationality rescue ""
    places['place_of_death_district'] = District.find(person.place_of_death_district_id).name rescue ""
    places['hospital_of_death'] = HealthFacility.find(person.hospital_of_death_id).name rescue ""
    places['place_of_death_ta'] = TraditionalAuthority.find(person.place_of_death_ta_id).name rescue ""
    places['place_of_death_village'] = Village.find(person.place_of_death_village_id).name rescue ""
    places['current_district'] = District.find(person.current_district_id).name rescue ""
    places['current_ta'] = TraditionalAuthority.find(person.current_ta_id).name rescue ""
    places['current_village'] = Village.find(person.current_village_id).name rescue ""
    places['home_district'] = District.find(person.home_district_id).name rescue ""
    places['home_ta'] = TraditionalAuthority.find(person.home_ta_id).name rescue ""
    places['home_village'] = Village.find(person.home_village_id).name rescue ""
    places['informant_current_district'] = District.find(person.informant_current_district_id).name rescue ""
    places['informant_current_ta'] = TraditionalAuthority.find(person.informant_current_ta_id).name rescue ""
    places['informant_current_village'] = Village.find(person.informant_current_village_id).name rescue ""
    return places

  end

  def mysql_connection
     YAML.load_file(File.join(Rails.root, "config", "mysql_connection.yml"))['connection']
  end

  ##########################################################################################################################
    ############################# Duplicate ###############################################################################
  def duplicate_index(person)

    search_content = format_content(person) 

    person_hash = {
    couchdb_id: person.id,
    group_id: "",
    group_id2: "",
    date_added: person.created_at.strftime("%Y-%m-%d %H:%M:%S"),
    title: person.first_name + " " + person.last_name,
    content: search_content.squish
    }
    
    RestClient.post("#{CONFIG['duplicate_service_url']}"+"/write", 
                    person_hash.to_json, 
                    content_type: "application/json", 
                    accept: :json )  rescue []   

  end

  #Read person record after indexing
  def potential_duplicate?(person)

          result = []
          search_content = format_content(person)   
          person_hash = {
            content: search_content,
            score: CONFIG["duplicate_score"]
          }
                  
            potential_duplicates_result =  RestClient.post("#{CONFIG['duplicate_service_url']}"+"/read", 
                                                            person_hash.to_json, 
                                                            content_type: "application/json", 
                                                            accept: :json ) rescue []
          return potential_duplicates_result

          #Process result here                        
   end

   def potential_duplicate_full_text?(person)
      if person.middle_name.blank?
        score = (CONFIG['duplicate_score'].to_i - 1)
      else
        score = CONFIG['duplicate_score'].to_i
      end
      searchables = "#{person.first_name} #{person.last_name} #{ format_content(person)}"
      sql_query = "SELECT couchdb_id,title,content,MATCH (title,content) AGAINST ('#{searchables}' IN BOOLEAN MODE) AS score 
                  FROM documents WHERE MATCH(title,content) AGAINST ('#{searchables}' IN BOOLEAN MODE) ORDER BY score DESC LIMIT 5"
      results = SQLSearch.query_exec(sql_query).split(/\n/)
      results = results.drop(1)

      potential_duplicates = []

      results.each do |result|
          data = result.split("\t");
          next if person.id.present? && person.id == data[0]
          potential_duplicates << data if data[3].to_i >= score
      end
      return potential_duplicates
   end
   #Format content
   def format_content(person)
     
     search_content = ""
      if person.middle_name.present?
         search_content = person.middle_name + ", "
      end 

      birthdate_formatted = person.birthdate.to_date.strftime("%Y-%m-%d")
      search_content = search_content + birthdate_formatted + " "
      death_date_formatted = person.date_of_death.to_date.strftime("%Y-%m-%d")
      search_content = search_content + death_date_formatted + " "
      search_content = search_content + person.gender.upcase + " "

      if person.place_of_death_district.present?
        search_content = search_content + person.place_of_death_district + " " 
      else
        registration_district = District.find(person.district_code).name
        search_content = search_content + registration_district + " " 
      end    

      if person.nationality.present?
        search_content = search_content + person.nationality + " " 
      end

      return search_content.squish

  end

  def readable_format(result)
      person = Person.find(result[0])
      return [person.id, "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name} #{person.gender}"+
                    " Born on #{DateTime.parse(person.birthdate.to_s).strftime('%d/%B/%Y')} "+
                    " died on #{DateTime.parse(person.date_of_death.to_s).strftime('%d/%B/%Y')} " +
                    " at #{person.place_of_death_district}"]
  end

  def format_content_back(person)
     
     search_content = ""
      if person.middle_name.present?
         search_content = person.middle_name + ", "
      end 

      birthdate_formatted = person.birthdate.to_date.strftime("%Y-%m-%d")
      search_content = search_content + birthdate_formatted + " "
      death_date_formatted = person.date_of_death.to_date.strftime("%Y-%m-%d")
      search_content = search_content + death_date_formatted + " "
      search_content = search_content + person.gender.upcase + " "

      if person.place_of_death_district.present?
        search_content = search_content + person.place_of_death_district + " " 
      else
        registration_district = District.find(person.district_code).name
        search_content = search_content + registration_district + " " 
      end    

      if person.mother_first_name.present?
        search_content = search_content + person.mother_first_name + " " 
      end

      if person.mother_middle_name.present?
         search_content = search_content + person.mother_middle_name + " "
      end   

      if person.mother_last_name.present?
        search_content = search_content + person.mother_last_name + " "
      end

      if person.father_first_name.present?
         search_content = search_content + person.father_first_name + " "
      end 

      if person.father_middle_name.present?
         search_content = search_content + person.father_middle_name + " "
      end 

      if person.father_last_name.present?
         search_content = search_content + person.father_last_name
      end 

      return search_content.squish

  end
  protected

  def login!(user)
    session[:current_user_id] = user.username
    @current_user = user
  end

  def logout!
    session[:current_user_id] = nil
    @current_user = nil
  end

  def current_user
    unless @current_user == false # meaning a user has previously been established as not logged in
      @current_user ||= authenticate_from_session || authenticate_from_basic_auth || false
      User.current_user = @current_user
    end
  end

  def authenticate_from_basic_auth
    authenticate_with_http_basic do |user_name, password|
      user = User.get_active_user(user_name)
      if user and user.password_matches?(password)
        return user
      else
        return false
      end
    end
  end

  def authenticate_from_session
    unless session[:current_user_id].blank?
      user = User.get_active_user(session[:current_user_id])
      return user
    end
  end

  def perform_basic_auth
    authorize! :access, :anything
  end

  def check_den_assignment
    if CONFIG['site_type'].to_s != "facility"
      last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
      job_interval = CONFIG['ben_assignment_interval']
      job_interval = 1.5 if job_interval.blank?
      job_interval = job_interval.to_f
      now = Time.now
      if (now - last_run_time).to_f > job_interval
        AssignDen.perform_in(1)
      end
    end
  end

  def check_user_level_and_site
    user = User.current_user
    if CONFIG['site_type'] == "facility" && user.role != "System Administrator"
      redirect_to "/logout" and return  if user.site_code.to_s != CONFIG['facility_code'].to_s
    end
    if CONFIG['site_type'] == "dc" && user.role != "System Administrator"
      redirect_to "/logout" and return  if user.site_code.present?
    end
  end

  def check_database
    create_query = "CREATE TABLE IF NOT EXISTS documents (
                    id int(11) NOT NULL AUTO_INCREMENT,
                    couchdb_id varchar(255) NOT NULL UNIQUE,
                    group_id varchar(255) DEFAULT NULL,
                    group_id2 varchar(255) DEFAULT NULL,
                    date_added datetime DEFAULT NULL,
                    title TEXT,
                    content TEXT,
                    created_at datetime NOT NULL,
                    updated_at datetime NOT NULL,
                    PRIMARY KEY (id),
                    FULLTEXT KEY content (content)
                  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    SQLSearch.query_exec(create_query)
                      
  end

  def access_denied
    respond_to do |format|
      format.html { redirect_to login_path(referrer_param => current_path) }
      format.any  { head :unauthorized }
    end
  end

end
