class UsersController < ApplicationController

  before_action :set_user, :only => [:show, :edit, :edit_account, :update, :destroy]

  before_filter :check_if_user_admin

  @@file_path = "#{Rails.root.to_s}/app/assets/data/MySQL_data/"
  # GET /users
  # GET /users.json
  def index
    
    @section = "User Management"

    @targeturl = "/"

    @targettext = "Finish"
    
    render :layout => "landing"

  end

  # GET /users/1
  # GET /users/1.json
  def show
    
    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))


    @section = "View User"

    @targeturl = "/view_users"

    render :layout => "landing"

  end

  # GET /users/new
  def new

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Create User"))

    @user = User.new

    @section = "Create User"

    @targeturl = "/users"

    if SETTINGS['site_type']=="facility"

        @roles = Role.by_level.keys(["Facility"]).each.collect{|x| x.role}.uniq

    else

        @roles = Role.by_level.keys(["DC"]).each.collect{|x| x.role}.uniq
      
    end

    render :layout => "touch"
  end

  def districts
    
    cities = ["Lilongwe City", "Blantyre City", "Zomba City", "Mzuzu City"]
    
    if params["search_string"].present?
        entry = params["search_string"] rescue nil
        districts = District.by_name.startkey(entry).endkey("#{entry}\ufff0").limit(32).each
    else
        districts = District.all.each
    end
    
    names = []
    districts.each do |district|
        names << district.name unless cities.include? district.name
    end
    if SETTINGS['site_type']=="remote"
       render :text => names.collect { |w| "<li>#{w}" unless SETTINGS['exclude'].split(",").include? w }.join("</li>")+"</li>"
    else
       render :text => names.collect { |w| "<li>#{w}"}.join("</li>")+"</li>"
    end
   
  end

  # GET /users/1/edit
  def edit

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Update User"))

    @section = "Edit User"

    @targeturl = "/view_users"

     if SETTINGS['site_type']=="facility"

        @roles = Role.by_level.keys(["Facility"]).each.collect{|x| x.role}.uniq

    else

        @roles = Role.by_level.keys(["DC"]).each.collect{|x| x.role}.uniq
      
    end

    render :layout => "touch"

  end

  def keyboard_preference
      if params[:preferred_keyboard].present?
           @user = User.current_user rescue nil
           @user.preferred_keyboard = params[:preferred_keyboard]
           @user.save
           flash[:notice] = "Keyboard preference changed succesfully!"
           redirect_to '/my_account'
      else
       @user = User.current_user rescue nil
      end

  end

  def edit_account

    @user = @current_user

    @keyboards = ['abc', 'qwerty']

    @section = "Edit Account"

    @targeturl = "/users/my_account"

    render :layout => "touch"

  end

  # POST /users
  # POST /users.json
  def create

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Create User"))
     
      user = User.by_username.key(params[:user]['username']).first
      
      if user.present?

        flash["notice"] = "User already already exists"

        redirect_to "/users/new" and return

      end   
       
      @user = User.new()

      @user.username = params[:user]['username']

      @user.plain_password = params[:user]['password']

      @user.first_name = params[:user]['first_name']

      @user.last_name = params[:user]['last_name']

      @user.role = params[:user]['role']

      @user.email = params[:user]['email']

      if SETTINGS['site_type'] == "remote"

        @user.district_code = District.by_name.key(params[:user]['district']).first.id 

      else

        @user.district_code = SETTINGS['district_code']
        
      end

      
      
    respond_to do |format|
    
      if @user.save
        format.html { redirect_to @user, :notice => 'User was successfully created.' }
        format.json { render :show, :status => :created, :location => @user }
      else
        format.html { render :new }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    
    if request.referrer.match('edit_account')
      @current_user.preferred_keyboard = params[:user][:preferred_keyboard]
      @current_user.save!
      Audit.create(record_id: @current_user.id, audit_type: "Audit", level: "User", reason: "Updated user preference")
      redirect_to '/users/my_account' and return
    end
    
    if params[:user][:password].present? && params[:user][:password].length > 1
      @user.update_attributes(:password_hash => params[:user][:password], :password_attempt => 0, :last_password_date => Time.now)
       Audit.create(record_id: @user.id, audit_type: "Audit", level: "User", reason: "Updated user password")
    end

    respond_to do |format|
      if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false) and @user.update_attributes(user_params)
         Audit.create(record_id: @user.id, audit_type: "Audit", level: "User", reason: "Updated user") 
        format.html { redirect_to @user, :notice => 'User was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @user }
      else
        format.html { render :edit }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end

  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Deactivate User"))

    @user.destroy if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
    Audit.create(record_id: @user.id, audit_type: "Audit", level: "User", reason: "Destroyed user")
    respond_to do |format|
      format.html { redirect_to "/view_users", :notice => 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def block

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Deactivate User"))

    @users = User.all.each

    @section = "Block User"

    @targeturl = "/users"

    render :layout => false#render :layout => "facility"

  end

  def unblock

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Activate User"))

    @users = User.all.each

    @section = "Unblock User"

    @targeturl = "/users"

    render :layout => false#render :layout => "facility"

  end

  def block_user
    redirect_to "/" and return if !(User.current_user.activities_by_level(@facility_type).include?("Deactivate User"))

    user = User.find(params[:id]) rescue nil

    if !user.nil?

      user.update_attributes(:active => false, :un_or_block_reason => params[:reason]) if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
      Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Blocked user")

    end

    if params[:next_url].present?
      redirect_to params[:next_url] and return
    else
      redirect_to "/view_users" and return
    end

  end

  def unblock_user

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Activate User"))

    user = User.find(params[:id]) rescue nil

    if !user.nil?

      user.update_attributes(:active => true, :un_or_block_reason => params[:reason]) if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
      Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Unblocked user")

    end

    if params[:next_url].present?
      redirect_to params[:next_url] and return
    else
      redirect_to "/view_users" and return
    end

  end

  def view

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    @users = User.all.each

    @section = "View Users"

    @targeturl = "/users"

    render :layout => "landing"

  end

  def query

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    results = []
    if params[:active].present?
      if SETTINGS['site_type'] == "facility" && SETTINGS['facility_code'].present?
          key = [SETTINGS['facility_code'].to_s, eval(params[:active])]
          users = User.by_facility_activation.key(key).page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each
      elsif SETTINGS['site_type'] == "dc" && SETTINGS['district_code'].present?
          key = [SETTINGS['district_code'],eval(params[:active])]
          users = User.by_district_actication.key(key).page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each
      else
           users = User.by_active.key(eval(params[:active])).page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each
      end
    else
      if SETTINGS['site_type'] == "facility" && SETTINGS['facility_code'].present?
        users = User.by_site_code.key(SETTINGS['facility_code'].to_s).page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each
      elsif  SETTINGS['site_type'] == "dc" && SETTINGS['district_code'].present?
        users = User.by_district_code.key(SETTINGS['district_code'].to_s).page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each
      else
        users = User.all.page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each
      end
    end
    users.each do |user|

      record = {
          "id"  => "#{user.id}",
          "username" => "#{user.username}",
          "name" => "#{user.first_name} #{user.last_name}",
          "roles" => "#{user.role}",
          "active" => (user.active rescue false)
      }

      results << record

    end

    render :text => results.to_json

  end

  def search

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    @section = "Search for User"

    @targeturl = "/users"

    render :layout => false#render :layout => "facility"

  end

  def view_active
    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    @users = User.all.each

    @section = "Active Users"

    @targeturl = "/users"

    render :layout => "landing"
  end

  def view_blocked
    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    @users = User.all.each

    @section = "Blocked Users"

    @targeturl = "/users"

    render :layout => "landing"
  end

  def add_comment
    @user = User.find(params[:id]);
    if params[:operation] =="Block"
        @action = '/block_user'
    elsif  params[:operation] =="Unblock"
        @action = '/unblock_user'
    end
    
  end
  def search_by_username

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    name = params[:id].strip rescue ""

    results = []

    if name.length > 1

      users = User.by_username.key(name).limit(10).each

    else

      users = User.by_username.limit(10).each

    end

    users.each do |user|

      next if user.username.strip.downcase == User.current_user.username.strip.downcase

      record = {
          "username" => "#{user.username}",
          "fname" => "#{user.first_name}",
          "lname" => "#{user.last_name}",
          "role" => "#{user.role}",
          "active" => (user.active rescue false)
      }

      results << record

    end

    render :text => results.to_json

  end
  
  def search_by_active

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    status = params[:status] == "true" ? true : false 
  
    results = []

    users = User.by_active.key(status).limit(10).each
     
    users.each do |user|

      next if user.username.strip.downcase == User.current_user.username.strip.downcase

      record = {
          "username" => "#{user.username}",
          "fname" => "#{user.first_name}",
          "lname" => "#{user.last_name}",
          "role" => "#{user.role}",
          "active" => (user.active rescue false)
      } 

      results << record

    end

    render :text => results.to_json

  end
  
  def confirm_username

       
      username = params[:username]

      user = User.by_username.key(username).last
          
      if user
          render :text => {:response => true}.to_json
      else
        render :text => {:response => false}.to_json
      end
           
  end

  

  def username_availability
    user = User.get_active_user(params[:search_str])
    render :text => user = user.blank? ? 'OK' : 'N/A' and return
  end

  def my_account
    
    redirect_to "/" and return if !(User.current_user.activities_by_level(@facility_type).include?("Change own password"))

    @section = "My Account"

    @user = User.current_user

    render :layout => "landing"

  end

  def change_password
    redirect_to "/" and return if !(User.current_user.activities_by_level(@facility_type).include?("Change own password"))

    @section = "Change Password"

    @targeturl = "/change_password"

    @user = User.current_user

    render :layout => "touch"#false#render :layout => "facility"

  end
  def confirm_password
      user = User.current_user rescue User.find(params[:user_id])
      password = params[:old_password]
      if user.password_matches?(password)
          render :text => {:response => true}.to_json
      else
        render :text => {:response => false}.to_json
      end
        
  end

  def update_password
     
    user = User.current_user
    user.plain_password = params[:user][:new_password]
    user.password_attempt = 0
    user.last_password_date = Time.now
    user.save
    
    flash["notice"] = "Your new password has been changed succesfully" 
    Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Updated user password")
    
    redirect_to '/my_account'

  end

  def build_mysql
    render :layout => "landing"
  end

   def build_mysql_database
    @section = "Build MSQL"
    start_date = "1900-01-01 00:00:00".to_time
    #end_date = (Date.today - 1.day).to_date.strftime("%Y-%m-%d 23:59:59").to_time
    end_date = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time

    @couchdb_files = {
      'Person' => {count: Person.count, name: 'Person doc.', id: 'person_doc', 
        doc_primary_key: 'person_id', table_name: 'people'},

      'PersonIdentifier' => {count: PersonIdentifier.count, name: 'PersonIdentifier doc.', 
        id: 'person_identifier_doc', doc_primary_key: 'person_identifier_id', table_name: 'person_identifier'},

      'PersonRecordStatus' => {count: PersonRecordStatus.count, name: 'PersonRecordStatus doc.', 
        id: 'person_record_status_doc', doc_primary_key: 'person_record_status_id', table_name: 'person_record_status'},
      
      'District' => {count: District.count, name: 'District doc.', 
        id: 'district_doc', doc_primary_key: 'district_id', table_name: 'district'},

      'Nationality' => {count: Nationality.count, name: 'Nationality doc.', 
        id: 'nationality_doc', doc_primary_key: 'nationality_id', table_name: 'nationality'},

      'Village' => {count: Village.count, name: 'Village doc.', 
        id: 'village_doc', doc_primary_key: 'village_id', table_name: 'village'},

      'TraditionalAuthority' => {count: TraditionalAuthority.count, name: 'TraditionalAuthority doc.', 
        id: 'traditional_authority_doc', doc_primary_key: 'traditional_authority_id', table_name: 'traditional_authority'},

      'User' => {count: User.count, name: 'User doc.', 
        id: 'user_doc', doc_primary_key: 'user_id', table_name: 'user'},

      'Role' => {count: Role.count, name: 'Role doc.', 
        id: 'role_doc', doc_primary_key: 'role_id', table_name: 'role'},

      'Country' => {count: Country.count, name: 'Country doc.', 
        id: 'country_doc', doc_primary_key: 'country_id', table_name: 'country'}

    }

    (@couchdb_files || []).each do |doc, data|
      create_file(data[:doc_primary_key], doc, data[:table_name])
    end
    render :layout => "landing"
  end

  def create_mysql_database
    start_date = "1900-01-01 00:00:00".to_time
    #end_date = (Date.today - 1.day).to_date.strftime("%Y-%m-%d 23:59:59").to_time
    end_date = DateTime.now
    data = [] ; sql_insert_field_plus_data = {}
    set_model = eval(params[:model_name])
    table_name = params[:table_name]
    records_per_page = params[:records_per_page].to_i
    page_number = params[:page_number].to_i
    table_primary_key = params[:table_primary_key]

    begin
      count = set_model.by_updated_at.startkey(start_date).endkey(end_date).page(page_number).per(records_per_page).each.count
    rescue
      count = set_model.all.page(page_number).per(records_per_page).each.count
    end

    if count > 0
      begin
        count_couchdb = set_model.by_updated_at.startkey(start_date).endkey(end_date).page(page_number).per(records_per_page).each
      rescue
        count_couchdb = set_model.all.page(page_number).per(records_per_page).each
      end

      sql_statement =<<EOF

EOF

      sql_statement += "INSERT INTO #{table_name} (#{table_primary_key}, "
    else
      render text: {people_count: count }.to_json  and return
    end

    (count_couchdb || []).each do |person|
      sql_insert_field_plus_data[person.id] = [] if sql_insert_field_plus_data[person.id].blank?
      (person.properties || []).each do |property|
        sql_insert_field_plus_data[person.id] << {
          name: "#{property.name}" , data: person.send(property.name),
          type: property.type.to_s
        }    
      end
    end 

    (sql_insert_field_plus_data || []).each do |id, statements|
      (statements || []).each do |statement|
        sql_statement += "#{statement[:name]}, "
      end
      break
    end
    sql_statement = ("#{sql_statement[0..-3]}) VALUES ")

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts sql_statement
    end



    sql_statement = ''
    (sql_insert_field_plus_data || []).each do |id, statements|
      sql_statement += "('#{id}', "

      (statements || []).each do |statement|
        if statement[:data].blank?
          if statement[:type] == 'TrueClass'
            sql_statement += "0, "
          else 
            sql_statement += "NULL, "
          end
        elsif statement[:type] == 'Integer' || statement[:type] == 'TrueClass'
          sql_statement += "'#{statement[:data]}',"
        elsif statement[:type] == 'Date'
          sql_statement += '"' + "#{statement[:data].to_date.strftime('%Y-%m-%d')}" + '",'
        elsif statement[:type] == 'Time'
          sql_statement += '"' + "#{statement[:data].to_time.strftime('%Y-%m-%d %H:%M:%S')}" + '",'
        else
          if statement[:data].to_s.match(/"/)
            sql_statement += "'" + "#{statement[:data]}" + "',"
          else
            sql_statement += '"' + "#{statement[:data]}" + '",'
          end
        end
      end
      sql_statement = sql_statement[0..-2] + '),'
    end
    sql_statement = sql_statement[0..-2] + ";"

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts sql_statement
    end

    render text: {people_count: count }.to_json  and return
  end

  def database_load
    @mysql_connection =  mysql_connection
    @documents = {}
    (params[:documents] || {}).each do |doc, count|
      sql_file_name = "#{doc}.sql"
      @documents[sql_file_name] = count.to_i
    end
    @section = "Load MSQL Dump"
    render :layout => 'landing'
    #raise @documents.inspect
  end

  def load_dumps

    database =mysql_connection['database']
    user = mysql_connection['username']
    password = mysql_connection['password']
    host = mysql_connection['host']

    file_path =  Rails.root.to_s + '/app/assets/data/MySQL_data/'

    @documents = Dir.foreach(file_path) do |file|
        if file.match(".sql")
            `nice mysql -u#{user} #{database} -p#{password} -h #{host} < #{file_path}#{file}`
        end
    end
    render :text => "loading dump"
  end

  def database_load_progress
    db_result = `nice mysql -u#{mysql_connection['username']} #{mysql_connection['database']} -p#{mysql_connection['password']} -e "select count(*) as c from #{params[:table_name]};"`
    dbcount = db_result.split("\n")[1].to_i rescue 0
    render text: { count: dbcount }.to_json and return
  end

  def mysql_connection
     YAML.load_file(File.join(Rails.root, "config", "database.yml"))[Rails.env]
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user

    @user = User.find(params[:id])

    @facility = facility

    @district = district

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :active, :create_at, :creator, :email, :first_name, :last_name, :notify, :plain_password, :role, :updated_at, :_rev)
  end

  def check_if_user_admin

    @facility = facility

    @district = district

    if SETTINGS['site_type'] =="facility"

          @facility_type = "Facility"

    else

            @facility_type = "DC"

    end

    @admin = ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)

  end

  def create_file(doc_primary_key, doc, table_name)
    #Create insert statments for all documets
    #Ducument path: app/assets/data/MySQL_data/
    
    if doc_primary_key.blank?
      doc_primary_key = 'id'
      person_table = <<EOF
        DROP TABLE IF EXISTS `#{table_name}`;
        CREATE TABLE `#{table_name}` (
        `#{doc_primary_key}` INT(11)  NOT NULL AUTO_INCREMENT,
EOF
    
    else
      person_table = <<EOF
        DROP TABLE IF EXISTS `#{table_name}`;
        CREATE TABLE `#{table_name}` (
        `#{doc_primary_key}` VARCHAR(225) NOT NULL,
EOF
    
    end

    (eval(doc).properties || []).each do |property|
      field_name = property.name
      case property.type.to_s
        when 'String'
          field_type = "VARCHAR(255) DEFAULT NULL"
        when 'Date'
          field_type = "date DEFAULT NULL"
        when 'Integer'
           if field_name.include?("sort_value")
            field_type = "VARCHAR(255) DEFAULT NULL"
          else 
            field_type = "INT(11) DEFAULT NULL"
          end
        when 'Time'
          field_type = "datetime DEFAULT NULL"
        when 'TrueClass'
          field_type = "tinyint(1) NOT NULL  DEFAULT '0'"
        else
          field_type = "TEXT DEFAULT NULL" 
      end
      person_table += <<EOF
      `#{field_name}` #{field_type},
EOF

    end

    person_table += <<EOF
      PRIMARY KEY (`#{doc_primary_key}`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
EOF

    if !File.exists?(@@file_path + "#{table_name}.sql")
      file = File.new(@@file_path + "#{table_name}.sql", 'w')
    end

    #deleting all file contents
    File.open(@@file_path + "#{table_name}.sql", 'w') do |f|
      f.truncate(0)
    end

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts person_table
    end

    return true
  end

end

