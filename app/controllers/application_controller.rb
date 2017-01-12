class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery #with: :exception

   skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :perform_basic_auth, :except => ['login', 'logout', 'update_password', 'search_by_hospital',
                                                 'search_by_district', 'search_by_ta', 'search_by_village',"update_field"]

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
    
      return HealthFacility.find(CONFIG['facility_code'].to_s) rescue nil
  end
  
  def district
      if facility.present?

           return District.find(facility.district_code) rescue nil

      else

           return District.find(CONFIG['district_code'].to_s) rescue nil

      end
     
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

        if person.first_name.blank? || person.last_name.blank? 

              return false

        end

        if person.place_of_death.blank?

              return false

        end

        return complete
    
  end


  #Root index of app
  def index

        if CONFIG['site_type'] =="facility"

          redirect_to "/people/"

        else

           redirect_to "/dc/"

        end
    
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

  def access_denied
    respond_to do |format|
      format.html { redirect_to login_path(referrer_param => current_path) }
      format.any  { head :unauthorized }
    end
  end

end
