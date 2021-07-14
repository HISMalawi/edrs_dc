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

    if user and user.password_matches?(password)

      if  user.username != 'admin' and  user.district_code != SETTINGS['district_code']
        flash[:error] = 'That username and/or password is not valid.'
        redirect_to '/login' and return
          
      end

      session[:current_user_id] = user.username
      session[:current_user] = user
      session[:expires_at] =  Time.current + 4.hours

      login!(user,params[:remote_portal])
      redirect_to default_path and return
      #redirect_to "/" and return
    else
      flash[:error] = 'That username and/or password is not valid.'
      redirect_to '/login' and return
    end
  end

  def logout
    # session[:touchcontext] = nil
    if UserModel.current_user.present?
      MyLock.by_user_id.key(UserModel.current_user.id).each do |lock|
        lock.destroy
      end      
    end

    begin
      user_access = UserAccess.by_user_id.key(UserModel.current_user.id).each rescue []
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
