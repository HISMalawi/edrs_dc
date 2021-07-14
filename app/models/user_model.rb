class UserModel < ActiveRecord::Base
	after_commit :push_to_couchDB,:push_to_remote
	self.table_name = "user"
	cattr_accessor :current_user
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
  def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "user_id"
				data["_id"] = self.as_json[key]
			else
				data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "User"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end
	def has_role?(role_name)
		self.current_user.role == role_name ? true : false
	end
	
	def activities_by_level(level) 
		RoleRecord.where(level: level, role: self.current_user.role).last.activities.split("|") rescue []
	end

	def self.get_active_user(username)
		UserModel.where(username: username, active: 1).first
	end

	def push_to_remote
		return  RemotedPusher.push(self.as_json)
	end
end
