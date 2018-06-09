require 'couchrest_model'

class User < CouchRest::Model::Base
  
  after_create :create_audit

  before_save :set_site

  property :username, String
  property :first_name, String
  property :last_name, String
  property :password_hash, String
  property :last_password_date, Time, :default => Time.now
  property :password_attempt, Integer, :default => 0
  property :login_attempt, Integer, :default => 0
  property :email, String
  property :active, TrueClass, :default => true
  property :notify, TrueClass, :default => false
  property :role, String
  property :district_code, String
  property :site_code, String
  property :preferred_keyboard, String, :default => 'abc'
  property :signature
  property :creator, String
  property :plain_password, String
  property :un_or_block_reason, String
  property :_rev, String

  timestamps!

  cattr_accessor :current_user

  def has_role?(role_name)
    self.current_user.role == role_name ? true : false
  end

  def activities_by_level(level)
    Role.by_level_and_role.key([level, self.current_user.role]).last.activities # rescue []
  end

  def set_site
    if SETTINGS['site_type'] =="facility"
      self.site_code = SETTINGS["facility_code"]
    end
  end

  design do
    view :by_active
    view :by_username
    view :by_username_and_active
    view :by_role
    view :by_created_at
    view :by_updated_at
    view :by_site_code
    view :by_district_code
    # active views
    view :active_users,
         :map => "function(doc){
            if (doc['type'] == 'User' && doc['active'] == true){
              emit(doc.username, {username: doc.username,first_name: doc.first_name,
              last_name: doc.last_name, email: doc.email,role: doc.role,
              creator: doc.creator, notify: doc.notify, updated_at: doc.updated_at});
            }
          }"
    view :inactive_users,
         :map => "function(doc){
            if (doc['type'] == 'User' && doc['active'] == false){
              emit(doc.username, {username: doc.username,first_name: doc.first_name,
              last_name: doc.last_name, email: doc.email,role: doc.role,
              creator: doc.creator, notify: doc.notify, updated_at: doc.updated_at});
            }
          }"
    view :by_facility_activation,
          :map => "function(doc){
                if(doc['type'] == 'User'){
                    emit([doc['site_code'], doc['active']],1)
                }
                     
          }"
    view :by_district_actication,
          :map =>  "function(doc){
                if(doc['type'] == 'User'){
                    emit([doc['district_code'], doc['active']],1)
                }
                     
          }"
                
     filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"    
             
  end

  before_save do |pass|
    unless self.plain_password.blank?
      check_password = BCrypt::Password.new(self.plain_password) rescue 'invalid hash'
      self.password_hash = BCrypt::Password.create(self.plain_password) if (check_password == 'invalid hash')
    end
    self.creator = 'admin' if self.creator.blank?
    self.plain_password = nil
  end

  def password_matches?(plain_password)
    not plain_password.nil? and self.password == plain_password
  end

  def password
    @password ||= BCrypt::Password.new(password_hash)
  rescue BCrypt::Errors::InvalidHash
    Rails.logger.error "The password_hash attribute of User[#{self.username}] does not contain a valid BCrypt Hash."
    return nil
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end

  def self.create(params)

    return if params.blank?

    user = User.new()

    user.username = (params[:username] rescue nil || params[:user]['username'] rescue nil) 

    if params[:plain_password].present?

          user.plain_password = params[:plain_password]    

    elsif params[:user]['password'].present?

          user.plain_password = params[:user]['password']

    else

          user.plain_password  = nil  

    end 

    user.first_name = (params[:first_name] rescue nil || params[:user]['first_name'] rescue nil)

    user.last_name = (params[:last_name] rescue nil || params[:user]['last_name'] rescue nil)

    user.role = (params[:role] rescue nil || params[:user]['role'] rescue nil)


    if SETTINGS['site_type'] == 'remote'
      user.district_code = (District.by_name.key(params[:user]['district']).code rescue SETTINGS['district_code'])
    else
      user.district_code = SETTINGS['district_code']
    end
   
    user.email = (params[:email] rescue nil || params[:user]['email'] rescue nil)

    user.save

    return user
  end

  def self.edit(params)
    if params[:edit_action] == 'password_only'
      cur_user = User.current
      cur_user.plain_password = params[:user]['password']
      cur_user.save
    elsif params[:edit_action] == 'edit'
      cur_user = Utils::UserUtil.get_active_user(params[:username])
      cur_user.first_name = params[:user]['first_name']
      cur_user.last_name = params[:user]['last_name']
      cur_user.role = params[:user]['role']
      cur_user.email = params[:user]['email']
      cur_user.save
    end

    true
  end

  def self.get_active_user(username)

    user_hash = User.active_users.keys [username]

    return if user_hash.blank?

    username = user_hash.rows.first['value']['username']

    User.by_username.key(username).first
    
  end

  def confirm_password
    password_hash
  end
  
  def self.admin?
    ((self.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
  end
  
  def create_audit
    Audit.create(record_id: self.username, audit_type: "Audit", level: "User", reason: "Created user record")
  end
  
end
