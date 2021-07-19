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
  before_filter :perform_basic_auth,:check_session_expirely,:check_database,:check_den_table,:current_user_keyboard_preference,:set_current_user, :except => exceptions

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
     @preferred_keyboard = UserModel.current_user.preferred_keyboard rescue 'qwerty'
  end
  def set_current_user
    @current_user = session[:current_user]
  end
  def district
      if facility.present?
           return District.find(facility.district_id) rescue nil
      else
          if SETTINGS['district_code'].blank?
            district_code = UserModel.current_user.district_code.to_s

          else
            district_code = SETTINGS['district_code'].to_s
          end
           
          district = District.find(district_code) rescue nil

          return district
      end     
  end


  def current_nationality
      return NationalityRecord.where(nationality: "Malawian").last
  end
  
  def check_if_user_admin
    @admin = ((UserModel.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
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
    if SETTINGS['site_type'] =="facility" || UserModel.current_user.role == "Data Clerk" ||  UserModel.current_user.role == "Nurse/Midwife"
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
    places['home_country'] = NationalityRecord.find(person.nationality_id).nationality rescue ""
    places['place_of_death_district'] = DistrictRecord.find(person.place_of_death_district_id).name rescue ""
    places['hospital_of_death'] = Facility.find(person.hospital_of_death_id).name rescue ""
    places['place_of_death_ta'] = TA.find(person.place_of_death_ta_id).name rescue ""
    places['place_of_death_village'] = VillageRecord.find(person.place_of_death_village_id).name rescue ""
    places['current_district'] = DistrictRecord.find(person.current_district_id).name rescue ""
    places['current_ta'] = TA.find(person.current_ta_id).name rescue ""
    places['current_village'] = VillageRecord.find(person.current_village_id).name rescue ""
    places['home_district'] = DistrictRecord.find(person.home_district_id).name rescue ""
    places['home_ta'] = TA.find(person.home_ta_id).name rescue ""
    places['home_village'] = VillageRecord.find(person.home_village_id).name rescue ""
    places['informant_current_district'] = DistrictRecord.find(person.informant_current_district_id).name rescue ""
    places['informant_current_ta'] = TA.find(person.informant_current_ta_id).name rescue ""
    places['informant_current_village'] = VillageRecord.find(person.informant_current_village_id).name rescue ""
    return places

  end

  def to_readable(person)
    (1..4).each do |i|
      if person["cause_of_death#{i}"].blank?
        person["cause_of_death#{i}"] = (person["other_cause_of_death#{i}"] rescue "")
      end
      secs = person["onset_death_interval#{i}"].to_i
      time_to_string = [[60, :second], [60, :minute], [24, :hour], [365, :day],[1000, :year]].map{ |count, name|
        if secs > 0
          secs, n = secs.divmod(count)
          if n > 0 
            if n == 1
              "#{n.to_i} #{name}"
            elsif n > 1
              "#{n.to_i} #{name}s"
            end
          end
        end
      }.compact.reverse.join(' ')
      person["onset_death_interval#{i}"] = time_to_string
    end
    return person
  end

  def readable_format(result)
      person = Record.find(result['_id'])
      return [person.id, "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name} #{person.gender}"+
                    " Born on #{DateTime.parse(person.birthdate.to_s).strftime('%d/%B/%Y')} "+
                    " died on #{DateTime.parse(person.date_of_death.to_s).strftime('%d/%B/%Y')} " +
                    " at #{person.place_of_death_district}"]
  end

  def place_of_death(person)
    place_of_death = ""
    case person['place_of_death']
      when "Home"
          if person["place_of_death_village"].present? && person["place_of_death_village"].to_s.length > 0
              place_of_death = person["place_of_death_village"]
          end
          if person["place_of_death_ta"].present? && person["place_of_death_ta"].to_s.length > 0
              place_of_death = "#{place_of_death}, #{person['place_of_death_ta']}"
          end
          if person["place_of_death_district"].present? && person["place_of_death_district"].to_s.length > 0
              place_of_death = "#{place_of_death}, #{person['place_of_death_district']}"
          end
      when "Health Facility"
          place_of_death = "#{person['hospital_of_death']}, #{person['place_of_death_district']}"
      else  
          place_of_death = "#{person['other_place_of_death']}, #{person['place_of_death_district']}"
      end

      if person["place_of_death"] && person["place_of_death"].strip.downcase.include?("facility")
                 place_of_death = "#{person['hospital_of_death']}, #{person['place_of_death_district']}"
      elsif person["place_of_death_foreign"] && person["place_of_death_foreign"].strip.downcase.include?("facility")
             if person["place_of_death_foreign_hospital"].present? && person["place_of_death_foreign_hospital"].to_s.length > 0
                place_of_death  = person["place_of_death_foreign_hospital"]
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

  def data_table_entry(person, den=false)
    row = []
   
    if den.present? && den=="true"
       row << person.den
    end
      row = row + [
                   "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name} (#{person.gender.first})",
                   person.birthdate.strftime("%d/%b/%Y"),
                   person.date_of_death.strftime("%d/%b/%Y"),
                   place_of_death(person), 
                  "#{person.informant_first_name} #{person.informant_middle_name rescue ''} #{person.informant_last_name}",
                   person.id]
 end

  def person_selective_fields(person)


      den = RecordIdentifier.where(person_record_id: person.id, identifier_type: "DEATH ENTRY NUMBER").first

      connection = ActiveRecord::Base.connection
      statuses_query = "SELECT * FROM person_record_status WHERE  person_record_id='#{person.id}' ORDER BY created_at"
      statuses = connection.select_all(statuses_query).as_json

      status = statuses.last
      status = statuses.last['status']


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
      if SETTINGS["site_type"] == "facility"
          url = "#{SYNC_SETTINGS[:dc][:protocol]}://#{SYNC_SETTINGS[:dc][:host]}:#{SYNC_SETTINGS[:dc][:port]}/"
      else
          url = "#{SYNC_SETTINGS[:hq][:protocol]}://#{SYNC_SETTINGS[:hq][:host]}:#{SYNC_SETTINGS[:hq][:port]}/"
      end
      url = URI.parse(url)
      req = Net::HTTP.new(url.host, url.port)
      res = req.request_head(url.path)
      puts "#{url}api/v1/dc_sync"

      if ["200","201","202","204","302"].include?(res.code.to_s)  
         render :text => {status: true}.to_json
      else
         render :text => {status: false}.to_json  
      end
  end

  protected

  def login!(user,portal_link = nil)
    
    session[:current_user_id] = user.username
    session[:current_user] = user
    if SETTINGS["site_type"] == "remote"
        session[:district_code] = user.district_code 
    else
        session[:district_code] = SETTINGS["district_code"]     
    end
   

    @current_user = user
  
    AuditRecord.create({
                          :record_id  => @current_user.id,
                          :audit_type => "User Access",
                          :reason     => "Log in",
                          :level => "User"
    })

  end

  def logout!

    AuditRecord.create({
                          :record_id  => session[:current_user_id],
                          :audit_type => "User Access",
                          :reason     => "Log out",
                          :level => "User"
    })
    session[:current_user_id] = nil
    session[:current_user] = nil
    @current_user = nil
  end

  def current_user
    unless @current_user == false # meaning a user has previously been established as not logged in
      @current_user ||= authenticate_from_session || authenticate_from_basic_auth || false
      UserModel.current_user = @current_user
    end
  end

  def authenticate_from_basic_auth
    authenticate_with_http_basic do |user_name, password|
      user = UserModel.get_active_user(user_name)
      if user and user.password_matches?(password)
        return user
      else
        return false
      end
    end
  end

  def authenticate_from_session
    unless session[:current_user_id].blank?
      user = UserModel.get_active_user(session[:current_user_id])
      return user
    end
  end

  def perform_basic_auth
    authorize! :access, :anything
  end

  def check_session_expirely
    if session[:expires_at].present?
      if session[:expires_at].to_time < Time.now
          session[:expires_at] = nil
          flash[:error] = 'You have been log out'
          redirect_to "/login" and return
      else
          session[:expires_at] =  Time.current + 4.hours         
      end
    end    
  end

  def check_user_level_and_site
    user = UserModel.current_user
    return if user.blank?
    if SETTINGS['site_type'] == "facility" && user.role != "System Administrator"
      redirect_to "/logout" and return  if user.site_code.to_s != SETTINGS['facility_code'].to_s
    end
    if SETTINGS['site_type'] == "dc" && user.role != "System Administrator"
      redirect_to "/logout" and return  if user.site_code.present?
    end
  end

  def check_database

    if SETTINGS['use_mysql_potential_search']
      create_query = "CREATE TABLE IF NOT EXISTS potential_search (
                      id int(11) NOT NULL AUTO_INCREMENT,
                      person_id varchar(255) NOT NULL UNIQUE,
                      content TEXT,
                      created_at datetime NOT NULL,
                      updated_at datetime NOT NULL,
                      PRIMARY KEY (id),
                      FULLTEXT KEY content (content)
                    )ENGINE=InnoDB DEFAULT CHARSET=latin1;"

      SimpleSQL.query_exec(create_query);
    end 

    create_audit_trail_table = "CREATE TABLE IF NOT EXISTS audit_trail(
                                  audit_record_id VARCHAR(255) NOT NULL,
                                  record_id VARCHAR(255) NOT NULL,
                                  audit_type VARCHAR(50) DEFAULT NULL,
                                  level VARCHAR(50) NOT NULL,
                                  model VARCHAR(50) DEFAULT NULL,
                                  field VARCHAR(50) DEFAULT NULL,
                                  previous_value VARCHAR(255) DEFAULT NULL,
                                  current_value VARCHAR(255) DEFAULT NULL,
                                  reason VARCHAR(255) DEFAULT NULL,
                                  user_id VARCHAR(255) DEFAULT NULL, 
                                  site_id VARCHAR(255) DEFAULT NULL,
                                  site_type VARCHAR(50) DEFAULT NULL,
                                  ip_address VARCHAR(64) DEFAULT NULL,
                                  mac_address VARCHAR(255) DEFAULT NULL,
                                  change_log VARCHAR(255) DEFAULT NULL,
                                  creator VARCHAR(255) DEFAULT NULL,
                                  voided INT(1) DEFAULT NULL,
                                  created_at DATETIME DEFAULT NULL,
                                  updated_at DATETIME DEFAULT NULL,
                                  PRIMARY KEY (audit_record_id)) ENGINE=InnoDB DEFAULT CHARSET=latin1;;"          
    SimpleSQL.query_exec(create_audit_trail_table); 
    create_local_configuration ="CREATE TABLE IF NOT EXISTS local_config (
                                    local_config_id varchar(200) NOT NULL,
                                    name varchar(50) NOT NULL,
                                    value int(1) NOT NULL,
                                    value_text varchar(100) NOT NULL,
                                    created_at datetime NOT NULL,
                                    updated_at datetime NOT NULL,
                                    PRIMARY KEY (local_config_id),
                                    UNIQUE KEY name (name)
                                  ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"    
      SimpleSQL.query_exec(create_local_configuration);              
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

  def person_hash(person)
      record = {}
      record["first_name"] = person.first_name
      record["last_name"] = person.last_name
      record["middle_name"] = (person.middle_name rescue nil)
      record["gender"] = person.gender.first
      record["birthdate"] = person.birthdate
      record["date_of_death"] = person.date_of_death
      record["mother_last_name"] = (person.mother_last_name rescue nil)
      record["mother_middle_name"] = (person.mother_middle_name rescue nil)
      record["mother_first_name"] = (person.mother_first_name rescue nil)
      record["father_last_name"] = (person.father_last_name rescue nil)
      record["father_middle_name"] = (person.father_middle_name rescue nil)
      record["father_first_name"] = (person.father_first_name rescue nil)
      record["person_id"] = person.id
      record["location"] = person.place_of_death_district
      return record
  end

  def access_denied
    respond_to do |format|
      format.html { redirect_to login_path(referrer_param => current_path) }
      format.any  { head :unauthorized }
    end
  end

end
