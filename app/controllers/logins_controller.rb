class LoginsController < ApplicationController
  skip_before_filter :perform_basic_auth, :only => :logout

  def login
    @portal = nil
    if SETTINGS['site_type'] == "remote" && params["referrer"].present?
      uri = URI::parse(params["referrer"])
      @portal = uri.query.split("=")[1] rescue nil
    end
    @districts = []
    DistrictRecord.all.each  do |e| 
       next if e.name.include?("City")
       next if SETTINGS['exclude'].split(",").include?(e.name)
       @districts << e.name
    end
    render :layout => false
  end

  def create
    username = params[:user][:username]
    password = params[:user][:password]
    #user = User.get_active_user(username)
    user = UserModel.where(username: username, active: 1).first

    if SETTINGS['site_type'] == "remote"
      district = DistrictRecord.where(name: params[:user][:district]).first

      if user.present? && user.district_code != district.id
              flash[:error] = 'User does not have rights for the district selected'
              redirect_to "/login" and return
      end
    end
    if user and user.password_matches?(password)
      
      session[:current_user_id] = user.username

      ############## Checking if the user is from the district ####################################
      if SETTINGS['site_type'] != "remote"

          if (user.district_code != SETTINGS['district_code']) 
            if (user.role !="System Administrator") && (user.site_code != "HQ")
                logout!
                flash[:error] = 'Your user credentilas is not from this district'
                redirect_to "/", referrer_param => referrer_path and return
            end
            
          end 
      else
        #do something if remote
        if (user.role !="System Administrator") && (user.site_code != "HQ")
          user_district = DistrictRecord.find(user.district_code).name

          if SETTINGS['exclude'].split(",").include? user_district

                logout!
                flash[:error] = 'You user district has a pilot version'
                redirect_to "/", referrer_param => referrer_path and return
            
          end
        end

      end

      ###############################################################################################
      
      site_type = SETTINGS['site_type']
      if site_type =="dc"
        site_type = "DC"
      else
        site_type = site_type.humanize
      end
      roles = Role.by_level.key(site_type).collect{|r| r.role}
      if roles.include? user.role
        user_access = UserAccess.by_user_id.key(user.id).last
        if SETTINGS['restrict_same_creatials_for_multiple_users'] && user_access.present?
            flash[:error] = 'Another user has already login with the details you have entered'
            redirect_to "/login" and return
        end
        
        login!(user,params[:remote_portal])

        # Password expirely should be refined
=begin
        if (Time.now.to_date - user.last_password_date.to_date).to_i >= 90 && false
          
           if user.role =="System Administrator"
            redirect_to "/" and return 
           end

           if user.password_attempt >= 5 && (SETTINGS['password_can_expire'] rescue false)
             logout!
             flash[:error] = 'Your password has expired.Please contact your System Administrator.'
             redirect_to "/", referrer_param => referrer_path and return
           else
             @password_attempt = user.password_attempt
             user.update_attributes(:password_attempt => user.password_attempt + 1)

             flash[:error] = 'Your password has expired.Please change it!!! or you will be logged out'
             redirect_to "/change_password" and return
           end
        else
          
           if user.role !="System Administrator"
             if (Time.now.to_date - user.last_password_date.to_date).to_i >= 85 && (Time.now.to_date - user.last_password_date.to_date).to_i < 90
             		flash[:info] = 'Your password will expire soon. Please change it.'
             end
           end
           redirect_to default_path and return
        end 
=end  
        redirect_to default_path and return
      else
          flash[:error] = 'That username and/or password is not valid for this level'
          redirect_to "/login" and return
      end
    else
      flash[:error] = 'That username and/or password is not valid.'
      redirect_to "/login" and return
    end
  end

  def logout
    # session[:touchcontext] = nil
    if User.current_user.present?
      MyLock.by_user_id.key(User.current_user.id).each do |lock|
        lock.destroy
      end      
    end

    begin
      user_access = UserAccess.by_user_id.key(User.current_user.id).each rescue []
      user_access.each do |access|
        access.destroy
      end      
    rescue Exception => e
      
    end


    logout!
   
    if SETTINGS['app_gate_url'].present?
      redirect_to SETTINGS['app_gate_url'].to_s
    else
      flash[:notice] = "User #{session[:current_user_id].present? ? session[:current_user_id] : ''} has been logged out"
      redirect_to "/", referrer_param => referrer_path and return
    end
  end



  def login_wrapper
    
  end

  def set_context
    session[:touchcontext] = params[:id]

    render :text => "OK"
  end

  protected

  def default_path
    '/'
  end

  def perform_basic_auth
    authorize! :access, :login
  end

  def access_denied
    redirect_to default_path
  end

end
