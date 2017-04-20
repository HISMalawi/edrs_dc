  class UsersController < ApplicationController
  before_action :set_user, :only => [:show, :edit, :edit_account, :update, :destroy]

  before_filter :check_if_user_admin

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

    if CONFIG['site_type']=="facility"

        @roles = Role.by_level.keys(["Facility"]).each.collect{|x| x.role}.uniq

    else

        @roles = Role.by_level.keys(["DC"]).each.collect{|x| x.role}.uniq
      
    end

    render :layout => "touch"
  end

  # GET /users/1/edit
  def edit

    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Update User"))

    @section = "Edit User"

    @targeturl = "/view_users"

     if CONFIG['site_type']=="facility"

        @roles = Role.by_level.keys(["Facility"]).each.collect{|x| x.role}.uniq

    else

        @roles = Role.by_level.keys(["DC"]).each.collect{|x| x.role}.uniq
      
    end

    render :layout => "touch"

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

      if CONFIG['site_type'] == "remote"

        @user.district_code = District.by_name.key(params[:user]['district']).first.id 

      else

        @user.district_code = CONFIG['district_code']
        
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

    if params[:active].present? && params[:active] == "true"

      users = User.active_users.page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each

    elsif params[:active].present? && params[:active] == "false"

      users = User.inactive_users.page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each

    else
      users = User.all.page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 8)).each
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
    redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Change own password"))

    @section = "Change Password"

    @targeturl = "/"

    @user = User.current_user

    render :layout => false#render :layout => "facility"

  end

  def update_password
     
    user = User.current_user

    result = user.password_matches?(params[:old_password])
    
    if user && !user.password_matches?(params[:old_password]) 
    	 result = "not same"
    elsif user && user.password_matches?(params[:new_password]) 
    	 result = "same" 
    else
      user.update_attributes(:password_hash => params[:new_password], :password_attempt => 0, :last_password_date => Time.now)
      flash["notice"] = "Your new password has been changed succesfully" 
      Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Updated user password")
    end
    
    render :text => result

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

    if CONFIG['site_type'] =="facility"

          @facility_type = "Facility"

    else

            @facility_type = "DC"

    end

    @admin = ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)

  end

end

