class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery #with: :exception

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  exceptions =  ['login', 
                'logout', 
                'update_password', 
                'search_by_hospital',
                'search_by_district', 
                'search_by_ta', 
                'search_by_village',
                "update_field",
                "reject_record",
                "search_similar_record",
                "confirm_not_duplicate", 
                "confirm_duplicate",
                "create_burial_report",
                "mark_as_pending",
                "mark_for_reprint",
                "search_barcode",
                "proceed_amend",
                "block_user",
                "unblock_user",
                "database_load",
                "confirm_password",
                "update_password",
                "samePassword",
                "passwordLength",
                "confirm_username",
                "reaprove_record",
               "find_identifier"]
  before_filter :perform_basic_auth,:check_cron_jobs,:check_database,:check_den_table,:current_user_keyboard_preference, :except => exceptions

  rescue_from CanCan::AccessDenied,
              :with => :access_denied

  helper_method :current_user

  def configs
    YAML.load_file("#{Rails.root}/config/couchdb.yml")["#{Rails.env}"]
  end

  def site_type
    SETTINGS['site_type'].to_s
  end

  def facility    
      return HealthFacility.by_facility_code.key(SETTINGS['facility_code'].to_s).first rescue nil
  end

  def current_user_keyboard_preference
     @preferred_keyboard = User.current_user.preferred_keyboard rescue 'qwerty'
  end
  
  def district
      if facility.present?
           return District.find(facility.district_id) rescue nil
      else
          if SETTINGS['district_code'].blank?
            district_code = User.current_user.district_code.to_s

          else
            district_code = SETTINGS['district_code'].to_s
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
    if SETTINGS['site_type'] =="facility" || User.current_user.role == "Data Clerk" ||  User.current_user.role == "Nurse/Midwife"
      redirect_to "/people/"
    else
      redirect_to "/dc/"
    end   
  end

  def facility_info
    @facility = facility
    @district = district
    if SETTINGS['site_type'] =="facility"
      @facility_type = "Facility"
    elsif SETTINGS['site_type'] =="dc"
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

  def readable_format(result)
      person = Person.find(result['_id'])
      return [person.id, "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name} #{person.gender}"+
                    " Born on #{DateTime.parse(person.birthdate.to_s).strftime('%d/%B/%Y')} "+
                    " died on #{DateTime.parse(person.date_of_death.to_s).strftime('%d/%B/%Y')} " +
                    " at #{person.place_of_death_district}"]
  end
  protected

  def login!(user)
    session[:current_user_id] = user.username
    @current_user = user
    Audit.ip_address_accessor = request.remote_ip
    Audit.mac_address_accessor = ` arp #{request.remote_ip}`.split(/\n/).last.split(/\s+/)[2]
    Audit.create({
                          :record_id  => @current_user.id,
                          :audit_type => "User Access",
                          :reason     => "Log in"
    })

  end

  def logout!
    Audit.create({
                          :record_id  => session[:current_user_id],
                          :audit_type => "User Access",
                          :reason     => "Log out"
    })
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

  def check_cron_jobs
      last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
      job_interval = SETTINGS['ben_assignment_interval']
      job_interval = 1.5 if job_interval.blank?
      job_interval = job_interval.to_f
      now = Time.now

      if (now - last_run_time).to_f > job_interval
        if SETTINGS['site_type'].to_s != "facility"
          if (defined? PersonIdentifier.can_assign_den).nil?
            PersonIdentifier.can_assign_den = true
          end
          AssignDen.perform_in(2)
        end
        CouchSQL.perform_in(15)
      end

      cron_job_tracker = CronJobsTracker.first
      return if cron_job_tracker.blank?
      if Rails.env == 'development'
        if (now - (cron_job_tracker.time_last_synced.to_time rescue  Date.today.to_time)).to_i > 90
            SyncData.perform_in(60)
        end
       if (now - (cron_job_tracker.time_last_updated_sync.to_time rescue  Date.today.to_time)).to_i > 120
            UpdateSyncStatus.perform_in(90)
        end
      else
        if (now - (cron_job_tracker.time_last_synced.to_time rescue  Date.today.to_time)).to_i > 1000
            SyncData.perform_in(900)
        end
        if (now - (cron_job_tracker.time_last_updated_sync.to_time rescue  Date.today.to_time)).to_i > 1060
            UpdateSyncStatus.perform_in(1000)
        end
      end

  end

  def check_user_level_and_site
    user = User.current_user
    if SETTINGS['site_type'] == "facility" && user.role != "System Administrator"
      redirect_to "/logout" and return  if user.site_code.to_s != SETTINGS['facility_code'].to_s
    end
    if SETTINGS['site_type'] == "dc" && user.role != "System Administrator"
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
    SimpleSQL.query_exec(create_query);

    create_status_table = "CREATE TABLE IF NOT EXISTS person_record_status (
                            person_record_status_id varchar(225) NOT NULL,
                            person_record_id varchar(255) DEFAULT NULL,
                            status varchar(255) DEFAULT NULL,
                            prev_status varchar(255) DEFAULT NULL,
                            district_code varchar(255) DEFAULT NULL,
                            facility_code varchar(255) DEFAULT NULL,
                            voided tinyint(1) NOT NULL DEFAULT '0',
                            reprint tinyint(1) NOT NULL DEFAULT '0',
                            registration_type  varchar(255) DEFAULT NULL,
                            creator varchar(255) DEFAULT NULL,
                            updated_at datetime DEFAULT NULL,
                            created_at datetime DEFAULT NULL,
                          PRIMARY KEY (person_record_status_id)
                        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
    SimpleSQL.query_exec(create_status_table);   

    create_identifier_table = "CREATE TABLE IF NOT EXISTS person_identifier (
                                person_identifier_id varchar(225) NOT NULL,
                                person_record_id varchar(255) DEFAULT NULL,
                                identifier_type varchar(255) DEFAULT NULL,
                                identifier varchar(255) DEFAULT NULL,
                                check_digit text,
                                site_code varchar(255) DEFAULT NULL,
                                den_sort_value int(11) DEFAULT NULL,
                                drn_sort_value int(11) DEFAULT NULL,
                                district_code varchar(255) DEFAULT NULL,
                                creator varchar(255) DEFAULT NULL,
                                _rev varchar(255) DEFAULT NULL,
                                updated_at datetime DEFAULT NULL,
                                created_at datetime DEFAULT NULL,
                              PRIMARY KEY (person_identifier_id)
                            ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"  

    SimpleSQL.query_exec(create_identifier_table);            
                      
  end

  def check_den_table

    if SETTINGS['site_type'] != "facility"
        create_query_den_table = "CREATE TABLE IF NOT EXISTS dens (
                                      den_id int(11) NOT NULL AUTO_INCREMENT,
                                      person_id varchar(225) NOT NULL,
                                      den varchar(15) NOT NULL,
                                      den_sort_value varchar(15) NOT NULL,
                                      created_at datetime NOT NULL,
                                      updated_at datetime NOT NULL,
                                      PRIMARY KEY (den_id),
                                      UNIQUE KEY den (den),
                                      KEY person_id (person_id),
                                      CONSTRAINT dens_ibfk_1 FOREIGN KEY (person_id) REFERENCES people (person_id)
                                  ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
          #SimpleSQL.query_exec(create_query_den_table)
    end
  end


  def access_denied
    respond_to do |format|
      format.html { redirect_to login_path(referrer_param => current_path) }
      format.any  { head :unauthorized }
    end
  end

end
