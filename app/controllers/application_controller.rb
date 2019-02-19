require 'open3'
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
                "find_identifier",
                "dispatch_barcodes",
                "do_print_these",
                "death_certificate",
                "hq_is_online"]
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
      return HealthFacility.by_facility_code.key(SETTINGS['facility_code'].to_s).last rescue nil
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

  def unlock_users_record(person)
      MyLock.by_user_id_and_person_id.key([User.current_user.id,person.id]).each do |lock|
            lock.destroy
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

  def place_of_death(person)
    place_of_death = ""
    case person.place_of_death
      when "Home"
          if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0
              place_of_death = person.place_of_death_village
          end
          if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0
              place_of_death = "#{place_of_death}, #{person.place_of_death_ta}"
          end
          if person.place_of_death_district.present? && person.place_of_death_district.to_s.length > 0
              place_of_death = "#{place_of_death}, #{person.place_of_death_district}"
          end
      when "Health Facility"
          place_of_death = "#{person.hospital_of_death}, #{person.place_of_death_district}"
      else  
          place_of_death = "#{person.other_place_of_death}, #{person.place_of_death_district}"
      end

      if person.place_of_death && person.place_of_death.strip.downcase.include?("facility")
                 place_of_death = "#{person.hospital_of_death}, #{person.place_of_death_district}"
      elsif person.place_of_death_foreign && person.place_of_death_foreign.strip.downcase.include?("facility")
             if person.place_of_death_foreign_hospital.present? && person.place_of_death_foreign_hospital.to_s.length > 0
                place_of_death  = person.place_of_death_foreign_hospital
             end
              
             if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
                if person.place_of_death_country == "Other"
                  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
                end
                 
             end
      elsif person.place_of_death_foreign && person.place_of_death_foreign.strip =="Home"

              if person.place_of_death_foreign_village.present? && person.place_of_death_foreign_village.length > 0
                 place_of_death = person.place_of_death_foreign_village
              end

              if person.place_of_death_foreign_district.present? && person.place_of_death_foreign_district.to_s.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_district}"
              end

              if person.place_of_death_foreign_state.present? && person.place_of_death_foreign_state.to_s.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_state}"
              end

              if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
                if person.place_of_death_country == "Other"
                  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
                end
                 
              end
        elsif person.place_of_death_foreign && person.place_of_death_foreign.strip =="Other"
               if person.other_place_of_death.present? && person.other_place_of_death.to_s.length > 0
                 place_of_death = person.other_place_of_death
              end

              if person.place_of_death_foreign_village.present? && person.place_of_death_foreign_village.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_village}"
              end

              if person.place_of_death_foreign_district.present? && person.place_of_death_foreign_district.to_s.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_district}"
              end

              if person.place_of_death_foreign_state.present? && person.place_of_death_foreign_state.to_s.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_state}"
              end

              if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
                if person.place_of_death_country == "Other"
                  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
                end
                 
              end

      elsif person.place_of_death  && person.place_of_death =="Other"
                if person.other_place_of_death.present?
                    place_of_death  = person.other_place_of_death;
                end
                if person.place_of_death_district.present?
                    place_of_death = "#{place_of_death}, #{person.place_of_death_district}"
                end
      elsif person.place_of_death  && person.place_of_death =="Home"
          if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0
            if person.place_of_death_village == "Other"
               place_of_death = person.other_place_of_death_village
            else
               place_of_death = person.place_of_death_village
            end
             
          end
          if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0
            if person.place_of_death_ta == "Other"
                place_of_death = "#{place_of_death}, #{person.other_place_of_death_ta}"
            else
                place_of_death = "#{place_of_death}, #{person.place_of_death_ta}"
            end
              
          end
          if person.place_of_death_district.present? && person.place_of_death_district.to_s.length > 0
              place_of_death = "#{place_of_death}, #{person.place_of_death_district}"
          end

    end
    return place_of_death 
  end

  def fields_for_data_table(person)

      return {
          drn: (person.drn rescue nil),
          den: (person.den rescue nil),
          name: "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name}",
          gender:     person.gender,
          dob:        person.birthdate.strftime("%d/%b/%Y"),
          dod:        person.date_of_death.strftime("%d/%b/%Y"),
          place_of_death: place_of_death(person),
          person_id:  person.id
        }
  end

  def person_selective_fields(person)

      den = PersonIdentifier.by_person_record_id_and_identifier_type.key([person.id,"DEATH ENTRY NUMBER"]).first

      if PersonRecordStatus.by_person_recent_status.key(person.id).last.present?
        status = PersonRecordStatus.by_person_recent_status.key(person.id).last.status
      else
        last_status = PersonRecordStatus.by_person_record_id.key(person.id).each.sort_by{|d| d.created_at}.last
        
        states = {
                    "DC ACTIVE" =>"DC COMPLETE",
                    "DC COMPLETE" => "MARKED APPROVAL",
                    "MARKED APPROVAL" => "MARKED APPROVAL"
                 }
        if last_status.blank?
           PersonRecordStatus.change_status(person, "DC ACTIVE")
        elsif states[last_status.status].blank?
          PersonRecordStatus.change_status(person, "DC COMPLETE")
        else  
          PersonRecordStatus.change_status(person, states[last_status.status])
        end  
          status = PersonRecordStatus.by_person_recent_status.key(person.id).last.status
      end

      return {
                      _id: person.id,
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
                      other_home_village: (person.other_home_village  rescue ""),
                      home_ta:  (person.home_ta rescue ""),
                      other_home_ta:  (person.other_home_ta rescue ""),
                      home_district: (person.home_district rescue ""),
                      home_country:  ( person.home_country rescue ""),
                      current_village: (person.current_village  rescue ""),
                      other_current_village: (person.other_current_village  rescue ""),
                      current_ta:  (person.current_ta rescue ""),
                      other_current_ta:  (person.other_current_ta rescue ""),
                      current_district: (person.current_district rescue ""),
                      current_country:  ( person.current_country rescue ""),
                      den: (den.identifier rescue ""),
                      status: status,
                      nationality: person.nationality,
                      death_place: place_of_death(person)

                     }
  end

  def create_barcode(person)
    if person.npid.blank?
       npid = Npid.by_assigned.keys([false]).first
       person.npid = npid.national_id
       person.save
    end
    `bundle exec rails r bin/generate_barcode #{person.npid.present?? person.npid : '123456'} #{person.id} #{SETTINGS['barcodes_path']}`
  end

  def create_qr_barcode(person)
    if person.npid.blank?
       npid = Npid.by_assigned.keys([false]).first
       person.npid = npid.national_id
       person.save
    end
    `bundle exec rails r bin/generate_qr_code #{person.id} #{SETTINGS['qrcodes_path']}`    
  end
  def is_up?(host)
    host, port = host.split(':')
    a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
    b.scan(/succeeded/).length > 0
  end

  def hq_is_online
      hq_link = "#{SYNC_SETTINGS[:hq][:host]}:#{SYNC_SETTINGS[:hq][:port]}"
      online = is_up?(hq_link) rescue false
      if online
         render :text => {status: true}.to_json
      else
         render :text => {status: false}.to_json  
      end
  end

  protected

  def login!(user,portal_link = nil)
    session[:current_user_id] = user.username
    user_access = UserAccess.create(user_id: user.id,portal_link: portal_link)
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
          AssignDen.perform_in(job_interval)
        end
        
    end

    process = fork{
      Kernel.system "curl -s #{SETTINGS['app_jobs_url']}/application/start_couch_to_mysql"
    }
    Process.detach(process)
  end

  def check_user_level_and_site
    user = User.current_user
    return if user.blank?
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
