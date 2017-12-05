class LoginsController < ApplicationController
  skip_before_filter :perform_basic_auth, :only => :logout

  def login
    render :layout => false
  end

  def create
    username = params[:user][:username]
    password = params[:user][:password]
    user = User.get_active_user(username)
    if user and user.password_matches?(password)

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
        login! user
        if (Time.now.to_date - user.last_password_date.to_date).to_i >= 90
           if user.password_attempt >= 5 && username.downcase != 'admin'
             logout!
             flash[:error] = 'Your password has expired.Please contact your System Administrator.'
             redirect_to "/", referrer_param => referrer_path and return
           else
             user.update_attributes(:password_attempt => user.password_attempt + 1)
             flash[:error] = 'Your password has expired.Please change it!!!'
             redirect_to "/change_password" and return
           end
        else
        
           if (Time.now.to_date - user.last_password_date.to_date).to_i >= 85 && (Time.now.to_date - user.last_password_date.to_date).to_i < 90
           		flash[:info] = 'Your password will expire soon. Please change it.'
           end

           redirect_to default_path and return
        end   
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
    flash[:notice] = "User #{User.current_user.username rescue ''} has been logged out"

    logout!
   
    if SETTINGS['app_gate_url'].present?
      redirect_to SETTINGS['app_gate_url'].to_s
    else
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
